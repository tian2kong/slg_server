local class = require "class"
local PlayerMailId = class("PlayerMailId")

--[[
    *在邮件服上，玩家邮件 id 记录器    
]]

PlayerMailId.s_PlayerMailId_table = {
    table_name = "mail_ids",
    key_name = {"playerid"},    
    select_where = " where playerid=%d",
    field_name = {
        "mailid",   --int, 玩家已经使用到的邮件id        
    }
}

function PlayerMailId:ctor(record)
    self._record = record
end

function PlayerMailId:getplayerid()
    return self._record:get_key_value("playerid")
end

--给玩家分配一个，新的邮件id
function PlayerMailId:get_new_id()
    local maxid = self._record:get_field("mailid") or 0
    maxid = maxid + 1
    self._record:set_field("mailid", maxid)
    self:savedb()
    return maxid
end

function PlayerMailId:savedb()
    self._record:asyn_save()
end

return PlayerMailId