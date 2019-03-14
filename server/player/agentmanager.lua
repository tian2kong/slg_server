local class = require "class"
local Player = require "player"
local interaction = require "interaction"
local skynet = require "skynet"
local skynetext = require "skynetext"
local clusterext = require "clusterext"
local timext = require "timext"
local common = require "common"
local httprequest = require "httprequest"
local Database = class("Database")

--客户端消息
local client_request =  require "client_request"
--交互消息
local agent_interaction = require "agent_interaction"

local AgentManager = class("AgentManager")

local check_mq_time = 3

function AgentManager:ctor(gateserver, servername)
	--sproto协议数据
	self.sproto = nil
	self.host = nil
	self.proto_request = nil

	--网关服务器
	self.gateserver = gateserver

	--玩家集合
	self.user_list = {}

    --玩家消息处理队列
    self.msgqueue = {}

    self.msgtimer = timext.create_timer(check_mq_time)

    self.errorply = {} --错误的玩家列表

    self.serveraddr = skynet.self()
    if clusterext.iscluster() then --这里分布式的话要另外写
        self.serveraddr = clusterext.pack_cluster_address(clusterext.self(), servername)
    end
end

function AgentManager:get_server_addr()
    return self.serveraddr
end

--获取玩家列表
function AgentManager:get_user_list()
    return self.user_list
end

--初始化
function AgentManager:init()
	--加载协议
	local protoloader = require "protoloader"
    self.sproto, self.host, self.proto_request = protoloader.load(protoloader.GAME)

    --注册远端服务器
    init_cluster_service()

    --初始化配置信息
    init_static_config()

    --注册远端消息
    skynet.register_protocol {
        id = skynetext.agent_protocol,
	    name = skynetext.agent_protocol_name,
	    pack = skynet.pack,
	    unpack = skynet.unpack,
        dispatch = function(_, source, playerid, response, command, ...)
            local ret = self:dispatch_interaction(source, playerid, command, ...)
            if response then
                skynet.retpack(ret)
            end
        end,
    }
    skynet.register_protocol {
        id = skynetext.agentgroup_protocol,
        name = skynetext.agentgroup_protocol_name,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch = function(_, source, group, response, command, ...)
            for k,v in pairs(group) do
                self:dispatch_interaction(source, v.playerid, command, ...)
            end
        end,
    }
    
    --注册客户端消息
    skynet.register_protocol {
        name = "client",
        id = skynet.PTYPE_CLIENT,
        unpack = function(msg, sz)
            return self.host:dispatch (msg, sz)
        end,
        dispatch = function (_, playerid, type, ...)
            if type == "REQUEST" then
                self:handle_request(playerid, ...)
            elseif type == "RESPONSE" then
                self:handle_response(playerid, ...)
            else
                LOG_ERROR("invalid message type : %s", type)  
            end
        end,
    }

    --注册定时器
    --每日刷新时间
    local function zero_event_func()
        for _,v in pairs(self.user_list) do
            v:dayrefresh()
        end
    end
    --周触发时间
    local function week_event_func()
        for _,v in pairs(self.user_list) do
            v:weekrefresh()
        end
    end
    local _,t = timext.system_refresh_time()
    timext.reg_time_event(zero_event_func, nil, t.hour, t.min, t.sec)
    timext.reg_time_event(week_event_func, nil, t.hour, t.min, t.sec, timext.week_day.monday)

    --初始化
    if interaction.is_service_init() then
        self:service_init()
    end
end

function AgentManager:run(frame)
    for _,player in pairs(self.user_list) do
        player:init_run(frame)
        if player:is_online() then
            player:run(frame)
        end
    end

    if self.msgtimer:expire() and not table.empty(self.msgqueue) then
        self.msgtimer:update(check_mq_time)
        skynet.call(self.gateserver, "lua", "check_mq", self.msgqueue)
        self.msgqueue = {}
    end

    --collectgarbage("collect")
end

--加载玩家数据
function AgentManager:load_player(msg, gm)
    local ok,err = xpcall(function() 
        local player = self.user_list[msg.playerid]
        if player then
            LOG_ERROR("AgentManager have player %s", msg.account)
        else
            player = Player.new()
            player:init_account(msg)
            player:loaddb()
            if player:is_create_role() then
                player:init()
                if gm then
                    player:init_service()
                end
            end
            return player
        end
    end, debug.traceback)
    local ret = nil
    if not ok then
        LOG_ERROR(err)
    else
        local player = err
        self.user_list[msg.playerid] = player
        ret = true
    end
    return ret
end

--玩家登录
function AgentManager:login_player(playerid, fd, ip, args)
    -- you may use secret to make a encrypted data stream
    local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("login_player unkown player %d", playerid)
        return 
    end
    if player:is_create_role() then
        player:init_service()
        player:online()
    end

    player:login(fd, ip, args)

    return player:is_create_role()
end

--玩家登录
function AgentManager:check_login_sign(account, datetime, sign)
    return httprequest.server_sign(account, datetime, sign)
end

--玩家断线
function AgentManager:disconnect_player(playerid)
    local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("disconnect_player unkown player %d", playerid)
        return 
    end
    player:away()
end

--玩家重连
function AgentManager:reconnect_player(playerid, fd, islogin, ip, args)
    local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("reconnect_player unkown player %d", playerid)
        return 
    end
    player:reconnect(fd, ip, args)

    return player:is_create_role()
end

--T出玩家
function AgentManager:kick_player(playerid, cachetime)
    local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("kick_player unkown player %d", playerid)
        return 
    end
    player:offline()

    skynet.call(self.gateserver, "lua", "logout", player:getaccount(), cachetime)
end

--释放玩家数据
function AgentManager:release_player(playerid)
    print("release_player", playerid)
    local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("release_player unkown player %d", playerid)
        return 
    end
    player:destroy()

    self.msgqueue[player:getaccount()] = nil
    self.user_list[playerid] = nil
end

--是否已创角
function AgentManager:is_create_role(playerid)
    local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("is_create_role unkown player %d", playerid)
        return 
    end
    return player:is_create_role()
end

--interaction消息
function AgentManager:dispatch_interaction(source, playerid, command, ...)
	local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("unkown dispatch_interaction player[%d] source[%d] command[%s] param[%s]", playerid, source, command, tostring({...}))
        
        local timer = self.errorply[playerid]
        if not timer or timer:expire() then
            self.errorply[playerid] = timext.create_timer(10)  --10秒内不重新发
            clusterext.send(get_cluster_service().teamserver, "lua", "error_player", playerid)
            clusterext.send(get_cluster_service().scenehubd, "lua", "error_player", playerid)
        end
    else
		local f = assert(agent_interaction[command], string.format("not found agent interaction [%s]", command))
		return f(player, ...)
	end
end

--过滤的打印消息
AgentManager.s_filter_print = {
    characterwalk = true,
    characterwalkret = true,
    objectmoveto = true,
    objectarrive = true,
    removeobject = true,
    syncobjects = nil,
    objectstopmove = true,
    updateobject = nil,
    keepalive = true,
    channelvoicechat = true,
    privatevoicechat = true,
    syncprivatevoicechat = true,
    syncchannelvoicechat = true,
    syncofflineprivatvoicechat = true,
    syncvoice = true,
    c_round_begin = true,
    c_round_end = true,
    c_update_fighter = true,
    c_war_start = true,
    reqsetspacesignsound = true,
    reqsetspaceimage = true,
    uploadbuffer = true,
    syncbuffer = true,
    reqmarketprice = true,
    reqstallprice = true,
    reqpartnerdesc = true,
    --reqguidetask = true,
    reqprivatenpc = true,
    reqthingdesctemp = true,
}
--处理客户端请求消息
--sproto协议默认结构
local request_default = {}
local default_struct = {}
function AgentManager:handle_request(playerid, name, args, response)
    if name == "join" or name == "login" or name == "back" then --登录消息在网关处理了
        return 
    end
    local player = self.user_list[playerid]
    if not player then
        LOG_ERROR("handle_request unkown player %d", playerid)
        return 
    end
    local account = player:getaccount()
    self.msgqueue[account] = (self.msgqueue[account] or 0) + 1
    if not player:is_conect() then
        --断开链接不处理消息了
        return 
    end

    if not player:is_online() and name ~= "reqcreaterole" and name ~= "createrole" then --未创角 不处理其他消息
        --LOG_ERROR("loss message[%s]", name)
        return 
    end
    --给请求参数设置元表
    local function sproto_default_struct(param)
        for k,v in pairs(param) do
            if type(v) == "table" and v.__type then
                local temp = default_struct[v.__type]
                if not temp then
                    temp = self.sproto:default(v.__type)
                    sproto_default_struct(temp)
                    default_struct[v.__type] = temp
                end
                param[k] = temp
            end
			if type(v) == "table" and v.__arr then
                v.__arr = nil
            end
        end
    end
    local default = request_default[name]
    if not default then
        default = self.sproto:default(name, "REQUEST") or true
        if type(default) == "table" then
            sproto_default_struct(default)
        end

        request_default[name] = default
    end
    local function copy_table(src, dest)
        for k,v in pairs(src) do
            if type(v) == "table" then
                dest[k] = dest[k] or {}
                copy_table(v, dest[k])
            elseif not dest[k] then
                dest[k] = v
            end
        end
    end
    local rawargs
    if args then
        rawargs = table.copy(args, true)
    end
    if default and type(default) == "table" then
        if not args then
            args = {}
        end
        copy_table(default, args)
    end
    if not AgentManager.s_filter_print[name] then
        print(string.format("player[%s] client request name[%s] args:%s", player:playerbasemodule():get_name(), name, tostring(args)))
    end

    player:process_message(name)

    local f = assert(client_request[name], name ..  " is not found")
    if f then
	    local ok, ret = xpcall(f, debug.traceback, player, args, rawargs)
	    if not ok then
		    LOG_ERROR("handle message(%s) failed : %s", name, ret)   
	    else  
		    if response and ret then
                if not AgentManager.s_filter_print[name] then
                    print(string.format("player[%s] response client request name[%s] args:%s", player:playerbasemodule():get_name(), name, tostring(ret)))
                end
			    player:send_msg(response(ret))
		    end
	    end
    else
	    LOG_ERROR("unhandled message : %s", name)  
    end
    
end
function AgentManager:handle_response(playerid, id, args)
end

--登出玩家
function AgentManager:logout_player(player)
	-- NOTICE: The logout MAY be reentry
	skynet.call(self.gateserver, "lua", "logout", player:getaccount())
end

function AgentManager:disconnect_agent(player)
    skynet.call(self.gateserver, "lua", "disconnect_agent", player:getaccount())
end

function AgentManager:service_init()
    
end

function AgentManager:safe_quit_over()
    --DBMgrInst():safe_quit()
end

return AgentManager