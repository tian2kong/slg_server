local interaction = require "interaction"
local skynet = require "skynet"
local clusterext = require "clusterext"
local interaction = require "interaction"
local cacheinterface = require "cacheinterface"
--local mailinterface = require "mailinterface"
--local thinginterface = require "thinginterface"

local CMD = {}

local interactiond
--在线玩家数量
function CMD.online_num(session, param)
    return clusterext.call(get_cluster_service().interactionhubd, "lua", "online_num")
end

--禁言
function CMD.silence(session, param)
	local ret = 2
	local playerid = tonumber(param.playerid)
	local flag = tonumber(param.flag)
	if playerid and flag then
		if cacheinterface.call_player_command(playerid, "lua", "silence_player", flag) then
			ret = 0
		end
	end
	return ret
end

function CMD.reqplayer(session, param)
	local ret = {}
	local playerid
	if param.account then
		playerid = clusterext.call(get_cluster_service().logind, "lua", "get_account_playerid", param.account)
	elseif param.name then
		playerid = cacheinterface.call_search_player_by_name(param.name)
	end
	if playerid then
		local temp = cacheinterface.call_player_command(playerid, "lua", "gm_request_player")
		if temp then
			table.insert(ret, temp)
		end
	end
	return table.encode(ret)
end

--强制下线
function CMD.kickplayer(session, param)
	local ret = 2
	local playerid = tonumber(param.playerid)
	if playerid then
		local address = interaction.call_agent_address(playerid)
		if address then
			interaction.call(address, "lua", "gm_kick_out")
			ret = 0
		end
	end
	return ret
end

function CMD.deleteplayer(session, param)
	local ret = 1
	local playerid = tonumber(param.playerid)
	if playerid then
		clusterext.call(get_cluster_service().logind, "lua", "delete_account", playerid)
		ret = 0

		--删除完之后直接T出角色
		local address = interaction.call_agent_address(playerid)
		if address then
			interaction.call(address, "lua", "gm_kick_out")
		end
	end
	return ret
end

function CMD.sendmail(session, param)
	-- local ret = 0
	-- local playerid = tonumber(param.playerid)
	-- local t = table.decode(param.mails)
	-- if t and t.mailid then
	-- 	local params = t.params
	-- 	if type(params) ~= "table" then
	-- 		params = nil
	-- 	end
	-- 	local tokens = t.tokens
	-- 	if type(tokens) ~= "table" then
	-- 		tokens = nil
	-- 	end
	-- 	local things
	-- 	if t.things then
	-- 		things = {}
	-- 		for k,v in pairs(t.things) do
	-- 			local temp = thinginterface.create_thing(nil, tonumber(k), tonumber(v))
	-- 			for k1,v1 in pairs(temp) do
	-- 				table.insert(things, v1)
	-- 			end
	-- 		end
	-- 		if #things > 10 then
	-- 			LOG_ERROR("gm send mails have too much thing")
	-- 			things = nil
	-- 		end
	-- 	end
	-- 	if playerid then
	-- 		local temp = cacheinterface.call_get_player_info(playerid, "level")
	-- 		if not temp or not temp[playerid] then
	-- 			ret = 2
	-- 		else
	-- 			mailinterface.send_mail(playerid, t.mailid, params, tokens, things)
	-- 		end
	-- 	else
	-- 		local arrid = cacheinterface.call_get_all_player()
	-- 		if arrid then
	-- 			mailinterface.send_mail(arrid, t.mailid, params, tokens, things)
	-- 		end
	-- 	end
	-- else
	-- 	ret = 1
	-- end
	-- return ret
end

function CMD.charge(session, param)
	local ret = cacheinterface.call_player_command(tonumber(param.playerid), "lua", "charge_ship", param.productid, tonumber(param.platform) or 1)
	return ret and 1 or 0
end

function CMD.getorderpay(session, param)
	print(param)
	local cfg = get_static_config().recharge_ext[param.orderid]
	if cfg then
		return cfg.need_rmb
	end
	cfg = get_static_config().daily_recharge[param.orderid]
	if cfg then
		return cfg.need_rmb
	end
	return 0
end

function CMD.gmxianyu(session, param)
	local ret = interaction.call(tonumber(param.playerid), "lua", "gm_xianyu", param.xianyu)
	return ret and 1 or 0
end

function CMD.facebookinvate(session, param)
	clusterext.call(get_cluster_service().logind, "lua", "facebook_invate", param.account, param.invatecode)
	return 1
end

function CMD.gm_zmd(session, param)
	if not param then
		return 1
	end
	print(param)
	
	clusterext.send(get_cluster_service().gmserver, "lua", "gm_zmd", param)
	return 0
end

--问卷调查
function CMD.questionnaire(session, param)
	local ret = cacheinterface.call_player_command(tonumber(param.playerid), "lua", "answer_question")
	return ret and 1 or 0
end

--更新配置
function CMD.reloadconfig(session, param)
	local configd = skynet.queryservice("configd")
	skynet.call(configd, "lua", "reload_server_static")
	interaction.send_online_player("reload_server")
	return 1
end

return CMD