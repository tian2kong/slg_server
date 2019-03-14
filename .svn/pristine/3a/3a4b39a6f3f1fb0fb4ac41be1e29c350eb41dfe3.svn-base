local class = require "class"
local scenecommon = require "scenecommon"
local IRobotModule = require "irobotmodule"

local RobotRole = class("RobotRole", IRobotModule)

function RobotRole:ctor(robot)
    self.robot = robot
    self.roledata = {}
end

function RobotRole:init()
    
end

function RobotRole:run(frame)
    
end

function RobotRole:online()
    --请求角色基础信息
    self.robot.net:send_request("reqrolebase")
end

function RobotRole:set_role_date(data)
    for k,v in pairs(data) do
        self.roledata[k] = v
    end
end

function RobotRole:get_level()
    return self.roledata.level
end

function RobotRole:get_player_id()
    return self.roledata.id
end

function RobotRole:alter_level(level)
    self.robot:gm_commond("/addlevel " .. level)
end

return RobotRole