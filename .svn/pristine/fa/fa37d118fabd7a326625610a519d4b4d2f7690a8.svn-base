local protos = {}

local types = require "prototype"
local thingproto = require "thingproto"
local tokenproto = require "tokenproto"
local systemproto = require "systemproto"
local playerproto = require "playerproto"
local shopproto = require "shopproto"
local chatproto = require "chatproto"
local mailproto = require "mailproto"
local titleproto = require "titleproto"
local commonproto = require "commonproto"
local chargeproto = require "chargeproto"
local cityproto = require "cityproto"
local mapproto = require "mapproto"

protos.types = types
protos.c2s = types 
    .. systemproto.c2s
    .. thingproto.c2s 
    .. tokenproto.c2s 
    .. chatproto.c2s
    .. mailproto.c2s
    .. chargeproto.c2s
    .. playerproto.c2s
    .. titleproto.c2s
    .. cityproto.c2s
    .. mapproto.c2s
    

protos.s2c = types
    .. systemproto.s2c
    .. thingproto.s2c 
    .. tokenproto.s2c 
    .. playerproto.s2c
    .. chatproto.s2c
    .. mailproto.s2c
    .. chargeproto.s2c
    .. titleproto.s2c
    .. cityproto.s2c
    .. mapproto.s2c


return protos
