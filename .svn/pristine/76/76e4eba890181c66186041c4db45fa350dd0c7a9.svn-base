local class = require "class"
local titlecommon = require "titlecommon"
local Title = class("Title")

Title.s_title_table = {
    table_name = "title",
    key_name = {"playerid", "id"},
    select_where = " where playerid=%d",
    field_name = {
       "time",  --int, 称号到期时间               
       "param", --string=>table
    },
}

function Title:ctor(record)
    self._record = record
    self.param = nil    --需要对 param 做处理的才有
end

function Title:init()
end

function Title:pack_msg()
    local msg = {}
    msg.id = self._record:get_key_value("id")
    msg.time = self:get_field("time")
    msg.param = self:get_param()
    return msg
end

function Title:get_title_id()
    return self._record:get_key_value("id")
end

function Title:get_type()
    local cfg = get_static_config().title_dat[self:get_title_id()]
    if cfg then
        return cfg.Type
    end 
end

function Title:get_param()
    if  self.param then
        return self.param
    end
    return self:get_field("param")
end

-------------------------------------- 数据库操作 ---------------------------------------------------------------
function Title:set_field(k, v)
    self._record:set_field(k, v)
end
function Title:get_field(k)
    return self._record:get_field(k)
end
function Title:savedb()
    self._record:asyn_save()
end
function Title:delete()
    self._record:asyn_delete()
end

return Title

