local skynet = require "skynet"
local clusterext = require "clusterext"

local imageinterface = {}



skynet.init(function()
    imageinterface.server = clusterext.queryservice("interaction", "imageserver")
end)

return imageinterface