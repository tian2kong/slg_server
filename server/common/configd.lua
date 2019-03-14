local skynet = require "skynet"
local sharedata = require "sharedata"
local httprequest = require "httprequest"

--加载静态配置
local function load_static_config(load_func)
    local name = "./server/common/static_loader.lua"
    local file = io.open(name, "rb")
    local source = file:read "*a"
    file:close()

    local f, err = load(source, "load_static_config", "t")
    if not f then
        if LOG_ERROR then
            LOG_ERROR("load_static_config error: error \n " .. err)
        end
    end

    local temp = f()()
    for k,v in pairs(temp) do
        load_func(k, v)
    end
end

--加载服务器配置
local function load_server_config(load_func)
    local cfg = httprequest.req_server_cfg()
    if not cfg then
        return
    end

    local temp = table.decode(cfg)
    temp = temp.game
    --数据库配置
    local dbconfig = {}
    dbconfig.player = { --玩家数据库
        {
            host=temp.dbc_player_host,
            port=temp.dbc_player_port,
            dbname=temp.dbc_player_dbname,
            user=temp.dbc_player_user,
            password=temp.dbc_player_password,
            max_packet_size = 1024 * 1024 * 15,--15m
        },
    }
    dbconfig.gamelog = {    --日志数据库
        host=temp.gl_host,
        port=temp.gl_port,
        dbname=temp.gl_dbname,
        user=temp.gl_user,
        password=temp.gl_password,
        max_packet_size = 1024 * 1024 * 15,--15m
    }
    dbconfig.global = {--全局数据库
        {
            host=temp.dbc_global_host,
            port=temp.dbc_global_port,
            dbname=temp.dbc_global_dbname,
            user=temp.dbc_global_user,
            password=temp.dbc_global_password,
            max_packet_size = 1024 * 1024 * 15,--15m
        },
    }

    --服务器配置
    local serverconfig = {}
    serverconfig.login = {--登录服务器配置
        ip = temp.ls_ip,     --监听ip
        port = temp.ls_port,        --监听端口
        network_ip = temp.ls_network_ip, --让客户端连接的ip地址
        network_port = temp.ls_network_port,    --让客户端连接的端口
    }
    serverconfig.gameserver = {
        ip = temp.gs_ip,     --监听ip
        port = temp.gs_port,        --监听端口
        maxclient = 4000,  --最大客户端连接数
        servername = "sample",
        --cluster = "sample", --集群名字
        --cluster_port = 19002,
        network_ip = temp.gs_network_ip, --让客户端连接的ip地址
        network_port = temp.gs_network_port,    --让客户端连接的端口
    }
    serverconfig.debug_port = temp.debug_port
    serverconfig.http_port = temp.http_port
    serverconfig.http_host = temp.http_host
    serverconfig.server_name = temp.server_name
    serverconfig.status = tonumber(temp.status)
    serverconfig.newtag = tonumber(temp.newtag)
    serverconfig.groupid = tonumber(temp.groupid)
    serverconfig.groupname = temp.groupname
    serverconfig.serverid = tonumber(temp.serverid)
    serverconfig.gmt = tonumber(temp.gmt) or 0
    serverconfig.questionnaire = (tonumber(temp.question) == 1)
    load_func("config", { dbconfig = dbconfig, serverconfig = serverconfig})
end

local CMD = {}

function CMD.hotfix()
    load_static_config(sharedata.update)
    skynet.retpack(true)
end

function CMD.reload_server_static()
    load_server_config(sharedata.update)
    skynet.retpack(true)
end

skynet.start (function ()
    load_server_config(sharedata.new)
	load_static_config(sharedata.new)

    skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd])
		f(...)
	end)
end)