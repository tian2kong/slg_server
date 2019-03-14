local class = require "class"
local mapcommon = require "mapcommon"
local random = require "random"
local timext = require "timext"
local MapRefreshMgr = require "maprefreshmgr"

local MapMgrBase = require "mapmgrbase"
local MapMonsterObject = require "mapmonsterobject"
local MapMonsterMgr = class("MapMonsterMgr", MapMgrBase)

local pairs = pairs
local G_BackUpNum = 30 --每一帧备份N个
local G_BackUpTM = 30 --N秒备份一次

function MapMonsterMgr:ctor(servermgr, objectmgr)
	self._servermgr = servermgr
	self._objectmgr = objectmgr

	self._allobjmap = {} --全部怪物活物列表 [objectid]->object
	self._msobjmap = {} --地图怪物列表(不含墓地) [mstype][objectid]->object
	self._tombmap = {} --怪物墓地列表 [objectid]->object

	self._waitbackupobject = {} --等待备份对象
	self._backuptimer = timext.create_timer(G_BackUpTM)

	--刷新管理类
	self._refreshmgr = MapRefreshMgr.new(mapcommon.MapObjectType.eMOT_Monster, handler(self, MapMonsterMgr.born_monsterobj))

	for _, mstype in pairs(mapcommon.MonsterType) do
		self._msobjmap[mstype] = {}
	end
end


--开服, 生成所有怪物点
function MapMonsterMgr:server_open()
	local MappingKey = self._refreshmgr:get_cfgkeys()
	local refreshcfg = get_static_config().objectrefresh
	for _,cfg in pairs(refreshcfg) do
		for _, cfgkey in pairs(MappingKey) do
			if cfg[cfgkey] then
				for _, neednum in pairs(cfg[cfgkey]) do
					for n=1,neednum do
						self:create_msobjontomb()
					end
				end
			end
		end
	end
end

function MapMonsterMgr:loaddb()
	local t_record = self._servermgr:get_db():select_db_record(MapMonsterObject.s_table)	
	for k,record in pairs(t_record) do
		local object = MapMonsterObject.new(record)
		local objectid = object:get_objectid()

		self._allobjmap[objectid] = object
		self._objectmgr:set_maxobjectid(objectid)
		self._objectmgr:insert_object(object)
	end
end

function MapMonsterMgr:init()
	--开服生成所有怪物, 放在init, 因为其他的模块活物掩码也在INIT里添加
	if table.empty(self._allobjmap) then
		self:server_open()
	end

	local MapBlockMgr = self._servermgr:MapBlockMgr()
	local MapMaskMgr = self._servermgr:MapMaskMgr()
	for objectid,object in pairs(self._allobjmap) do
		repeat
			local mstype = object:get_type()
			local x, y, width, height = object:get_range()
			if object:on_tomb() then --墓地
				self._tombmap[objectid] = object
				break
			end

			if MapMaskMgr:check_maskrange(x, y, width, height) then --已经被格挡了, 丢到墓地
				self:insert_tombmsobj(object, true) 
				break
			end

			self._msobjmap[mstype][objectid] = object
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
			
			self._refreshmgr:change_areacount(areaobj:get_areaid(), mstype, object:get_level(), 1)
		until 0;
	end
end

function MapMonsterMgr:initcomplete()
	--怪物刷满
	self._refreshmgr:refresh_full()
end

function MapMonsterMgr:born_monsterobj(mstype, areaid, level, bornnum, nosyn)
	local MapMaskMgr = self._servermgr:MapMaskMgr()
	local MapBlockMgr = self._servermgr:MapBlockMgr()
	while(bornnum>0) do 
		local objectid, object = next(self._tombmap)
		if not objectid then --墓地里边没有活物了
			object, objectid = self:create_msobjontomb()
		end

		local _, _, width, height = object:get_range()
		local pos = MapMaskMgr:random_spacepos_byareaid(areaid, width, height)
		if not pos then --该区域都没有位置了 退出
			return 
		end

		local x, y = pos[1], pos[2]
		object:init_data(mstype, level, x, y)
		object:savedb()

		local blockkey = mapcommon.xyToblockkey(x, y)
		--区块添加活物
		MapBlockMgr:insert_mapobject(blockkey, object)
		--添加掩码
		MapMaskMgr:add_dynamicmask(objectid, x, y, width, height)	

		self._refreshmgr:change_areacount(areaid, mstype, level, 1)

		self._tombmap[objectid] = nil
		self._msobjmap[mstype][objectid] = object
		bornnum = bornnum - 1


		if not nosyn then 
			MapBlockMgr:sync_mapobjectchange(object)
		end
	end
end

function MapMonsterMgr:run()
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

	--怪物刷新
	self._refreshmgr:run()
end

--生成怪物在墓地
function MapMonsterMgr:create_msobjontomb()
	local object = self._objectmgr:create_object(mapcommon.MapObjectType.eMOT_Monster)
	local objectid = object:get_objectid()
	object:clear_data()

	self._allobjmap[objectid] = object
	self._tombmap[objectid] = object
	--object:savedb() 
	return object, objectid
end

function MapMonsterMgr:insert_tombmsobj(object, binit)
	if not binit then
		local MapBlockMgr = self._servermgr:MapBlockMgr()
		MapBlockMgr:sync_removemapobject(object) --同步
		MapBlockMgr:remove_mapobject(object:get_blockkey(), object)
	end

	object:clear_data()
	self:insert_backupmsobj(object)

	local objectid = object:get_objectid()
	self._tombmap[objectid] = object	
end

function MapMonsterMgr:insert_msobj(object)
	local mstype = object:get_type()
	local objectid = object:get_objectid()
	self._msobjmap[mstype][objectid] = object	
end

function MapMonsterMgr:insert_backupmsobj(object)
	self._waitbackupobject[object:get_objectid()] = object
end

return MapMonsterMgr