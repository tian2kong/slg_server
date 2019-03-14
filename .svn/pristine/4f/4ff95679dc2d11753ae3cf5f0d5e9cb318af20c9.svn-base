local class = require "class"
local random = require "random"
local MapAreaObject = class("MapAreaObject")

function MapAreaObject:ctor(areatype, areaid, x, y, width, height, maskmgr)
	self._maskmgr = maskmgr
	self._areatype = areatype
	self._areaid = areaid
	self._startx = x
	self._starty = y
	self._width = width
	self._height = height

	self._endx = self._startx + self._width - 1
	self._endy = self._starty + self._height - 1

	self._cellnum = width * height

	self._posoutoforder = {}
	self._posoutofindex = 1
end

function MapAreaObject:init()
	self._posoutoforder = {}
	for x=self._startx,self._endx do
		for y=self._starty,self._endy do
			local maskobj = self._maskmgr:get_maskobj(x,y)
			assert(maskobj)
			table.insert(self._posoutoforder, maskobj)
			maskobj:set_areaobj(self)
		end
	end
	self:posoutoforder_again()
end

function MapAreaObject:get_areaid()
	return self._areaid
end

--将池子里的格子打乱
function MapAreaObject:posoutoforder_again()
	self._posoutoforder = random.GetSets(self._posoutoforder)
	self._posoutofindex = 1
end

--获取空格子
function MapAreaObject:get_spacepos(width, height)
	local pairsflag = false
	local max = #self._posoutoforder
	if self._posoutofindex >= max then
		self:posoutoforder_again()
		pairsflag = true
	else
		self._posoutofindex = self._posoutofindex + 1
	end

	while (self._posoutofindex <= max) do 
		local x,y = self._posoutoforder[self._posoutofindex]:get_xy()
		self._posoutofindex = self._posoutofindex + 1

		if not self._maskmgr:check_maskrange(x, y, width, height) then
			return {x, y}
		end 

		--当满足一次全遍历 还是没有合适的空格, 返回nil
		if self._posoutofindex >= max then
			if pairsflag then
				break
			else
				self:posoutoforder_again()
				pairsflag = true
			end
		end
	end

	return nil
end

return MapAreaObject