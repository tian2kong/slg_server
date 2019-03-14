local chatcommon = require "chatcommon"
local class = require "class"
local common = require "common"

local whisper_sql = {
    ins_chat_sql        = "insert into whisper(playerid, id, senderid, sendername, senderface, senderpic, posttime, content, type, language) values (%d,%d,%d,'%s',%d,%d,%d,'%s',%d,%d)" ,
    ins_voice_sql       = "insert into whisper(playerid, id, senderid, sendername, senderface, senderpic, posttime, voiceindex, lasttime, type, language) values (%d,%d,%d,'%s',%d,%d,%d,%d,%d,%d,%d)" ,
    ins_sys_sql         = "insert into whisper(playerid, id, senderid, sendername, senderface, senderpic, posttime, strparam, type, language) values (%d,%d,%d,'%s',%d,%d,%d,'%s',%d,%d)" ,

    del_sql             = "delete from whisper where playerid = %d",
    del_sig_sql         = "delete from whisper where playerid = %d and id = %d",

    sel_all_sql         = "select playerid, senderid, type, id from whisper order by posttime desc", 
    sel_player_sql      = "select * from whisper where playerid = %d", 
}

local WhisperDBMgr = class("WhisperDBMgr")

function WhisperDBMgr:ctor(db)
    self._db = db
end

function WhisperDBMgr:get_all_db()
    local sql = whisper_sql.sel_all_sql
    return self._db:syn_query_sql(sql) --同步获取
end

function WhisperDBMgr:get_db_byplayerid(playerid)
    local sql = string.format(whisper_sql.sel_player_sql, playerid)
    return self._db:syn_query_sql(sql) --同步获取
end

function WhisperDBMgr:delete_db_byplayerid(playerid)
    local sql = string.format(whisper_sql.del_sql, playerid)
    self._db:asyn_query_sql(sql) --删除异步
    return true
end

function WhisperDBMgr:delete_sig_db(playerid, id)
    local sql = string.format(whisper_sql.del_sig_sql, playerid, id)
    self._db:asyn_query_sql(sql) --删除异步
    return true
end

--验证玩家数据是否不为空
local function playerdata_not_nil(data)
    if not data or 
       not data.sourceid or 
       not data.time or 
       not data.roleid or 
       not data.name or 
       not data.language then
        return false
    end
    return true
end

--
function WhisperDBMgr:save_offline_whisper(targetid, id, senderid, chatinfo)
    if  not chatinfo or 
        not playerdata_not_nil(chatinfo.data) or 
        not chatinfo.content then
        return false
    end

    --赋值
    local playerid      = targetid
    local senderid      = senderid
    local sendername    = common.mysqlEscapeString(chatinfo.data.name)
    local senderface    = chatinfo.data.roleid 
    local posttime      = chatinfo.data.time 
    local language      = chatinfo.data.language 
    local content       = common.mysqlEscapeString(chatinfo.content)
    local type          = chatcommon.whisper_type.text 
    local senderpic
    if chatinfo.data.pic then    --将bool型转换成inter
        senderpic       = 1
    else
        senderpic       = 0
    end

    --playerid, id, senderid, sendername, senderface, senderpic, posttime, content, type
    local sql = string.format(whisper_sql.ins_chat_sql, playerid, id, senderid, sendername, senderface, senderpic, posttime, content, type, language)
    self._db:asyn_query_sql(sql)
    return true
end

--
function WhisperDBMgr:save_offline_voice_whisper(targetid, id, senderid, voiceinfo)
    if  not voiceinfo or 
        not playerdata_not_nil(voiceinfo.data) or 
        not voiceinfo.lasttime or 
        not voiceinfo.index then
        return false
    end
    --赋值
    local playerid      = targetid
    local senderid      = senderid
    local sendername    = common.mysqlEscapeString(voiceinfo.data.name)
    local senderface    = voiceinfo.data.roleid 
    local posttime      = voiceinfo.data.time 
    local language      = voiceinfo.data.language 
    local voiceindex    = voiceinfo.index 
    local lasttime      = voiceinfo.lasttime
    local type          = chatcommon.whisper_type.sound 
    local senderpic
    if voiceinfo.data.pic then    --将bool型转换成inter
        senderpic       = 1
    else
        senderpic       = 0
    end
    
    --playerid, id, senderid, sendername, senderface, senderpic, posttime, voiceindex, lasttime, type
    local sql = string.format(whisper_sql.ins_voice_sql, playerid, id, senderid, sendername, senderface, senderpic, posttime, voiceindex, lasttime, type, language)
    self._db:asyn_query_sql(sql)
    return true
end


function WhisperDBMgr:save_offline_sys_whisper(targetid, id, senderid, sysinfo)
    if  not sysinfo or 
        not playerdata_not_nil(sysinfo.data) or
        not sysinfo.strparam then
        return false
    end

    --赋值
    local playerid      = targetid
    local senderid      = senderid
    local sendername    = common.mysqlEscapeString(sysinfo.data.name)
    local senderface    = sysinfo.data.roleid 
    local posttime      = sysinfo.data.time 
    local language      = sysinfo.data.language 
    local strparam      = sysinfo.strparam
    local type          = chatcommon.whisper_type.system 
    local senderpic
    if sysinfo.data.pic then    --将bool型转换成inter
        senderpic       = 1
    else
        senderpic       = 0
    end

    --playerid, id, senderid, sendername, senderface, senderpic, posttime, strparam, type
    local sql = string.format(whisper_sql.ins_sys_sql, playerid, id, senderid, sendername, senderface, senderpic, posttime, strparam, type, language)
    print(sql)
    self._db:asyn_query_sql(sql)
    return true
end

return WhisperDBMgr
