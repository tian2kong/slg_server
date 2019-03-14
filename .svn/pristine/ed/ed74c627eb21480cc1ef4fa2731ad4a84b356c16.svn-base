local class = require "class"

local mapcommon = require "mapcommon"
local MapObjectBase = require "mapobjectbase"
local MapPlayerObject = class("MapPlayerObject", MapObjectBase)


MapPlayerObject.s_table = {
    table_name = "mapplayerobject",
    key_name = "objectid",
    field_name = {
    	"playerid", 
    	"name",
    	"level",
    	"x",
    	"y",
	}
}

function MapPlayerObject:ctor(record)
	self._objecttype = mapcommon.MapObjectType.eMOT_Player
	self._record = record
	
	self._width = mapcommon.playercity_width  
	self._height = mapcommon.playercity_height

	self._lockmarchmap = {} --锁定该城池的行军
end

function MapPlayerObject:get_objectid()
	return self._record:get_key_value("objectid")
end

function MapPlayerObject:get_playerid()
	return self._record:get_field("playerid")
end

function MapPlayerObject:get_xy()
	return self._record:get_field("x"), self._record:get_field("y")
end

function MapPlayerObject:get_range()
	return self._record:get_field("x"), self._record:get_field("y"), self._width, self._height
end

function MapPlayerObject:get_level()
	return self._record:get_field("level")
end

function MapPlayerObject:get_name()
	return self._record:get_field("name")
end

function MapPlayerObject:set_xy(x, y)
	self._record:set_field("x", x)
	self._record:set_field("y", y)
end

function MapPlayerObject:set_name(name)
	self._record:set_field("name", name)
end

function MapPlayerObject:set_level(level)
	self._record:set_field("level", level)
end

function MapPlayerObject:set_playerid(playerid)
	self._record:set_field("playerid", playerid)
end

function MapPlayerObject:savedb()
	self._record:asyn_save()
end

return MapPlayerObject