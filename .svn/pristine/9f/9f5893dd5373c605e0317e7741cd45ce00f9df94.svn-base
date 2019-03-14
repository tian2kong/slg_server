local sparser = require "sprotoparser"
local protos = require "protos"
local game_proto = {}

game_proto.types = sparser.parse (protos.types)
game_proto.c2s = sparser.parse (protos.c2s)
game_proto.s2c = sparser.parse (protos.s2c)

return game_proto
