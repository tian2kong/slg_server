local client_request =  require "client_request"

local common = require "common"
local marchcommon = require "marchcommon"
local mapcommon = require "mapcommon"
local mapinterface = require "mapinterface"

local mapcode = mapcommon.map_code
function client_request.reqmapinfo(player, msg)
	--观察者注册, 同步地图信息

	local module = player:mapmodule()
	repeat
		--TODOX
		--验证serverid 合法性
		if false then
		end

		--验证x,y合法性
		if false then
		end


		local playerid = player:getplayerid()
		local watchid = module:get_watchid() 
		if watchid and watchid ~= msg.serverid then
			mapinterface.Cancle_Watch(watchid, playerid)
		end

		local playerparam = {
			x = msg.x,
			y = msg.y,
			playerid = playerid,
			addr = player:get_address(),
		}
		mapinterface.CallBack_Player_WatchMap(msg.serverid, playerparam, function(retmsg)
			if not retmsg then
				return
			end

			for objtype,msglist in pairs(retmsg.mapobjectlist) do
				local protoname = mapcommon.ObjectProto[objtype]
				if protoname then
					player:send_request(protoname, { serverid = msg.serverid, objlist = msglist })
				end
			end

			if not table.empty(retmsg.marchobjectlist) then
				player:send_request(mapcommon.MarchListProto, { serverid = msg.serverid, objlist = retmsg.marchobjectlist })
			end
		end)
	until 0;
end


function client_request.reqmarch(player, msg)
	local code = mapcode.unknow
	local module = player:mapmodule()
	repeat
		--TODOX
		--验证marchtype
		if not table.find(marchcommon.MarchType, msg.marchtype) then
			code = mapcode.errorparam
			break
		end
		--验证x,y合法性
		if false then
		end
		--队列合法性验证
		if false then
		end
		--军队验证 操作
		if false then
		end
		--目前不支持跨服行军

		local startx, starty = module:get_playercityxy() 
		if not startx or not starty then  --异步问题.玩家迁城导致起始坐标错误 考虑容错 TODOX
			code = mapcode.nocitydata
			break
		end

		local endx, endy = msg.x, msg.y
		local marchparam = {
			marchtype = msg.marchtype,
			endx = endx,
			endy = endy,
			startx = startx,
			starty = starty,
		}

		local initspeed = 10 --初始速度, 模块有加成 --TODOX
		marchparam.param = {
			playerid = player:getplayerid(),
			name = player:playerbasemodule():get_name(),
			
			initspeed  = initspeed, --初始速度, 模块有加成 --TODOX
			marchspeed = initspeed, --当前行军速度
			maxweight = 10000, --行军负重上限
			collectrate = 1000, --采集速率
			distance =  math.floor(common.distance(startx, starty, endx, endy)),
		}
		
		mapinterface.CallBack_Player_March(marchparam, function(ret)
			print("march return ....", ret)
			if not ret then
			end

			if ret.code == mapcode.success and ret.marchdata then
				--TODOX			

			end
		end)
	until 0;
end


function client_request.reqsearchmap(player, msg)
	local code = mapcode.unknow
	local module = player:mapmodule()
	repeat
		if not table.find(mapcommon.SearchType, msg.searchtype) then
			code = mapcode.errorparam
			break
		end

		--搜索等级区间验证
		local lvrange = mapcommon.SearchLevelRange[msg.searchtype]
		if not lvrange or msg.level < lvrange[1] or msg.level > lvrange[2] then
			code = mapcode.errorparam
			break
		end

		local param = {
			index = msg.index,
			playerid = player:getplayerid(),
			searchtype = msg.searchtype,
			level = msg.level,
		}
		mapinterface.CallBack_Player_Search(player:getplayerid(), msg.searchtype, msg.level, msg.index, function(ret)
			player:send_request("retsearchresult", ret)
		end)
		code = mapcode.success
	until 0;
	if code ~= mapcode.success then
		player:send_request("retsearchresult", { code = code })
	end	
end