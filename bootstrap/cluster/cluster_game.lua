local skynet = require "skynet"
local snax = require "snax"
require "debugcmd"
local clusterext = require "clusterext"
require "interaction"
require "skynet.manager"
local dbconfig = require "dbconfig"
local serverconfig = require "serverconfig"

skynet.start(function()
    local conf = serverconfig[skynet.getenv "game_name"]
    clusterext.open(conf.cluster)

    local log = clusterservice("logservice")
	skynet.call(log, "lua", "start")

    gamelogd = skynet.newservice("gamelogd")
    skynet.send(gamelogd, "lua", "open", 8, dbconfig.gamelog)

    if not skynet.getenv "daemon" then
        skynet.newservice("console")
    end
    local console = skynet.newservice("debug_console",conf.debug_port)
    init_debug_cmd(console)
    
    snax.uniqueservice("databasemanager", dbconfig.player)

    local interactiongate = clusterservice("interactiongate")
    clusterext.register("interactiongate", interactiongate)

    local proxy1 = clusterext.proxy("login", "logind")
    skynet.newservice ("protod")
    clusterservice("static_configd")
    local proxy2 = clusterext.proxy("login", "accountd")
    local gamed = skynet.newservice ("gamed", proxy1, proxy2)
    clusterext.register(conf.cluster, gamed)
    skynet.call(gamed, "lua", "open" , {
	    address = conf.ip,
	    port = conf.port,
	    maxclient = conf.max_client,
	    servername = conf.cluster,
        network_ip = conf.network_ip,
        network_port = conf.network_port,
    })

    
    skynet.exit()
end)

