local playerinterface = require "playerinterface"
local gamelog = require "gamelog"
local agent_interaction = {}

local loaded = {}
setmetatable(agent_interaction, {
    __newindex = function(t, key, value)
        if loaded[key] then
            LOG_ERROR("reset agent_interaction method " .. key)
        end
        rawset(loaded, key, value)
    end,
    __index = loaded,
})

function agent_interaction.send2client(player, protoname, ret)
    player:send_request(protoname, ret)
    return true
end

--获取玩家详细信息(第三方请求)
function agent_interaction.get_detail_playerinfo(player)
    return playerinterface.get_detail_playerinfo(player)
end

--记录公共服数据日志
function agent_interaction.log_globalservice(player, Param)
    if not Param then
        return
    end
    gamelog.write_object_log(player, Param)
end

function agent_interaction.array_command(player, arr)
    for _,v in pairs(arr) do
        local cmd = v[1]
        local func = assert(agent_interaction[cmd], string.format("not found agent interaction [%s]", cmd))
        func(player, table.unpack(v, 2, v.n))
    end
end

function agent_interaction.charge_ship(player, productId, platform)
    return player:chargemodule():charge_ship(productId, platform)
end

function agent_interaction.gm_xianyu(player, num)
    local old = player:tokenmodule():gettoken("XianYu")
    player:tokenmodule():altertoken("XianYu", num, object_action.action1010)
    player:chatmodule():gmcommand_log(string.format("gmxianyu %d", num))
    return true
end

function agent_interaction.silence_player(player, flag)
    player:playerbasemodule():set_silence(flag)
    return true
end

function agent_interaction.gm_kick_out(player)
    AgentManagerInst():kick_player(player:getplayerid(), 0)
    return true
end

function agent_interaction.gm_request_player(player)
    local base = player:playerbasemodule()
    return {
        playerid = player:getplayerid(),
        account = player:getaccount(),
        serverid = base:get_server_id(),
        name = base:get_name(),
        profession = base:get_role_id(),
        silence = base:is_silence(),
        chargenum = player:chargemodule():get_history_charge(),
        online = (player:is_online() and true or false),
        ip = player:getIP(),
    }
end

return agent_interaction