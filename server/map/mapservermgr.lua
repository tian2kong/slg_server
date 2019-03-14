local class = require "class"
local Database = require "database"
local serverconfig = require "serverconfig"

local MapBlockMgr = require "mapblockmgr"
local MapMaskMgr = require "mapmaskmgr"
local MapObjectMgr = require "mapobjectmgr"
local MapPlayerMgr = require "mapplayermgr"
local MapResourceMgr = require "mapresourcemgr"
local MapMonsterMgr = require "mapmonstermgr"
local MapMarchMgr = require "mapmarchmgr"

local MapServerMgr = class("MapServerMgr")

local pairs = pairs

function MapServerMgr:ctor()
	self._db = Database.new("global")
	self._module = {}

	self._module.MapMaskMgr = MapMaskMgr.new(self)
	self._module.MapBlockMgr = MapBlockMgr.new(self)
	self._module.MapObjectMgr = MapObjectMgr.new(self) --活物管理类
	self._module.MapMarchMgr = MapMarchMgr.new(self, self._module.MapBlockMgr)
	self._module.MapPlayerMgr = MapPlayerMgr.new(self, self._module.MapObjectMgr)
	self._module.MapResourceMgr = MapResourceMgr.new(self, self._module.MapObjectMgr, self._module.MapMarchMgr)
	self._module.MapMonsterMgr = MapMonsterMgr.new(self, self._module.MapObjectMgr)
end

function MapServerMgr:loaddb()
	for k,module in pairs(self._module) do
		module:loaddb()
	end
end

--各模块初始化, (场景活物初始化, 掩码锁定)
function MapServerMgr:init()
	--优先级
	self._module.MapMaskMgr:init()
	self._module.MapBlockMgr:init()
	self._module.MapObjectMgr:init()

	self._module.MapPlayerMgr:init()
	self._module.MapResourceMgr:init()
	self._module.MapMonsterMgr:init()
	self._module.MapMarchMgr:init()
end

--处理场景活物中的异常 
function MapServerMgr:initcomplete()
	--优先级
	self._module.MapPlayerMgr:initcomplete()
	self._module.MapResourceMgr:initcomplete()
	self._module.MapMonsterMgr:initcomplete()
end

function MapServerMgr:run()
	for k,module in pairs(self._module) do
		module:run()
	end
end

function MapServerMgr:get_db()
	return self._db
end

function MapServerMgr:get_serverid()
	return serverconfig.serverid
end

function MapServerMgr:serverquit()
	for k,module in pairs(self._module) do
		module:serverquit()
	end
end

------------------------------模块获取接口----------------------------------
function MapServerMgr:MapBlockMgr()
	return self._module.MapBlockMgr
end
function MapServerMgr:MapObjectMgr()
	return self._module.MapObjectMgr
end
function MapServerMgr:MapMaskMgr()
	return self._module.MapMaskMgr
end

function MapServerMgr:MapPlayerMgr()
	return self._module.MapPlayerMgr
end

function MapServerMgr:MapResourceMgr()
	return self._module.MapResourceMgr
end

function MapServerMgr:MapMonsterMgr()
	return self._module.MapMonsterMgr
end

function MapServerMgr:MapMarchMgr()
	return self._module.MapMarchMgr
end

return MapServerMgr