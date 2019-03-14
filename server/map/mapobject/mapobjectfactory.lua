local mapcommon = require "mapcommon"

local MapPlayerObject = require "mapplayerobject"
local MapResourceObject = require "mapresourceobject"
local MapMonsterObject = require "mapmonsterobject"

local MapObjectFactory = {}

local function _createPlayerObject(database, objectid)
	local record = database:create_db_record(MapPlayerObject.s_table, objectid)
	return MapPlayerObject.new(record)
end

local function _createResourceObject(database, objectid)
	local record = database:create_db_record(MapResourceObject.s_table, objectid)
	return MapResourceObject.new(record)
end

local function _createMonsterObject(database, objectid)
	local record = database:create_db_record(MapMonsterObject.s_table, objectid)
	return MapMonsterObject.new(record)
end

MapObjectFactory.ceateHandler = {
	[mapcommon.MapObjectType.eMOT_Player] = _createPlayerObject,
	[mapcommon.MapObjectType.eMOT_Resource] = _createResourceObject,
	[mapcommon.MapObjectType.eMOT_Monster] = _createMonsterObject,
}

function MapObjectFactory.create(database, objecttype, keyvalue)
	local createFuc = MapObjectFactory.ceateHandler[objecttype]
	if createFuc then
		return createFuc(database, keyvalue)
	else
		assert(false)
	end
end

return MapObjectFactory