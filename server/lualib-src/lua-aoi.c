#include <lua.h>
#include <lauxlib.h>
#include <time.h>
#include "aoi.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static int
_create(lua_State *L) {
	float radis = luaL_checknumber(L, 1);
	struct aoi_space* space = aoi_new(radis);
	lua_pushlightuserdata(L, space);
	return 1;
}

static int
_release(lua_State *L) {
	struct aoi_space* space = lua_touserdata(L, 1);
	if (space == NULL) {
		return 0;
	}
	aoi_release(space);
	return 0;
}

static int
_update(lua_State *L) {
	struct aoi_space* space = lua_touserdata(L, 1);
	if (space == NULL) {
		return 0;
	}
	int id = luaL_checkinteger(L, 2);
	const char* mode = luaL_checkstring(L, 3);
	float radis = luaL_checknumber(L, 6);
	float pos[3] = { 0 };
	pos[0] = luaL_checknumber(L, 4);
	pos[1] = luaL_checknumber(L, 5);
	aoi_update(space, id, mode, pos, radis);
	return 0;
}

static int
traceback(lua_State *L) {
	const char *msg = lua_tostring(L, 1);
	if (msg)
		luaL_traceback(L, L, msg, 1);
	else {
		lua_pushliteral(L, "(no error message)");
	}
	return 1;
}

static void 
_cb(void *ud, uint32_t watcher, uint32_t marker) {
	int trace = 1;
	lua_State *L = ud;
	int top = lua_gettop(L);
	int r;
	if (top == 0) {
		lua_pushcfunction(L, traceback);
		lua_rawgetp(L, LUA_REGISTRYINDEX, _cb);
	} else {
		assert(top == 2);
	}
	lua_pushvalue(L, 2);
	lua_pushinteger(L, watcher);
	lua_pushinteger(L, marker);

	r = lua_pcall(L, 2, 0, trace);
	if (r == LUA_OK) {
		return ;
	}
	fprintf(stdout, "aoi error %d", r);
	fflush(stdout);
	lua_pop(L, 1);

	return ;
}

static int
_run(lua_State *L) {
	struct aoi_space* space = lua_touserdata(L, 2);
	if (space == NULL) {
		return 0;
	}
	luaL_checktype(L, 1, LUA_TFUNCTION);
	lua_settop(L, 1);
	lua_rawsetp(L, LUA_REGISTRYINDEX, _cb);
	lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
	lua_State *gL = lua_tothread(L, -1);
	lua_settop(gL, 0);
	aoi_message(space, _cb, (void*)gL);
	return 0;
}

int luaopen_aoi_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "create", _create },
		{ "release", _release },
		{ "update", _update },
		{ "run", _run },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}
