local mapcommon = require "mapcommon"
local clusterext = require "clusterext"
local marchcommon = require "marchcommon"
local mapinterface = BuildInterface("mapinterface")

-------------------------------------------------------
function mapinterface.Call_ReqPlayerCityData(serverid, playerid)
	--支持跨服请求
	--TODOX
	return clusterext.call(get_cluster_service().mapserver, "lua", "req_playercitydata", playerid)
end

function mapinterface.Call_CreateMapPlayerObject(serverid, playerid, data)
	return clusterext.call(get_cluster_service().mapserver, "lua", "req_createmapplayerobj", playerid, data)
end

--取消查看
function mapinterface.Cancle_Watch(serverid, playerid)
	return clusterext.call(get_cluster_service().mapserver, "lua", "cacle_watch", self._player:getplayerid())
end

function mapinterface.CallBack_Player_WatchMap(serverid, playerparam, func)
	clusterext.callback(get_cluster_service().mapserver, "lua", "player_watchmap", playerparam, func)
end

function mapinterface.CallBack_Player_March(marchparam, func)
	clusterext.callback(get_cluster_service().mapserver, "lua", "player_march", marchparam, func)
end

function mapinterface.CallBack_Player_Search(playerid, searchtype, level, index, func)
	clusterext.callback(get_cluster_service().mapserver, "lua", "player_search", playerid, searchtype, level, index, func)
end

function mapinterface.Pack_MapObject_MSG(object)
	local objecttype = object:get_objecttype()
	if objecttype == mapcommon.MapObjectType.eMOT_Player then
		local data = {}
		data.objectid = object:get_objectid()
		data.playerid = object:get_playerid()
		data.level = object:get_level()
		data.name = object:get_name()
		data.x, data.y = object:get_xy()
		return data
	elseif objecttype == mapcommon.MapObjectType.eMOT_Resource then
		local data = {}
		data.objectid = object:get_objectid()	
		data.type = object:get_type()
		data.x, data.y = object:get_xy()
		data.occupymarchid = object:get_occupymarchid()
		return data
	end
	return nil
end

function mapinterface.Pack_MapMarchObject_MSG(marchobj)
	local param = marchobj:get_param()
	local data = {
		marchid 	= marchobj:get_marchid(),
		marchtype	= marchobj:get_marchtype(),
		army		= marchobj:get_army(), 		
		status  	= marchobj:get_status(),  --状态
		endtime 	= marchobj:get_endtime(), --结束时间
		name  		= param.name, --名字就放param里边
		playerid 	= param.playerid,
	}	

	data.pastdistance = marchcommon.CaculateMarchPastDistance(marchobj)
	data.startx, data.starty = marchobj:get_startxy()
	data.endx, data.endy	 = marchobj:get_endxy()
	return data
end

return mapinterface 
