local keyword = require "keyword"
local skynet = require "skynet"
local serverconfig = require "serverconfig"
local utf8 = require "utf8_simple"

local common = BuildCommon("common")

common.offline_cache_time = 30 * 60 --离线玩家缓存30分钟
common.cache_time = 10 * 60 --10分钟

common.player_section = 1000000   --服务器玩家角色id区段

--获取服务器自增id初始值
function common.get_server_autoid(section)
    return math.floor(section or common.player_section * serverconfig.serverid)
end

function common.get_player_server(playerid)
    return math.floor(playerid / common.player_section)
end

--
common.APP = "ID10029"
common.AppKey = "bdc96026c4fb2bdbe86cf2c29aaf39c9"

--检测是否有屏蔽词
function common.check_shield_word(str)
    --mysql的utf8字符集只能最多支持3个字节的utf8字符
    --这里检测屏蔽词时 直接屏蔽掉大于3个字节的utf8字符
    local newstr = utf8.strip(str, 3) 
    return string.len(newstr) ~= string.len(str) or keyword.check_shield_word(str)
end

--获取玩家所在db
local playerdb_threshold = 1000000
function common.get_playerdb_index(playerid)
    --[[
    local dbindex = math.floor(playerid / playerdb_threshold)
    return dbindex
    ]]
    return 0
end

--替换字符串为可用
function common.escape_string(str, maxlen)
    maxlen = maxlen or get_static_config().globals.chat_max_content_length
    if string.len(str) > maxlen then
        str = string.sub(str, 1, maxlen)
    end
    return str
end

-- 处理mysql转义字符  
local mysqlEscapeMode = "[%z\'\"\\\26\b\n\r\t]"
local mysqlEscapeReplace = {  
    ['\0']='\\0',  
    ['\''] = '\\\'',  
    ['\"'] = '\\\"',  
    ['\\'] = '\\\\',  
    ['\26'] = '\\Z',
    ['\b'] = '\\b',
    ['\n'] = '\\n',  
    ['\r'] = '\\r',  
    ['\t'] = '\\t',  
    }
-- 处理mysql转义字符 
function common.mysqlEscapeString(s)
    return string.gsub(s, mysqlEscapeMode, mysqlEscapeReplace)
end
--检测是否有mysql转移字符
function common.checkEscapeString(s)
    return string.find(s, mysqlEscapeMode)
end

--返回attr_data的Index
function common.get_attr_index(t)
    local result = {}
    for k,v in pairs(t) do
        local index = get_static_config().attr_data[k].Index
        table.insert(result,  { type = index, value = math.floor(v) })
    end
    return result
end

--取出两个table差异项 以第一个参数为准
local function raw_diffrent(value, value1)
    local ret = false
    if type(value) ~= type(value1) then
        ret = true
    elseif type(value) == "table" then
        if table.size(value) ~= table.size(value1) then
            ret = true
        else
            for k1,v1 in pairs(value) do
                if raw_diffrent(v1, value1[k1]) then
                    ret = true
                    break
                end
            end
        end
    elseif value ~= value1 then
        ret = true
    end
    return ret
end
function common.table_diff(info, cacheinfo)
    local ret = {}
    local temp1 = info
    local temp2 = cacheinfo
    if table.size(cacheinfo) > table.size(info) then
        temp2 = info
        temp1 = cacheinfo
    end
    for k,v in pairs(temp1) do
        if raw_diffrent(temp2[k], v) then
            ret[k] = info[k]
        end
    end
    return ret
end

--筛选回调
function common.callback_param(...)
    local param = { }
    local cbparam = { }
    local temp = param
    local cb = nil
    local t = table.pack(...)
    for i = 1, t.n do
        local v = t[i]
        if type(v) == "function" and not cb then
            cb = v
            temp = cbparam
            param = table.pack(table.unpack(t, 1, i - 1))
            cbparam = table.pack(table.unpack(t, i + 1, t.n))
            break
        end
    end
    if not cb then
        param = t
    end
    return param, cbparam, cb
end

--计算区间
function common.check_interval(info, value)
    if (not info.equal or value == info.equal) and
        (not info.upper or value > info.upper) and
        (not info.lower or value < info.lower) then
        return true
    end
end

--计算距离
function common.distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

--------------------------------------------------------全局函数-------------------------------------------------------------------------------

--注册指令
function register_command(cmdclass, command, response)
    return function (...)
        local func = cmdclass[command]
        if not func or type(func) ~= "function" then
            LOG_ERROR("cmdclass not found function [%s] %s", command, tostring(debug.traceback()))
        else
            local ret = func(cmdclass, ...)
            if response then
                skynet.retpack(ret)
            end
            return ret
        end     
    end
end

return common