local GlobalDataBean = require "globaldatabean"
local timext = require "timext"

----------------------------------------------------缓存服 公共数据----------------------------------------------------------
local CacheGlobalData = class("CacheGlobalData", GlobalDataBean)
function CacheGlobalData:ctor()
    GlobalDataBean.ctor(self)
end

function CacheGlobalData:_field_name()
    return {
        "opensertime",
    }
end

function CacheGlobalData:get_server_time()
    return self:get_field("opensertime")
end

function CacheGlobalData:loaddb()
    GlobalDataBean.loaddb(self)
    local servertime = self:get_field("opensertime")
    if not servertime or servertime == 0 then
        self:set_field("opensertime", timext.current_time())
        self:savedb()
    end
end

return CacheGlobalData