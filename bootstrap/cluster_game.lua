local skynet = require "skynet"
local snax = require "snax"
local debugcmd = require "debugcmd"
local config = require "config"
require "cluster_service"
local clusterext = require "clusterext"
require "skynet.manager"
local cluster = require "cluster"

skynet.start(function()
    skynet.uniqueservice("configd")

    local conf = config.get_server_config()
    cluster.reload(config.get_cluster_config())
    clusterext.open(conf.cluster_name)

    skynet.uniqueservice("dbservice")
    local hubd = clusterservice("interactionhubd")

    local console = skynet.newservice("debug_console",conf.debug_port)
    debugcmd.init(console)
    skynet.newservice ("protod")

    local cache = clusterservice("cacheservice")
    skynet.call(cache, "lua", "open")

    local gamed = clusterservice("gateservice")
    
    clusterservice("mapserver") 
    clusterservice("mailserver") 
    clusterservice("imageserver")
    clusterservice("chatserver")
    clusterservice("gmweb")
    clusterservice("gmserver")

    skynet.open_sign()

    skynet.call(gamed, "lua", "open")

    skynet.call(hubd, "lua", "init_over")

    skynet.call(".launcher", "lua", "GC")
    skynet.exit()
end)