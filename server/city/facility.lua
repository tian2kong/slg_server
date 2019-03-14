local class = require "class"

local Facility = class("Facility")

Facility.facility_tab = {
    table_name = "player_facility",
    key_name = {"playerid", "facilityid"},
    field_name = {
       "type",          --类型
       "level",         --等级
       "origin_x",      --x坐标
       "origin_y",      --x坐标
    },
}

function Facility:ctor(record)
    self._record = record
end

function Facility:get_id()
    return self._record:get_key_value("facilityid")
end

function Facility:get_config()
    return get_static_config().building[self:get_type()][self:get_level()]
end

function Facility:get_type()
    return self._record:get_field("type")
end

function Facility:set_type(_type)
    self._record:set_field("type", _type)
end

function Facility:set_origin(_x, _y)
    self._record:set_field("origin_x", _x)
    self._record:set_field("origin_y", _y)
end

function Facility:set_level(_level)
    self._record:set_field("level", _level)
end

function Facility:get_level()
    return self._record:get_field("level")
end

function Facility:savedb()
    self._record:asyn_save()
end

function Facility:get_origin()
    return {
        x = self._record:get_field("origin_x"),
        y = self._record:get_field("origin_y"),
    }
end

function Facility:get_message_data()
    return {
        id = self:get_id(),
        type = self:get_type(),
        level = self:get_level(),
        pos = self:get_origin(),
    }
end

return Facility