local timext = require "timext"
local tokencommon = require "tokencommon"
local class = require "class"
local IPlayerModule = require "iplayermodule"
local gamelog = require "gamelog"

local PlayerTokenModule = class("PlayerTokenModule", IPlayerModule)

--代币数据库信息
local player_token_table = 
{
    table_name = "player_token",
    key_name = "playerid",
    field_name = tokencommon.token_field,
}

--构造函数
function PlayerTokenModule:ctor(player)
    self._player = player
    self._dirty = {}
end

local function get_token_log_object(currency)
    local objecttype = nil
    if currency == "Money" then
        objecttype = gamelog.object_type.xianyu
    elseif currency == "YinLiang" then
        objecttype = gamelog.object_type.yinliang
    elseif currency == "ArenaMoney" then
        objecttype = gamelog.object_type.arenapoint
    elseif currency == "SysXianYu" then
        objecttype = gamelog.object_type.sysxianyu
    end
    return objecttype
end
local function settoken(self, currency, num, log, logparam)
    num = math.floor(num)
    local oldnum = self:raw_get_token(currency)
    if num and num >= 0 and oldnum ~= num then
        if num > tokencommon.max_currency_number then
            num = tokencommon.max_currency_number
            LOG_ERROR("player token too much")
        end
        self._record:set_field(currency, num)
        self._record:asyn_save()
        self._dirty[currency] = true

        if log then
            local objecttype = get_token_log_object(currency)
            if objecttype then
                logparam = logparam or {}
                local param = {
                    objtype = objecttype,
                    object_id = objecttype,
                    change_num = num - oldnum,
                    left_num = num,
                    action_id = logparam.action_id or 0,
                    para = logparam.para or {},
                }
                gamelog.write_object_log(self._player, param)
            end
        end
    end
end

--
function PlayerTokenModule:loaddb()
	self._record = self._player:getplayerdb():create_db_record(player_token_table, self._player:getplayerid())
	self._record:syn_select()
    for _,v in pairs(tokencommon.token_field) do
        local num = self:raw_get_token(v)
        if num > tokencommon.max_currency_number then
            settoken(self, v, tokencommon.max_currency_number, true)
        end
    end
end

function PlayerTokenModule:init()
end
--AI
function PlayerTokenModule:run(frame)
end

--上线处理
function PlayerTokenModule:online()
end

--下线处理
function PlayerTokenModule:offline()
end

--5点刷新
function PlayerTokenModule:dayrefresh()
end

local function check_currency(currency)
    assert(tokencommon.check_field[currency], "error token " .. currency)
end

function PlayerTokenModule:raw_get_token(currency)
    return self._record:get_field(currency) or 0
end

function PlayerTokenModule:gettoken(currency)
    check_currency(currency)
    return self:raw_get_token(currency)
end

--代币是否会溢出
function PlayerTokenModule:is_token_overflow(currency, num)
    return self:gettoken(currency) + num > tokencommon.max_currency_number
end

--[[
    logparam: 经分配置
    {
        action_id, 经分id
        para, {} 经分附加参数
        parastr, {} 经分附加参数 1~5=>para_str1 ~para_str5
    }
]]
--增加代币
function PlayerTokenModule:addtoken(currency, num, logparam)
    check_currency(currency)
    num = math.floor(num)
    if num <= 0 then
        LOG_ERROR("add token error num %s %d", currency, num)
        return
    end
    if currency == "Money" then
        self:addsystoken(currency, num, logparam)
        return
    else
        local old = self:gettoken(currency)
        settoken(self, currency, old + num, true, logparam)
    end
    self:synctoken()
end
--增加系统代币（可掠夺/系统元宝）
function PlayerTokenModule:addsystoken(currency, num, logparam)
    check_currency(currency)
    num = math.floor(num)
    if num <= 0 then
        LOG_ERROR("add system token error num %s %d", currency, num)
        return
    end
    local syscurrency = tokencommon.related_token[currency]
    if not syscurrency then
        LOG_ERROR("add system token error token %s %d", currency)
        self:addtoken(currency, num, logparam)
        return
    end
    do--增加代币
        local old = self:gettoken(currency)
        settoken(self, currency, old + num)
    end

    do--增加系统代币
        local old = self:raw_get_token(syscurrency)
        settoken(self, syscurrency, old + num, true, logparam)
    end
    self:synctoken()
end
--充值代币
function PlayerTokenModule:chargemoney(num, logparam)
    num = math.floor(num)
    if num <= 0 then
        LOG_ERROR("chargemoney error num %s %d", currency, num)
        return
    end
    local old = self:gettoken("Money")
    settoken(self, "Money", old + num, true, logparam)
    self:synctoken()
end
--消耗代币
function PlayerTokenModule:subtoken(currency, num, logparam)
    check_currency(currency)

    num = math.floor(num)
    if num <= 0 then
        LOG_ERROR("sub token error num %s %d", currency, num)
        return
    end
    if num and num > 0 then
        local syscurrency = tokencommon.related_token[currency]
        if syscurrency then
            --先消耗系统代币
            local systoken = self:raw_get_token(syscurrency)
            local chgnum = 0
            if systoken > 0 then
                settoken(self, syscurrency, math.max(systoken - num, 0), true, logparam)

                local token = self:gettoken(currency)
                chgnum = math.min(systoken, num)
                settoken(self, currency, math.max(token - chgnum, 0))
            end

            --消耗额外代币
            if chgnum < num then
                num = num - chgnum
                local token = self:gettoken(currency)
                if token < num then
                    LOG_ERROR("PlayerTokenModule subtoken less token %s", currency)
                end
                settoken(self, currency, math.max(token - num, 0), true, logparam)
            end
        else
            local old = self:get_token(currency)
            if old < num then
                LOG_ERROR("PlayerTokenModule subtoken less token")
            end
            settoken(self, currency, math.max(old - num, 0), true, logparam)
        end
    end
    self:synctoken()
end
--是否可消耗代币
function PlayerTokenModule:cansubtoken(currency, num)
    check_currency(currency)
    return self:gettoken(currency) >= num
end

function PlayerTokenModule:get_token_message()
    local data = {}
    for _,v in pairs(tokencommon.token_field) do
        data[v] = self:raw_get_token(v)
    end
    self._dirty = {}
    return data
end

function PlayerTokenModule:synctoken()
    if table.empty(self._dirty) then
        return
    end
    local data = {}
    for currency, _ in pairs(self._dirty) do
        data[currency] = self:raw_get_token(currency)
    end
    self._dirty = {}
    self._player:send_request("synctoken", { data = data })
end

return PlayerTokenModule