#!/bin/sh
export LUA_CPATH="skynet/luaclib/?.so;client/lsocket/?.so;client/?.so"
export LUA_PATH="client/?.lua;skynet/lualib/?.lua;global/?.lua;proto/?.lua;server/?.lua;skynet/lualib/compat10/?.lua;"
rlwrap skynet/3rd/lua/lua client/newmain.lua $1 $2 $3
