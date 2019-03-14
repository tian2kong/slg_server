local agent_interaction = require "agent_interaction"
local chatcommon = require "chatcommon"

--接收私聊消息(发送方也会收到)
function agent_interaction.recv_private_chat(player, playerid, args)
    if not player:is_conect() then--若socket断开则告诉来源,该玩家不在线
        return nil
    end
    local code = chatcommon.chat_message_code.unkown
    repeat

        if playerid ~= player:getplayerid() then
            --是否有设置陌生人拒接
            if not proto_args then
                LOG_ERROR("rec_private_chat : info is nil")
                break
            end
        end
        
        player:send_request("syncprivatechat", { chats = { args } })
        code = chatcommon.chat_message_code.success
    until 0;
    return code
end
