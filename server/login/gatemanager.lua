local class = require "class"
local gatecommon = require "gatecommon"
local common = require "common"
local interaction = require "interaction"
local msgqueue = require "skynet.queue"
local crypt = require "crypt"
local socketdriver = require "socketdriver"
local skynet = require "skynet"
local clusterext = require "clusterext"
local timext = require "timext"
local debugcmd = require "debugcmd"
local config = require "config"
local GateUser = require "gateuser"
local worldcommon = require "worldcommon"
local ServiceBase = require "servicebase"

local GateManager = class("GateManager", ServiceBase)

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

function GateManager:ctor(openclient, closeclient)
	self.accountqueue = {} --账号登录队列 防止重入
	self.online_user = {} --玩家列表 account -> { secret, fd, online, timer, agent, playerid, iscreate }
	self.internal_id = 0 --唯一id
	self.connection = {} -- fd -> connection : { fd , user }
    self.pending_msg = {} --fd 消息缓存 
    self._account_list = {} --记录服务器账号

	self.agentserver = {} --agent服务 
    self.hashserver = {}  --哈希

	--sproto消息
	self.host = nil
	self.proto_request = nil
    self.openclient = openclient
    self.closeclient = closeclient
end

function GateManager:create_agent_server()
    local newkey = #self.hashserver + 1
    local name = "agentservice" .. newkey
	local s = skynet.newservice("agentservice", skynet.self(), name)
    local temp = { address = s }
	self.agentserver[s] = temp
    table.insert(self.hashserver, temp)
	return temp
end

function GateManager:init()
	local protoloader = require "protoloader"
    _, self.host, self.proto_request = protoloader.load(protoloader.GAME)
    
    for i=1,INSTANCE do
        self:create_agent_server()
    end

    self._account_list = clusterext.call(get_cluster_service().loginservice, "lua", "load_account_list", config.get_server_id())
end

--释放
local function release_handler(self, account)
    local user = self.online_user[account]
    if user and user:expire() then
        if user:get_agent() then
            skynet.call(user:get_agent(), "lua", "release_player", user:get_playerid())
        end
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
    for _,k in pairs(t) do
        self.online_user[k] = nil
    end
end

function GateManager:_get_user(account)
    return self.online_user[account]
end

--创建用户
function GateManager:_create_user(obj)
    --[[@obj
        account,
        serverid,
        playerid,
        gm,
    ]]
    local user = GateUser.new(obj)
    self.online_user[user:get_account()] = user
    return user
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

   local user = self:_get_user(account)
    if not user then
        return
    end
    if not user:get_secret() then
        LOG_ERROR("unkown account[%s] secret", account)
        return
    end
    local v = crypt.hmac_hash(user:get_secret(), text)	-- equivalent to crypt.hmac64(crypt.hashkey(text), user.secret)
    if v ~= hmac then
        return
    end
    return account
end

--关联socket
function GateManager:forward(fd, user)
    local c = assert(self.connection[fd])
    c.user = user
	self.openclient(fd)
end
--释放socket
function GateManager:release_socket(fd)
    if self.connection[fd] then
        local c = self.connection[fd]
        if c and c.user then
            c.user:set_fd(nil)
        end
	    self.connection[fd] = nil
    end
    self.closeclient(fd)
end
--socket 断开
function GateManager:disconnect_socket(fd)
	local c = self.connection[fd]
    if c then
        if c.user then
            local agent = c.user:get_agent()
            if agent then
            	skynet.call(agent, "lua", "disconnect_player", c.user:get_playerid())
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
	self.openclient (fd)
end

--加载agent
local balance = 1
function GateManager:get_balance_agent(hashkey)
    return self.hashserver[(hashkey % INSTANCE) + 1]
end
function GateManager:raw_load_agent(user, gm)
	local server = self:get_balance_agent(user:get_playerid())
	if not server then
		LOG_ERROR("gate not found balance agent service")
		return
	end
    local ret = skynet.call(server.address, "lua", "load_player", user:get_obj(), gm)
    if ret then
        user:set_agent(server.address)
    	return true
    end
end
--重连agent
local function back_handler(self, fd, account, islogin, args, check)
	local user = self:_get_user(account)
	if not user or not user:get_agent() then
        skynet.error("not found back user ", account)
        return message_code.error_back
	end
    if check then
        if not args.datetime or not args.sign then
            return message_code.sign_expire
        end
        local platform = skynet.call(user:get_agent(), "lua", "check_login_sign", account, args.datetime, args.sign)
        if not platform then
            return message_code.sign_expire
        end
        args.platform = platform
    end
    if not user:is_online() then
        --skynet.error("not found online user ", account)
        return message_code.error_back
    end
    if user:get_fd() then
        --skynet.error(string.format("reconnect account[%s] kick old socket ", account))
        --原有的链接断开
        self:disconnect_socket(user:get_fd())
    end

    local code = message_code.success
    local iscreate = skynet.call(user:get_agent(), "lua", "reconnect_player", user:get_playerid(), fd, islogin, user:get_obj(), args)
    if not iscreate then
        code = message_code.no_create_role
    end
    user:set_fd(fd)
	self:forward(fd, user)

	return code, user
end
--登录agent
local function login_handler(self, fd, account, args)
    
    local user = self:_get_user(account)
    
    if not user then
        LOG_ERROR("unkown login account %s", account)
        return message_code.user_error
    end
	if user:is_online() then
        return back_handler(self, fd, account, true, args, true)
	end
    local succ
    if not user:get_agent() then
        succ = self:raw_load_agent(user)
    else
        succ = true
    end
    if succ then
        if not args.datetime or not args.sign then
            return message_code.sign_expire
        end
        
        local platform = skynet.call(user:get_agent(), "lua", "check_login_sign", account, args.datetime, args.sign)
        
        if not platform then
            return message_code.sign_expire
        end
        args.platform = platform

	    user:set_fd(fd)
        user:set_online(true)
        user:clear_timer()

        local code = message_code.re_login
        local iscreate = skynet.call(user:get_agent(), "lua", "login_player", user:get_playerid(), fd, user:get_obj(), args)
        
		self:forward(fd, user)
        if not iscreate then
            code = message_code.no_create_role
        end
		return code, user
	end
    return message_code.user_error
end
--
local function gm_login_handler(self, obj)
    local user = self:_get_user(obj.account)
    if not user then
        user = self:_create_user(obj)
    end
    if not user:get_agent() then
        local succ = self:raw_load_agent(user, true)
        if not succ then
        	return
        end
    end
    if not user:is_online() then
        user:start_timer()
    end
    local ret = skynet.call(user:get_agent(), "lua", "is_create_role", user:get_playerid())
    if ret then
        return interaction.pack_agent_address(user:get_playerid(), user:get_agent())
    end
end
--登出
local function logout_handler(self, account, cachetime)
    local user = self:_get_user(account)
    if user then
        if user:get_fd() then
            self:release_socket(user:get_fd())
        end
        user:set_online(false)
        user:start_timer(cachetime)
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
		    skynet.redirect(user:get_agent(), user:get_playerid(), "client", 0, t.msg, t.sz)
        end
        user:add_mqlen(#self.pending_msg[fd])
    end
	return account
end
--消息处理
function GateManager:handle_message(fd, msg, sz)
    local user = self.connection[fd] and self.connection[fd].user
    if user and user:get_agent() then
        --过载
        user:add_mqlen(1)
        if user:get_mqlen() > gatecommon.message_overload then
            skynet.mqfilter(user:get_agent(), user:get_playerid(), skynet.PTYPE_CLIENT)
            user:sub_mqlen(user:get_mqlen())
            self:disconnect_socket(user:get_fd())
        else
            skynet.redirect(user:get_agent(), user:get_playerid(), "client", 0, msg, sz)
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
function GateManager:check_mq(mq)
    for k,v in pairs(mq) do
        local user = self:_get_user(k)
        if user then
           user:sub_mqlen(v)
        end
    end
end
-- call by agent 登出
function GateManager:logout(account, cachetime)
    local tempqueue = self:get_account_queue(account)
    tempqueue.call(logout_handler, self, account, cachetime)
end
-- call by login server 玩家同时在线则T出玩家
function GateManager:kick(account)
    local user = self:_get_user(account)
    if user and user:get_agent() then
        skynet.call(user:get_agent(), "lua", "kick_player", user:get_playerid())
    else
        --直接登出
        self.online_user[account] = nil
    end
end
--断开agent
function GateManager:disconnect_agent(account)
    local user = self:_get_user(account)
    if user and user:get_fd() then
        self:disconnect_socket(user:get_fd())
    end
end
-- loginserver notify gameserver user token 设置登录密码
function GateManager:secret(obj, _secret, addr)
    print("GateManager secret", obj)
    local user = self:_get_user(obj.account)
    if not user then
        user = self:_create_user(obj)
    else
        user:update_obj(obj)
    end
    self.internal_id = self.internal_id + 1
    user:set_secret(_secret)
    user:set_ip(addr)
    self._account_list[obj.playerid] = obj.account
    return self.internal_id
end
--强制登录帐号
function GateManager:gm_login_account(obj)
    local tempqueue = self:get_account_queue(obj.account)
    return tempqueue.call(gm_login_handler, self, obj)
end

function GateManager:safe_quit()
    --T出所有玩家
    for _,user in pairs(self.online_user) do
        if user:get_agent() and user:is_online() then
            skynet.call(user:get_agent(), "lua", "kick_player", user:get_playerid())
        end
    end
    
    timext.close_clock()
end

--无视玩家是否在线的指令请求
function GateManager:player_command(response, playerid, ...)
    local ret
    local account = self._account_list[playerid]
    local agent
    if account then
        local user = self:_get_user(account)
        if user then
            agent = user:get_agent()
        end
        if not agent then
            agent = self:gm_login_account({
                serverid = config.get_server_id(),
                account = account,
                playerid = playerid,
            })
        end
    else
        --不在当前服务器 去世界上查询
        agent = clusterext.call(get_cluster_service().loginservice, "lua", "gm_login_account", playerid)
    end
    if agent then
        if response then
            ret = interaction.call(agent, "lua", ...)
        else
            interaction.send(agent, "lua", ...)
        end
    end
    if response then
        skynet.retpack(ret)
    end
end

--发送给所有
function GateManager:send_online_player(...)
    for k,v in pairs(self.agentserver) do
        skynet.send(v.address, "lua", "send_online_player", ...)
    end
end

--查找玩家地址
function GateManager:fuzzy_agent_addr(playerid)
    local account = self._account_list[playerid]
    if account then
        return self:get_agent_addr(playerid)
    else
        --不在当前服务器 去世界上查询
        return clusterext.call(get_cluster_service().loginservice, "lua", "get_agent_addr", playerid)
    end
end

--查找玩家地址
function GateManager:get_agent_addr(playerid)
    local agent = self:_get_user_agent(playerid)
    if agent then
        return interaction.pack_agent_address(playerid, agent)
    end
end

--获取在线玩家agent
function GateManager:_get_user_agent(playerid, nolog)
    local account = self._account_list[playerid]
    if not account then
        if not nolog then
            LOG_ERROR("_get_user_agent not found player %s", tostring(debug.traceback()))
        end
    else
        local agent
        local user = self:_get_user(account)
        if user then
            agent = user:get_agent()
        end
        if not agent then
            if not nolog then
                LOG_ERROR("_get_user_agent not found online player %s", tostring(debug.traceback()))
            end
        end
        return agent
    end
end

--玩家消息
function GateManager:change_account_server(obj)
    local playerid = obj.playerid
    local account = self._account_list[playerid]
    if not account then
        LOG_ERROR("change_account_server not found account", playerid)
    else
        local agent = self:_get_user_agent(playerid, true)
        if agent then
            skynet.call(agent, "lua", "kick_player", playerid, 0)
        end

        self._account_list[playerid] = nil
    end
end 

--玩家消息
function GateManager:agent_interaction(response, playerid, ...)
    local ret
    local agent = self:_get_user_agent(playerid)
    if agent then
        if response then
            ret = skynet.call(agent, "lua", "dispatch_interaction", playerid, true, ...)
        else
            skynet.send(agent, "lua", "dispatch_interaction", playerid, false, ...)
        end
    end
    if response then
        skynet.retpack(ret)
    end
end

--模糊玩家消息（不确定是否在当前网关）
function GateManager:fuzzy_agent_interaction(response, playerid, ...)
    local account = self._account_list[playerid]
    if account then
        self:agent_interaction(response, playerid, ...)
    else
        if response then
            local ret = clusterext.call(get_cluster_service().loginservice, "lua", "agent_interaction", true, playerid, ...)
            skynet.retpack(ret)
        else
            clusterext.send(get_cluster_service().loginservice, "lua", "agent_interaction", false, playerid, ...)
        end
    end
end

--组播消息
function GateManager:group_interaction(group, ...)
    local temp = {}
    for _, playerid in pairs(group) do
        local agent = self:_get_user_agent(playerid)
        if agent then
            temp[agent] = temp[agent] or {}
            table.insert(temp[agent], playerid)
        end
    end
    for agent, arr in pairs(temp) do
        skynet.send(agent, "lua", "group_interaction", arr, ...)
    end
end

--模糊组播消息（不确定是否在当前网关）
function GateManager:fuzzy_group_interaction(group, ...)
    local found = {}
    for k,playerid in pairs(group) do
        local account = self._account_list[playerid]
        if account then
            table.insert(found, playerid)
            group[k] = nil
        end
    end
    self:group_interaction(found, ...)
    if not table.empty(group) then
        clusterext.send(get_cluster_service().loginservice, "lua", "group_interaction", group, ...)
    end
end

return GateManager