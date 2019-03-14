--local scenecommon = require "scenecommon"
local gmcommon = require "gmcommon"

local function deserialize_config(t, field, sep1, sep2)
    for _,t1 in pairs(t) do
        local str = t1[field]
        if not str then
            
        elseif type(str) ~= "string" then
            t1[field] = { t1[field] }
        else
            t1[field] = {}
            local t2 = string.split(str, sep1)
            for i=1,#t2 do
                local temp = t2[i]
                if sep2 then
                    local t3 = string.split(temp, sep2)
                    if t3 then
                        if #t3 == 2 then
                            t1[field][tonumber(t3[1])] = tonumber(t3[2])
                        end
                    end
                else 
                    table.insert(t1[field], tonumber(temp))
                end
            end
        end
    end
end

--重置配置表key
local function reset_static_key(tb, key)
    --无需设置key直接返回
    if key == "" then
        return 
    end
    local temp = {}
    for _,v in ipairs(tb) do
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
                        local id = #t + 1
                        t[id] = v
                        v._static_key = id
                    else
                        assert(nil, "unkown key")
                    end
                end
            end
        end
    end
    return temp
end

local function load_config_table(cfgname)
    local name = "static/" .. cfgname .. ".lua"
    local file = io.open(name, "rb")
	if not file then
        if LOG_ERROR then
	        LOG_ERROR("config error: Can't open " .. name)
        end
        return 
	end
	local source = file:read "*a"
	file:close()

    local f, err = load(source, "load_config", "t")
    if not f then
        if LOG_ERROR then
            LOG_ERROR("config error: load file[" .. name .. "] error \n " .. err)
        end
    end
    return f()
end

local function load_config(_robotflag)
    local static = {}
    local function load_func(name, t)
        static[name] = t
    end
    do--
        local t = load_config_table("globals")
        local temp = t.Add_queueitem 
        t.Add_queueitem = {}
        for _,key in pairs(temp) do
            t.Add_queueitem[key] = true
        end
        load_func("globals", t)
    end
    do--[[
        local t = load_config_table("datatext_event")
        t = reset_static_key(t, {"action_id"})
        load_func("datatext_event", t)
        ]]
    end
    do--
        local t = load_config_table("build_unlockbase")
        t = reset_static_key(t, {"Base_id"})
        load_func("build_unlockbase", t)
    end
    do--
        local t = load_config_table("speedup_price")
        load_func("speedup_price", t)
    end
    do--
        local t = load_config_table("build_num")
        t = reset_static_key(t, {"Buildtype"})
        load_func("build_num", t)
    end
    do--
        local t = load_config_table("building")
        t = reset_static_key(t, {"Build_type", "Level"})
        load_func("building", t)
    end
    do
        local t = load_config_table("item")
        t = reset_static_key(t, {"id"})
        load_func("item", t)
    end
    do--[[
        local t = load_config_table("server_lv")
        load_func("server_lv", t)
        local temp = reset_static_key(t, { "level" })
        load_func("server_lv_ext", temp)
        ]]
    end 
    do--[[
        local t = load_config_table("server_lv_bonus")
        load_func("server_lv_bonus", t)
        ]]
    end
    do--[[
        if not _robotflag then
            local timext = require "timext"
            local t = load_config_table("shop_item")
            t =  reset_static_key(t, {"key"})
            for k,v in pairs(t) do
                if v.limitbegintime then
                    v.limitbegintime = timext.from_unix_time_stamp(v.limitbegintime)
                end
                if v.limitendtime then
                    v.limitendtime = timext.from_unix_time_stamp(v.limitendtime)
                end
            end
            load_func("shop_item", t)
        end
        ]]
    end



    ----------------------------------SLG配置--------------------------
    do
        local t = load_config_table("resourcearea")
        t = reset_static_key(t, {"AreaID"})
        load_func("resourcearea", t)
    end
    do
        local t = load_config_table("objectrefresh")
        t = reset_static_key(t, {"AreaID"})
        load_func("objectrefresh", t)
    end

    return static
end

return load_config