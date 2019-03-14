local common = require "common"
local chatcommon = require "chatcommon"
local Database = require "database"
local storagecommon = require "storagecommon"
local clusterext = require "clusterext"
local class = require "class"
local chatinterface = require "chatinterface"
local interaction = require "interaction"
local chatrecordmgr = require "chatrecordmgr"
local ChatMgr = class("ChatMgr")

function ChatMgr:ctor()
    self._db = nil
    self.chatrecordmgr = nil --离线私聊管理
end

function ChatMgr:loaddb()
    self._db = Database.new("global")
    self.chatrecordmgr = chatrecordmgr.new(self._db) 

    self.chatrecordmgr:loaddb()
end

function ChatMgr:run()
end

function ChatMgr:dayrefresh()
end


local function apply_voice_key(args)
    return clusterext.call(get_cluster_service().imageserver, "lua", "apply_key", args)
end

--发送离线私聊:玩家服务上线请求
function ChatMgr:req_chatrecord(playerid, address)
    local records = self.chatrecordmgr:get_player_chatrecord(playerid)
    self.chatrecordmgr:remove_player_chatrecord(playerid)
    return records
end

--args : { chnl, player[玩家基础信息], msg[type, content, voice[key, voicetime]]}
function ChatMgr:channel_chat(chnl, args, address)
    repeat
        --语音处理
        if args.msg.type == chatcommon.chat_type.voice then 
            --远端服请求语音key, token
            local result = apply_voice_key {
                bsave = false,
                type = storagecommon.type.channel_voice,
                expired = chatcommon.chnl_voice_expire,--到期时间
            }

            if not result or not result.key then
                break
            end

            --赋值
            args.msg.voice.key = result.key
            interaction.send(address, "lua", "send2client", "channelvoicechatret", { key = result.key, token = result.token })                
        end


        --各频道聊天可做聊天缓存
        --全服广播
        --可做低优先级(采集频道聊天信息, 定时合并发送) 
        if chnl == chatcommon.chat_chnl.chnl_world or
           chnl == chatcommon.chat_chnl.chnl_servertyphon or 
           chnl == chatcommon.chat_chnl.chnl_worldtyphon then
            interaction.send_online_player("send2client", "syncchannelchat", { chats = { args } })
        end 
    until 0;
end


--
function ChatMgr:private_chat(playerid, tagid, args, address)
    local ret = {}
    local code = chatcommon.chat_message_code.success
    local key = nil
    repeat
        --语音处理
        if args.msg.type == chatcommon.chat_type.voice then 
            local result = apply_voice_key {
                bsave = true,
                type = storagecommon.type.private_voice,
            }

            if not result or not result.key then
                code = chatcommon.chat_message_code.send_fail
                break
            end

            args.msg.voice.key = result.key
            interaction.send(address, "lua", "send2client", "privatevoiceret", { tagid = tagid, key = result.key, token = result.token })                
            key = cbret.key
        end

        interaction.send(address, "lua", "recv_private_chat", playerid, args) --发送给自己
        code = interaction.call(tagid, "lua", "recv_private_chat", playerid, args) --发送
        if not code then --不在线,或暂离
            code = chatcommon.chat_message_code.is_offline
            self.chatrecordmgr:insert_chatrecord(tagid, args)
            break
        end
    until 0;

    return code
end

return ChatMgr
