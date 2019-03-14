local sharedata = require "sharedata"
local Random = require "random"

local _static_config = {}

local static_pairs = {}

setmetatable(_static_config, { __index = function(t, k)
    t[k] = sharedata.query(static_pairs[k])
    return t[k]
end })

--static_pairs.datatext_event = "datatext_event"
static_pairs.globals = "globals"
--static_pairs.server_lv = "server_lv"
--static_pairs.server_lv_ext = "server_lv_ext"
--static_pairs.server_lv_bonus = "server_lv_bonus"
--static_pairs.shop_item = "shop_item"
static_pairs.item = "item"
static_pairs.build_unlockbase = "build_unlockbase"
static_pairs.building = "building"
static_pairs.build_num = "build_num"
static_pairs.speedup_price = "speedup_price"


------------------------------SLG配置--------------------------
static_pairs.resourcearea = "resourcearea"
static_pairs.objectrefresh = "objectrefresh"



function init_static_config()
    _static_config = {}
    for k,v in pairs(static_pairs) do
        local ok, err = xpcall(sharedata.query, debug.traceback, v)
        if not ok then
            LOG_ERROR("unkown static[%s] error[%s]", v, err)
        end
        _static_config[k] = err
    end
end

function get_static_config()
    --[[
    if not _static_config then
        init_static_config()
    end
    ]]
    return _static_config
end

local static_func_pairs = {
    globals = {},
}
local _static_func = {}
do
    for k,v in pairs(static_func_pairs) do
        _static_func[k] = {}
    end
end
function get_config_func(cfg, tbname, fieldname)
    local func, err
    local str = cfg[fieldname]
    if str and type(str) == "string" then
        local temp = _static_func[tbname]
        local key = static_func_pairs[tbname]
        if not temp or not key then
            assert(nil, string.format("unkown config[%s] function", tbname))
        end
        local num = #key
        for i=1,num do
            local k = key[i]
            local v = cfg[k]
            temp[v] = temp[v] or {}
            temp = temp[v]
        end
        func = temp[fieldname]
        if not func then
            func, err = load(str, "static_func", "t")
            if not func then
                LOG_ERROR("get_config_func %s, error: %s", str, err)
            end
            func = func()
            temp[fieldname] = func
        end
    end
    return func
end

