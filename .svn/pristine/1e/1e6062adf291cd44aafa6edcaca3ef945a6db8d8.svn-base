local clusterext = require "clusterext"
local skynet = require "skynet"
require "skynet.manager"

local cluster_service = {}

local service_list = {}

local service_pairs = {
    cacheservice = {"interaction", "cacheservice"},
    interactionhubd = {"interaction", "interactionhubd"},
    chatserver = {"interaction", "chatserver"},
    imageserver = {"interaction", "imageserver"},
    mailserver = {"interaction", "mailserver"},
    teamserver = {"interaction", "teamserver"},
    tradeserver = {"interaction", "tradeserver"},
    logind = {"interaction", "logind"},
    gmserver = {"interaction", "gmserver"},
    worldservice = {"world", "worldservice"},
    shopserver = {"interaction", "shopserver"},
    mapserver = {"interaction", "mapserver"},
}

setmetatable(service_list, { __index = function(t, k)
    local cfg = service_pairs[k]
    if cfg then
        t[k] = clusterext.queryservice(cfg[1], cfg[2])
        return t[k]
    elseif type(k) == "table" then
        return clusterext.queryservice(k[1], k[2])
    end
end })

function get_cluster_service()
    return service_list
end

local initflag = nil
function init_cluster_service()
    if initflag then
        return
    end
    initflag = true
    for k,v in pairs(service_pairs) do
        if k ~= "worldservice" or clusterext.iscluster() then
            service_list[k] = clusterext.queryservice(v[1], v[2])
        end
    end
end

--创建支持远端服务
function clusterservice(name, ...)
    local addr = skynet.newservice(name, ...)
    if service_pairs[name] then
        skynet.name("." .. name, addr)
    end
    return addr
end

function registercluster(name, addr)
    skynet.name("." .. name, addr)
    return addr
end