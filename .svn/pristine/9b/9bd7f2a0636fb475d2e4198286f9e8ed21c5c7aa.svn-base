local class = require "class"
local common = require "common"
local mapcommon = require "mapcommon"
local timext = require "timext"
local marchcommon = require "marchcommon"

local MarchCollectHandler = require "marchcollecthandler"
local TimeCheckMgr = require "timecheckmgr"
local MapMgrBase = require "mapmgrbase"
local MapMarchObject = require "mapmarchobject"
local MapMarchMgr = class("MapMarchMgr", MapMgrBase)

--[[
	考虑下要不要做个行军活物墓地机制, 可减少行军创建删除, 减少DB压力.
]]

function MapMarchMgr:ctor(servermgr, blockmgr)
	self._servermgr = servermgr
	self._blockmgr = blockmgr
	self._maxmarchid = 0

	self._marchmap = {}
	self._playermap = {}

	self._timecheckmgr = TimeCheckMgr.new({1, 300, 3600}, handler(self, MapMarchMgr.HandleMarchTimeExpire))
end

function MapMarchMgr:get_newmarchid()
	self._maxmarchid = self._maxmarchid + 1
	return self._maxmarchid
end

function MapMarchMgr:set_maxmarchid(marchid)
	if self._maxmarchid < marchid then
		self._maxmarchid = marchid
	end
end

function MapMarchMgr:loaddb()
	local t_record = self._servermgr:get_db():select_db_record(MapMarchObject.s_table)	
	for k,record in pairs(t_record) do
		local marchobject = MapMarchObject.new(record)
		marchobject:loaddb()

		local marchid = marchobject:get_marchid()
		self._marchmap[marchid] = marchobject
		local playerid = marchobject:get_playerid()
		if playerid then
			if not self._playermap[playerid] then
				self._playermap[playerid] = {}
			end
			self._playermap[playerid][marchid] = marchobject
		end

		self:set_maxmarchid(marchid)
	end
end

function MapMarchMgr:init()
	for marchid,marchobj in pairs(self._marchmap) do
		local startx, starty = marchobj:get_startxy()
		local endx, endy = marchobj:get_endxy()
		local block_set = marchcommon.marchThroughblocks(startx, starty, endx, endy)
		for blockkey,_ in pairs(block_set) do
	    	local blockobj = self._blockmgr:get_blockobj(blockkey)
	    	if blockobj then
				marchobj:insert_block(blockkey, blockobj)
	    	end
	    end

	    self:insert_marchobj_tomap(marchobj)
		self._timecheckmgr:addCheckItem(marchid, marchobj, marchobj:get_endtime())
	end
end

function MapMarchMgr:initcomplete()
end

function MapMarchMgr:run()
    local curtime = timext.current_time()
	self._timecheckmgr:run(curtime)	
end

function MapMarchMgr:get_marchobjbyid(marhcid)
	return self._marchmap[marhcid]
end

function MapMarchMgr:get_timecheckmgr()
	return self._timecheckmgr
end

--从地图上移除行军活物
function MapMarchMgr:remove_marchobj_frommap(marchobj)
	local marchid = marchobj:get_marchid()
	for _,blockobj in pairs(marchobj:get_marchblockset()) do
		blockobj:remove_mapmarch(marchid)
	end
	self._blockmgr:sync_removemapmarchobj(marchobj)
end

--添加地图上行军
function MapMarchMgr:insert_marchobj_tomap(marchobj)
	local marchid = marchobj:get_marchid()
	for blockkey,blockobj in pairs(marchobj:get_marchblockset()) do
		blockobj:insert_mapmarch(marchid, marchobj)
    end
end

--删除行军
function MapMarchMgr:delete_marchobj(marchobj)
	local marchid = marchobj:get_marchid()
	self._marchmap[marchid] = nil

	local playerid = marchobj:get_playerid()
	if playerid then
		self._playermap[playerid][marchid] = nil
	end
	
	marchobj:deletedb()
end

function MapMarchMgr:create_march(marchparam)
	local marchtype = marchparam.marchtype
	local startx, starty, endx, endy = marchparam.startx, marchparam.starty, marchparam.endx, marchparam.endy
	local speed = marchparam.param.marchspeed
	local distance = marchparam.param.distance
	local marchtime = marchcommon.CaculateMarchtime(distance, speed)
	local curtime = timext.current_time()
	local endtime = curtime + marchtime

	local block_set = marchcommon.marchThroughblocks(startx, starty, endx, endy)
	local newmarchid = self:get_newmarchid()
	local record = self._servermgr:get_db():create_db_record(MapMarchObject.s_table, newmarchid)
	local marchobj = MapMarchObject.new(record)	
	--数据初始化
	local dbdata = {
		marchtype = marchtype,
		status = marchcommon.MarchStatus.eMS_Walk,
		startx = startx,
		starty = starty,
		endx = endx,
		endy = endy,
		--remaintime = marchtime,
		starttime = curtime,
		endtime = endtime,
	}
	marchobj:create(dbdata)
	--marchobj:set_army(marchparam.army)
	marchobj:update_marchnode(0, curtime) --初始化节点
	marchobj:set_param(marchparam.param)
	marchobj:savedb()

	self._marchmap[newmarchid] = marchobj
	local playerid = marchparam.param.playerid
	if playerid and not self._playermap[playerid] then
		self._playermap[playerid] = {}
	end
	self._playermap[playerid][newmarchid] = marchobj

	--加入时间管理类
	self._timecheckmgr:addCheckItem(newmarchid, marchobj, endtime)

    for blockkey,_ in pairs(block_set) do
    	local blockobj = self._blockmgr:get_blockobj(blockkey)
    	if blockobj then
    		marchobj:insert_block(blockkey, blockobj) --设置经过的格子信息
    	else
    		LOG_ERROR("march line caculate error, playerid=[%d], no find blockkey=[%d], p1{ %d, %d }, p2{ %d, %d }", playerid, blockkey, startx, starty, endx, endy)
    	end
    end
    self:insert_marchobj_tomap(marchobj)

	--同步
	self._blockmgr:sync_mapmarchobject(marchobj)
	return marchobj
end



-- function MapMarchMgr:speedup_marchobj(marchid, )
-- 	local marchobj = self:get_marchobjbyid(marchid)
-- 	if not marchobj then
-- 		return
-- 	end

-- 	local status = marchobj:get_status()
-- 	if marchcommon.MarchStatus.eMS_Walk ~= status or marchcommon.MarchStatus.eMS_Walk ~= status then
-- 		return
-- 	end

-- 	local curtime = timext.current_time()
-- 	local distance = marchobj:get_distance()
-- 	local pastdistance = marchcommon.CaculateMarchPastDistance(marchobj)


-- end

local C_MarchType = marchcommon.MarchType
local MarchHandler = {
	[C_MarchType.eMT_CollectRes] = MarchCollectHandler.HandleTimeExpire,
	[C_MarchType.eMT_AtkRes] = MarchCollectHandler.HandleTimeExpire,
}
function MapMarchMgr:HandleMarchTimeExpire(marchid, marchobj)
	local marchtype = marchobj:get_marchtype()
	local Func = MarchHandler[marchtype]
	if Func then
		Func(self._servermgr, marchobj)
	else
		LOG_ERROR("no find march handler, marchtype = [%d]", marchtype)
	end
end

return MapMarchMgr