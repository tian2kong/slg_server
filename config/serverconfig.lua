local serverconfig = {}

--[[服务器配置]]
--[[
--集群端口    
interaction="0.0.0.0:19001"
sample="0.0.0.0:19002"
sample1="0.0.0.0:19003"
world="0.0.0.0:20000"

serverconfig.login = {--登录服务器配置
    ip = "0.0.0.0",     --监听ip
    port = 8001,        --监听端口
    network_ip = "192.168.1.3", --让客户端连接的ip地址
    network_port = 8001,    --让客户端连接的端口
}

serverconfig.interaction = {--交互服务器配置
    debug_port = 6667,  --后台端口
    cluster = "interaction",--集群名字
}

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--下面的都为游戏服务配置
serverconfig.gameserver = {
    [1] = {
        ip = "0.0.0.0",     --监听ip
        port = 8002,        --监听端口
        debug_port = 8003,  --后台端口
        max_client = 1024,  --最大客户端连接数
        cluster = "sample", --集群名字
        cluster_port = 19002,
        network_ip = "192.168.1.3", --让客户端连接的ip地址
        network_port = 8002,    --让客户端连接的端口
    },
}

serverconfig.http_port = 8004
]]

serverconfig.serverid = 20   --服务器id
serverconfig.httphost = "192.168.1.5:8002"

return serverconfig
