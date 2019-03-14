local class = require "class"
local skynet = require "skynet"
local mapcommon = require "mapcommon"
local mapblock = require "mapblock"
local mapmgrbase = require "mapmgrbase"
local mapinterface = require "mapinterface"
local interaction = require "interaction"
local timext = require "timext"
local common = require "common"
local MapBlockMgr = class("MapBlockMgr", mapmgrbase)

local pairs = pairs

function MapBlockMgr:ctor(servermgr)
	self._servermgr = servermgr
	self._blockmap = {}
	self._blockrect = {}

	self._observermap = {} --[[
		playerid -> {
			addr, x, y, blockkey,	
		},
	]]


	self._playersearch = {} --[[{
		[playerid]-> { 
			x, y, searchtype, expire, level, searchresult
		}
	}]]
end

function MapBlockMgr:loaddb()
end

function MapBlockMgr:init()
	self:init_blockmap()
end

function MapBlockMgr:init_blockmap()
	local begint = skynet.now()	

	local x_offset = mapcommon.block_x_offset
	local y_offset = mapcommon.block_y_offset
	local Func_ToBlockKey = mapcommon.blockxyToblockkey
	for block_x=1,mapcommon.block_x_num do
		self._blockrect[block_x] = {}
		for block_y=1,mapcommon.block_y_num do
			local blockkey = Func_ToBlockKey(block_x, block_y)
			local blockobj = mapblock.new(blockkey, block_x, block_y, self.servermgr, self)
			self._blockmap[blockkey] = blockobj
			self._blockrect[block_x][block_y] = blockobj
		end		
	end


	--记录每个格子中九宫格范围的所有格子(包含自己)
	local Func_getaroundpos = mapcommon.getaroundpos
	for blockkey,blockobj in pairs(self._blockmap) do
		local block_x, block_y = blockobj:get_blockxy()
		local pos_set = Func_getaroundpos(block_x, block_y)
		for k,pos in pairs(pos_set) do
			local blockkey = Func_ToBlockKey(pos[1], pos[2])
			local obj = self._blockmap[blockkey]
			if obj then
				blockobj:add_aroundblockobj(blockkey, obj)
			end
		end
	end	

	local endt = skynet.now()	
	LOG_ERROR("block mgr init time = [%d]", endt - begint)
end

function MapBlockMgr:get_blockobj(blockkey)
	return self._blockmap[blockkey]
end

function MapBlockMgr:get_blockobjbyblockxy(bx, by)
	if self._blockrect[bx] then
		return self._blockrect[bx][by]
	end
end

function MapBlockMgr:insert_mapobject(blockkey, object)
	local blockobj = self:get_blockobj(blockkey)
	if blockobj then
		blockobj:insert_obj(object)
	else
		LOG_ERROR("insert blockobj no find, blockkey=[%d], objid=[%d]", blockkcey, object:get_objectid())
	end
end

function MapBlockMgr:remove_mapobject(blockkey, object)
	local blockobj = self:get_blockobj(blockkey)
	if blockobj then
		blockobj:remove_obj(object)
	else
		LOG_ERROR("remove blockobj no find, blockkey=[%d], objid=[%d]", blockkcey, object:get_objectid())
	end
end

function MapBlockMgr:insert_observerplayer(blockkey, playerid, addr)
	local blockobj = self:get_blockobj(blockkey)
	if blockobj then
		blockobj:register_observer(playerid, addr)
	end
end

function MapBlockMgr:remove_observerplayer(blockkey, playerid)
	local blockobj = self:get_blockobj(blockkey)
	if blockobj then
		blockobj:unregister_observer(playerid)
	end
end

function MapBlockMgr:handle_playerwatch(playerparam)
	local playerid = playerparam.playerid
	local ob = self._observermap[playerid]
	if not ob then
		ob = {}
		self._observermap[playerid] = ob
	end

	ob.addr = playerparam.addr
	ob.x, ob.y = playerparam.x, playerparam.y
	local newblockkey = mapcommon.xyToblockkey(playerparam.x, playerparam.y)
	local blockobj = self:get_blockobj(newblockkey)
	if not blockobj then--检测下是否有这个blockobj
		LOG_ERROR("blockobj no find playerid=[%d],x=[%d],y=[%d]", playerid, playerparam.x, playerparam.y)
		return
	end

	local oldblockkey = ob.blockkey
	if oldblockkey and newblockkey ~= oldblockkey then
		self:remove_observerplayer(oldblockkey, playerid)
	end
	self:insert_observerplayer(newblockkey, playerid, addr)
	ob.blockkey = newblockkey

	-------------------------
	--打包地图详情
	local mapmsglist = {}
	mapmsglist.mapobjectlist = {} --活物队列
	mapmsglist.marchobjectlist = {} --行军队列
	for k,blockobj in pairs(blockobj:get_aroundblocks()) do
		for _,mapobject in pairs(blockobj:get_allobjectmap()) do
			local objtype = mapobject:get_objecttype()
			if not mapmsglist.mapobjectlist[objtype] then
 				mapmsglist.mapobjectlist[objtype] = {}
			end
			table.insert(mapmsglist.mapobjectlist[objtype], mapinterface.Pack_MapObject_MSG(mapobject))
		end

		for _,marchobject in pairs(blockobj:get_marchmap()) do
			table.insert(mapmsglist.marchobjectlist, mapinterface.Pack_MapMarchObject_MSG(marchobject))
		end
	end

	print("mapmsglist ..", mapmsglist)
	return mapmsglist
end

function MapBlockMgr:handle_canclewatch(playerid)
	local ob = self._observermap[playerid]
	if ob then
		self:remove_observerplayer(ob.blockkey)
		self._observermap[playerid] = nil
	end
end

--广播指定部分的block
function MapBlockMgr:broadcast_partblock(blockobjmap, ...)
	local syngroup = {}
	for _,blockobj in pairs(blockobjmap) do
		for plyid,addr in pairs(blockobj:get_observers()) do
			syngroup[plyid] = addr
		end
	end

	if not table.empty(syngroup) then
		interaction.send_to_group(syngroup, "lua", ...)
	end
end

function MapBlockMgr:sync_mapobjectchange(object)
	local blockobj = self:get_blockobj(object:get_blockkey())
	local protoname = mapcommon.ObjectProto[object:get_objecttype()]
	if protoname and blockobj then
		local objdata = mapinterface.Pack_MapObject_MSG(object)
		self:broadcast_partblock(blockobj:get_aroundblocks(), "send2client", protoname, { 
			serverid = self._servermgr:get_serverid(),
			objlist = { objdata },
		 })
	end
end

function MapBlockMgr:sync_removemapobject(object)
	local blockobj = self:get_blockobj(object:get_blockkey())
	if blockobj then
		self:broadcast_partblock(blockobj:get_aroundblocks(), "send2client", mapcommon.MapObjRemoveProto, { 
			serverid = self._servermgr:get_serverid(),
			objectid = object:get_objectid(),
		 })
	end
end

--行军同步(这里pairs较多)
function MapBlockMgr:sync_mapmarchobject(marchobject)
	--每个经过的格子周围的九宫格都同步
	local blockobjmap = {}
	for k, blockobj in pairs(marchobject:get_marchblockset()) do
		for key,obj in pairs(blockobj:get_aroundblocks()) do
			blockobjmap[key] = obj
		end
	end

	local objdata = mapinterface.Pack_MapMarchObject_MSG(marchobject)
	self:broadcast_partblock(blockobjmap, "send2client", mapcommon.MarchListProto, { 
			serverid = self._servermgr:get_serverid(),
			objlist = { objdata },
		 })
end

--
function MapBlockMgr:sync_removemapmarchobj(marchobject)
	--每个经过的格子周围的九宫格都同步
	local blockobjmap = {}
	for k, blockobj in pairs(marchobject:get_marchblockset()) do
		for key,obj in pairs(blockobj:get_aroundblocks()) do
			blockobjmap[key] = obj
		end
	end

	self:broadcast_partblock(blockobjmap, "send2client", mapcommon.MarchRemoveProto, { 
			serverid = self._servermgr:get_serverid(),
			marchid = marchobject:get_marchid(),
		 })
end

function MapBlockMgr:create_search(playerid, x, y, index, searchtype, level, expire)
	local search = {
		x = x,
		y = y,
		level = level,
		expire = expire,
		searchtype = searchtype,
	}

	local searchresult = {}
	local bx, by = mapcommon.xyToblockxy(x, y)
	local blockset = mapcommon.getaroundpos(bx, by, mapcommon.search_blockoffset) 
	for _,pos in pairs(blockset) do
		local blockobj = self:get_blockobjbyblockxy(pos[1], pos[2])
		if blockobj then
			local objectmap = blockobj:search(searchtype, level)
			for _, object in pairs(objectmap) do
				table.insert(searchresult, object)
			end
		end
	end	

	--距离排序
	table.sort(searchresult, function(obj1, obj2)
		local x1, y1 = obj1:get_xy()
		local x2, y2 = obj2:get_xy()
		return common.distance(x, y, x1, y1) < common.distance(x, y, x2, y2)
	end)
	search.searchresult = searchresult
	self._playersearch[playerid] = search
	return search
end


local Filter_Searchtype = { --需要过滤的搜索类型
	[mapcommon.SearchType.eST_Gas] = true,
	[mapcommon.SearchType.eST_Food] = true,
	[mapcommon.SearchType.eST_Water] = true,
	[mapcommon.SearchType.eST_Cement] = true,
}
function MapBlockMgr:search_object(playerid, x, y, searchtype, level, index)
	local search = self._playersearch[playerid]
	local curtime = timext.current_time()
	if index <= 1 or --从新开始搜索
	   not search or 
	   search.x ~= x or
	   search.y ~= y or
	   search.searchtype ~= searchtype or 
	   search.level ~= level or 
	   search.expire < curtime then
		search = self:create_search(playerid, x, y, index, searchtype, level, curtime + mapcommon.search_expiretm)
	end
	
	if Filter_Searchtype[searchtype] then 
		local MapResourceMgr = self._servermgr:MapResourceMgr()
		for i=#search.searchresult,1, -1 do --过滤掉已被占领的资源, 每次创建搜索, 资源状态有可能改变
			local object = search.searchresult[i]
			if MapResourceMgr:get_occupymarchobj(object) then --排除非空闲资源
				table.remove(search.searchresult[i], i)
			end
		end		   
	end
	
	local count = #search.searchresult
	if count == 0 then
		return nil, count
	end

	if index > count then
		index = count
	end	
	return search.searchresult[index], count
end

return MapBlockMgr