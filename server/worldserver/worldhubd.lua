local skynet = require "skynet"
local clusterext = require "clusterext"
local sharedata = require "sharedata"

local CMD = {}

local s_serverlist = {}
local s_balance = 1
local s_slave = {}
local s_instance = 8

function CMD.register_server(serverid, ip, port)
	local address = clusterext.queryservice("server" .. serverid, "logind")
	s_serverlist[serverid] = {
		address = address,
        ip = ip,
        port = port,
        serverid = serverid,
	}
	sharedata.update("s_serverlist", s_serverlist)
	skynet.error("register server list %s", tostring(s_serverlist[serverid]))
end

function CMD.unregister_server(serverid)
	if s_serverlist[serverid] then
		skynet.error("unregister server list %s", tostring(s_serverlist[serverid]))

		s_serverlist[serverid] = nil
		sharedata.update("s_serverlist", s_serverlist)
	end
end

function CMD.open(instance)
	sharedata.new("s_serverlist", s_serverlist)
	instance = instance or s_instance
	s_instance = instance
    for i=1,instance do
        local s = skynet.newservice("worldservice")
		table.insert(s_slave, s)
    end
end

function CMD.handle_command(response, cmd, ...)
	local s = s_slave[s_balance]
	s_balance = s_balance + 1
	if s_balance > s_instance then
		s_balance = 1
	end
	if response then
		local ret = skynet.call(s, "lua", cmd, ...)
		skynet.retpack(ret)
	else
		skynet.send(s, "lua", cmd, ...)
	end
end


skynet.init(function()

end)

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd])
		f(...)
	end)
end)