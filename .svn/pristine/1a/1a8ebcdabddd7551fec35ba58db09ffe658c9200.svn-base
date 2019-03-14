local class = require "class"
local mapcommon = require "mapcommon"
local random = require "random"
local timext = require "timext"
local MapCfgAPI = require "mapcfgapi"
local MapRefreshMgr = require "maprefreshmgr"
local MapMgrBase = require "mapmgrbase"
local MapResourceObject = require "mapresourceobject"
local MapResourceMgr = class("MapResourceMgr", MapMgrBase)

local pairs = pairs
local G_BackUpNum = 30 --每一帧备份N个
local G_BackUpTM = 30 --N秒备份一次
local G_RecoverTM = 30 --回收检测定时器


function MapResourceMgr:ctor(servermgr, objectmgr, marchmgr)
	self._servermgr = servermgr
	self._objectmgr = objectmgr
	self._marchmgr = marchmgr

	self._allobjmap = {} --全部资源活物列表 [objectid]->object
	self._resobjmap = {} --地图资源列表(不含墓地) [restype][objectid]->object
	self._tombmap = {} --资源墓地列表 [objectid]->object

	self._waitbackupobject = {} --等待备份对象
	self._backuptimer = timext.create_timer(G_BackUpTM)

	self._recoverobjmap = {} --等待回收资源列表
	self._recovertimer = timext.create_timer(G_RecoverTM)

	--刷新管理类
	self._refreshmgr = MapRefreshMgr.new(mapcommon.MapObjectType.eMOT_Resource, handler(self, MapResourceMgr.born_resobj))

	for _, restype in pairs(mapcommon.ResourceType) do
		self._resobjmap[restype] = {}
	end
end


--开服, 生成所有资源点
function MapResourceMgr:server_open()
	local MappingKey = self._refreshmgr:get_cfgkeys()
	local refreshcfg = get_static_config().objectrefresh
	for _,cfg in pairs(refreshcfg) do
		for _, cfgkey in pairs(MappingKey) do
			if cfg[cfgkey] then
				for _, neednum in pairs(cfg[cfgkey]) do
					for n=1,neednum do
						self:create_resobjontomb()
					end
				end
			end
		end
	end
end

function MapResourceMgr:loaddb()
	local t_record = self._servermgr:get_db():select_db_record(MapResourceObject.s_table)	
	for k,record in pairs(t_record) do
		local object = MapResourceObject.new(record)
		local objectid = object:get_objectid()

		self._allobjmap[objectid] = object
		self._objectmgr:set_maxobjectid(objectid)
		self._objectmgr:insert_object(object)
	end
end

function MapResourceMgr:init()
	--开服生成所有资源, 放在init, 因为其他的模块活物掩码也在INIT里添加
	if table.empty(self._allobjmap) then
		self:server_open()
	end

	local MapBlockMgr = self._servermgr:MapBlockMgr()
	local MapMaskMgr = self._servermgr:MapMaskMgr()
	for objectid,object in pairs(self._allobjmap) do
		repeat
			local restype = object:get_type()
			local x, y, width, height = object:get_range()
			if object:on_tomb() then --墓地
				self._tombmap[objectid] = object
				break
			end

			if not self:get_occupymarchobj(object) and --空闲资源, 资源少于25%开服直接刷掉
			   (object:get_reserves() / object:get_maxreserves() < mapcommon.recoverscale) then
				self:insert_tombresobj(object, true)
				break
			end

			if MapMaskMgr:check_maskrange(x, y, width, height) then --已经被格挡了
				self:insert_tombresobj(object, true)
				LOG_ERROR("resobj pos is occupy objectid=[%d]", objectid)
				break
			end

			self._resobjmap[restype][objectid] = object
			local blockkey = mapcommon.xyToblockkey(x, y)
			--区块添加活物
			MapBlockMgr:insert_mapobject(blockkey, object)
			--添加掩码
			MapMaskMgr:add_dynamicmask(objectid, x, y, width, height)	

			local areaobj = MapMaskMgr:get_areaobj(x, y)
			if not areaobj then
				LOG_ERROR("no find areaobj pos{%d,%d}", x, y)
				assert(false)
			end
			
			self._refreshmgr:change_areacount(areaobj:get_areaid(), restype, object:get_level(), 1)
		until 0;
	end
end

function MapResourceMgr:initcomplete()
	--资源刷满
	self._refreshmgr:refresh_full()
end

function MapResourceMgr:born_resobj(restype, areaid, level, bornnum, nosyn)
	local MapMaskMgr = self._servermgr:MapMaskMgr()
	local MapBlockMgr = self._servermgr:MapBlockMgr()
	while(bornnum>0) do 
		local objectid, object = next(self._tombmap)
		if not objectid then --墓地里边没有活物了
			object, objectid = self:create_resobjontomb()
		end

		local _, _, width, height = object:get_range()
		local pos = MapMaskMgr:random_spacepos_byareaid(areaid, width, height)
		if not pos then --该区域都没有位置了 退出
			return 
		end

		local x, y = pos[1], pos[2]
		object:init_data(restype, level, x, y, MapCfgAPI.GetResourceMaxReserves(restype, level))
		object:savedb()

		local blockkey = mapcommon.xyToblockkey(x, y)
		--区块添加活物
		MapBlockMgr:insert_mapobject(blockkey, object)
		--添加掩码
		MapMaskMgr:add_dynamicmask(objectid, x, y, width, height)	

		self._refreshmgr:change_areacount(areaid, restype, level, 1)

		self._tombmap[objectid] = nil
		self._resobjmap[restype][objectid] = object
		bornnum = bornnum - 1

		if not nosyn then 
			MapBlockMgr:sync_mapobjectchange(object)
		end
	end
end

function MapResourceMgr:run()
	--数据备份
	if self._backuptimer:expire() then
		local index = 1
		while(index <= G_BackUpNum) do
			local objectid, object = next(self._waitbackupobject)
			if object then
				object:savedb()
				self._waitbackupobject[objectid] = nil
				index = index + 1
			else
				break
			end
		end
		self._backuptimer:update(G_BackUpTM)
	end

	--回收的资源队列丢入墓地, 等待下个刷新轮
	if self._recovertimer:expire() then
 		local objectid,object = next(self._recoverobjmap)
		local MapBlockMgr = self._servermgr:MapBlockMgr()
 		while(object) do
 			if self:get_occupymarchobj(object) then
 				self._recoverobjmap[objectid] = nil
 			else
				self:insert_tombresobj(object) 		
 			end
 			objectid, object = next(self._recoverobjmap)
 		end
		self._recovertimer:update(G_RecoverTM)
	end

	--资源刷新
	self._refreshmgr:run()
end

--生成资源在墓地
function MapResourceMgr:create_resobjontomb()
	local object = self._objectmgr:create_object(mapcommon.MapObjectType.eMOT_Resource)
	local objectid = object:get_objectid()
	object:clear_data()

	self._allobjmap[objectid] = object
	self._tombmap[objectid] = object
	--object:savedb() 
	return object, objectid
end

function MapResourceMgr:insert_recoverresobj(object)
	self._recoverobjmap[object:get_objectid()] = object
end

function MapResourceMgr:insert_tombresobj(object, binit)
	if not binit then
		local MapBlockMgr = self._servermgr:MapBlockMgr()
		MapBlockMgr:sync_removemapobject(object) --同步
		MapBlockMgr:remove_mapobject(object:get_blockkey(), object)
	end


	object:clear_data()
	self:insert_backupresobj(object)

	local objectid = object:get_objectid()
	local restype = object:get_type()

	if self._resobjmap[restype] then
		self._resobjmap[restype][objectid] = nil	
	end

	if self._recoverobjmap[objectid] then
		self._recoverobjmap[objectid] = nil
	end

	self._tombmap[objectid] = object	
end

function MapResourceMgr:insert_resobj(object)
	local restype = object:get_type()
	local objectid = object:get_objectid()
	self._resobjmap[restype][objectid] = object	
end

function MapResourceMgr:insert_backupresobj(object)
	self._waitbackupobject[object:get_objectid()] = object
end

function MapResourceMgr:get_resobj(restype, objectid)
	if self._resobjmap[restype] then
		return self._resobjmap[restype][objectid]
	end
	return nil
end

function MapResourceMgr:get_resobjbyid(objectid)
	local resobj = self._allobjmap[objectid]
	if resobj then
		local restype = resobj:get_type()
		return self:get_resobj(restype, objectid)
	end
	return nil
end

--获取占领资源点的行军对象
function MapResourceMgr:get_occupymarchobj(object)
	local marchid = object:get_occupymarchid()
	if marchid ~= 0 then
		return self._marchmgr:get_marchobjbyid(marchid)
	end
	return nil
end

--占领资源点
function MapResourceMgr:occupy_resobj(objectid, marchid)
	local resobj = self:get_resobjbyid(objectid)
	if resobj and resobj:get_occupymarchid() ~= marchid then
		resobj:set_occupymarchid(marchid)
		self:insert_backupresobj(resobj)
	end
end

--解除占领资源点
function MapResourceMgr:unoccupy_resobj(objectid, marchid)
	local resobj = self:get_resobjbyid(objectid)
	if resobj then
		resobj:set_occupymarchid(0)
		self:insert_backupresobj(resobj)
	end
end

return MapResourceMgr