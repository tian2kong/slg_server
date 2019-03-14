local loader = require "common/static_loader"


--重置配置表key
local function reset_static_key(tb, key)
    --无需设置key直接返回
    if key == "" then
        return 
    end
    local temp = {}
    for _,v in pairs(tb) do
        if type(key) == "string" then
            temp[v[key]] = v
        elseif type(key) == "table" then
            local t = temp
            for i=1,#key do
                local k = key[i]
                if i < #key then
                    if not t[v[k]] then
                        t[v[k]] = {}
                    end
                    t = t[v[k]]
                else
                    if type(k) == "string" then
                        t[v[k]] = v
                    elseif k == 0 then
                        t[#t + 1] = v
                    else
                        assert(nil, "unkown key")
                    end
                end
            end
        end
    end
    return temp
end

local _static_config

function init_static_config()
    _static_config = loader(true)
end

function get_static_config()
    return _static_config
end
