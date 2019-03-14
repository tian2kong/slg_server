local request = require "request"
local tcommon = require "trade.tradecommon"
local Rand = require "random"


local function getid(t)
	if #t < 1 then 
		return 
	end
	local r = Rand.Get(1, #t)
	return t[r]
end


--查看别人卖的东西回复
function request.synquerethinginfo(robot, args)
	if args.ret == 0 then 
		local allthing = args.result
		if not allthing or table.empty(allthing) then 
			return 
		end
		
		local thing 
		for i= 1, #allthing do 
			local t1 = getid(allthing)
			if not t1 then 
				t = nil
				break
			end
			
			if t1.playerid ~=  robot.rolelogic:get_player_id() then
				break
			end
		end
		
		if not thing then 
			printf "not thing of buy.... "
			robot:trademodule():SetActionQueSelf() --去查看自己卖的东西 
			return 
		end
			
		robot:trademodule():SetActionParam(thing)
		robot:trademodule():SetActionBuy()
		return
	end
	robot:trademodule():SetActionQueryOthe() --继续去查看别人的东西
end

--回复 买别人的东西
function request.sysbuytradething(robot, args)
	if args.ret == tcommon.ret.BAG_FULL then --背包满了清下包裹接着买买买
		robot:gm_commond("/clearbag")
		robot:trademodule():SubCursor()
		robot:trademodule():SetActionQueryOthe()
		
	elseif args.ret == tcommon.ret.NO_MONEY then --没钱 了， 加钱接着买买买
		robot:gm_commond("/addyinliang 9999999999999999")
		robot:trademodule():SubCursor()
		robot:trademodule():SetActionQueryOthe()
		
	elseif args.ret == tcommon.ret.NOT_COUNT then --数量不对？
		printf("your moust buy count or config param cnt")
	elseif args.ret == tcommon.ret.BUY_BAG_FULL then -- 买的星系太多了， 去领取东西
		robot:trademodule():SubCursor()
		robot:trademodule():SetActionQuerySelfBuy() --去查看自己卖的东西并领取东西
	else 
		robot:trademodule():SetActionQueSelf() --去查看自己卖的东西 
	end
end


--查看自己卖的东西回复列表
function request.sysqueryselfthing(robot, args)
	if args.ret == 0 and args.info then 
		printf(#args.info)
		if #args.info >= 8 then
			local r = Rand.Get(1, #args.info)
			local v = args.info[r]
			robot:trademodule():SetActionParam(v)
			robot:trademodule():SetActionUnSale()
			printf("un sale ")
			return 
		else 
			robot:trademodule():SetActionAddThing()--去加点东西
		end
	end
	robot:trademodule():SetActionAddThing() --去加点东西
end

--卖东西结果
function request.syssalething(robot, args)
	if args.ret ==  tcommon.ret.MAX_TRADE_GRID then --卖的格子超限
		robot:trademodule():SetActionQueSelf() --去看下自己卖的东西
		return
	end
	robot:trademodule():SetActionGetLog() --卖玩东西去看下日志
end

--查看波动因子结果
function request.sysgetfactor(robot, args)
	local f = 10000
	if args.factor then 
		f = args.factor 
	end
	local pa = robot:trademodule():GetActionParam()
	pa.factor = f 
	robot:trademodule():SetActionSale()
end

--回复查看自己买到的东西结果
function request.sysgetbuythingslist(robot, args)
	if args.ret == 0 then 
		if args.info and not table.empty(args.info) then 
			local m = #args.info 
			local r = Rand.Get(1, m)
			local t = args.info[r]
			robot:trademodule():SetActionParam(t)
			robot:trademodule():SetActionDraw()
			return
		end
	end
	robot:trademodule():SetActionQueryOthe() --去查看别人的东西
end

--回复领取买到的东西结果
function request.sysdrawbuything(robot, args)
	if args.ret ~= 0 then 
		printf("draw self thing faild")
	end
	robot:trademodule():SetActionQueSelf() --去查看自己卖的东西
end

--回复下架结果
function request.sysunsalething(robot, args)
	if args.ret ~= 0 then 
		printf("not thing at un sale thing.....")
	end
	robot:trademodule():SetActionAddThing() --去加点东西
end

--回复查看日志
function request.sysgettradelog(robot, args)
	robot:trademodule():SetActionQueryOthe() --去查看别人的东西
end


--回复查看关注结果
function request.sysattentions(robot, args)
	if args.ret == 0 then 
		if args.info and not table.empty(args.info) then 
			local m = #args.info
			local r = Rand.Get(1, m)
			local t = args.info[r]
			robot:trademodule():SetActionParam(t)
			robot:trademodule():SetActionUnAttention()
		end
	end
	robot:trademodule():SetActionQueryOthe() --去查看别人的东西
end
























