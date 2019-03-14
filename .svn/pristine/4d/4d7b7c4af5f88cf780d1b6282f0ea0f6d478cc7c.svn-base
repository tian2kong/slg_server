local skynet = require "skynet"
local snax = require "snax"
require "debugcmd"
local clusterext = require "clusterext"
require "skynet.manager"
local serverconfig = require "serverconfig"
local dbconfig = require "dbconfig"

skynet.start(function()
    local conf = serverconfig.interaction
    clusterext.open(conf.cluster)

    local log = clusterservice("logservice")
	skynet.call(log, "lua", "start")

    if not skynet.getenv "daemon" then
        skynet.newservice("console")
    end
    local console = skynet.newservice("debug_console",conf.debug_port)
    init_debug_cmd(console)

    clusterservice("static_configd")

    local interactiongate = clusterservice("interactiongate")
    clusterext.register("interactiongate", interactiongate)

    snax.uniqueservice("databasemanager", dbconfig.global)

    local interactiond = clusterservice("interactiond")
    clusterext.register("interactiond", interactiond)
    local chat = clusterservice("chatservice")
    clusterext.register("chatservice", chat)
    local whisper = clusterservice("whisperservice")
    clusterext.register("whisperservice", whisper)
    local cache = clusterservice("cacheservice")
    clusterext.register("cacheservice", cache)
    local comment = clusterservice("commentservice")
    clusterext.register("commentservice", comment)
    
    skynet.exit()
end)

