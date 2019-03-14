local skynet = require "skynet"
local timext = require "timext"
local clusterext = require "clusterext"

local chatinterface = BuildInterface("chatinterface")

function chatinterface.extract_chatplayer(player)
    local args = {
        playerid = player:getplayerid(),
        name = player:playerbasemodule():get_name(),
    }
    return args
end

return chatinterface