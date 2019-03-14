local skynet = require "skynet"
local snax = require "snax"
local gateserver = require "gateserver"
local clusterext = require "clusterext"
local timext = require "timext"
local GateManager = require "gatemanager"

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local s_gatemgr = GateManager.new()

local handler = {}
--开服
function handler.open(source, config)
    s_gatemgr:init(config)
    --时钟
    local function run(frame)
        s_gatemgr:run(frame)
    end
    timext.open_clock(run)
end
--socket建立连接
function handler.connect(fd, addr)
    s_gatemgr:connect_socket(fd, addr)
end
--socket 断开
function handler.disconnect(fd)
    s_gatemgr:disconnect_socket(fd)
end
function handler.error(fd, msg)
    s_gatemgr:disconnect_socket(fd)
end

--处理消息
function handler.message(fd, msg, sz)
    s_gatemgr:handle_message(fd, msg, sz)
end

-- when gateserver has no handler function
function handler.command(cmd, ...)
    return s_gatemgr:handle_command(cmd, ...)
end

gateserver.start(handler)

