package.cpath = "skynet/luaclib/?.so;luaclib/?.so"
package.path = "proto/?.lua;robot/?.lua;skynet/lualib/?.lua;global/?.lua;proto/?.lua;config/?.lua;server/?.lua;server/common/?.lua;server/scene/?.lua;server/gm/?.lua"

require "static_config"
require "luaext"
local RobotClient = require "robotclient"
local config = require "robotconfig"
local astarmanager = require "astarmanager"
local socket = require "clientsocket"
local core = require "daemon.core"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local stdout = print
if not config.debuginfo then
    printf = function() end
    print = function() end
end

do
    if config.daemon then
        core.daemon()
    end
    init_static_config()
    astarmanager.init()
end

local robot_set = {}

local index = 0
local mirosecond = 1000000
local sleep_time = 1 * mirosecond
local last_frame = os.clock()
while true do
    
    local now_frame = os.clock()

    local i = 1
    while index < config.num and i < 20 do
        i = i + 1
        local user = config.template .. index
        index = index + 1
        stdout(user)
        local robot = RobotClient.new(user)
        robot:login()
        robot_set[index] = robot
    end

    for i,robot in pairs(robot_set) do
        local ok, err = xpcall(robot.run, debug.traceback, robot, (now_frame - last_frame))
        if not ok then
            stdout("robot", i, " run error : ", err)
        end
    end
    
    last_frame = now_frame - sleep_time / mirosecond

    socket.usleep(sleep_time)
end