local class = require "class"
local MapCfgAPI = require "mapcfgapi"
local mapcommon = require "mapcommon"
local MapObjectBase = require "mapobjectbase"
local MapResourceObject = class("MapResourceObject", MapObjectBase)


MapResourceObject.s_table = {
    table_name = "mapresourceobject",
    key_name = "objectid",
    field_name = {
    	"type", --资源类型
    	"level", --资源等级
    	"x",
    	"y",
        "reserves", --储量
        "occupymarchid", --采集中的行军队列
	}
}

function MapResourceObject:ctor(record)
	self._record = record
	self._objecttype = mapcommon.MapObjectType.eMOT_Resource

    self._width = mapcommon.default_width
    self._height = mapcommon.default_height
end

function MapResourceObject:get_objectid()
    return self._record:get_key_value("objectid")
end

function MapResourceObject:get_type()
    return self._record:get_field("type")
end

function MapResourceObject:get_reserves()
    return self._record:get_field("reserves")
end

function MapResourceObject:get_xy()
    return self._record:get_field("x"), self._record:get_field("y")
end

function MapResourceObject:get_range()
    return self._record:get_field("x"), self._record:get_field("y"), self._width, self._height
end

function MapResourceObject:get_level()
    return self._record:get_field("level")
end

function MapResourceObject:get_occupymarchid()
    return self._record:get_field("occupymarchid") or 0
end

function MapResourceObject:set_occupymarchid(v)
    self._record:set_field("occupymarchid", v)
end

function MapResourceObject:set_xy(x, y)
    self._record:set_field("x", x)
    self._record:set_field("y", y)
end

function MapResourceObject:set_type(v)
    self._record:set_field("type", v)
end

function MapResourceObject:set_reserves(v)
    self._record:set_field("reserves", v)
end


function MapResourceObject:set_level(v)
    self._record:set_field("level", v)
end

function MapResourceObject:clear_data()
    self:set_type(mapcommon.TombType)
    self:set_level(0)
    self:set_reserves(0)
    self:set_occupymarchid(0)
    self:set_xy(0, 0)
end

function MapResourceObject:sub_reserves(v)
    local old = self:get_reserves()
    local new = old - v
    if new < 0 then
        new = 0
    end
    self:set_reserves(new)
end

function MapResourceObject:init_data(type, level, x, y, amount)
    self:set_reserves(amount)
    self:set_type(type)
    self:set_level(level)
    self:set_xy(x, y)
end

function MapResourceObject:savedb()
    self._record:asyn_save()
end

function MapResourceObject:on_tomb()
    return self._record:get_field("type") == mapcommon.TombType
end

function MapResourceObject:get_maxreserves()
    return MapCfgAPI.GetResourceMaxReserves(self:get_type(), self:get_level())
end

function MapResourceObject:is_occupy()
    return self:get_occupymarchid() ~= 0
end

return MapResourceObject