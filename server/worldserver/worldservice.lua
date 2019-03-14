local skynet = require "skynet"
local clusterext = require "clusterext"
require "common"
require "static_config"
local sharedata = require "sharedata"

local CMD = {}

local s_serverlist = {}

function get_server_config()
	return get_static_config().serverlist
end

function CMD.get_server_group()
	local ret = {}
	local servercfg = get_server_config()
	for _,groupcfg in pairs(servercfg) do
		for _,cfg in pairs(groupcfg) do
			table.insert(ret, {groupid = cfg.server_list_id, groupname = cfg.server_list_name})
			break
		end
	end
	skynet.retpack(ret)
end

function CMD.get_server_list(account, groupid)
	local ret = {}
	local servercfg = get_server_config()
	local groupcfg = servercfg[groupid]
	if not groupcfg then
		return ret
	end
	for k,v in pairs(groupcfg) do
		local info = {
			serverid = v.server_id,
			servername = v.server_name,
			newtag = v.new_tag,
			status = 0,
		}
		local temp = s_serverlist[v.server_id]
		if temp then
			info.ip = temp.ip
			info.port = temp.port
			info.status = 1

			info.player = clusterext.call(temp.address, "lua", "get_account_player", account)
		end
		table.insert(ret, info)
	end
	skynet.retpack(ret)
end

function CMD.get_account_server(account)
	local ret = {}
	local servercfg = get_server_config()
	for _,groupcfg in pairs(servercfg) do
		for _,v in pairs(groupcfg) do
			local temp = s_serverlist[v.server_id]
			if temp then
				local player = clusterext.call(temp.address, "lua", "get_account_player", account)
				if player then
					local info = {
						groupid = v.server_list_id,
						groupname = v.server_list_name,
						serverid = v.server_id,
						servername = v.server_name,
						newtag = v.new_tag,
						status = 1,
						ip = temp.ip,
						port = temp.port,
						player = player,
					}
					table.insert(ret, info)
				end
			end
		end
	end
	skynet.retpack(ret)
end

skynet.init(function()
	s_serverlist = sharedata.query("s_serverlist")
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd])
		f(...)
	end)
end)