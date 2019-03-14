local skynet = require "skynet"
local snax = require "snax"
require "debugcmd"
local clusterext = require "clusterext"
require "interaction"
require "skynet.manager"
local serverconfig = require "serverconfig"
local dbconfig = require "dbconfig"

skynet.start(function()
    local conf = serverconfig.guild
    clusterext.open(conf.cluster)

    local log = clusterservice("logservice")
	skynet.call(log, "lua", "start")

    if not skynet.getenv "daemon" then
        skynet.newservice("console")
    end
    local console = skynet.newservice("debug_console",conf.debug_port)
    init_debug_cmd(console)

    local interactiongate = clusterservice("interactiongate")
    clusterext.register("interactiongate", interactiongate)

    clusterservice("static_configd")

    snax.uniqueservice("databasemanager", dbconfig.global)

    local guildmgr = clusterservice("guildservice")
    clusterext.register("guildservice", guildmgr)
    
    skynet.exit()
end)

