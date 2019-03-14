local class = require "class"
local IRobotModule = require "irobotmodule"
local config = require "robotconfig"
local Random = require "random"

local RobotGuild = class("RobotGuild", IRobotModule)

function RobotGuild:ctor(robot)
    self.robot = robot
    self.guild = nil
    self.guildwarflag = nil
end

function RobotGuild:init()
    
end

function RobotGuild:run(frame)
    if config.getai("guildwar") and self.guild then
    	if not self.guildwarflag and self.robot:activitymodule():is_guildwar_open() then
    		self.robot.net:send_request("joinguildwar")
    	end 
    end
end

function RobotGuild:online()
    --请求活动基础信息
    self.robot.net:send_request("reqplayerguildbaseinfo")
    self.robot.net:send_request("guildwarsceneinfo")
end

function RobotGuild:create_guild()
    self.robot.net:send_request("createguild", {
    	name = self.robot:getaccount(),
        enounce = "robot万岁",
        language = 1,
        limitlv = 1,
        limitapply = 1,
    })
end

function RobotGuild:init_guild(args)
	self.guild = args.info
	if table.empty(self.guild) then
		self.guild = nil
	end
	print("init_guild", self.guild)
	if config.getai("createguild") and not self.guild then
		self:create_guild()
	end
	if config.getai("guildwar") then
		if not self.guild or not self.guild.guildid then--没有帮派 加入一个帮派
			self.robot.net:send_request("reqguildlist", {
				sort = 1,
		        order = true,
		        bgpos = 0,
		        edpos = 20,
			})
		end
	end
end

function RobotGuild:enter_guild_war(args)
	self.guildwarflag = true
end

function RobotGuild:sync_guild_list(args)
	local size = args.size
	print("sync_guild_list", args)
	if args.info and #args.info > 0 then
		if config.getai("guildwar") then
			local index = Random.Get(#args.info)
			local temp = args.info[index]
			self.robot.net:send_request("reqapplyguild", {
				id = temp.guildid,
			})
		end
	end
end

function RobotGuild:get_guild()
	return self.guild
end

return RobotGuild