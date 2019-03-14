local class = require "class"

local mapcommon = require "mapcommon"
local MapMaskObject = class("MapMaskObject")
local isemptytable = table.empty

function MapMaskObject:ctor(x, y)
	self._x = x
	self._y = y
	self._static = nil --静态掩码
	self._dynamic = nil
	self._lock = nil	

	self._areaobj = nil
end

function MapMaskObject:set_areaobj(areaobj)
	if self._areaobj then
		LOG_ERROR("area cfg error , maskobj overlap")
		assert(false)
	end
	self._areaobj = areaobj
end

function MapMaskObject:get_areaobj()
	return self._areaobj
end

function MapMaskObject:get_xykey()
	return self._xykey
end

function MapMaskObject:mask_static()
	self._static = true
end

function MapMaskObject:unmask_static()
	self._static = nil
end

function MapMaskObject:mask_lock()
	self._lock = true
end

function MapMaskObject:unmask_lock()
	self._lock = nil
end

function MapMaskObject:get_xy()
	return self._x, self._y
end

function MapMaskObject:mask_dynamic(objid)
	self._dynamic = self._dynamic or {}
	self._dynamic[objid] = true
end

function MapMaskObject:get_dynamic()
	return self._dynamic
end

function MapMaskObject:unmask_dynamic(objid)
	if self._dynamic then
		self._dynamic[objid] = nil
		if isemptytable(self._dynamic) then
			self._dynamic = nil
		end
	end
end

--检测是否有掩码
function MapMaskObject:check()
	return self._static or self._dynamic or self._lock
end

return MapMaskObject
