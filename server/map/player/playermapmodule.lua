local class = require "class"
local clusterext = require "clusterext"

local mapinterface = require "mapinterface"
local mapcommon = require "mapcommon"
local IPlayerModule = require "iplayermodule"
local PlayerMapModule = class("PlayerMapModule", IPlayerModule)

function PlayerMapModule:ctor(player)
	self._player = player

	self._mapcitydata = nil

	self._watchid = nil --当前观察的服务器id
end

function PlayerMapModule:init()
end

function PlayerMapModule:online()
	--请求map服当前城池坐标信息
	local serverid = self._player:playerbasemodule():get_server_id()	
	local playerid = self._player:getplayerid()
	local ret = mapinterface.Call_ReqPlayerCityData(serverid, playerid)
	if not ret then
		LOG_ERROR("map server retpack error, serverid=[%d], playerid=[%d]", serverid, playerid)
		assert(false)
	end

	if ret.code == mapcommon.map_code.success then
		self._mapcitydata = ret.data
	else--在大地图上没有城池信息, 创建 
		--TODOX
		local data = { level = 1, name = self._player:playerbasemodule():get_name(), }
		self._mapcitydata = mapinterface.Call_CreateMapPlayerObject(serverid, playerid, data)
	end

	print("my city data", self._mapcitydata)
end

function PlayerMapModule:offline()
	if self._watchid then
		mapinterface.Cancle_Watch(self._watchid, self._player:getplayerid())
	end
end

function PlayerMapModule:get_playercityxy()
	return self._mapcitydata.x, self._mapcitydata.y
end

--当前观察的服务器ID
function PlayerMapModule:get_watchid()
	return self._watchid
end



return PlayerMapModule