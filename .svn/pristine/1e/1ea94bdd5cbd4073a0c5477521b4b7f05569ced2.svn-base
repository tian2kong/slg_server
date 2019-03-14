local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socketdriver = require "skynet.socketdriver"
local timext = require "timext"
local GateManager = require "gatemanager"
local config = require "config"

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local socket	-- listen socket
local queue		-- message queue
local maxclient	-- max client
local client_number = 0
local CMD = setmetatable({}, { __gc = function() netpack.clear(queue) end })
local nodelay = false

local connection = {}

local function openclient(fd)
	if connection[fd] then
		socketdriver.start(fd)
	end
end

local function closeclient(fd)
	local c = connection[fd]
	if c then
		connection[fd] = false
		socketdriver.close(fd)
	end
end

local s_gatemgr = GateManager.new(openclient, closeclient)
CMD.check_mq = register_command(s_gatemgr, "check_mq", true)
CMD.logout = register_command(s_gatemgr, "logout", true)
CMD.kick = register_command(s_gatemgr, "kick", true)
CMD.secret = register_command(s_gatemgr, "secret", true)
CMD.gm_login_account = register_command(s_gatemgr, "gm_login_account", true)
CMD.player_command = register_command(s_gatemgr, "player_command")
CMD.send_online_player = register_command(s_gatemgr, "send_online_player")
CMD.get_agent_addr = register_command(s_gatemgr, "get_agent_addr", true)
CMD.fuzzy_agent_addr = register_command(s_gatemgr, "fuzzy_agent_addr", true)
CMD.agent_interaction = register_command(s_gatemgr, "agent_interaction")
CMD.fuzzy_agent_interaction = register_command(s_gatemgr, "fuzzy_agent_interaction")
CMD.group_interaction = register_command(s_gatemgr, "group_interaction")
CMD.fuzzy_group_interaction = register_command(s_gatemgr, "fuzzy_group_interaction")
CMD.change_account_server = register_command(s_gatemgr, "change_account_server")
s_gatemgr:__service_start__(CMD)

function CMD.open(source)
    assert(not socket)
    local gamecfg = config.get_server_config()
    local address = gamecfg.gate.ip or "0.0.0.0"
    local port = assert(gamecfg.gate.port)
    maxclient = gamecfg.gate.maxclient or 1024
    nodelay = gamecfg.gate.nodelay
    skynet.error(string.format("Listen on %s:%d", address, port))
    socket = socketdriver.listen(address, port)
    socketdriver.start(socket)
    s_gatemgr:init()
    --时钟
    local function run(frame)
        s_gatemgr:run(frame)
    end
    timext.open_clock(run)
    skynet.retpack(true)
end

function CMD.close()
    assert(socket)
    socketdriver.close(socket)
    skynet.retpack(true)
end

--client msg
local MSG = {}

local function dispatch_msg(fd, msg, sz)
    if connection[fd] then
        s_gatemgr:handle_message(fd, msg, sz)
    else
        skynet.error(string.format("Drop message from fd (%d) : %s", fd, netpack.tostring(msg,sz)))
    end
end

MSG.data = dispatch_msg

local function dispatch_queue()
    local fd, msg, sz = netpack.pop(queue)
    if fd then
        -- may dispatch even the handler.message blocked
        -- If the handler.message never block, the queue should be empty, so only fork once and then exit.
        skynet.fork(dispatch_queue)
        dispatch_msg(fd, msg, sz)

        for fd, msg, sz in netpack.pop, queue do
            dispatch_msg(fd, msg, sz)
        end
    end
end

MSG.more = dispatch_queue

function MSG.open(fd, msg)
    if client_number >= maxclient then
        socketdriver.close(fd)
        return
    end
    if nodelay then
        socketdriver.nodelay(fd)
    end
    connection[fd] = true
    client_number = client_number + 1
    s_gatemgr:connect_socket(fd, msg)
end

local function close_fd(fd)
    local c = connection[fd]
    if c ~= nil then
        connection[fd] = nil
        client_number = client_number - 1
    end
end

function MSG.close(fd)
    if fd ~= socket then
        s_gatemgr:disconnect_socket(fd)
        close_fd(fd)
    else
        socket = nil
    end
end

function MSG.error(fd, msg)
    if fd == socket then
        socketdriver.close(fd)
        skynet.error("gateserver close listen socket, accpet error:",msg)
    else
        s_gatemgr:disconnect_socket(fd)
        close_fd(fd)
    end
end

function MSG.warning(fd, size)
end

skynet.register_protocol {
    name = "socket",
    id = skynet.PTYPE_SOCKET,	-- PTYPE_SOCKET = 6
    unpack = function ( msg, sz )
        return netpack.filter( queue, msg, sz)
    end,
    dispatch = function (_, _, q, type, ...)
        queue = q
        if type then
            MSG[type](...)
        end
    end
}

skynet.start(function()
    skynet.dispatch("lua", function (_, address, cmd, ...)
        local f = assert(CMD[cmd], cmd)
        f(...)
    end)
end)