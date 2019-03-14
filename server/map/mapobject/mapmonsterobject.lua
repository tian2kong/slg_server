local class = require "class"
local mapcommon = require "mapcommon"
local MapObjectBase = require "mapobjectbase"
local MapMonsterObject = class("MapMonsterObject", MapObjectBase)

MapMonsterObject.s_table = {
    table_name = "mapmonsterobject",
    key_name = "objectid",
    field_name = {
    	"type", --怪物类型
    	"level",
    	"x",
    	"y",
	}
}

function MapMonsterObject:ctor(record)
	self._record = record
	self._objecttype = mapcommon.MapObjectType.eMOT_Monster

	self._width = mapcommon.default_width
    self._height = mapcommon.default_height
end

function MapMonsterObject:get_objectid()
	return self._record:get_key_value("objectid")
end

function MapMonsterObject:get_type()
    return self._record:get_field("type")
end


function MapMonsterObject:get_range()
	return self._record:get_field("x"), self._record:get_field("y"), self._width, self._height
end

function MapMonsterObject:get_xy()
    return self._record:get_field("x"), self._record:get_field("y")
end

function MapMonsterObject:get_level()
	return self._record:get_field("level")
end

function MapMonsterObject:set_xy(x, y)
    self._record:set_field("x", x)
    self._record:set_field("y", y)
end

function MapMonsterObject:set_type(v)
    self._record:set_field("type", v)
end

function MapMonsterObject:set_level(v)
    self._record:set_field("level", v)
end

function MapMonsterObject:clear_data()
    self:set_type(mapcommon.TombType)
    self:set_level(0)
    self:set_xy(0, 0)
end

function MapMonsterObject:init_data(type, level, x, y)
    self:set_type(type)
    self:set_level(level)
    self:set_xy(x, y)
end

function MapMonsterObject:savedb()
    self._record:asyn_save()
end

function MapMonsterObject:on_tomb()
    return self._record:get_field("type") == mapcommon.TombType
end

return MapMonsterObject