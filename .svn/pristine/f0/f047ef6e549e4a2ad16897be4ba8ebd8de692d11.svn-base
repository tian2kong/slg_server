local httpc = require "http.httpc"
local tempconfig = require "serverconfig"
local timext = require "timext"
local skynet = require "skynet"

local httprequest = {}


local function escape(s)
	return (string.gsub(s, "([^A-Za-z0-9_])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end
local function httpreq(method, host, url, form)
	local body = {}
	for k,v in pairs(form) do
		table.insert(body, string.format("%s=%s",escape(k),escape(v)))
	end
	local url = url .. "?" .. table.concat(body , "&")
	print("httpreq", url)
	return httpc.request(method, host, url)
end

function httprequest.req_server_cfg()
	local form = {
		serverid = tempconfig.serverid
	}
	local code, cfg = httpreq("GET", tempconfig.httphost, "/servercfg.php", form)
    if code ~= 200 then
        LOG_ERROR(code, cfg)
        return 
    end
    return cfg
end

function httprequest.upload_player(player)
	local base = player:playerbasemodule()
	local form = {
		account = player:getaccount(),
		name = base:get_name(),
		roleid = base:get_role_id(),
		serverid = base:get_server_id(),
		level = base:get_level(),
	}
	if table.size(form) ~= 5 then
		return
	end

	skynet.fork(function()
		local code, cfg = httpreq("GET", tempconfig.httphost, "/upload.php", form)
	    if code ~= 200 or cfg ~= "1" then
	        LOG_ERROR("upload_player error code %s get %s form %s", tostring(code), tostring(cfg), tostring(form))
	        return 
	    end
	end)
end

function httprequest.requset_charge(player)
	local base = player:playerbasemodule()
	local form = {
		serverid = base:get_server_id(),
		playerid = player:getplayerid(),
		account = player:getaccount(),
	}
	skynet.fork(function()
		local code, cfg = httpreq("GET", tempconfig.httphost, "/reqplayercharge.php", form)
	    if code ~= 200 and cfg ~= "1" then
	        LOG_ERROR("upload_player error code %s get %s", tostring(code), tostring(cfg))
	        return 
	    end
	end)
end

function httprequest.server_sign(account, time, sign)
	local form = {
		account = account,
		datetime = time,
		sign = sign,
	}
	local code, ret = httpreq("GET", tempconfig.httphost, "/serversign.php", form)
    if code ~= 200 then
        LOG_ERROR("serversign form[%s] error code %s get %s", tostring(form), tostring(code), tostring(ret))
        return 
    end
    return table.decode(ret)
end

function httprequest.bind_account(account, platform, signture, email)
	local form = {
		platform = platform,
		signture = signture,
		email = email,
		account = account,
	}
	local code, ret = httpreq("GET", tempconfig.httphost, "/bindaccount.php", form)
    if code ~= 200 or ret ~= "1" then
        LOG_ERROR("bind_account device[%s] error code %s get %s", account, tostring(code), tostring(ret))
    end
    return tonumber(ret)
end


function httprequest.create_role(player)
	--[[
	local base = player:playerbasemodule()
	local form = {
		pid = player:getplayerid(),
		did = player:get_device_id(),
		sid = base:get_server_id(),
		channel_id = player:get_channel_id(),
		time = timext.current_time(),
		uid = player:getaccount(),
		pname = base:get_name(),
		level = base:get_level(),
	}

	skynet.fork(function()
		local code, cfg = httpreq("POST", tempconfig.httphost, "/createrole.php", form)
	    if code ~= 200 then
	        LOG_ERROR("create_role error code %s get %s", tostring(code), tostring(cfg))
	        return 
	    end
	end)
	]]
end

function httprequest.player_login(player, reconnect)
	--[[
	local base = player:playerbasemodule()
	local form = {
		pid = player:getplayerid(),
		did = player:get_device_id(),
		sid = base:get_server_id(),
		channel_id = player:get_channel_id(),
		time = timext.current_time(),
		uid = player:getaccount(),
		shortlogin = reconnect and 1 or 0,
	}

	skynet.fork(function()
		local code, cfg = httpreq("POST", tempconfig.httphost, "/userlogin.php", form)
	    if code ~= 200 then
	        LOG_ERROR("player_login error code %s get %s", tostring(code), tostring(cfg))
	        return 
	    end
	end)
	]]
end

function httprequest.translate(content, language)
	local form = {
		text = content,
		language = language,
	}	
	local code, ret = httpreq("GET", tempconfig.httphost, "/translate.php", form)
	local text, from, to 
	local data = table.decode(ret)
	if not data then
		text = content
	else
		from = data.from
		to = data.to
		text = data.text and decodeURI(data.text) or content
	end
	return text, from, to 
end

--后台推送
function httprequest.FCM_Broadcast_Part(accounts, package)
	if not package then
		LOG_ERROR("FCM_Broadcast_Part : package is nil")
		return 
	end

	if not accounts then
		LOG_ERROR("FCM_Broadcast_Part : accounts is nil")
		return 
	end 		

	if type(accounts) ~= "table" then
		accounts = { accounts }
	end

	if table.empty(accounts) then
		return 
	end

	local form = {
		accounts = table.encode(accounts),
		package = table.encode(package),
		serverid = tempconfig.serverid,
	}
	
	local code, ret = httpc.post(tempconfig.httphost, "/fcm_broadcast.php", form)
	print("FCM_Broadcast_All", code, ret)
	return code
end

function httprequest.FCM_Broadcast_All(package)
	if not package then
		LOG_ERROR("FCM_Broadcast_All : package is nil")
		return 
	end

	local form = {
			package = table.encode(package),
			allflag = "true",
			serverid = tempconfig.serverid,
		}
		print("form  ..", form)
	local code, ret = httpc.post(tempconfig.httphost, "/fcm_broadcast.php", form)
	print("FCM_Broadcast_All", code, ret)
end


function httprequest.token(key, serverid)
	local form = {
		key = key,
		serverid = serverid,
	}	
	local code, ret = httpreq("GET", tempconfig.httphost, "/token.php", form)
	print ("token is", ret)
	return ret
end


return httprequest