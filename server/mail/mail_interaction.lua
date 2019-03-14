local agent_interaction = require "agent_interaction"
local thinginterface = require "thinginterface"
local gamelog= require "gamelog"
local mailcommon = require "mailcommon"

function agent_interaction.extract_mail(player, reward, mailid, id, sendtime)
    local thingmod = player:thingmodule()
    
    local ret = {}
    for k,v in pairs(reward.token) do
        player:tokenmodule():addtoken(k, v, object_action.action1029, mailid)
    end
    ret.token = reward.token

    thingmod:add_multiple_thing(reward.thing)
    ret.thing = thinginterface.get_thing_messagedata(reward.thing)
    
    player:send_request("extractmailret", {code = mailcommon.message_code.success, id = id, reward = ret})
    return true
end

function agent_interaction.sync_mail(player, msg)
    player:send_request("syncnewmail", {info = msg})
    -- msg.id
    -- msg.mailid
    local event_log = {
        event_type = gamelog.event_type.mail,
        action_id = event_action.action13001,
        para = {
            msg.id,     -- 收到的邮件的id
            msg.mailid, -- 邮件的typeid(mail表中的)
        },
    }
    gamelog.write_event_log(player, event_log)
end