local class = require "class"
local mapcommon = require "mapcommon"
local MapMgrBase = require "mapmgrbase"
local MapObjectFactory = require "mapobjectfactory"

local MapPlayerMgr = require "mapplayermgr"
local MapResourceMgr = require "mapresourcemgr"
local MapMonsterMgr = require "mapmonstermgr"

local MapObjectMgr = class("MapObjectMgr", MapMgrBase)
---活物总管理类, 所有活物创建删除都在该类上
function MapObjectMgr:ctor(servermgr)
	self._servermgr = servermgr
	self._objectlist = {} --活物总列表

	self._maxobjectid = 0
	self._tombobjectids = {} --ID复用
	self:init_tombobjectids()
end

function MapObjectMgr:loaddb()
end

function MapObjectMgr:init()
end

function MapObjectMgr:init_tombobjectids()
	--活物ID复用, 场景活物大量创建, 优先找前N个没有复用的ID
	for i=1,mapcommon.mapobject_maxtombid do
		self._tombobjectids[i] = true
	end 
end

function MapObjectMgr:get_newobjectid(bnew)
	if not bnew then
		local tombid = next(self._tombobjectids)
		if tombid then
			self._tombobjectids[tombid] = nil
			return tombid 
		end
	end
	
	self._maxobjectid = self._maxobjectid + 1
	return self._maxobjectid
end

function MapObjectMgr:set_maxobjectid(newmaxobjid)
	if newmaxobjid > self._maxobjectid then
		self._maxobjectid = newmaxobjid
	end
	if self._tombobjectids[newmaxobjid] then
		self._tombobjectids[newmaxobjid] = nil
	end
end

function MapObjectMgr:insert_object(object)
	local objectid = object:get_objectid()
	self._objectlist[objectid] = object
end

function MapObjectMgr:remove_object(object)
	local objectid = object:get_objectid()
	self._objectlist[objectid] = nil

	if objectid <= mapcommon.mapobject_maxtombid then
		self._tombobjectids[objectid] = true
	end
end

--创建活物接口
function MapObjectMgr:create_object(objecttype)
	local object = MapObjectFactory.create(self._servermgr:get_db(), objecttype, self:get_newobjectid())
	self:insert_object(object)
	return object
end


function MapObjectMgr:delete_object()
	--TODOx
end


return MapObjectMgr