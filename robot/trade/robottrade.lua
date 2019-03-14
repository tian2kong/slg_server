local class = require "class"
local tcommon = require "trade.tradecommon"
local config = require "robotconfig"
local Rand = require "random"
local IRobotModule = require "irobotmodule"

local RobotTrade = class("RobotTrade", IRobotModule)

function RobotTrade:ctor(robot)
    self.robot = robot
	self.cousor = 1
	self.max = 0
	self.actionparam = {}			--制定参数
	self.action = tcommon.QUERY_SELF_THING --执行动作, 开始先看下自己卖的东西， 触发一系列东西
	self.initflg = false
	self.time = os.time() + 2

	self.tradeai = config.getai("trade")
end

function RobotTrade:init()
	if self.tradeai then
		local selfthing = self.tradeai.thingid 
		self.max = (selfthing and #selfthing ) or 0
		self.wait_time = os.time() + 20
		self.initflg  = true
		return true
	end
	return false
end

function RobotTrade:online()
	self.robot:gm_commond("/addxianyu 999999999999999")
	self.robot:gm_commond("/addyinliang 999999999999999")
end

function RobotTrade:run(frame) --有限状态机
	if os.time()  < self.time then 
		return 
	end
	
	if not self.tradeai then
		return 
	end
	
	if not self.initflg then 
		if not self:init() then 
			return
		end
	end
	
	printf(self.action)
    if self.action == tcommon.BUY_THING then --买东西
		self:BuyThing()
		
	elseif self.action == tcommon.SALE_THING then --卖东西
		self:SaleThing()
		
	elseif self.action == tcommon.QUERY_OTHER_THING then --查看别人的东西
		self:QueryBuyThing()
	
	elseif self.action == tcommon.QUERY_SELF_THING then --查看自己的东西
		self:QuerySelfSaleThing()
		
	elseif self.action == tcommon.UNSALE_THING then --下架东西
		printf("un sale ..ff")
		self:UnSaleThing()
		
	elseif self.action == tcommon.QUERY_FACTOR then --查看波动因子
		self:QueryFactor()
	
	elseif self.action == tcommon.QUERY_BUYTHINT then --查看自己买到的东西
		self:GetSelfBuy()
		
	elseif self.action == tcommon.DRAW_THING then ----领取自己买的东西
		self:DrawThing()
		
	elseif self.action == tcommon.ADD_THING then --加东西
		self:AddThing()

	elseif self.action == tcommon.QUERRY_LOG then --看日志
		self:QueryLog()
		
	elseif self.action == tcommon.ATTENTION then --关注物品
		self:Attention()
		
	elseif self.action == tcommon.UNATTENTION then --取消关注
		self:UnAttention()
		
	elseif self.action == tcommon.GETATTENTION then --获取关注列表
		self:GetAttention()
	end
	
	if self.action == tcommon.WAIT	then 	--等待服务起结果
		if self.wait_time < os.time() then 
			self.action = nil
			self:SetActionQueSelf()
			self.wait_time = os.time() + 30
		end
	else 
		self:SetActionWait()
	end
	
end

function RobotTrade:gettag1(id)
	while id < 10000 do 
		id = id * 10
	end
	return id // 1000
end

function RobotTrade:gettag2(id)
	while id < 10000 do 
		id = id * 10
	end
	return id // 10
end

--查看日志
function RobotTrade:QueryLog()
	printf("at  QueryLog ......................")
	self.robot.net:send_request("gettradelog", {})
end

--关注物品
function RobotTrade:Attention()
	printf("at  Attention ......................")
	local pa = self:GetActionParam()
	assert(pa)
	self.robot.net:send_request("AttentionTradeThing", {saleid = pa.saleid, thingcfgid = pa.thingcfgid, action = 1, tradethingtype = 1})
end

--取消关注物品
function RobotTrade:UnAttention()
	printf("at  UnAttention ......................")
	local pa = self:GetActionParam()
	assert(pa)
	self.robot.net:send_request("AttentionTradeThing", {saleid = pa.saleid, thingcfgid = pa.thingcfgid, action = 2, tradethingtype = 1})
end

--获取关注列表
function RobotTrade:GetAttention()
	printf("at  GetAttention ......................")
	self.robot.net:send_request("getattention", {})
end


--下架东西
function RobotTrade:UnSaleThing()
	printf("at  UnSaleThing ......................")
	local pa = self:GetActionParam()
	assert(pa)
	self.robot.net:send_request("unsalething", {thingcount = (pa.surcount == 0 and 1) or pa.surcount , saleid = pa.saleid, thingcfgid = pa.thingcfgid, tradethingtype = 1})
	self:ClearActionParam()
end

--领取自己买到的东西
function RobotTrade:DrawThing()
	printf("at  DrawThing ......................")
	local pa = self:GetActionParam()
	assert(pa)
	self.robot.net:send_request("drawbuything", {thingcfgid = pa.thingcfgid, count = pa.thingcount, saleid = pa.saleid, thingtype=pa.thingtype})
end


--查看自己买到的东西
function RobotTrade:GetSelfBuy()
	printf("at  GetSelfBuy ......................")
	self.robot.net:send_request("getbuythingslist", {})
end

--查看自己卖的东西
function RobotTrade:QuerySelfSaleThing()
	printf("at  QuerySelfSaleThing ......................")
	self.robot.net:send_request("queryselfthing", {})
end

function RobotTrade:IsSaleId(id)
	local selfthing = self.tradeai.thingid
	for _, v in pairs(selfthing) do 
		if v.id == id then 
			return true
		end
	end
	return false
end

--加完东西后结果
function RobotTrade:AfterAddThing(id)
	if not self.tradeai then
		return 
	end
	
	if not self:IsSaleId(id) then 
		printf("not sale id ..")
		printf(id)
		return 
	end
	printf("at After AddThing ...................... id is .." .. id)
	self:SetActionQueFactor()
end

--加东西
function RobotTrade:AddThing()
	printf("at addthing ......................")
	local selfthing = self.tradeai.thingid
	assert(selfthing and not table.empty(selfthing))
	local r = Rand.Get(1, #selfthing)
	local t = selfthing[r]
	printf(t)
	self.robot:gm_commond("/clearbag " ) --先清下背包吧
	self.robot:gm_commond("/addthing " .. t.id .. " " .. t.cnt)
	self:SetActionParam(t)
end

--卖东西
function RobotTrade:SaleThing()
	printf("at  SaleThing ......................")
	local pa = self:GetActionParam()
	assert(pa)
	printf(pa.id)
	local key = self.robot:thingmodule():get_trade_thing(pa.id)
	assert(key)
	local cfg = get_static_config().trade_item[pa.id]
	assert(cfg)
	self.robot.net:send_request("salething", {key = key, thingcount = pa.cnt, thingprice= cfg.PriceValue * pa.factor /10000 , tradethingtype = 1})
	self:ClearActionParam()
end

--查看别人卖的东西，
function RobotTrade:QueryBuyThing()
	printf("at  Query othe player sale thing ......................")
	if self.cousor > self.max then 
		self:ReSetCursor()
	end
	
	local selfthing = self.tradeai.thingid
	local id = selfthing[self.cousor].id
	local ticfg = get_static_config().trade_item[id]
	local tid =  self:gettag1(ticfg.Tag)
	
	printf(self.cousor)
	printf(tid)
	self.robot.net:send_request("queryotherthing", {supertag = tid, quetype= 1, status = 3})
	self:AddCursor()
end


--查看波动因子
function RobotTrade:QueryFactor()
	printf("at  QueryFactor ......................")
	local pa = self:GetActionParam()
	assert(pa)
	self.robot.net:send_request("getfactor", {thingcfgid = pa.id})
end

--去买东西
function RobotTrade:BuyThing()
	printf("at  BuyThing ......................")
	local pa = self:GetActionParam()
	assert(pa)
	self.robot.net:send_request("buytradething", {saleid = pa.saleid, thingcfgid = pa.thingcfgid, count= self.tradeai.cnt, 
	thingprice = pa.thingprice, tradethingtype = 1, userxianyu = true})
end

--这几个游标的买东西时候一个一个变量表去买
function RobotTrade:AddCursor()
	self.cousor = self.cousor + 1
end
function RobotTrade:ReSetCursor()
	self.cousor = 1
	self:SetActionQueSelf() --查看完所有物品， 去卖东西吧
end
function RobotTrade:GetCursor()
	return self.cousor
end

--设置当前动作
function RobotTrade:SubCursor()
	if self.cousor > 1 then 
		self.cousor = self.cousor - 1
	end
end

---------------------------操作机器人函数 begin-------------------------------------

--设置当前等待服务器返回后接着执行
function RobotTrade:SetActionWait()
	self.action = tcommon.WAIT
end

--设置机器人买东西
function RobotTrade:SetActionBuy()
	self.action = tcommon.BUY_THING
end

--设置机器人下架东西
function RobotTrade:SetActionUnSale()
	self.action = tcommon.UNSALE_THING
end

--设置机器人卖东西
function RobotTrade:SetActionSale()
	self.action = tcommon.SALE_THING
end

--设置机器人加物品
function RobotTrade:SetActionAddThing()
	self.action = tcommon.ADD_THING
end

--设置机器人去看别人的东西
function RobotTrade:SetActionQueryOthe()
	self.action = tcommon.QUERY_OTHER_THING
end

--设置机器人去看波动因子
function RobotTrade:SetActionQueFactor()
	self.action = tcommon.QUERY_FACTOR
end

--设置机器人查看自己卖的东西
function RobotTrade:SetActionQueSelf()
	self.action = tcommon.QUERY_SELF_THING
end

--设置机器人领取东西
function RobotTrade:SetActionDraw()
	self.action = tcommon.DRAW_THING
end

--设置机器人取消关注
function RobotTrade:SetActionUnAttention()
	self.action = tcommon.UNATTENTION
end

--设置机器人获取关注
function RobotTrade:SetActionGetAttention()
	self.action = tcommon.GETATTENTION
end

--设置机器人获取日志
function RobotTrade:SetActionGetLog()
	self.action = tcommon.QUERRY_LOG
end

--设置机器人关注物品
function RobotTrade:SetActionAttention()
	self.action = tcommon.ATTENTION
end

--设置机器人查看自己买到的东西
function RobotTrade:SetActionQuerySelfBuy()
	self.action = tcommon.QUERY_BUYTHINT
end




--设机器人的执行参数
function RobotTrade:SetActionParam(v)
	self.actionparam = v
end

--清楚机器人执行参数
function RobotTrade:ClearActionParam()
	self.actionparam = nil
end

--获取机器人执行参数
function RobotTrade:GetActionParam()
	return self.actionparam
end

--
----------------------机器人操作函数 end-----------------------------------------------------

return RobotTrade
 