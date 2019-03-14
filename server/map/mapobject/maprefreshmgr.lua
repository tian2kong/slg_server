local class = require "class"
local mapcommon = require "mapcommon"
local MapCfgAPI = require "mapcfgapi"
local timext = require "timext"
local random = require "random"
local MapRefreshMgr = class("MapRefreshMgr")

--该管理类针对对应objectrefresh表 定制刷新规则

local G_RefreshCommon = {
	[mapcommon.MapObjectType.eMOT_Resource] = {
		TypeMappingCfgkeys = { --资源类型映射配置key  ObjectRefresh
			[mapcommon.ResourceType.eRT_Gas] = "Gas",
			[mapcommon.ResourceType.eRT_Food] = "Food",
			[mapcommon.ResourceType.eRT_Water] = "Water",
			[mapcommon.ResourceType.eRT_Cement] = "Cement",

		},

		RefreshTM = {30, 300}, --刷新时间区域随机
		RefreshMaxNum = 50, --一个刷新频率内刷新的最大个数
	},

	[mapcommon.MapObjectType.eMOT_Monster] = {
		TypeMappingCfgkeys = {
			[mapcommon.MonsterType.eMT_Zombie] = "Zombie",

		},

		RefreshTM = {30, 300},
		RefreshMaxNum = 50,
	},
}

function MapRefreshMgr:ctor(mapobjecttype, refreshhandler)
	self._mapobjecttype = mapobjecttype
	self._cfgkeys = assert(G_RefreshCommon[mapobjecttype]["TypeMappingCfgkeys"])
	self._refreshtm = assert(G_RefreshCommon[mapobjecttype]["RefreshTM"])
	self._refreshmax = assert(G_RefreshCommon[mapobjecttype]["RefreshMaxNum"])


	self._refreshhandler = assert(refreshhandler)
	self._refreshtimer = timext.create_timer(random.Get(self._refreshtm[1], self._refreshtm[2]))
	self._areacount = {} --区域分布统计 [areaid][subtype]={ [level] = num }, 由外层统计维护

	self:init()	
end

function MapRefreshMgr:get_cfgkeys()
	return self._cfgkeys
end

--初始化区间分布
function MapRefreshMgr:init()
	local refreshcfg = get_static_config().objectrefresh
	for areaid, cfg in pairs(refreshcfg) do
		local tmptable = {}
		for subtype,cfgkey in pairs(self._cfgkeys) do
			local cfg = MapCfgAPI.GetRefreshCfg(areaid, cfgkey)
			if cfg then
				tmptable[subtype] = {}
				for level, neednum in pairs(cfg) do
					if neednum > 0 then
						tmptable[subtype][level] = 0
					end
				end

				if table.empty(tmptable[subtype]) then
					tmptable[subtype] = nil
				end
			end
		end
		self._areacount[areaid] = tmptable
	end
end

function MapRefreshMgr:pack_needrefreshinfo()
	local need = {}
	for areaid,temp1 in pairs(self._areacount) do
		for subtype,temp2 in pairs(temp1) do
			local cfg = MapCfgAPI.GetRefreshCfg(areaid, self._cfgkeys[subtype])
			for level, n in pairs(temp2) do
				local bornnum = cfg[level] - n
				if bornnum > 0 then
					table.insert(need, { subtype = subtype, areaid = areaid, level = level, bornnum = bornnum})
				elseif bornnum < 0 then
					printf("area resobj overflow %d, areaid=%d", math.abs(bornnum), areaid)
				end
			end
		end
	end
	return need
end

--活物刷满
function MapRefreshMgr:refresh_full()
	for _, info in pairs(self:pack_needrefreshinfo()) do
		self._refreshhandler(info.subtype, info.areaid, info.level, info.bornnum, true)
	end
end

--该接口一般有由上层调用
function MapRefreshMgr:change_areacount(areaid, subtype, level, changenum)
	if self._areacount[areaid] and self._areacount[areaid][subtype] and self._areacount[areaid][subtype][level] then
		local count = self._areacount[areaid][subtype][level] + changenum
		if count < 0 then
			count = 0
		end
		self._areacount[areaid][subtype][level] = count
	end
end

function MapRefreshMgr:run()
	--活物刷新
	if self._refreshtimer:expire() then
		local needinfo = self:pack_needrefreshinfo()
		needinfo = random.GetSets(needinfo) --随机打乱
		local count = 0 --计数
		for k,info in ipairs(needinfo) do
			local bornnum = info.bornnum	
			if bornnum+count > self._refreshmax then
				bornnum = self._refreshmax - count
			end

			self._refreshhandler(info.subtype, info.areaid, info.level, bornnum)
			count = count + bornnum		

			if count >= self._refreshmax then
				break
			end
		end
		self._refreshtimer:update(random.Get(self._refreshtm[1], self._refreshtm[2]))
	end
end

return MapRefreshMgr