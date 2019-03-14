local mapcommon = require "mapcommon"
local MapCfgAPI = BuildCfgAPI("MapCfgAPI")

local ResTypeMappingCfgKey = mapcommon.ResTypeMappingCfgKey

--获取资源代币最大配置储量
function MapCfgAPI.GetResourceMaxReserves(restype, level)
	--TODOX
	return 100000
end

--获取指定活物刷新配置
function MapCfgAPI.GetRefreshCfg(areaid, cfgkey)
	local cfg = get_static_config().objectrefresh[areaid]
	if cfg then
		return cfg[cfgkey]
	end
	return nil
end

return MapCfgAPI