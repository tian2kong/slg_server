local class = require "class"
local random = require "random"
local mapcommon = require "mapcommon"
local MapAreaObject = require "mapareaobject"
local MapAreaMgr = class("MapAreaMgr")

function MapAreaMgr:ctor(servermgr, maskmgr)
	self._servermgr = servermgr
	self._maskmgr = maskmgr
	self._allareamap = {} --所有区域

	self._areamap = {} --各级区域 [areatype]->{}
end

function MapAreaMgr:init()
	self._areaobject = {}
	for _,areatype in pairs(mapcommon.MapAreaType) do
		self._areamap[areatype] = {}
	end


	local areacfg = get_static_config().resourcearea
	for areaid, cfg in pairs(areacfg) do
		local areatype = cfg.Type
		local areaobj = MapAreaObject.new(areatype, areaid, cfg.Origin[1], cfg.Origin[2], cfg.Origin[3], cfg.Origin[4], self._maskmgr)
		areaobj:init()

		self._allareamap[areaid] = areaobj
		self._areamap[areatype][areaid] = areaobj
	end
end

--指定资源带取一个空格子
function MapAreaMgr:random_spacepos_byareatype(areatype, width, height)
	local areaset = table.indices(self._areamap[areatype])
	while(not table.empty(areaset)) do
		local index = random.Get(1, #areaset)
		local pos = self._allareamap[areaset[index]]:get_spacepos(width, height)
		if pos then
			return pos
		else
			table.remove(areaset, index)
		end
	end

	--该资源区没有空地
	return nil
end

--指定区域抽取一个空格子
function MapAreaMgr:random_spacepos_byareaid(areaid, width, height)
	return self._allareamap[areaid]:get_spacepos(width, height)
end

return MapAreaMgr