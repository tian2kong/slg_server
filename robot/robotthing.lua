local class = require "class"
local config = require "robotconfig"
local thingcommon = require "thing.thingcommon"
local IRobotModule = require "irobotmodule"

local RobotThing = class("RobotThing", IRobotModule)

function RobotThing:ctor(robot)
    self.robot = robot
    self.bag = {}
end

function RobotThing:init()
    
end

function RobotThing:run(frame)
    
end

function RobotThing:online()
    --进入场景
    self.robot.net:send_request("reqcontainer", { type = thingcommon.ContainerType.bag })
end

function RobotThing:update_container_thing(data)
    if not data then
        return 
    end
    for _,v in pairs(data) do
        local thingkey = v.key
        if thingkey.type == thingcommon.ContainerType.bag then
            self.bag[thingkey.key] = v.thing
        end
    end
end

function RobotThing:init_container(args)
    if args.type == thingcommon.ContainerType.bag then
        self:update_container_thing(args.data)
    end
end

--获取背包中指定配置可交易物品key
function RobotThing:get_trade_thing(thingcfgid)
    local key = nil
    for k,v in pairs(self.bag) do
        if v.cfgid == thingcfgid and not v.bind then
            key = { key = k, type = thingcommon.ContainerType.bag }
            break
        end        
    end
    return key
end

return RobotThing