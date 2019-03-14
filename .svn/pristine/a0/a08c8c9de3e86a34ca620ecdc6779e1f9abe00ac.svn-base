local class = require "class"
local MapMgrBase = require "mapmgrbase"
local mapcommon = require "mapcommon"
local MapPlayerObject = require "mapplayerobject"

local MapPlayerMgr = class("MapPlayerMgr", MapMgrBase)

function MapPlayerMgr:ctor(servermgr, objectmgr)
	self._servermgr = servermgr
	self._objectmgr = objectmgr

	self._objectmap = {} --objectid索引
	self._playermap = {} --玩家主城信息
	
	self._checkobjectmap = {} --初始化结束事件中, 异常的玩家城池活物处理
end

function MapPlayerMgr:loaddb()
	local t_record = self._servermgr:get_db():select_db_record(MapPlayerObject.s_table)	
	for k,record in pairs(t_record) do
		local object = MapPlayerObject.new(record)
		local playerid = object:get_playerid()
		local objectid = object:get_objectid()

		self._objectmap[objectid] = object
		self._playermap[playerid] = object

		self._objectmgr:set_maxobjectid(objectid)
		self._objectmgr:insert_object(object)
	end
end

function MapPlayerMgr:init()
	local MapBlockMgr = self._servermgr:MapBlockMgr()
	local MapMaskMgr = self._servermgr:MapMaskMgr()

	for objectid,object in pairs(self._objectmap) do
		local x, y, width, height = object:get_range()
		if MapMaskMgr:check_maskrange(x, y, width, height) then
			--加入容错处理队列
			self._checkobjectmap[objectid] = object
		else
			local blockkey = object:get_blockkey()
			--区块添加活物
			MapBlockMgr:insert_mapobject(blockkey, object)
			--添加掩码
			MapMaskMgr:add_dynamicmask(objectid, x, y, width, height)
		end
	end
end

--初始化结束事件
function MapPlayerMgr:initcomplete()

	--等待其他模块都初始化之后, 异常玩家容错处理
	local MapBlockMgr = self._servermgr:MapBlockMgr()
	local MapMaskMgr = self._servermgr:MapMaskMgr()

	for objectid,object in pairs(self._checkobjectmap) do
		local x, y, width, height = object:get_range()
		LOG_ERROR("player city init : mask already occupy, playerid = [%d], x=[%d], y=[%d]", object:get_playerid(), x, y)
		--重新迁城		
		local pos = MapMaskMgr:random_spacepos_byareatype(mapcommon.MapAreaType.eMAT_Lower, width, height)
	 	if pos then
	 		x, y = pos[1], pos[2]
	 		object:set_xy(x, y)
	 		object:savedb()

	 		local blockkey = object:get_blockkey()
			--区块添加活物
			MapBlockMgr:insert_mapobject(blockkey, object)
			--添加掩码
			MapMaskMgr:add_dynamicmask(objectid, x, y, width, height)
	 	else
	 		--低级资源带都没有位置 直接报错吧
	 		assert(false)
	 	end
	end
end

function MapPlayerMgr:get_playercityobj(playerid)
	return self._playermap[playerid]
end

--创建玩家城池活物
function MapPlayerMgr:create_mapplayerobject(playerid, data)
	if self._playermap[playerid] then
		return nil
	end	

	local MapBlockMgr = self._servermgr:MapBlockMgr()
	local MapMaskMgr = self._servermgr:MapMaskMgr()
	local object = self._objectmgr:create_object(mapcommon.MapObjectType.eMOT_Player)
	local objectid = object:get_objectid()

	--默认一级资源带 配置 长宽
	local pos = MapMaskMgr:random_spacepos_byareatype(mapcommon.MapAreaType.eMAT_Lower, mapcommon.playercity_width, mapcommon.playercity_height)	
	local x, y = pos[1], pos[2]
	object:set_xy(x, y)
	object:set_playerid(playerid)
	object:set_level(data.level)
	object:set_name(data.name)
	object:savedb()

	local blockkey = object:get_blockkey()
	--区块添加活物
	MapBlockMgr:insert_mapobject(blockkey, object)
	--添加掩码
	MapMaskMgr:add_dynamicmask(objectid, x, y, width, height)
	--同步活物发生变化
	MapBlockMgr:sync_mapobjectchange(object)
	return object
end


return MapPlayerMgr