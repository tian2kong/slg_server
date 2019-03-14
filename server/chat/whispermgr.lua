local class = require "class"
local timext = require "timext"
local chatcommon = require "chatcommon"
local whisperdbmgr = require "whisperdbmgr"
local WhisperMgr = class("WhisperMgr")

local s_whisper_table = {
    table_name = "player_whisper",
    key_name = {"playerid","id"},
    select_where = " where playerid=%d",
    field_name = {
        "senderid", --发送至ID
        "sendername", --发送至信息
        "senderface",
        "senderpic",
        "posttime",
        "content",
        "type", --区分语音和文本
        "lasttime", --语音持续时间
        "voiceindex", --语音索引
        "strparam", --多余参数
        "language", --语种
    },
}

local MsgSize = 100 --私聊存储服务器的条数,即“离线留言”(对单一一个玩家的上限),超过上限会顶替最旧的消息
local WhisperDBMgr = nil

function WhisperMgr:ctor(db)
    self._db = db
    self.whisper = {} --索引 [playerid] -> { [sourceid] -> { id, type }, ... }
    self.maxid = {} --最大索引 [playerid] -> maxid

    WhisperDBMgr = whisperdbmgr.new(db)
end

function WhisperMgr:loaddb()
    local query_obj = WhisperDBMgr:get_all_db()
    if query_obj then
        for _,tmp in ipairs(query_obj) do --按时间顺序排序 大->小
            local playerid = tmp.playerid 
            local sourceid = tmp.senderid
            local id = tmp.id
            local dt = {
                id          = id,
                type        = tmp.type,
            }
            self.whisper[playerid] = self.whisper[playerid] or {}
            local t = self.whisper[playerid]
            t[sourceid] = t[sourceid] or {}
            table.insert(t[sourceid], dt)
            
            local maxid = self.maxid[playerid] or 0
            if maxid < id then
                self.maxid[playerid] = id
            end
        end
    end
end

function WhisperMgr:init()
    MsgSize = get_static_config().globals.chat_offline_msg_max 
end

--离线私聊存库:
function WhisperMgr:save_whisper(playerid, sourceid, type, info) 
    local newid = ( self.maxid[playerid] or 0 ) + 1
    local bsave = false --是否成功
    if type == chatcommon.whisper_type.text then
        if WhisperDBMgr:save_offline_whisper(playerid, newid, sourceid, info) then
            bsave = true
        end

    elseif type == chatcommon.whisper_type.sound then
        if WhisperDBMgr:save_offline_voice_whisper(playerid, newid, sourceid, info) then
            bsave = true
        end

    elseif type == chatcommon.whisper_type.system then
        if WhisperDBMgr:save_offline_sys_whisper(playerid, newid, sourceid, info) then
            bsave = true
        end

    else
        return 
    end

    if not bsave then
        print("save_whisper error ")
        print(info)
        return 
    end

    --索引
    self.maxid[playerid] = newid
    local dt = {
        id          = newid,
        type        = type,
    }
    self.whisper[playerid] = self.whisper[playerid] or {}
    self.whisper[playerid][sourceid] = self.whisper[playerid][sourceid] or {}
    local t = self.whisper[playerid][sourceid]
    table.insert(t, 1, dt) --头插

    --限制条数
    if t[MsgSize] and t[MsgSize].id then
        local id = t[MsgSize].id
        t[MsgSize] = nil
        WhisperDBMgr:delete_sig_db(playerid, id)--去尾
    end
end

--获取离线信息
function WhisperMgr:get_whisper(playerid)
    local t = {}
    if self.whisper[playerid] then
        local query_obj = WhisperDBMgr:get_db_byplayerid(playerid)
        if query_obj then
            for k,v in pairs(query_obj) do
                if v.type then
                    t[v.type] = t[v.type] or {}
                    table.insert(t[v.type], v)
                end 
            end
        end
    end
    return t
end

function WhisperMgr:del_whisper(playerid)
    if self.whisper[playerid] then
        print("del_whisper  ")
        self.whisper[playerid] = nil
        WhisperDBMgr:delete_db_byplayerid(playerid)
    end
end

return WhisperMgr