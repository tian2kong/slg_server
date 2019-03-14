#include <lua.h>
#include <lauxlib.h>
#include <time.h>
#include <stdint.h>
#include<sys/time.h>

static int
ltime(lua_State *L) {
	uint32_t sec;

	struct timeval tv;
	struct timezone tz;
	gettimeofday(&tv, &tz);
	sec = tv.tv_sec + tz.tz_minuteswest * 60;
	lua_pushinteger(L, (lua_Integer)sec);
	return 1;
}

int luaopen_time_core(lua_State *L)
{
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "time", ltime },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}
