local class = require "class"
local mapcommon = require "mapcommon"

local MapObjectBase = class("MapObjectBase")

--活物基类
function MapObjectBase:ctor()
	self._objecttype = nil --mapcommon.MapObjectType
end

function MapObjectBase:get_objectid()
	assert(false)
end

function MapObjectBase:get_objecttype()
	return self._objecttype
end

function MapObjectBase:get_xy()
	assert(false)
end

function MapObjectBase:get_blockkey()
	return mapcommon.xyToblockkey(self:get_xy())
end

return MapObjectBase