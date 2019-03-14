local class = require "class"
local activitycommon = require "activity.activitycommon"
local IRobotModule = require "irobotmodule"

local RobotActivity = class("RobotActivity", IRobotModule)

function RobotActivity:ctor(robot)
    self.robot = robot
    self.activitys = {}
end

function RobotActivity:init()
    
end

function RobotActivity:run(frame)
    
end

function RobotActivity:online()
    --请求活动基础信息
    self.robot.net:send_request("reqopenactivity")
end

function RobotActivity:init_activitys(args)
	for k,v in pairs(args.ids) do
		self.activitys[v.id] = v.section
	end
	print("init_activitys", self.activitys)
end

function RobotActivity:update_activity(args)
	local temp = args.info
	self.activitys[temp.id] = temp.section
end

--帮派战是否已开启
function RobotActivity:is_guildwar_open()
	for k,v in pairs(self.activitys) do
		if v == activitycommon.ACT_SECTION_READY or v == activitycommon.ACT_SECTION_START then
			local cfg = get_static_config().act_dat[k]
			if cfg and cfg.ActType == activitycommon.type.TYPE_GUILD_WAR then
				return true
			end
		end
	end
end


return RobotActivity