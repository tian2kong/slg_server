local skynet = require "skynet"
local clusterext = require "clusterext"
local cluster_service = require "cluster_service"
local common = require "common"
local gatecommon = require "gatecommon"

local interaction = {}

--打包玩家地址
function interaction.pack_agent_address(playerid, addr)
    return {cluster_node = clusterext.self(), addr = (addr or skynet.self()), playerid = playerid}
end

--取玩家地址  阻塞接口
function interaction.call_agent_address(playerid)
    local address = get_remote_service().gateservice
    if address then
        return clusterext.call(address, "lua", "fuzzy_agent_addr", playerid)
    else
        return clusterext.call(get_cluster_service().loginservice, "lua", "get_agent_addr", playerid)
    end
end
--向指定玩家发送消息 有可能发生阻塞  玩家服务不要用此接口
function interaction.call(dest, _, ...)
    if type(dest) == "number" then--只有一个playerid去loginservice查找
        local address = get_remote_service().gateservice
        if address then
            return clusterext.call(address, "lua", "fuzzy_agent_interaction", true, dest, ...)
        else
            return clusterext.call(get_cluster_service().loginservice, "lua", "agent_interaction", true, dest, ...)
        end
    elseif type(dest) == "table" then
        if clusterext.iscluster() and clusterext.self() ~= dest.cluster_node then--在集群的另一端
            local address = get_remote_service(dest.cluster_node).gateservice
            return clusterext.call(address, "lua", "agent_interaction", true, dest.playerid, ...)
        else--在同一进程
            return skynet.call(dest.addr, "lua", "dispatch_interaction", dest.playerid, true, ...)
        end
    else
        assert(nil, "unkown dest")
    end
end
--向指定玩家发送消息
function interaction.send(dest, _, ...)
    if type(dest) == "number" then
        local address = get_remote_service().gateservice
        if address then
            clusterext.send(address, "lua", "fuzzy_agent_interaction", false, dest, ...)
        else
            clusterext.send(get_cluster_service().loginservice, "lua", "agent_interaction", false, dest, ...)
        end
    elseif type(dest) == "table" then
        if clusterext.iscluster() and clusterext.self() ~= dest.cluster_node then--在集群的另一端
            local address = get_remote_service(dest.cluster_node).gateservice
            clusterext.send(address, "lua", "agent_interaction", false, dest.playerid, ...)
        else--在同一进程
            skynet.send(dest.addr, "lua", "dispatch_interaction", dest.playerid, false, ...)
        end
    else
        assert(nil, "unkown dest")
    end
end
--向玩家组发送消息
function interaction.send_to_group(group, _, ...)
    local _, dest = next(group)
    if dest then
        if type(dest) == "number" then
            local address = get_remote_service().gateservice
            if address then
                clusterext.send(address, "lua", "fuzzy_group_interaction", group, ...)
            else
                clusterext.send(get_cluster_service().loginservice, "lua", "group_interaction", group, ...)
            end
        elseif type(dest) == "table" then
            local temp = {}
            for k,v in pairs(group) do
                local key = v.cluster_node .. "@" .. v.addr
                temp[key] = temp[key] or {}
                table.insert(temp[key], v.playerid)
            end
            for _,arr in pairs(temp) do
                local _, dest = next(arr)
                if clusterext.iscluster() and clusterext.self() ~= agentaddr.cluster_node then--在集群的另一端
                    local address = get_remote_service(dest.cluster_node).gateservice
                    clusterext.send(address, "lua", "group_interaction", arr, ...)
                else--在同一进程
                    skynet.send(dest.addr, "group_interaction", arr, ...)
                end
            end
        else
            assert(nil, "unkown dest")
        end
    end
end

local function raw_callback(dest, _, ...)
    local param,cbparam,cb = common.callback_param(...)
    if cb then 
        local ok, ret = xpcall(interaction.call, debug.traceback, dest, _, table.unpack(param, 1, param.n))
        if not ok then
            LOG_ERROR("interaction.callback assert %s", tostring(ret))
            ret = nil
        end
        cb(ret, table.unpack(cbparam, 1, cbparam.n))
    else
        interaction.send(dest, _, ...)
    end
end
--向指定玩家回调信息
function interaction.callback(dest, _, ...)
    skynet.fork(raw_callback, dest, _, ...)
end

--[[
注册服务事件
event => {
    service_init = true, --基础服务都加载完的事件
    service_init_over = true, --service_init结束事件
    safe_quit = priority, --安全退出事件 priority优先级值越大优先级越高
}
]]
function interaction.register_service_event(event)
    clusterext.send(get_cluster_service().interactionhubd, "lua", "register_service_event", skynet.self(), event or {})
end

function interaction.close_server()
    clusterext.send(get_cluster_service().interactionhubd, "lua", "close_server")
end

return interaction