local class = require "class"
local IRobotModule = require "irobotmodule"

local RobotTeam = class("RobotTeam", IRobotModule)

function RobotTeam:ctor(robot)
    self.robot = robot
    self.team = {}
end

function RobotTeam:init()
    
end

function RobotTeam:run(frame)
    
end

function RobotTeam:online()
    --请求活动基础信息
    self.robot.net:send_request("reqmyteam")
    self.robot.net:send_request("createteam")
end

function RobotTeam:init_team(args)
	self.team = args
	print("init_team", args)
end

return RobotTeam