local skynet = require "skynet"
local skynetext = require "skynetext"
local clusterext = require "clusterext"
local cluster_service = require "cluster_service"
local common = require "common"

--发送消息给fightinterfaced，并建立会话等待回应，回调函数给发送方

local interaction = {}

local s_cb_flag = nil     --是否注册回调

local registerproto = nil
function interaction.register_agent_protocol()
    skynet.register_protocol {
        id = skynetext.agent_protocol,
        name = skynetext.agent_protocol_name,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch = function(_,source,command, ...) end,
    }
    skynet.register_protocol {
        id = skynetext.agentgroup_protocol,
        name = skynetext.agentgroup_protocol_name,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch = function(_,source,command, ...) end,
    }
    registerproto = true
end

--打包玩家地址
function interaction.pack_agent_address(playerid, addr)
    return {cluster_node = clusterext.self(), addr = (addr or skynet.self()), playerid = playerid}
end

--注册玩家到交互服务
function interaction.register_agent(playerid)
    clusterext.send(get_cluster_service().interactionhubd, "lua", "register_agent", playerid, interaction.pack_agent_address(playerid))
end
--反注册
function interaction.unregister_agent(playerid)
    clusterext.send(get_cluster_service().interactionhubd, "lua", "unregister_agent", playerid, interaction.pack_agent_address(playerid))
end
--取玩家地址  阻塞接口
function interaction.call_agent_address(playerid)
    return clusterext.call(get_cluster_service().interactionhubd, "lua", "get_agent_addr", playerid)
end
--向指定玩家发送消息 有可能发生阻塞  玩家服务不要用此接口
function interaction.call(dest, _, ...)
    if type(dest) == "number" then
        return clusterext.call(get_cluster_service().interactionhubd, "lua", "call_to_agent", dest, ...)
    elseif type(dest) == "table" then
        if clusterext.iscluster() and clusterext.self() ~= dest.cluster_node then--在集群的另一端
            return clusterext.call(clusterext.get_cluster_addr(dest.cluster_node), "lua", "response", dest, ...)
        else--在同一进程
            if not skynet.is_register_protocol(skynetext.agent_protocol_name) then
                interaction.register_agent_protocol()
            end
            return skynet.call(dest.addr, skynetext.agent_protocol_name, dest.playerid, true, ...)
        end
    else
        assert(nil, "unkown dest")
    end
end
--向指定玩家发送消息
function interaction.send(dest, _, ...)
    if type(dest) == "number" then
        clusterext.send(get_cluster_service().interactionhubd, "lua", "send_to_agent", dest, ...)
    elseif type(dest) == "table" then
        if clusterext.iscluster() and clusterext.self() ~= dest.cluster_node then--在集群的另一端
            clusterext.send(clusterext.get_cluster_addr(dest.cluster_node), "lua", "accept", dest, ...)
        else--在同一进程
            if not skynet.is_register_protocol(skynetext.agent_protocol_name) then
                interaction.register_agent_protocol()
            end
            skynet.send(dest.addr, skynetext.agent_protocol_name, dest.playerid, false, ...)
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
            clusterext.send(get_cluster_service().interactionhubd, "lua", "send_to_group", group, ...)
        elseif type(dest) == "table" then
            local temp = {}
            for k,v in pairs(group) do
                local key = v.cluster_node .. "@" .. v.addr
                temp[key] = temp[key] or {}
                table.insert(temp[key], v)
            end
            for _,arr in pairs(temp) do
                local _, agentaddr = next(arr)
                if clusterext.iscluster() and clusterext.self() ~= agentaddr.cluster_node then--在集群的另一端
                    clusterext.send(clusterext.get_cluster_addr(agentaddr.cluster_node), "lua", "accept_group", arr, ...)
                else--在同一进程
                    if not skynet.is_register_protocol(skynetext.agentgroup_protocol_name) then
                        interaction.register_agent_protocol()
                    end
                    skynet.send(agentaddr.addr, skynetext.agentgroup_protocol_name, arr, false, ...)
                end
            end
        else
            assert(nil, "unkown dest")
        end
    end
end

--向所有玩家发送消息
function interaction.send_online_player(...)
    clusterext.send(get_cluster_service().interactionhubd, "lua", "send_all_agent", ...)
end

--获取在线玩家列表
function interaction.callback_get_onlineplayerlist(list, ...)
    clusterext.callback(get_cluster_service().interactionhubd, "lua", "get_onlineplayerlist", list, ...)
end

--请求第三方角色基础数据
function interaction.callback_other_player(sceneobjid, targetid, sceneserver, cb, ...)
    clusterext.callback(get_cluster_service().interactionhubd, "lua", "req_other_player", sceneobjid, targetid, sceneserver, cb, ...)
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
function interaction.register_service_event(clustername, event)
    clusterext.send(get_cluster_service().interactionhubd, "lua", "register_service_event", clustername, event or {})
end

function interaction.close_server()
    clusterext.send(get_cluster_service().interactionhubd, "lua", "close_server")
end

--服务是否加载完毕
function interaction.is_service_init()
    return clusterext.call(get_cluster_service().interactionhubd, "lua", "is_service_init")
end

return interaction