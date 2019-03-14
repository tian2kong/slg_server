local common = require "common"
local marchcommon = require "marchcommon"
local mapcommon = require "mapcommon"
local timext = require "timext"
local MarchCollectHandler = {}

--时间回调
function MarchCollectHandler.HandleTimeExpire(servermgr, marchobj)
	print("资源行军 到时处理")
	local marchstatus = marchobj:get_status()
	if marchstatus == marchcommon.MarchStatus.eMS_Walk then
		print("到达采集点 准备采集")
		MarchCollectHandler.ReachResource(servermgr, marchobj)

	elseif marchstatus == marchcommon.MarchStatus.eMS_Working then
		print("采集完成")
		print("准备返回")
		MarchCollectHandler.CollectComplete(servermgr, marchobj)

	elseif marchstatus == marchcommon.MarchStatus.eMS_Back then
		print("返回")
		MarchCollectHandler.ReachBack(servermgr, marchobj)

	else 
		assert(false)
	end
end


--抵达资源点
function MarchCollectHandler.ReachResource(servermgr, marchobj)
	local MapBlockMgr = servermgr:MapBlockMgr()
	local MapResourceMgr = servermgr:MapResourceMgr()
	local MapMaskMgr = servermgr:MapMaskMgr()
	local MapMarchMgr = servermgr:MapMarchMgr()
	repeat
		--再移除一次, 该接口不止时间回调会回调到,
		local marchid = marchobj:get_marchid()
		MapMarchMgr:get_timecheckmgr():removeCheckItem(marchid)

		--没有找到活物
		local endx,endy = marchobj:get_endxy()
		local objectid = MapMaskMgr:get_objectidbyxy(endx, endy)
		if not objectid then--返回
			MarchCollectHandler.CollectMarchBack(servermgr, marchobj)
			break
		end	

		--没有找到活物
		local resobj = MapResourceMgr:get_resobjbyid(objectid)
		if not resobj then--返回
			print("objectid", objectid)
			MarchCollectHandler.CollectMarchBack(servermgr, marchobj)
			break
		end

		--不能采集(已经被占领)
		local occupymarchobj = MapResourceMgr:get_occupymarchobj(resobj)
		if occupymarchobj then
			--
			if true--[[判断是否在在同一阵营]] then
				--返回
				MarchCollectHandler.CollectMarchBack(servermgr, marchobj)
				break
			else
				--直接进入战斗.
				--等待战斗结果返回
				local fightresult = { win = true, report={}--[[战损报告]] }
				--TODOX

				if not fightresult then
					LOG_ERROR("collect fight unkonw error, fightserver retpack is nil")				
					--返回
					MarchCollectHandler.CollectMarchBack(servermgr, marchobj)
					break
				end

				--记入双方战损报告
				--TODOX
				

				if fightserver.win then
					--赶走对方采集部队, 部队资源点结算
					
				else
					--采集部队立即返回
					break
				end
			end
			
		end
		print("ssssssssssdfsdfs")
		--判断资源储量
		local reserves = resobj:get_reserves()
		print("reserves", reserves)
		if reserves <= 0 then
			--储量为空,移除该资源点
			MapResourceMgr:insert_tombresobj(resobj)--移除该资源点
			MarchCollectHandler.CollectMarchBack(servermgr, marchobj)
			break
		end
		
		local marchid = marchobj:get_marchid()
		local restype = resobj:get_type()
		local maxweight = marchobj:get_maxweight() --最大负重上限
		local collectrate = marchobj:get_collectrate() --采集速率

		local maxcollectnum = math.ceil(maxweight / marchcommon.WeightSlotByResObjectType[restype]) --行军最大可以采集数
    	local collectnum = math.min(maxcollectnum, reserves) --可采集的资源量
		local collecttime = math.floor(collectnum / collectrate)--计算采集时间
		local curtime = timext.current_time()
		local endtime = curtime + collecttime
		local distance = marchobj:get_distance()
		marchobj:set_starttime(curtime)
		marchobj:set_endtime(endtime)
		marchobj:update_collectnode(0, curtime) --采集节点更新
		marchobj:clear_marchnode() --行军节点更新清空
		marchobj:set_status(marchcommon.MarchStatus.eMS_Working)
		marchobj:savedb()

		print("need time", endtime - curtime)

		--行军路线移除
		MapMarchMgr:remove_marchobj_frommap(marchobj)
		--资源占领标记
		MapResourceMgr:occupy_resobj(objectid, marchid)
		--资源活物同步
		MapBlockMgr:sync_mapobjectchange(resobj) 
		--加入时间管理类
		MapMarchMgr:get_timecheckmgr():addCheckItem(marchid, marchobj, endtime)
	until 0;
end

--采集完成
function MarchCollectHandler.CollectComplete(servermgr, marchobj)
	local MapMarchMgr = servermgr:MapMarchMgr()
	local MapBlockMgr = servermgr:MapBlockMgr()
	local MapResourceMgr = servermgr:MapResourceMgr()

	--再移除一次, 该接口不止时间回调会回调到,
	local marchid = marchobj:get_marchid()
	MapMarchMgr:get_timecheckmgr():removeCheckItem(marchid)

	local resobj = MarchCollectHandler.HandleCollectCaculate(servermgr, marchobj) --结算
	if not resobj then
		LOG_ERROR("CollectComplete no find resobj, marchid=[%d], playerid=[%d]", marchobj:get_marchid(), marchobj:get_playerid())
		MarchCollectHandler.CollectMarchBack(servermgr, marchobj) --直接返回
	else
		local reserves = resobj:get_reserves()
		if reserves <= 0 then--判断资源储量
			MapResourceMgr:insert_tombresobj(resobj)--移除该资源点
		else
			MapResourceMgr:unoccupy_resobj(resobj, marchid) --占领标记清除
			MapBlockMgr:sync_mapobjectchange(resobj) --活物信息同步

			local maxreserves = resobj:get_maxreserves()
			if reserves/maxreserves <mapcommon.recoverscale then --资源小于25% 加入回收队列
				MapResourceMgr:insert_recoverresobj(resobj)
			end
		end
		MarchCollectHandler.CollectMarchBack(servermgr, marchobj) --行军采集返回
	end
end

--准备返回
function MarchCollectHandler.CollectMarchBack(servermgr, marchobj)
	print("准备返回")
	local MapMarchMgr = servermgr:MapMarchMgr()
	local MapBlockMgr = servermgr:MapBlockMgr()

	--再移除一次, 该接口不止时间回调会回调到,
	local marchid = marchobj:get_marchid()
	MapMarchMgr:get_timecheckmgr():removeCheckItem(marchid)

	local startx, starty = marchobj:get_startxy()
	local endx, endy = marchobj:get_endxy()
	local initspeed = marchobj:get_initspeed() --获取初始速度
	local distance = marchobj:get_distance()
	local pastdistance = marchcommon.CaculateMarchPastDistance(marchobj) --计算已经行驶过的路程
	local marchtime = marchcommon.CaculateMarchtime(distance-pastdistance, initspeed)
	local curtime = timext.current_time()
	local endtime = curtime + marchtime
	marchobj:set_marchspeed(initspeed) --重置为初始速度
	marchobj:update_marchnode(distance - pastdistance, curtime)
	marchobj:set_status(marchcommon.MarchStatus.eMS_Back)
	marchobj:set_starttime(curtime)
	marchobj:set_endtime(endtime)
	marchobj:set_startxy(endx, endy)
	marchobj:set_endxy(startx, starty)
	marchobj:savedb()
	MapMarchMgr:insert_marchobj_tomap(marchobj) --加入场景
	MapMarchMgr:get_timecheckmgr():addCheckItem(marchid, marchobj, endtime)
	MapBlockMgr:sync_mapmarchobject(marchobj) --行军同步
end

--返回抵达
function MarchCollectHandler.ReachBack(servermgr, marchobj)
	print("返回到达")

	--再移除一次, 该接口不止时间回调会回调到,
	local MapMarchMgr = servermgr:MapMarchMgr()
	local marchid = marchobj:get_marchid()
	MapMarchMgr:get_timecheckmgr():removeCheckItem(marchid)

	--通知玩家行军到达

	--行军移除
	MapMarchMgr:remove_marchobj_frommap(marchobj)
	MapMarchMgr:delete_marchobj(marchobj)
end

--结算采集
function MarchCollectHandler.HandleCollectCaculate(servermgr, marchobj)
	local MapBlockMgr = servermgr:MapBlockMgr()
	local MapResourceMgr = servermgr:MapResourceMgr()
	local MapMarchMgr = servermgr:MapMarchMgr()
	local MapMaskMgr = servermgr:MapMaskMgr()
	repeat
		
		local marchid = marchobj:get_marchid()
		local endx,endy = marchobj:get_endxy()
		local objectid = MapMaskMgr:get_objectidbyxy(endx, endy)
		if not objectid then--没有找到活物
			LOG_ERROR("CollectCollect maskmgr no find objectid, playerid=[%d],marchid=[%d]", marchobj:get_playerid(), marchid)
			break
		end	

		
		local resobj = MapResourceMgr:get_resobjbyid(objectid)
		if not resobj then--没有找到活物
			LOG_ERROR("CollectCollect resmgr no find object, \
				objectid=[%d],playerid=[%d],marchid=[%d]", objectid, marchobj:get_playerid(), marchid)
			break
		end
		
		--
		local totalcollectnum, lastcaltime = marchobj:get_collectnode()	
		if not totalcollectnum or not lastcaltime then
			LOG_ERROR("CollectCollect no find march collectnode")
			break
		end

		local collectrate = marchobj:get_collectrate() --采集速率
		local maxweight = marchobj:get_maxweight() --最大负重上限
		local restype = resobj:get_type()
		local maxcollectnum = math.ceil(maxweight / marchcommon.WeightSlotByResObjectType[restype]) --行军最大可以采集数
		local curtime = timext.current_time()
		local pasttime = curtime - lastcaltime + 1
		if pasttime <= 0 then
			--2测试改时间 容错下
			return resobj
		end

		local CollectNum = math.min(math.floor(collectrate * pasttime), maxcollectnum)
		totalcollectnum = totalcollectnum + CollectNum
		marchobj:update_collectnode(math.min(maxcollectnum, totalcollectnum), curtime) --采集部队结算
		resobj:sub_reserves(CollectNum) --资源点结算

		print("collect num ", CollectNum)

		MapResourceMgr:insert_backupresobj(resobj) --备份队列

		return resobj
	until 0;
end

return MarchCollectHandler