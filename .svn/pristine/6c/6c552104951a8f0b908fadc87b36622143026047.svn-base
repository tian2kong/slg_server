local skynet = require "skynet"
local config = require "config"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local table = table
local string = string
local assert = assert
local LoginManager = require "loginmanager"
require "common"

local s_loginmgr = LoginManager.new()

local CMD = {}
CMD.open = register_command(s_loginmgr, "open", true)
CMD.gm_login_account = register_command(s_loginmgr, "gm_login_account", true)
CMD.delete_account = register_command(s_loginmgr, "delete_account", true)
CMD.load_account_list = register_command(s_loginmgr, "load_account_list", true)
CMD.get_agent_addr = register_command(s_loginmgr, "get_agent_addr", true)
CMD.agent_interaction = register_command(s_loginmgr, "agent_interaction")
CMD.group_interaction = register_command(s_loginmgr, "group_interaction")
--s_loginmgr:start(CMD)

skynet.init(function()
    skynet.dispatch("lua", function(_,source,command, ...)
        local f = assert(CMD[command], command)
        f(...)
	end)
    s_loginmgr:init()
end)

--[[

Protocol:

	line (\n) based text protocol

	1. Server->Client : base64(8bytes random challenge)
	2. Client->Server : base64(8bytes handshake client key)
	3. Server: Gen a 8bytes handshake server key
	4. Server->Client : base64(DH-Exchange(server key))
	5. Server/Client secret := DH-Secret(client key/server key)
	6. Client->Server : base64(HMAC(challenge, secret))
	7. Client->Server : DES(secret, base64(token))
	8. Server : call auth_handler(token) -> server, uid (A user defined method)
	9. Server : call login_handler(server, uid, secret) ->subid (A user defined method)
	10. Server->Client : 200 base64(subid)

Error Code:
	400 Bad Request . challenge failed
	401 Unauthorized . unauthorized by auth_handler
	403 Forbidden . login_handler failed
	406 Not Acceptable . already in login (disallow multi login)

Success:
	200 base64(subid)
]]

local socket_error = {}
local function assert_socket(service, v, fd)
	if v then
		return v
	else
		skynet.error(string.format("%s failed: socket (fd = %d) closed", service, fd))
		error(socket_error)
	end
end

local function write(service, fd, text)
	assert_socket(service, socket.write(fd, text), fd)
end

local user_login = {}

local function accept(s, fd, addr)
	-- call slave auth
	local ok, server, uid, secret = skynet.call(s, "lua",  fd, addr)
	-- slave will accept(start) fd, so we can write to fd later

	if not ok then
		if ok ~= nil then
			write("response 401", fd, "401 Unauthorized\n")
		end
		error(server)
	end

    if user_login[uid] then
        write("response 406", fd, "406 Not Acceptable\n")
        error(string.format("User %s is already login", uid))
    end

    user_login[uid] = true
	local ok, err = pcall(s_loginmgr.login_handler, s_loginmgr, server, uid, secret, addr)
	-- unlock login
	user_login[uid] = nil

	if ok then
		err = err or ""
		write("response 200",fd,  "200 " .. crypt.base64encode(err).."\n")
	else
		write("response 403",fd,  "403 Forbidden\n")
		error(err)
	end
end

local function launch_master()
    local conf = config.get_world_config()
	local host = conf.login.ip
	local port = assert(tonumber(conf.login.port))
	local slave = {}
    local balance = 1

	for i=1,INSTANCE do
		table.insert(slave, skynet.newservice("loginslave"))
	end

	skynet.error(string.format("login server listen at : %s %d", host, port))
	local id = socket.listen(host, port)
	socket.start(id , function(fd, addr)
		local s = slave[balance]
		balance = balance + 1
		if balance > #slave then
			balance = 1
		end
		local ok, err = pcall(accept, s, fd, addr)
		if not ok then
			if err ~= socket_error then
				skynet.error(string.format("invalid client (fd = %d) error = %s", fd, err))
			end
		end
		socket.close_fd(fd)	-- We haven't call socket.start, so use socket.close_fd rather than socket.close.
	end)
end

skynet.start(function()
    launch_master()
end)
