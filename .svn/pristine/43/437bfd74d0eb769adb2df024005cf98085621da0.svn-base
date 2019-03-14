local class = require "class"
local RESPONSE = require "response"
local REQUEST = require "request"
local RobotScene = require "robotscene"
local RobotRole = require "robotrole"
local config = require "robotconfig"
local RobotTask = require "task.robottask"
local RobotThing = require "robotthing"
local RobotTrade = require "trade.robottrade"
local RobotPTool = require "prototool.robotptool"
local RobotActivity = require "robotactivity"
local RobotTeam = require "robotteam"
local RobotGuild = require "robotguild"

--加载协议
do
	require "task.task_request"
	require "task.task_response"
	
	require "trade.trade_request"
	require "trade.trade_response"
end

local RobotAI = class("RobotAI")

function RobotAI:ctor(account, net, token, spro, httpret)
    self.account = account
    self.net = net
    self.token = token --登录token
    self.httpret = httpret

    self.module = {}
    self.module.scenelogic = RobotScene.new(self)
    self.module.rolelogic = RobotRole.new(self)
	self.module.task = RobotTask.new(self)
    self.module.thinglogic = RobotThing.new(self)
	self.module.trade = RobotTrade.new(self)
	self.module.ptool = RobotPTool.new(self, spro)
	self.module.activity = RobotActivity.new(self)
	self.module.team = RobotTeam.new(self)
	self.module.guild = RobotGuild.new(self)
end

function RobotAI:getaccount()
	return self.account
end

function RobotAI:init()
    self.net:send_request("login", { token = self.token, datetime = self.httpret.datetime, sign = self.httpret.sign })
    self.net:send_request("changerolename", { name = self.account })
    for k,v in pairs(self.module) do
    	v:init()
    end
end

function RobotAI:run(frame)
	for k,v in pairs(self.module) do
		v:run(frame)
	end
	
end

function RobotAI:online()
    self.net:send_request("entergameok")

    for k,v in pairs(self.module) do
		v:online()
	end

	self:gm_commond("/addlevel 100")
    
    --召唤4个强力伙伴
    self:gm_commond("/addhuoban 10000")
    self:gm_commond("/addhuoban 10001")
    self:gm_commond("/addhuoban 10002")
    self:gm_commond("/addhuoban 10003")

    local cmd = config.getai("gmcommand")
	if cmd then
		self:gm_commond(cmd)
	end
end

function RobotAI:offline()
    
end

function RobotAI:server_response(name, args)
    local f = RESPONSE[name]
    if f then
        
        print("response", name)
	    print(tostring(args))
        f(self, args)
    end
    
end

function RobotAI:server_request(name, args)
    local f = REQUEST[name]
    if f then
        printf("request", tostring(name))
        printf(tostring(args))
        f(self, args)
    end
    
end

function RobotAI:gm_commond(str)
    self.net:send_request("gmcommand", { content = str })
end


--任务
function RobotAI:taskmodule()
	return self.module.task
end

--场景
function RobotAI:scenemodule()
	return self.module.scenelogic
end

--物品
function RobotAI:thingmodule()
	return self.module.thinglogic
end

--交易
function RobotAI:trademodule()
	return self.module.trade
end

--协议工具
function RobotAI:ptoolmodule()
	return self.module.ptool
end

--活动
function RobotAI:activitymodule()
	return self.module.activity
end

--帮派
function RobotAI:guildmodule()
	return self.module.guild
end

function RobotAI:rolemodule()
	return self.module.rolelogic
end

function RobotAI:teammodule()
	return self.module.team
end

return RobotAI