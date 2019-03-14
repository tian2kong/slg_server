local class = require "class"

local mapcommon = require "mapcommon"
local mapmgrbase = require "mapmgrbase"
local MapMaskObject = require "mapmaskobject"
local MapAreaMgr = require "mapareamgr"
local MapMaskMgr = class("MapMaskMgr", mapmgrbase)

local Func_xyToxykey = mapcommon.xyToxykey

function MapMaskMgr:ctor(servermgr)
	self._servermgr = servermgr

	self._masklist = {} --掩码列表 [x][y] -> maskobj
	self._maskhash = {}	--掩码hash [xykey] -> maskobj

	--各级资源带初始化
	self._areamgr = MapAreaMgr.new(servermgr, self)
end

function MapMaskMgr:init()
	self:init_mask()
	self._areamgr:init()
end

function MapMaskMgr:init_mask()
	local Fun_xyToarenatype = mapcommon.xyToarenatype
	for x=1,mapcommon.max_x do
		local ylist = {}
		local key = Func_xyToxykey(x, 0) --放在外层 少了x-1*y次的调用
		for y=1,mapcommon.max_y do
			local xykey = key+y
			local arenatype = Fun_xyToarenatype(x, y)
			local maskobj = MapMaskObject.new(x, y)
			ylist[y] = maskobj
			self._maskhash[xykey] = maskobj
		end
		self._masklist[x] = ylist 
	end
end

function MapMaskMgr:add_dynamicmask(objid, x, y, width, height)
	width = width or 1
	height = height or 1
	for x_index = x, x + width - 1 do
		for y_index = y, y + height - 1 do
			local obj = self:get_maskobj(x_index, y_index)
			if obj then
				obj:mask_dynamic(objid)
			end
		end
	end
end

function MapMaskMgr:remove_dynamicmask(objid, x, y, width, height)
	width = width or 1
	height = height or 1
	for x_index = x, x + width - 1 do
		for y_index = y, y + height - 1 do
			local obj = self:get_maskobj(x_index, y_index)
			if obj then
				obj:unmask_dynamic(objid)
			end
		end
	end
end

function MapMaskMgr:lock_mask(x, y)
	local obj = self:get_maskobj(x, y)
	if obj then
		obj:mask_lock(objid)
	end
end

function MapMaskMgr:unlock_mask(x, y)
	local obj = self:get_maskobj(x, y)
	if obj then
		obj:unmask_lock()
	end
end

function MapMaskMgr:get_objectidbyxy(x, y)
	local obj = self:get_maskobj(x, y)
	local dynamic = obj:get_dynamic()
	if dynamic then
		local objid = next(dynamic)
		return objid
	end
	return nil
end

function MapMaskMgr:get_maskobj(x, y)
	return self._masklist[x] and self._masklist[x][y]
end

function MapMaskMgr:get_areaobj(x, y)
	local obj = self:get_maskobj(x, y)
	if obj then
		return obj:get_areaobj()
	end
end

function MapMaskMgr:check_mask(x, y)
	local obj = self:get_maskobj(x, y)
	if not obj or obj:check() then
		return true
	end
	return false
end

function MapMaskMgr:check_maskrange(x, y, width, height)
	for x_index = x, x + width - 1 do
		for y_index = y, y + height - 1 do
			if self:check_mask(x_index, y_index) then
				return true
			end
		end
	end
	return false
end

--资源带随机一个空的矩形位置
function MapMaskMgr:random_spacepos_byareatype(areatype, width, height)
	width = width or mapcommon.default_width
	height = height or mapcommon.default_height
	return self._areamgr:random_spacepos_byareatype(areatype, width, height)
end

--资源带随机一个空的矩形位置
function MapMaskMgr:random_spacepos_byareaid(areaid, width, height)
	width = width or mapcommon.default_width
	height = height or mapcommon.default_height
	return self._areamgr:random_spacepos_byareaid(areaid, width, height)
end


return MapMaskMgr