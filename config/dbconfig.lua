local dbconfig = {}

--[[数据库配置]]

dbconfig.player = { --玩家数据库
    {
		host="192.168.1.3",
		port=3306,
		dbname="dh",
		user="root",
		password="123",
		max_packet_size = 1024 * 1024 * 15,--15m
	},
}

dbconfig.gamelog = {    --日志数据库
	host="192.168.1.3",
	port=3306,
	dbname="dhlog",
	user="root",
	password="123",
	max_packet_size = 1024 * 1024 * 15,--15m
}

dbconfig.global = {--全局数据库
    host="192.168.1.3",
	port=3306,
	dbname="dh",
	user="root",
	password="123",
	max_packet_size = 1024 * 1024 * 15,--15m
}

return dbconfig