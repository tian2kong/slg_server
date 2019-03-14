local class = require "class"
local mapcommon = require "mapcommon"
local timext = require "timext"

local MapMarchObject = class("MapMarchObject")

MapMarchObject.s_table = {
	table_name = "mapmarch",
    key_name = "marchid",
    field_name = {
		"marchtype",--行军类型
		"status", --行军状态
    	"startx",
    	"starty",
    	"endx",
    	"endy",
    	"starttime", --起始时间
        "endtime", --结束时间
        "param", --参数
        "marchnode",
        "collectnode", 
	}
}

function MapMarchObject:ctor(record)
	self._record = record
	self._blockset = {} --{[blockkey]=blockobj }

	self._army = {}
    self._param = {}
    self._collectnode = {}
    self._marchnode = {}
end

function MapMarchObject:loaddb()
    self:decode_army()
    self:decode_param()
    self:decode_marchnode()
    self:decode_collectnode()
end

function MapMarchObject:decode_army()
    self._army = table.decode(self._record:get_field("army"))
end

function MapMarchObject:encode_army()
    self._record:set_field("army", table.encode(self._army))
end

function MapMarchObject:decode_param()
    self._param = table.decode(self._record:get_field("param"))
end

function MapMarchObject:decode_marchnode()
    self._marchnode = table.decode(self._record:get_field("marchnode"))
end

function MapMarchObject:decode_collectnode()
    self._collectnode = table.decode(self._record:get_field("collectnode"))
end

function MapMarchObject:encode_param()
    self._record:set_field("param", table.encode(self._param))
end

function MapMarchObject:encode_marchnode()
    self._record:set_field("marchnode", table.encode(self._marchnode))
end

function MapMarchObject:encode_collectnode()
    self._record:set_field("collectnode", table.encode(self._collectnode))
end


function MapMarchObject:get_marchblockset()
	return self._blockset
end

function MapMarchObject:insert_block(blockkey, blockobj)
    self._blockset[blockkey] = blockobj
end

function MapMarchObject:clear_block()
    self._blockset = {}
end

function MapMarchObject:get_marchid()
	return self._record:get_key_value("marchid")
end

function MapMarchObject:get_marchtype()
    return self._record:get_field("marchtype")
end

function MapMarchObject:get_startxy()
    return self._record:get_field("startx"), self._record:get_field("starty")
end

function MapMarchObject:get_endxy()
    return self._record:get_field("endx"), self._record:get_field("endy")
end

function MapMarchObject:get_starttime( ... )
    return self._record:get_field("starttime")
end

function MapMarchObject:get_endtime()
    return self._record:get_field("endtime")
end

function MapMarchObject:get_status()
    return self._record:get_field("status")
end

function MapMarchObject:get_param()
    return self._param
end

function MapMarchObject:get_army()
    return self._army
end

function MapMarchObject:savedb()
	self._record:asyn_save()
end

function MapMarchObject:deletedb()
    self._record:asyn_delete()
end

function MapMarchObject:set_startxy(startx,starty)
    self._record:set_field("startx", startx)
    self._record:set_field("starty", starty)
end

function MapMarchObject:set_endxy(endx,endy)
    self._record:set_field("endx", endx)
    self._record:set_field("endy", endy)
end

function MapMarchObject:set_status(status)
    self._record:set_field("status", status)
end

function MapMarchObject:set_endtime(endtime)
    self._record:set_field("endtime", endtime)
end

function MapMarchObject:set_starttime(starttime)
    self._record:set_field("starttime", starttime)
end

function MapMarchObject:set_army(army)
	self._army = army or {}
    self:encode_army()
end 

function MapMarchObject:set_param(param)
    self._param = param or {}
    self:encode_param()
end

function MapMarchObject:create(dbdata)
	for fieldname, value in pairs(dbdata) do
		self._record:set_field(fieldname, value)
	end	

    self._marchnode = {}
    self._collectnode = {}
end

function MapMarchObject:walklogic()
    self._record:set_field("remaintime", self._record:get_field("remaintime") - 1)
end

function MapMarchObject:get_playerid()
    return self._param.playerid
end

-------------------行军速度相关----------------
function MapMarchObject:get_initspeed()
    return self._param.initspeed
end

function MapMarchObject:get_marchspeed()
    return self._param.marchspeed
end

function MapMarchObject:set_marchspeed(marchspeed)
    self._param.marchspeed = marchspeed
end

function MapMarchObject:get_distance()
    return self._param.distance
end

--获取行军节点
function MapMarchObject:get_marchnode()
    return self._marchnode[1] or 0, self._marchnode[2] or timext.current_time()
end

--
function MapMarchObject:update_marchnode(distance, time)
    self._marchnode[1] = distance
    self._marchnode[2] = time
    self:encode_marchnode()
end

--获取剩余行军路程
function MapMarchObject:get_lastdistance()
    self:get_distance()
end

function MapMarchObject:clear_marchnode()
    self._marchnode = {}
end

--------------------采集相关-------------------
--获取采集速率
function MapMarchObject:get_collectrate()
    return self._param.collectrate or 1
end

--获取负重上限
function MapMarchObject:get_maxweight()
    return self._param.maxweight or 1
end

--获取采集节点
function MapMarchObject:get_collectnode()
    return self:get_collectnum(), self:get_lastcollectcaltime()
end


--获取已采集资源量
function MapMarchObject:get_collectnum()
    return self._collectnode[1] or 0
end

--获取上次采集结算时间
function MapMarchObject:get_lastcollectcaltime()
    return self._collectnode[2] or timext.current_time()
end

--更新采集节点
function MapMarchObject:update_collectnode(collectnum, time)
    self._collectnode[1] = collectnum
    self._collectnode[2] = time
    self:encode_collectnode()
end

return MapMarchObject