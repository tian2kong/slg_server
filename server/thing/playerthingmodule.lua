local thingcommon = require "thingcommon"
local thinginterface = require "thinginterface"
local class = require "class"
local IPlayerModule = require "iplayermodule"
local interaction = require "interaction"
local timext = require "timext"
local PlayerThingModule = class("PlayerThingModule", IPlayerModule)
local Thing = require "thing"

--构造函数
function PlayerThingModule:ctor(player)
    self._player = player

    self._record = nil

    self.dailyitem = {} --每日物品使用信息
    self._things = {}   --物品数据
    self._dirtything = {} --脏数据
end

function PlayerThingModule:init()
end

--AI
function PlayerThingModule:run(frame)
end

--上线处理
function PlayerThingModule:online()
    
end

--下线处理
function PlayerThingModule:offline()
end

--5点刷新
function PlayerThingModule:dayrefresh()
    self.dailyitem = {}
    self:serialize_dailyitem()
    self._record:asyn_save()
end


local thing_other_tab = {
    table_name = "player_thing_other",
    key_name = {"playerid"},
    field_name = {
       "dailyitem",           --物品使用信息
    },
}

--
function PlayerThingModule:loaddb()
    local db = self._player:getplayerdb()
    self._record = db:create_db_record(thing_other_tab, self._player:getplayerid())
    self._record:syn_select()
    do
        local str = self._record:get_field("dailyitem")
        if str then
            self.dailyitem = table.decode(str) or {}
        end
    end

    local record_list = db:select_db_record(Thing.thing_tab, string.format(" where playerid=%d", self._player:getplayerid()))
    for _, record in pairs(record_list) do
        local newthing = Thing.new(record)
        self._things[newthing:getconfigid()] = newthing
    end
end

--获取物品
function PlayerThingModule:get_thing(cfgid)
    return self._things[cfgid]
end

--获取物品数量
function PlayerThingModule:get_thing_num(cfgid)
    local thing = self._things[cfgid]
    if thing then
        return thing:getamount()
    else
        return 0
    end
end
--[[增加/消耗多个物品
    param: 物品数据
    { 
        [cfgid] = num, ... 
    } 

    logparam: 经分配置
    {
        action_id, 经分id
        para, {} 经分附加参数
        parastr, {} 经分附加参数 1~5=>para_str1 ~para_str5
    }
]]
--增加多个物品
function PlayerThingModule:add_multiple_thing(param, logparam)
    if table.empty(param) then
        LOG_ERROR("add_multiple_thing empty param")
        return
    end
    for k, v in pairs(param) do
        self:add_thing(k, v, logparam, true)
    end
    self:update_dirty_thing()
end
--消耗多个物品
function PlayerThingModule:consume_multiple_thing(param, logparam)
    if table.empty(param) then
        LOG_ERROR("consume_multiple_thing empty param")
        return
    end
    for k, v in pairs(param) do
        self:consume_thing(k, v, logparam, true)
    end
    self:update_dirty_thing()
end
--增加物品
function PlayerThingModule:add_thing(cfgid, num, logparam, nosync)
    if not get_static_config().item[cfgid] then
        LOG_ERROR("add thing error config %d", cfgid)
        return
    end
    if num <= 0 then
        LOG_ERROR("add thing error amount %d %d", cfgid, num)
        return
    end
    if not self._things[cfgid] then
        local record = self._player:getplayerdb():create_db_record(Thing.thing_tab, { self._player:getplayerid(), cfgid })
        self._things[cfgid] = Thing.new(record)
    end
    local thing = self._things[cfgid]
    local oldnum = thing:getamount()
    thing:setamount(oldnum + num)
    thing:savedb()
    self._dirtything[cfgid] = thing
    if not nosync then
        self:update_dirty_thing()
    end
end
--消耗物品
function PlayerThingModule:consume_thing(cfgid, num, logparam, nosync)
    if num <= 0 then
        LOG_ERROR("consume thing error amount %d %d", cfgid, num)
        return
    end
    local thing = self._things[cfgid]
    if not thing then
        LOG_ERROR("consume thing error thing %d", cfgid)
        return
    end
    local oldnum = thing:getamount()
    if oldnum < num then
        LOG_ERROR("consume thing less thing[%d] amount[%d]", cfgid, num - oldnum)
        num = oldnum
    end
    thing:setamount(oldnum - num)
    thing:savedb()
    self._dirtything[cfgid] = thing
    if not nosync then
        self:update_dirty_thing()
    end
end

--使用物品auto自动使用元宝补足 使用该物品前请先用can_use_thing判断能否使用
function PlayerThingModule:use_thing(cfgid, need, auto, logparam)
    local cfg = thinginterface.get_thing_config(cfgid)
    if not cfg then
        LOG_ERROR("use_thing error thing config")
        return false, global_code.not_thing
    end

    --判断数量
    local num = self:get_thing_num(cfgid)
    if not auto and num < need then
        LOG_ERROR("use_thing not auto and less thing")
        return false, global_code.less_thing
    end
    local use = need
    if num < need then
        local buynum = need - num
        self._player:tokenmodule():subtoken("Money", cfg.price * buynum)
        use = num
    end
    if use > 0 then
        self:consume_thing(cfgid, use, logparam)
    end

    if cfg.vip_dailyusemax then
        self:add_dailyitem(cfgid, need)
    end
    
    return true
end

--是否可以使用指定数量物品auto自动使用元宝补足
function PlayerThingModule:can_use_thing(cfgid, need, auto)
    local cfg = thinginterface.get_thing_config(cfgid)
    if not cfg then
        return false, global_code.not_thing
    end

    --判断使用上限
    local viplv = self._player:playerbasemodule():get_vip_level()
    local used = self:get_dailyitem(cfgid)
    if cfg.vip_dailyusemax and cfg.vip_dailyusemax[viplv] and used + need > cfg.vip_dailyusemax[viplv] then
        return false, global_code.limit_use_thing
    end

    --判断数量
    local num = self:get_thing_num(cfgid)
    if not auto and num < need then
        return false, global_code.less_thing
    end
    
    if num < need then
        local buynum = need - num
        if not self._player:tokenmodule():cansubtoken("Money", cfg.price * buynum) then
            return false, global_code.less_money
        end
    end
    
    return true
end

--消耗多个物品
function PlayerThingModule:can_consume_multiple_thing(param, auto)
    if table.empty(param) then
        LOG_ERROR("can_consume_multiple_thing empty param")
        return
    end
    for cfgid, n in pairs(param) do
        local bsuc, code = self:can_use_thing(cfgid, n, auto)
        if not bsuc then
            return false, code
        end
    end
    return true
end

--同步脏物品
function PlayerThingModule:update_dirty_thing()
    if table.empty(self._dirtything) then
        return 
    end
    local ret = {}
    for cfgid, thing in pairs(self._dirtything) do
        ret[cfgid] = thing:get_message_data()

        --物品数量为0 删除物品
        if thing:getamount() == 0 then
            thing:deletdb()
            self._things[cfgid] = nil
        end
    end
    self._dirtything = {}
    self._player:send_request("updatethings", { info = ret })
end

--获取物品消息结构
function PlayerThingModule:get_thing_message()
    local ret = {}
    for cfgid, thing in pairs(self._things) do
        ret[cfgid] = thing:get_message_data()
    end
    self._dirtything = {}
    return ret
end

--每日道具使用
function PlayerThingModule:serialize_dailyitem()
    self._record:set_field("dailyitem", table.encode(self.dailyitem))
end
function PlayerThingModule:get_dailyitem(cfgid)
    return self.dailyitem[cfgid] or 0
end
function PlayerThingModule:add_dailyitem(cfgid, num)
    self.dailyitem[cfgid] = self:get_dailyitem(cfgid) + num
    self:serialize_dailyitem()
    self._record:asyn_save()
end

return PlayerThingModule