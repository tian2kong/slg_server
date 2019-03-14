local class = require "class"
local mapcommon = require "mapcommon"
local MapBlock = class("MapBlock")

function MapBlock:ctor(blockkey, block_x, block_y, servermgr, blockmgr)
	self._servermgr = servermgr
	self._blockmgr = blockmgr
	self._blockkey = blockkey

	self._x, self._y = mapcommon.blockxyToxy(block_x, block_y)
	self._width, self._height = mapcommon.block_x_offset, mapcommon.block_y_offset
	self._block_x = block_x
	self._block_y = block_y 
	self._aroundblocks = {} --九宫格的格子, 包含自己{ blockobj, blockobj, ... }
	self._observers = {} --观察者
	

	self._allobjectmap = {} --所有活物总列表
	--搜索用到
	self._playerobjmap = {} --玩家主城活物列表
	self._resobjmap = {} --资源活物列表
	self._msobjmap = {} --怪物活物列表

	self._marchmap = {}
end

function MapBlock:add_aroundblockobj(blockkey, blockobj)
	self._aroundblocks[blockkey] = blockobj
end

function MapBlock:get_aroundblocks()
	return self._aroundblocks
end

function MapBlock:get_blockkey()
	return self._blockkey
end

function MapBlock:get_blockxy()
	return self._block_x, self._block_y
end

function MapBlock:register_observer(playerid, addr)
	self._observers[playerid] = addr
end

function MapBlock:unregister_observer(playerid)
	self._observers[playerid] = nil
end

function MapBlock:get_observers()
	return self._observers
end

--活物移除
function MapBlock:remove_obj(object)
	local objectid = object:get_objectid()
	self._allobjectmap[objectid] = nil
	
	local objtype = object:get_objecttype()
	if objtype == mapcommon.MapObjectType.eMOT_Player then
		self._playerobjmap[objectid] = nil
	elseif objtype == mapcommon.MapObjectType.eMOT_Resource then
		for restype,temp in pairs(self._msobjmap) do
			if temp[objectid] then
				self._resobjmap[restype][objectid] = nil

				if table.empty(temp) then
					self._msobjmap[restype] = nil
				end
				break
			end
		end
	elseif objtype == mapcommon.MapObjectType.eMOT_Monster then
		for mstype,temp in pairs(self._msobjmap) do
			if temp[objectid] then
				self._msobjmap[mstype][objectid] = nil

				if table.empty(temp) then
					self._msobjmap[mstype] = nil
				end
				break
			end
		end
	end
end

--活物创建
function MapBlock:insert_obj(object)
	local objectid = object:get_objectid()
	self._allobjectmap[objectid] = object

	local objtype = object:get_objecttype()
	if objtype == mapcommon.MapObjectType.eMOT_Player then
		self._playerobjmap[objectid] = object
	elseif objtype == mapcommon.MapObjectType.eMOT_Resource then
		local restype = object:get_type()
		if not self._resobjmap[restype] then
			self._resobjmap[restype] = {}
		end
		self._resobjmap[restype][objectid] = object
	elseif objtype == mapcommon.MapObjectType.eMOT_Monster then
		local mstype = object:get_type()
		if not self._msobjmap[mstype] then
			self._msobjmap[mstype] = {}
		end
		self._msobjmap[mstype][objectid] = object
	end
end

function MapBlock:get_allobjectmap()
	return self._allobjectmap
end

function MapBlock:insert_mapmarch(marchid, marchobj)
	self._marchmap[marchid] = marchobj
end

function MapBlock:remove_mapmarch(marchid)
	self._marchmap[marchid] = nil
end

function MapBlock:get_marchmap()
	return self._marchmap
end

function MapBlock:search(searchtype, level)
	local t = {}
	local subtype = mapcommon.SearchTypeMappingType[searchtype]
	if searchtype == mapcommon.SearchType.eST_Gas or 
	   searchtype == mapcommon.SearchType.eST_Food or 
	   searchtype == mapcommon.SearchType.eST_Water or 
	   searchtype == mapcommon.SearchType.eST_Cement then 
		if self._resobjmap[subtype] then
			for _,object in pairs(self._resobjmap[subtype]) do
				if object:get_level() == level then
					table.insert(t, object)
				end
			end
		end
	elseif searchtype == mapcommon.SearchType.eST_Zombie then
		if self._msobjmap[subtype] then
			for _,object in pairs(self._msobjmap[subtype]) do
				if object:get_level() == level then
					table.insert(t, object)
				end
			end
		end
	end
	return t
end

return MapBlock