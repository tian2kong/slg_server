local skynet = require "skynet"
local clusterext = require "clusterext"
local cacheinterface = require "cacheinterface"
require "skynet.manager"
local timext = require "timext"
local interaction = require "interaction"
local debugcmd = require "debugcmd"
local TimeMgr = require "timemgr"

local CMD = {}
local user_map = {} -- playerid -> {cluster_node,addr,playerid}
local g_online_num = 0
local service_list = {} -- 公共服信息

--时间管理器
local s_timemgr = TimeMgr.new()

local initservice = nil --
local closeflag = nil
--注册公共服事件
local base_service = {
    "logind",
    "cacheservice",
}
function CMD.register_service_event(clustername, event)
    if event.safe_quit and type(event.safe_quit) ~= "number" then
        event.safe_quit = 0
    end
    local info = event
    info.clustername = clustername
    service_list[clustername] = info
end

function CMD.init_over()
    for k,v in pairs(service_list) do
        if v.service_init then
            clusterext.call(get_cluster_service()[k], "lua", "service_init")
        end
    end
    for k,v in pairs(service_list) do
        if v.service_init_over then
            clusterext.call(get_cluster_service()[k], "lua", "service_init_over")
        end
    end
    initservice = true
    skynet.retpack(true)
end

function CMD.is_service_init()
    skynet.retpack(initservice)
end

function CMD.close_server()
    if closeflag then
        return
    end
    s_timemgr:savedb()
    closeflag = true
    local t = {}
    for k,v in pairs(service_list) do
        if v.safe_quit then
            table.insert(t, v)
        end
    end
    table.sort(t, function(a1, a2) 
        return a1.safe_quit > a2.safe_quit
    end)
    for k,v in ipairs(t) do
        clusterext.call(get_cluster_service()[v.clustername], "lua", "safe_quit")
    end
    for k,v in ipairs(t) do
        clusterext.call(get_cluster_service()[v.clustername], "lua", "safe_quit_over")
    end
    --退出进程
    skynet.abort()
end

--[[
交互服务：用来存储全区全服在线玩家服务列表，进行远程交互
]]
function CMD.register_agent(playerid, agentaddr)
	-- todo: support cluster
    if not user_map[playerid] then
        g_online_num = g_online_num + 1
    else
        LOG_ERROR("%d agent had login interactionhubd", playerid)
    end
    user_map[playerid] = agentaddr
end

function CMD.unregister_agent(playerid, agentaddr)
    if user_map[playerid] then
        g_online_num = g_online_num - 1
    else
        LOG_ERROR("%d agent not login interactionhubd", playerid)
    end
    user_map[playerid] = nil
end

function CMD.get_agent_addr(playerid)
    local ret = user_map[playerid]
    skynet.retpack(ret)
end

function CMD.send_to_agent(playerid, ...)
    local agent = user_map[playerid]
    if agent then
        interaction.send(agent, "lua", ...)
    end
end
function CMD.call_to_agent(playerid, ...)
    local agent = user_map[playerid]
    local ret
    if agent then
        ret = interaction.call(agent, "lua", ...)
    end
    skynet.retpack(ret)
end

--广播所有在线玩家
function CMD.send_all_agent(...)
    interaction.send_to_group(user_map, "lua", ...)
end

--
function CMD.send_to_group(arrid, ...)
    local group = {}
    for k,v in pairs(arrid) do
        local agent = user_map[v]
        if agent then
            table.insert(group, agent)
        end
    end
    interaction.send_to_group(group, "lua", ...)
end

function CMD.online_num()
    --在线人数
    skynet.retpack(g_online_num) 
end

--列表中的玩家是否在线
function CMD.get_onlineplayerlist(list)
    local ret = {}
    if list then
        for _,v in pairs(list) do
            if user_map[v] then
                table.insert(ret, v)--返回在线玩家列表
            end        
        end
    end
    skynet.retpack(ret)
end

--请求其他玩家爱信息
function CMD.req_other_player(sceneobjid, targetid, objkey)
    local info
    local ret = cacheinterface.call_get_player_info({ targetid }, {"level","rei","name","roleid","language","online"})
    if ret[targetid] then
        info = ret[targetid]
    end
    skynet.retpack(info)
end

--gm修改系统时间
CMD.gm_system_time = register_command(s_timemgr, "gm_system_time")
CMD.get_current_time = register_command(s_timemgr, "get_current_time", true)

local function run(frame)
    s_timemgr:run()
    --关闭skynet通知
    if skynet.sign_kill() then
        CMD.close_server()
    end
end
skynet.init(function()
    debugcmd.register_debugcmd(CMD)
    s_timemgr:loaddb()
    s_timemgr:init()
    timext.open_clock(run)
end)

skynet.start(function()

    skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd])
		f(...)
	end)
end)
