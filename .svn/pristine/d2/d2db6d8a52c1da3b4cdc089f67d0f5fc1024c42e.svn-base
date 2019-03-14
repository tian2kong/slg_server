local skynet = require "skynet"
local skynetext = require "skynetext"
local common = require "common"

local cluster
local cluster_node = skynet.getenv "cluster_node"
if cluster_node then
    cluster = require "cluster"
end
--[[
    cluster扩展，可以在非集群下调用，如果要用集群功能，需要调用clusterext.open开启节点


    cluster.call(nodename, service, ...) 提起请求。service 可以是一个字符串，或者直接是一个数字地址（如果你能从其它渠道获得地址的话）。
    当 service 是一个字符串时，只需要是那个节点可以见到的服务别名，可以是全局名或本地名。
]]

local clusterext = {}

--开启集群节点
function clusterext.open(node)
    skynet.setenv("cluster_node", node)
    cluster_node = node
    if cluster_node then
        cluster = require "cluster"
    end
    cluster.open(cluster_node)
end

local cluster_addr = {}   --远程地址集合
function clusterext.get_cluster_addr(name)--获取远程地址
    local addr = cluster_addr[name]
    if not addr then
        addr = clusterext.queryservice(name, "interactiond")
        cluster_addr[name] = addr
    end
    return addr
end

--请求服务节点名字
function clusterext.self()
    return cluster_node or ""
end

--
function clusterext.iscluster()
    return cluster
end

function clusterext.pack_cluster_address(node, name)
    return { node = node, service = name}
end

--请求远程服务
function clusterext.queryservice(node, name)
    local tempname = "." .. name
    if cluster_node and node and cluster_node~=node then
        return clusterext.pack_cluster_address(node, tempname)
    else
        return skynet.localname(tempname)
    end
end

--远程服务请求
function clusterext.call(address, _, ...)
    if type(address) == "table" then
        return cluster.call(address.node,address.service,...)
    else
        return skynet.call(address, "lua", ...)
    end
end

function clusterext.send(address, _, ...)
    if type(address) == "table" then
        return cluster.send(address.node,address.service,...)
    else
        return skynet.send(address, "lua", ...)
    end
end


local function raw_callback(addr, msgtype, cmd, ...)
    local param,cbparam,cb = common.callback_param(...)
    if cb then
        local ok, err = xpcall(clusterext.call, debug.traceback, addr, msgtype, cmd, table.unpack(param, 1, param.n))
        if not ok then
            LOG_ERROR("clusterext.callback assert %s", tostring(err))
            err = nil
        end
        cb(err, table.unpack(cbparam, 1, cbparam.n))
    else
        clusterext.send(addr, msgtype, cmd, ...)
    end
end
--回调
function clusterext.callback(addr, msgtype, cmd, ...)
    skynet.fork(raw_callback, addr, msgtype, cmd, ...)
end

return clusterext