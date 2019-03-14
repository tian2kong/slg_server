local class = require "class"
local IPlayerModule = require "iplayermodule"
local playercommon = require "playercommon"
local gamelog = require "gamelog"
local serverconfig = require "serverconfig"
local cacheinterface = require "cacheinterface"
local httprequest = require "httprequest"
local config = require "config"
local timext = require "timext"
local common = require "common"

local PlayerBaseModule = class("PlayerBaseModule", IPlayerModule)

--玩家基础数据
local player_base_table = 
{
    table_name = "player",
    key_name = "playerid",
    field_name = {
        "account",      --账号
        "exp",          --经验
        "level",        --等级
        "shape",        --图标
        "name",         --名字
        "lastname",     --曾用名
        "offlinetime",  --离线时间
        "updatetime",   --更新时间
        "createtime",   --创建时间
        "online",       --是否在线
        "logintime",    --登录时间
        "loginIP",      --登录ip
        "language",     --语种
        "silence",      --是否禁言
        "roleid",       --角色配置id
        "viplevel",     --vip等级
        "vipexp",       --vip经验
    },
}


--构造函数
function PlayerBaseModule:ctor(player)
    self._player = player
    self._record = nil
    self.uploadflag = nil
    self.cacheinfo = {}
    self.refreshtimer = timext.create_timer(playercommon.refreshtime)
end

--读库
function PlayerBaseModule:loaddb()
    self._record = self._player:getplayerdb():create_db_record(player_base_table, self._player:getplayerid())
	self._record:syn_select()
end

function PlayerBaseModule:savedb()
    self._record:asyn_save()
end

--是否已创建过角色
function PlayerBaseModule:is_create_role()
    return self._record:insert_flag()
end
--初始化
function PlayerBaseModule:init()

end

--AI
function PlayerBaseModule:run(frame)
    if self.refreshtimer:expire() then
        self:refresh()
        self:upload_server_list()
    end
    self:chgproperty()
end

function PlayerBaseModule:reconnect()
    self.uploadflag = true
    self:upload_server_list()
end

function PlayerBaseModule:upload_server_list()
    if self.uploadflag then
        httprequest.upload_player(self._player)
        self.uploadflag = nil
    end
end

function PlayerBaseModule:dayrefresh()
end

function PlayerBaseModule:weekrefresh()
end

--上线处理
function PlayerBaseModule:online()
    self.uploadflag = true
    self:upload_server_list()

    local time = timext.current_time()
    self:set_field("online", 1)
    self:set_field("logintime", time)
    self:savedb()
end

--下线处理
function PlayerBaseModule:offline()
    self:upload_server_list()
    local time = timext.current_time()
    self:set_field("online", 0)
    self:set_field("offlinetime", time)
    self:set_field("updatetime", time)
    self:savedb()
end

function PlayerBaseModule:refresh()
    local time = timext.current_time()
    self:set_field("updatetime", time)
    self:savedb()
    self.refreshtimer:update(playercommon.refreshtime)
end

function PlayerBaseModule:create(account, name, roleid)
    local time = timext.current_time()
    self:set_field("roleid", roleid)
    self:set_field("account", account)
    self:set_field("name", name)
    self:set_field("level", 1)
    self:set_field("createtime", time)
    self:set_field("exp", 0)
    self:set_field("shape", 0)
    self:savedb()

    -- 创角成功，记录经分
    local event_log = {
        event_type = gamelog.event_type.player,
        action_id = event_action.action10005,
        para = {
            self:get_role_id(),    -- 角色职业
        },
    }
    gamelog.write_event_log(self._player, event_log)

    self.uploadflag = true
end

--增加\减小等级
function PlayerBaseModule:alter_level(level, notsync)
    local oldlevel = self:get_level()
    local newlevel = oldlevel + level

    if newlevel < 1 then
        newlevel = 1
    end
    if not get_static_config().player_exp[newlevel] then
        return 
    end

    if oldlevel ~= newlevel then
        self:setlevel(newlevel)

        --
        self._player:cachemodule():change_player_lv()
        -- 升级成功，记录经分
        local event_log = {
            event_type = gamelog.event_type.player,
            action_id = event_action.action10001,
            para = {
                newlevel,   -- 升级到的等级
            },
        }
        gamelog.write_event_log(self._player, event_log)

        self.uploadflag = true
    end
    if not notsync then
        self:chgproperty()
    end
end
--增加/减少经验
function PlayerBaseModule:raw_alter_exp(exp)
    local oldexp = self:get_exp()
    local oldlevel = self:get_level()
    local newexp = oldexp + exp
    local newlevel = oldlevel

    if exp > 0 then
        local worldlv = self._player:cachemodule():get_worldlv()
        local levelinfo = get_static_config().player_exp[oldlevel]
        local k = "NeedExpRei"

        --还未满级 自动升级
        while levelinfo and levelinfo[k] and newexp >= levelinfo[k] do
            newlevel = newlevel + 1
            local tempinfo = get_static_config().player_exp[newlevel]
            if not tempinfo or not tempinfo[k] then--满级
                newlevel = newlevel - 1
                newexp = levelinfo[k]
                break
            elseif newlevel - worldlv > get_static_config().globals.char_server_maxlv then
                newlevel = newlevel - 1
                break
            else
                newexp = newexp - levelinfo[k]
                levelinfo = tempinfo
            end
        end
    end

    if oldexp ~= newexp then
        self:setexp(newexp)
    end
    if oldlevel ~= newlevel then
        self:alter_level(newlevel - oldlevel, true)
    end
    self:chgproperty()
end
function PlayerBaseModule:alter_exp(exp)
    exp = math.floor(exp)
    local baseexp = exp 
    if exp > 0 then
        local percent = self._player:cachemodule():get_addtion_percent() --获取服务器等级加成百分比
        if percent <= 0 then
            return 
        end

        --大唐盛世经验加成奖励(服务器等级)
        local worldexp
        do
            local temp = exp
            exp = math.floor(temp * percent)
            worldexp = exp - temp
        end

        self._player:send_request("syncplayerexpchange", { baseexp = baseexp, exp = exp, worldexp = worldexp})
    end
    self:raw_alter_exp(exp)
    return exp
end

function PlayerBaseModule:get_role_message()
    return {
            id = self._player:getplayerid(),
            shape = self._record:get_field("shape"),
            name = self._record:get_field("name"),
            level = self._record:get_field("level"),
            exp = self._record:get_field("exp"),
            roleid = self._record:get_field("roleid"),
            lastname = self:get_lastname(),
            account = self._player:getaccount(),
            language = self:get_language(),
        }
end

--同步属性
function PlayerBaseModule:chgproperty()
    if self.cacheinfo then
        local newinfo = self:get_role_message()
        local temp = common.table_diff(newinfo, self.cacheinfo)
        self.cacheinfo = table.copy(newinfo, true)
        if not table.empty(temp) then
            self._player:send_request("syncrolebase", { info = temp })
            self:savedb()
        end
    end
end

--修改名字
function PlayerBaseModule:change_name(name)
    self:set_field("lastname", self._record:get_field("name"))
    self:set_field("name", name)
    self:savedb()
end
--是否被禁言
function PlayerBaseModule:is_silence()
    return self._record:get_field("silence") and self._record:get_field("silence") ~= 0
end
--设置禁言
function PlayerBaseModule:set_silence(flag)
    self:set_field("silence", flag)
    self:savedb()
end
--设置ip
function PlayerBaseModule:setIP(ip)
    if self:getIP() ~= ip then
        self:set_field("loginIP", ip)
    end
end
--获取图片
function PlayerBaseModule:get_shape()
    return self._record:get_field("shape")
end
--获取ip
function PlayerBaseModule:getIP()
    return self._record:get_field("loginIP")
end
--获取离线时间
function PlayerBaseModule:get_offline_time()
    return self._record:get_field("offlinetime")
end
--获取登录时间
function PlayerBaseModule:get_login_time()
    return self._record:get_field("logintime")
end
--获取更新时间
function PlayerBaseModule:get_update_time()
    return self._record:get_field("updatetime")
end
--获取曾用名
function PlayerBaseModule:get_lastname()
    return self._record:get_field("lastname")
end
--获取名字
function PlayerBaseModule:get_name()
    return self._record:get_field("name")
end
--设置经验
function PlayerBaseModule:setexp(exp)
    self:set_field("exp", exp)
end
--设置等级
function PlayerBaseModule:setlevel(level)
    self:set_field("level", level)
end
--获取vip经验
function PlayerBaseModule:get_vip_exp()
    return self._record:get_field("vipexp")
end
--获取vip等级
function PlayerBaseModule:get_vip_level()
    return self._record:get_field("viplevel")
end
--获取经验
function PlayerBaseModule:get_exp()
    return self._record:get_field("exp")
end
--获取等级
function PlayerBaseModule:get_level()
    return self._record:get_field("level")
end
--获取语种
function PlayerBaseModule:get_language()
    return self._record:get_field("language")
end
--设置语种
function PlayerBaseModule:set_language(language)
    self._record:set_field("language", language)
end
--设置字段
function PlayerBaseModule:set_field(k, v)
    self._record:set_field(k, v)

    --同步观察者数据
    self._player:update_observer(k, v)
end
--获取服务器id
function PlayerBaseModule:get_server_id()
    return serverconfig.serverid or 0
end
--获取服务器名字
function PlayerBaseModule:get_server_name()
    return config.get_server_config().server_name
end
--获取角色id
function PlayerBaseModule:get_role_id()
    return self._record:get_field("roleid")
end
return PlayerBaseModule
