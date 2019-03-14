local class = require "class"
local Database = require "database"
local interaction = require "interaction"
local timext = require "timext"
local clusterext = require "clusterext"
local mailinterface = require "mailinterface"

--全局信息表
local s_global_table = {
    table_name = "globaldata",
    key_name = {"id"},
}

----------------------------------------------基类--------------------------------------------------------------
local GlobalDataBean = class("GlobalDataBean")
function GlobalDataBean:ctor()
    self._db = Database.new("global")
    self._record = nil
end

function GlobalDataBean:_field_name()
    assert(nil, "please inherit this function")
end

function GlobalDataBean:loaddb()
    self._record = self._db:create_record(s_global_table.table_name, s_global_table.key_name, self:_field_name(), 0)
    self._record:syn_select()
end

function GlobalDataBean:get_field(k)
    return self._record:get_field(k)
end

function GlobalDataBean:set_field(k, v)
    self._record:set_field(k, v)
end

function GlobalDataBean:savedb(bsyn)
    if bsyn then
        self._record:syn_save()
    else
        self._record:asyn_save()
    end
end

return GlobalDataBean