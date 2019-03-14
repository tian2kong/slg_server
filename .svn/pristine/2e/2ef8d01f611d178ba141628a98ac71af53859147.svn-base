local skynet = require "skynet"
local snax = require "snax"
local debugcmd = require "debugcmd"
local clusterext = require "clusterext"
require "skynet.manager"
local worldconfig = require "worldconfig"

skynet.start(function()
    local conf = worldconfig.world
    clusterext.open(conf.cluster)

    local log = clusterservice("logservice")
	skynet.call(log, "lua", "start")

    if not skynet.getenv "daemon" then
        skynet.newservice("console")
    end
    local console = skynet.newservice("debug_console",conf.debug_port)
    debugcmd.init(console)

    clusterservice("static_configd")
    local worldd = clusterservice("worldhubd")
    skynet.send(worldd, "lua", "open")
    skynet.name("worldservice", worldd)

    skynet.exit()
end)

