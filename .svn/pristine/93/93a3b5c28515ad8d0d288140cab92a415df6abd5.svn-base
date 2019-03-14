#include <sys/file.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include<sys/stat.h>
#include <stdlib.h>
#include <lua.h>
#include <lauxlib.h>

static void createDir(const char *path) {
	if (access(path, 0) == -1) {
		mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
	}
}

static int
ldaemon(lua_State *L) {
	// 检查能否生成core
	struct rlimit rl = { 0 };
	getrlimit(RLIMIT_CORE, &rl);
	if (rl.rlim_cur == 0) {
		rl.rlim_cur = RLIM_INFINITY;
		rl.rlim_max = RLIM_INFINITY;
		if (setrlimit(RLIMIT_CORE, &rl) != 0) {
			printf("No core dump would be created. Server will be quit\n");
			exit(0);
		}
	}

	int fd, fdtablesize;
	int error, out;
	/* 忽略终端 I/O信号,STOP信号 */
	signal(SIGTTOU, SIG_IGN);
	signal(SIGTTIN, SIG_IGN);
	signal(SIGTSTP, SIG_IGN);
	signal(SIGHUP, SIG_IGN);
	signal(SIGPIPE, SIG_IGN);
	/* 父进程退出,程序进入后台运行 */
	if (fork() != 0) exit(0);
	if (setsid() < 0) exit(1);/* 创建一个新的会议组 */
	/* 子进程退出,孙进程没有控制终端了 */
	if (fork() != 0) exit(0);

	/* 关闭打开的文件描述符,包括标准输入、标准输出和标准错误输出 */
	close(0);
	for (fd = 3, fdtablesize = getdtablesize(); fd < fdtablesize; ++fd) {
		close(fd);
	}
	// 创建log目录
	createDir("log");
	out = open("log/stdout.txt", O_CREAT | O_RDWR | O_APPEND, 0644);
	dup2(out, 1); // stdout
	close(out);
	setlinebuf(stdout);
	error = open("log/stderr.txt", O_CREAT | O_RDWR | O_APPEND, 0644);
	dup2(error, 2);
	setlinebuf(stderr);
	close(error); // stdin
	umask(0);/*重设文件创建掩模 */
	signal(SIGCHLD, SIG_IGN);/* 忽略SIGCHLD信号 */

	return 1;
}

int luaopen_daemon_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "daemon", ldaemon },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}