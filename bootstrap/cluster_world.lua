local skynet = require "skynet"
local snax = require "snax"
local debugcmd = require "debugcmd"
local config = require "config"
require "cluster_service"
local clusterext = require "clusterext"
local cluster = require "cluster"
require "skynet.manager"

skynet.start(function()
    skynet.uniqueservice("configd")

    local conf = config.get_world_config().world
    cluster.reload(config.get_cluster_config())
    clusterext.open(conf.cluster_name)
    skynet.uniqueservice("dbservice")
    local console = skynet.newservice("debug_console", conf.debug_port)
    debugcmd.init(console)
    local world = clusterservice("worldservice")

    skynet.open_sign()
    
    skynet.call(".launcher", "lua", "GC")

    skynet.exit()
end)