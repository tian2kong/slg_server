local config_func = require "static_config"
local timext = require "timext"
local thingcommon = require "thingcommon"
local class = require "class"

local Thing = class("Thing")

Thing.thing_tab = {
    table_name = "player_thing",
    key_name = {"playerid", "cfgid"},
    field_name = {
        "amount",
    },
}

--构造函数
function Thing:ctor(record)    
    self._record = record
end

function Thing:loaddb()

end

function Thing:run(frame)

end

--获取物品消息数据
function Thing:get_message_data()
    local data = {
        cfgid=self:getconfigid(),
        amount=self:getamount(),
    }
    return data
end

function Thing:init()

end

function Thing:getconfig()
    return get_static_config().item[self:getconfigid()]
end

function Thing:getconfigid()   
    return self._record:get_key_value("cfgid")
end

function Thing:getplayerid()
    return self._record:get_key_value("playerid")
end

--数量
function Thing:getamount()	
    return self._record:get_field("amount") or 0
end

function Thing:setamount(amount)	
    self._record:set_field("amount",amount)
end

-- 删除记录
function Thing:deletdb()
    self._record:asyn_delete()
end

function Thing:savedb()
    self._record:asyn_save()
end

return Thing