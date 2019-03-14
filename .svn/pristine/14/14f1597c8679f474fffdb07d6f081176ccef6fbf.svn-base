local class = require "class"
local gatecommon = require "gatecommon"
local gateserver = require "gateserver"
local common = require "common"
local interaction = require "interaction"
local msgqueue = require "skynet.queue"
local crypt = require "crypt"
local socketdriver = require "socketdriver"
local skynet = require "skynet"
local clusterext = require "clusterext"
local timext = require "timext"
local debugcmd = require "debugcmd"

local GateManager = class("GateManager")

local message_code = {
    success = 0,
    error_message = 1,--协议号不对
    error_token = 2,--token验证失败
    multiple_login = 3,--已经登录
    error_back = 4,--没有找到重连的对象
    no_create_role = 5,--还未创建角色
    re_login = 6,--登录成功(重新登录)
    user_error = 7,--加载角色错误
    sign_expire = 8,--验证码失效
}

function GateManager:ctor()
	self.accountqueue = {} --账号登录队列 防止重入
	self.online_user = {} --玩家列表 account -> { secret, fd, online, timer, agent, playerid, iscreate }
	self.internal_id = 0 --唯一id
	self.connection = {} -- fd -> connection : { fd , user }
	self.pending_msg = {} --fd 消息缓存 

	self.agentserver = {} --agent服务 
    self.hashserver = {}  --哈希

	--sproto消息
	self.host = nil
	self.proto_request = nil

end

function GateManager:create_agent_server()
    local newkey = #self.hashserver + 1
    local name = "agentservice" .. newkey
	local s = skynet.newservice("agentservice", skynet.self(), name)
    registercluster(name, s)
    local temp = { address = s, burden = 0 }
	self.agentserver[s] = temp
    table.insert(self.hashserver, temp)
	return temp
end

function GateManager:init(config)
	local protoloader = require "protoloader"
	_, self.host, self.proto_request = protoloader.load(protoloader.GAME)

    for i=1,gatecommon.agent_pool do
        self:create_agent_server()
    end
    local address = skynet.self()
    if clusterext.iscluster() then
        address = clusterext.pack_cluster_address(clusterext.self(), config.servername)
    end
    clusterext.call(get_cluster_service().logind, "lua", "register_gate", config.servername, address, config.network_ip, config.network_port)
end

--释放
local function release_handler(self, account)
    local user = self.online_user[account]
    if user and user.timer and user.timer:expire() then
        if user.agent then
            skynet.call(user.agent, "lua", "release_player", user.playerid)
            self.agentserver[user.agent].burden = self.agentserver[user.agent].burden - 1
        end
        self.online_user[account] = nil
        return true
    end
end
function GateManager:run(frame)
	--离线缓存数据
    local t = {}
    for k,v in pairs(self.online_user) do
        local tempqueue = self:get_account_queue(k)
        if tempqueue.call(release_handler, self, k) then
            if tempqueue.empty() then
                self:clear_account_queue(k)
            end
            table.insert(t, k)
        end
    end
    if not table.empty(t) then
        clusterext.call(get_cluster_service().logind, "lua", "release", t)
    end
end

--创建用户
function GateManager:raw_create_user(account)
    self.online_user[account] = {
    	secret = nil, --密匙
    	fd = nil, --socket连接
    	online = nil, --在线标志
    	timer = nil, --定时器
    	agent = nil, --玩家服务
    	playerid = nil, --角色id
        mqlen = 0,--消息队列
	}
    return self.online_user[account]
end

--获取玩家队列
function GateManager:get_account_queue(account)
    if not self.accountqueue[account] then
        local execulte, empty = msgqueue()
        self.accountqueue[account] = { call = execulte, empty = empty }
    end
    return self.accountqueue[account]
end
function GateManager:clear_account_queue(account)
    self.accountqueue[account] = nil
end

--账号解析
local function userid(username)
    -- base64(account)@base64(server)#base64(subid)
    local account, servername, subid = username:match "([^@]*)@([^#]*)#(.*)"
    return crypt.base64decode(account), crypt.base64decode(subid), crypt.base64decode(servername)
end
--密码解析
function GateManager:auth_handler(fd, token)
    if not token then
        return
    end

    local username, version, hmac = string.match(token, "([^:]*):([^:]*):([^:]*)")
    hmac = crypt.base64decode(hmac)

    local account = userid(username)
    local text = string.format("%s:%s", username, version)

   local user = self.online_user[account]
    if not user then
        return
    end
    if not user.secret then
        LOG_ERROR("unkown account[%s] secret", account)
        return
    end
    local v = crypt.hmac_hash(user.secret, text)	-- equivalent to crypt.hmac64(crypt.hashkey(text), user.secret)
    if v ~= hmac then
        return
    end
    return account
end

--关联socket
function GateManager:forward(fd, user)
    local c = assert(self.connection[fd])
    c.user = user
	gateserver.openclient(fd)
end
--释放socket
function GateManager:release_socket(fd)
    if self.connection[fd] then
        local c = self.connection[fd]
        if c and c.user then
            c.user.fd = nil
        end
	    self.connection[fd] = nil
    end
    gateserver.closeclient(fd)
end
--socket 断开
function GateManager:disconnect_socket(fd)
	local c = self.connection[fd]
    if c then
        if c.user then
            local agent = c.user.agent
            if agent then
            	skynet.call(agent, "lua", "disconnect_player", c.user.playerid)
            end
        end
        self:release_socket(fd)
    end
end
--新的socket连接
function GateManager:connect_socket(fd, addr)
	local c = {
      fd = fd,
      ip = addr,
      user = nil,
    }
    self.connection[fd] = c
	gateserver.openclient (fd)
end

--加载agent
local balance = 1
function GateManager:get_balance_agent(hashkey)
    return self.hashserver[(hashkey % gatecommon.agent_pool) + 1]
    --[[
    local server = self.hashserver[balance]
    balance = balance + 1
    if balance > gatecommon.agent_pool then
        balance = 1
    end
    return server
    ]]
    --[[
    local server 
    for _,v in pairs(self.agentserver) do
        if v.burden < gatecommon.agent_threshold and (not server or server.burden > v.burden) then
            server = v
        end
    end
    if not server then
    	server = self:create_agent_server()
    end
    return server
    ]]
end
function GateManager:raw_load_agent(msg, gm)
	local user = self.online_user[msg.account]
	if not user or user.agent then
        skynet.error("load agent account %s error", msg.account)
        return
	end

	local server = self:get_balance_agent(msg.playerid)
	if not server then
		LOG_ERROR("gate not found balance agent service")
		return
	end
    local ret = skynet.call(server.address, "lua", "load_player", msg, gm)
    if ret then
    	user.agent = server.address
    	user.playerid = msg.playerid
        server.burden = server.burden + 1
    	return true
    end
end
--重连agent
local function back_handler(self, fd, account, islogin, args, check)
	local user = self.online_user[account]
	if not user or not user.agent then
        skynet.error("not found back user ", account)
        return message_code.error_back
	end
    if check then
        if not args.datetime or not args.sign then
            return message_code.sign_expire
        end
        local platform = skynet.call(user.agent, "lua", "check_login_sign", account, args.datetime, args.sign)
        if not platform then
            return message_code.sign_expire
        end
        args.platform = platform
    end
    if not user.online then
        --skynet.error("not found online user ", account)
        return message_code.error_back
    end
    if user.fd then
        --skynet.error(string.format("reconnect account[%s] kick old socket ", account))
        --原有的链接断开
        self:disconnect_socket(user.fd)
    end

    local code = message_code.success
    local iscreate = skynet.call(user.agent, "lua", "reconnect_player", user.playerid, fd, islogin, user.ip, args)
    if not iscreate then
        code = message_code.no_create_role
    end
    user.fd = fd
	self:forward(fd, user)

	return code, user
end
--登录agent
local function login_handler(self, fd, account, args)
	local user = self.online_user[account]
    if not user then
        LOG_ERROR("unkown login account %s", account)
        return message_code.user_error
    end
	if user.online then
        return back_handler(self, fd, account, true, args, true)
	end
    local succ
    if not user.agent then
        local ret = clusterext.call(get_cluster_service().logind, "lua", "check_account", account)
        if not ret or not ret.playerid then
            LOG_ERROR("unkown account %s", account)
            return message_code.user_error
        end

        succ = self:raw_load_agent(ret)
    else
        succ = true
    end
    if succ then
        if not args.datetime or not args.sign then
            return message_code.sign_expire
        end
        local platform = skynet.call(user.agent, "lua", "check_login_sign", account, args.datetime, args.sign)
        if not platform then
            return message_code.sign_expire
        end
        args.platform = platform

	    user.fd = fd
	    user.online = true
	    user.timer = nil

        local code = message_code.re_login
	    local iscreate = skynet.call(user.agent, "lua", "login_player", user.playerid, fd, user.ip, args)
		self:forward(fd, user)
        if not iscreate then
            code = message_code.no_create_role
        end
		return code, user
	end
    return message_code.user_error
end
--
local function gm_login_handler(self, msg)
    local user = self.online_user[msg.account]
    if not user then
        user = self:raw_create_user(msg.account)
    end
    if not user.agent then
        local succ = self:raw_load_agent(msg, true)
        if not succ then
        	return
        end
    end
    if not user.online then
        user.timer = timext.create_timer(common.offline_cache_time)
    end
    local ret = skynet.call(user.agent, "lua", "is_create_role", user.playerid)
    if ret then
        return interaction.pack_agent_address(msg.playerid, user.agent)
    end
end
--登出
local function logout_handler(self, account, cachetime)
    local user = self.online_user[account]
    if user then
        if user.fd then
            self:release_socket(user.fd)
        end
        user.online = nil
        user.timer = timext.create_timer(cachetime or common.offline_cache_time)
        clusterext.call(get_cluster_service().logind, "lua", "logout", account)
    end
end
--用户登录
local function user_login(self, fd, msg, sz)
    local msgcode = message_code.success
	local type, name, args, response = self.host:dispatch(msg, sz)
    local user
	assert(type == "REQUEST")
    local account
    if name ~= "login" and name ~= "back" then
    	--LOG_ERROR("user_login but error sproto message %s", name)
        msgcode = message_code.message_error
    else
        account = self:auth_handler(fd, args.token)
        if not account then
            msgcode = message_code.error_token
        else
            if name == "login" then
                local tempqueue = self:get_account_queue(account)
                msgcode, user = tempqueue.call(login_handler, self, fd, account, args)
            elseif name == "back" then
                local tempqueue = self:get_account_queue(account)
                msgcode, user = tempqueue.call(back_handler, self, fd, account, nil, args)
            end
        end
    end
    if response then
        local package = string.pack (">s2", response ({code = msgcode}))
        socketdriver.send(fd, package)
    end
    if user then
        queue = self.pending_msg[fd]
	    for _, t in pairs (queue) do
		    skynet.redirect(user.agent, user.playerid, "client", 0, t.msg, t.sz)
	    end
        user.mqlen = user.mqlen + #self.pending_msg[fd]
    end
	return account
end
--消息处理
function GateManager:handle_message(fd, msg, sz)
    local user = self.connection[fd] and self.connection[fd].user
    if user and user.agent then
        --过载
        user.mqlen = user.mqlen + 1
        if user.mqlen > gatecommon.message_overload then
            skynet.mqfilter(user.agent, user.playerid, skynet.PTYPE_CLIENT)
            user.mqlen = 0
            self:disconnect_socket(user.fd)
        else
            skynet.redirect(user.agent, user.playerid, "client", 0, msg, sz)
        end
        return
    end

	local queue = self.pending_msg[fd]
	if queue then
		table.insert(queue, { msg = msg, sz = sz })
	else
		self.pending_msg[fd] = {}

		local ok, account = xpcall(user_login, debug.traceback, self, fd, msg, sz)

		if not ok then
            self:release_socket(fd)
		end

		self.pending_msg[fd] = nil
	end
end

-- call by agent 
function GateManager:check_mq(source, mq)
    for k,v in pairs(mq) do
        local user = self.online_user[k]
        if user then
            user.mqlen = user.mqlen - v
            if user.mqlen < 0 then
                user.mqlen = 0
            end
        end
    end
end
-- call by agent 登出
function GateManager:logout(source, account, cachetime)
    local tempqueue = self:get_account_queue(account)
    tempqueue.call(logout_handler, self, account, cachetime)
end
-- call by login server 玩家同时在线则T出玩家
function GateManager:kick(source, account)
    local user = self.online_user[account]
    if user and user.agent then
        skynet.call(user.agent, "lua", "kick_player", user.playerid)
    else
        --直接登出
        self.online_user[account] = nil
        clusterext.call(get_cluster_service().logind, "lua", "release", account)
    end
end
--断开agent
function GateManager:disconnect_agent(source, account)
    local user = self.online_user[account]
    if user and user.fd then
        self:disconnect_socket(user.fd)
    end
end
-- loginserver notify gameserver user token 设置登录密码
function GateManager:secret(source, account, secret, addr)
    if not secret then
        LOG_ERROR("account[%s] secret is nil", account)
    end
    local user = self.online_user[account]
    if not user then
        user = self:raw_create_user(account)
    end
    self.internal_id = self.internal_id + 1
    user.secret = secret
    user.ip = addr
    return self.internal_id
end
--强制登录帐号
function GateManager:gm_login_account(source, msg)
    local tempqueue = self:get_account_queue(msg.account)
    return tempqueue.call(gm_login_handler, self, msg)
end
--服务指令
function GateManager:handle_command(cmd, ...)
	local func = self[cmd]
	if not func or type(func) ~= "function" then
		LOG_ERROR("gate handle_command unkown cmd %s", cmd)
	else
		return func(self, ...)
	end
end

function GateManager:safe_quit()
    --T出所有玩家
    for _,user in pairs(self.online_user) do
        if user.agent and user.online then
            skynet.call(user.agent, "lua", "kick_player", user.playerid)
        end
    end
    
    timext.close_clock()
end

function GateManager:safe_quit_over()
    --T出所有玩家
    for k,v in pairs(self.agentserver) do
        skynet.call(v.address, "lua", "safe_quit_over")
    end
end

function GateManager:service_init()
    for k,v in pairs(self.agentserver) do
        skynet.send(v.address, "lua", "service_init")
    end
end

function GateManager:hotfix_file(source, file)
    debugcmd.hotfix_file(file)
    for k,v in pairs(self.agentserver) do
        skynet.send(v.address, "lua", "hotfix_file", file)
    end
end

return GateManager