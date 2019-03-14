local common = require "common"
local class = require "class"

local ChatRecordMgr = class("ChatRecordMgr")

local s_table = {
    table_name = "chatrecord",
	key_name = {"playerid", "ckey"},
	field_name = {
		"chatrecord", --聊天记录	 		
		--"chatstate",  --0 表示离线, 1表示已接收(由于只入库离线数据, 该字段暂时不用)
	}
}

function ChatRecordMgr:ctor(db)
	self._db = db
	self.simple_chatrecord = {} --{ maxckey, count }
end

function ChatRecordMgr:loaddb()
	local records = self._db:syn_query_sql("select playerid, ckey from chatrecord")
	for _,v in pairs(records) do
		local playerid = v.playerid
		local ckey = v.ckey		
		
		local record = self:getorcreate_simplerecord(playerid)
		if record.maxckey < ckey then
			record.maxckey = ckey
		end
		record.count = record.count + 1
	end
end


function ChatRecordMgr:getorcreate_simplerecord(playerid)
	local record = self.simple_chatrecord[playerid]
	if not record then
	 	record = { maxckey = 0, count = 0 }
	 	self.simple_chatrecord[playerid] = record
	end
	return record
end

function ChatRecordMgr:insert_chatrecord(playerid, chatrecord)
	local record = self:getorcreate_simplerecord(playerid)
	record.maxckey = record.maxckey + 1
	record.count = record.count + 1
    local sql = string.format("insert into chatrecord(playerid,ckey,chatrecord) values(%d,%d,'%s')", playerid, record.maxckey, common.mysqlEscapeString(table.encode(chatrecord)))
    self._db:asyn_query_sql(sql)
end

function ChatRecordMgr:remove_player_chatrecord(playerid)
	if not self.simple_chatrecord[playerid] then
		return 
	end

    local sql = string.format("delete from chatrecord where playerid = %d", playerid)
	self._db:asyn_query_sql(sql)
end

function ChatRecordMgr:get_player_chatrecord(playerid)
	local msg = {}
    if self.whisper[playerid] then
    	local query_obj = self._db:syn_query_sql(string.format("select * from chatrecord where playerid = %d order by ckey desc", playerid))
        if query_obj then
            for k,v in ipairs(query_obj) do
               	table.insert(msg, v.chatrecord)
            end
        end
    end
    return msg
end


return ChatRecordMgr