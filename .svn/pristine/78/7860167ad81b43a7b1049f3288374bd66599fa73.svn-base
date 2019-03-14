local client_request =  require "client_request"
local clusterext = require "clusterext"
local mailinterface = require "mailinterface"
local mailcommon = require "mailcommon"

local function reqmail_cb(ret, player)
    if ret then
        player:send_request("syncmail", { info = ret })
    end
end
function client_request.reqmail(player, msg)
    clusterext.callback(get_cluster_service().mailserver, "lua", "request_mail", player:getplayerid(), reqmail_cb, player)
end

local function extractmail_cb(ret, player, id)
    if ret and ret == mailcommon.message_code.success then
        return
    end
    local code = ret or mailcommon.message_code.unkown

    player:send_request("extractmailret", {code = code, id = id})
end
function client_request.extractmail(player, msg)
    clusterext.callback(get_cluster_service().mailserver, "lua", "extract_mail", player:getplayerid(), msg.id, extractmail_cb, player, msg.id)
end

function client_request.delmail(player, msg)
    if not table.empty(msg.id) then
        clusterext.send(get_cluster_service().mailserver, "lua", "del_mail", player:getplayerid(), msg.id)
    end
    return { code = mailcommon.message_code.success, id = msg.id }
end

function client_request.openmail(player, msg)
    clusterext.send(get_cluster_service().mailserver, "lua", "open_mail", player:getplayerid(), msg.id)
    return { code = mailcommon.message_code.success, id = msg.id }
end