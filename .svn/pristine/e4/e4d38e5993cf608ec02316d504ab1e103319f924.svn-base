local commonSet = {}
local commonInterface = {}
local commonCfgAPI = {}

local function getCommon(name)
	if not commonSet[name] then
		commonSet[name] = {}
	end
	return commonSet[name]
end

local function getInterface(name)
	if not commonInterface[name] then
		commonInterface[name] = {}
	end
	return commonInterface[name]
end

local function getCfgAPI(name)
	if not commonCfgAPI[name] then
		commonCfgAPI[name] = {}
	end
	return commonCfgAPI[name]
end

function BuildCommon(name)
	return getCommon(name)
end

function BuildInterface(name)
	return getInterface(name)
end

function BuildCfgAPI(name)
	return getCfgAPI(name)
end

