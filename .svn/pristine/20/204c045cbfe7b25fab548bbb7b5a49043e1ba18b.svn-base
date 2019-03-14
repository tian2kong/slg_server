local skynet = require "skynet"
local clusterext = require "clusterext"
local skynetext = require "skynetext"
local interaction = require "interaction"
local cluster_service = require "cluster_service"

local cacheinterface = BuildInterface("cacheinterface")

function cacheinterface.create_player_object(player)
    local obj = {}
    obj.playerid = player:getplayerid()

    local base = player:playerbasemodule()
    obj.name = base:get_name()
    obj.level = base:get_level()
    obj.shape = base:get_shape()
    obj.roleid = base:get_role_id()
    obj.lastname = base:get_lastname()
    obj.language = base:get_language()
	obj.title = player:titlemodule():get_current_title()
    obj.logintime = base:get_login_time()
    return obj
end

--[[
    获取玩家信息  当cb为nil时接口为同步阻塞的，否则为异步回调  可取到的数据为cache_field列表，nil的话默认查询所有的数据
    返回值格式为： 
    return = { id -> { name = name, face = face, shield = shield } }
]]
local cache_field = {
    "name",
    "online",
    "level",
	"title",
    "logintime",
    "shape",
}
function cacheinterface.call_get_player_info(arrid, arrfield)
    if type(arrid) ~= "table" then
        arrid = {arrid}
    end
    if arrfield and type(arrfield) ~= "table" then
        arrfield = { arrfield }
    end
    if table.empty(arrid) then
        return {}
    end
    return clusterext.call(get_cluster_service().cacheservice, "lua", "get_player_info", arrid, arrfield)
end

function cacheinterface.callback_get_player_info(arrid, arrfield, cb, ...)
    if type(arrid) ~= "table" then
        arrid = {arrid}
    end
    if arrfield and type(arrfield) ~= "table" then
        arrfield = { arrfield }
    end
    if cb then
        clusterext.callback(get_cluster_service().cacheservice, "lua", "get_player_info", arrid, arrfield, cb, ...)
    else
        assert(false)
    end
end

function cacheinterface.callback_is_player_name(name, cb, ...)
    clusterext.callback(get_cluster_service().cacheservice, "lua", "is_player_name", name, cb, ...)
end

--模糊查找玩家“matchstr”匹配ID，或者名字，"except_set"剔除该集合玩家
function cacheinterface.callback_search_player(matchstr, except_set, cb, ...)
    if cb then
        clusterext.callback(get_cluster_service().cacheservice, "lua", "search_player", matchstr, except_set, cb, ...)
    else
        assert(false)
    end
end

--查询玩家id
function cacheinterface.call_search_player_by_name(name)
    return clusterext.call(get_cluster_service().cacheservice, "lua", "search_player_by_name", name)
end

--area:玩家的地区， except_set:剔除该集合玩家
function cacheinterface.callback_search_player_lv_area(minlv, maxlv, area, except_set, cb, ...)
    clusterext.callback(get_cluster_service().cacheservice, "lua", "search_player_lv_area", minlv, maxlv, area, except_set, cb, ...)
end

--注册监听玩家信息
function cacheinterface.reg_player_monitor(player, target, arrfield)
    if type(target) ~= "table" then
        target = {target}
    end
    if arrfield and type(arrfield) ~= "table" then
        arrfield = { arrfield }
    end
    local addr = interaction.pack_agent_address(player:getplayerid())
    clusterext.send(get_cluster_service().cacheservice, "lua", "reg_player_monitor", player:getplayerid(), addr, target, arrfield)
end

--反注册注册
function cacheinterface.unreg_player_monitor(player, target, arrfield)
    if type(target) ~= "table" then
        target = {target}
    end
    if arrfield and type(arrfield) ~= "table" then
        arrfield = { arrfield }
    end
    clusterext.send(get_cluster_service().cacheservice, "lua", "unreg_player_monitor", player:getplayerid(), target, arrfield)
end

--无视玩家是否在线的指令请求 （不要频繁调用）  
function cacheinterface.callback_player_command(playerid, _, ...)
    if not playerid then
        LOG_ERROR(tostring(debug.traceback()))
    end
    clusterext.callback(get_cluster_service().cacheservice, "lua", "player_command", true, playerid, ...)
end
function cacheinterface.call_player_command(playerid, _, ...)
    if not playerid then
        LOG_ERROR(tostring(debug.traceback()))
    end
    return clusterext.call(get_cluster_service().cacheservice, "lua", "player_command", true, playerid, ...)
end
function cacheinterface.player_command(playerid, _, ...)
    if not playerid then
        LOG_ERROR(tostring(debug.traceback()))
    end
    clusterext.send(get_cluster_service().cacheservice, "lua", "player_command", false, playerid, ...)
end

--获取玩家伙伴DB数据
function cacheinterface.call_get_player_partner_info(arrid)
    if type(arrid) ~= "table" then
        arrid = {arrid}
    end
    return clusterext.call(get_cluster_service().cacheservice, "lua", "get_player_partner_info", arrid)
end

return cacheinterface