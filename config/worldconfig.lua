local serverconfig = {}

server1001001 = "0.0.0.0:19001"
world="0.0.0.0:20000"
server1001002 = "0.0.0.0:19011"

serverconfig.world = {--世界服务器配置
    debug_port = 8100,  --后台端口
    cluster = "world",--集群名字
}

return serverconfig