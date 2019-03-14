local skynet = require "skynet"
local clusterext = require "clusterext"
local skynetext = require "skynetext"
local interaction = require "interaction"

local CMD = {}

--需要回包
function CMD.response(source, agent, ...)
    local ret
    local ok,err = xpcall(skynet.call, debug.traceback, agent.addr, skynetext.agent_protocol_name, agent.playerid, true, ...)
    if not ok then
        LOG_ERROR(err)
    else
        ret = err
    end
    skynet.retpack(ret)
end

--
function CMD.accept(source, agent, ...)
    skynet.send(agent.addr, skynetext.agent_protocol_name, agent.playerid, false, ...)
end

function CMD.accept_group(source, group, ...)
    skynet.send(agent.addr, skynetext.agentgroup_protocol_name, group, false, ...)
end

skynet.start(function()
    interaction.register_agent_protocol()

    skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = assert(CMD[cmd])
        f(source, ...)
	end)
end)