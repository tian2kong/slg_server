local gateinterface = BuildInterface("gateinterface")
local clusterext = require "clusterext"
local gatecommon = require "gatecommon"

--无视玩家是否在线的指令请求 （不要频繁调用）  
function gateinterface.callback_player_command(playerid, _, ...)
    if not playerid then
        LOG_ERROR(tostring(debug.traceback()))
        return 
    end
    clusterext.callback(get_remote_service().gateservice, "lua", "player_command", true, playerid, ...)
end
function gateinterface.call_player_command(playerid, _, ...)
    if not playerid then
        LOG_ERROR(tostring(debug.traceback()))
        return
    end
    return clusterext.call(get_remote_service().gateservice, "lua", "player_command", true, playerid, ...)
end
function gateinterface.player_command(playerid, _, ...)
    if not playerid then
        LOG_ERROR(tostring(debug.traceback()))
        return
    end
    clusterext.send(get_remote_service().gateservice, "lua", "player_command", false, playerid, ...)
end

--发送给所有在线玩家
function gateinterface.send_online_player(...)
    local address = get_remote_service().gateservice
    if not address then
        LOG_ERROR("send_online_player not in gameserver %s", tostring(debug.traceback()))
        return
    end
    clusterext.send(address, "lua", "send_online_player", ...)
end

return gateinterface