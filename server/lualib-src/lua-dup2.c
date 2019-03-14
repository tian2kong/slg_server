#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <lua.h>
#include <lauxlib.h>
#include <errno.h>
#include <string.h>

static int
ldup2(lua_State *L) {
	const char* sztty = luaL_checkstring(L, 1);

	int ttyfd = open(sztty, O_RDWR);
	if (-1 == ttyfd)
	{	
		perror("perror: ");
		printf("open tty %s error: %s.\n", sztty, strerror(errno));
		return 0;
	}

	/* 重定向 */
	if (-1 == dup2(ttyfd, STDOUT_FILENO)) {
		perror("perror: ");
		printf("can't redirect fd error %s \n", strerror(errno));
		return 0;
	}

	close(ttyfd);
	return 1;
}

int luaopen_dup2_core(lua_State *L)
{
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "dup2", ldup2 },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}
