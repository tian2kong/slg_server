local sprotoloader = require "sprotoloader"

local loader = {
	GAME_TYPES = 0,

	GAME = 1,
	GAME_C2S = 1,
	GAME_S2C = 2,
}

function loader.init ()
	local gamep = require "game_proto"
	sprotoloader.save (gamep.types, loader.GAME_TYPES)

	sprotoloader.save (gamep.c2s, loader.GAME_C2S)
	sprotoloader.save (gamep.s2c, loader.GAME_S2C)
end

function loader.load (index)
    local sproto = sprotoloader.load (index)
	local host = sproto:host "package"
	local request = host:attach (sprotoloader.load (index + 1))
	return sproto, host, request
end

return loader
