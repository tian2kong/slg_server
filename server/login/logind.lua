local login = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"
local clusterext = require "clusterext"
local account_sql = require "accountsql"
local Database = require "database"
local interaction = require "interaction"
local cacheinterface = require "cacheinterface"
local config = require "config"
local common = require "common"
local debugcmd = require "debugcmd"
local ServiceBase = require "servicebase"
local class = require "class"

local accountdatabase   --账号库
local s_quitflag = nil  --登出标记
local s_initoverflag = nil --初始化完成标记

local serverconfig = {}
local global_playerid = 0
do
    local temp = table.pack(...)
    serverconfig.ip = temp[1]
    serverconfig.port = temp[2]
    serverconfig.network_ip = temp[3]
    serverconfig.network_port = temp[4]
    serverconfig.serverid = temp[5]
end

local serverconf = {--服务器配置
    host = serverconfig.ip,
	port = serverconfig.port,
	multilogin = false,	-- disallow multilogin
	name = "login_master",
}

local server_list = {} --服务器列表 server -> {address, gameinfo, onlinenum}
local user_list = {} -- account -> {address, subid, server, timer}

--token 验证
function serverconf.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)
	-- todo : auth user's real password
	assert(password == "password")
	return server, user
end

--获取负载均衡游戏服务器
local function get_balancing_server(account)
    local server
    if not server then
        local min
        for k,v in pairs(server_list) do
            if not min or min < v.onlinenum then
                min = v.onlinenum
                server = v
            end
        end
    end
    return server
end

--账号登录
local function raw_create_user(account)
    if not s_initoverflag then
        error(string.format("logind not init over", account))
    end
    local s = get_balancing_server(account)
    if not s then
        error(string.format("user %s not found game server", account))
    end
	local gameserver = s.address
    s.onlinenum = s.onlinenum + 1
	user_list[account] = { address = gameserver, server = s.name}
    return user_list[account]
end
local function raw_login_user(user, subid)
    user.subid = subid
    user.timer = nil
end
function serverconf.login_handler(_, account, secret, addr)
    assert(not s_quitflag) --退出流程登录失败

	print(string.format("%s is login, secret is %s", account, crypt.hexencode(secret)))
    
	-- only one can login, because disallow multilogin
	local last = user_list[account]

    --[[不T玩家了
	if last and last.subid then
		clusterext.call(last.address, "lua", "kick", account)
	end
    last = user_list[account]
    print(last)
	if last and last.subid then--阻塞回来再判断一次
		error(string.format("user %s is already online", account))
	end
    ]]

    if not last then
        last = raw_create_user(account)
    end
	local subid = clusterext.call(last.address, "lua", "secret", account, secret, addr)
    raw_login_user(last, subid)

    local s = server_list[last.server]
	return string.format("%d@%s:%d",subid,s.ip,s.port)
end

local CMD = {}

function CMD.service_init()
    for k,v in pairs(server_list) do
        clusterext.call(v.address, "lua", "service_init")
    end
end

function CMD.service_init_over()
    s_initoverflag = true
end

function CMD.open()
    local LoginService = class("LoginService", ServiceBase)
    function LoginService:safe_quit()
        ServiceBase.safe_quit(self)
        s_quitflag = true
        for k,v in pairs(server_list) do
            clusterext.call(v.address, "lua", "safe_quit")
        end
    end
    function LoginService:safe_quit_over()
        ServiceBase.safe_quit_over(self)
        for k,v in pairs(server_list) do
            clusterext.call(v.address, "lua", "safe_quit_over")
        end
    end
    function LoginService:service_init()
        ServiceBase.service_init(self)
        for k,v in pairs(server_list) do
            clusterext.call(v.address, "lua", "service_init")
        end
    end
    function LoginService:service_init_over()
        ServiceBase.service_init_over(self)
        s_initoverflag = true
    end
    function LoginService:hotfix_file(file)
        ServiceBase.hotfix_file(self, file)
        for k,v in pairs(server_list) do
            clusterext.call(v.address, "lua", "hotfix_file", file)
        end
    end
    local base = LoginService.new('logind', 100)
    base:start(CMD, true)

    --连接账号数据库
    accountdatabase = Database.new("global")

    global_playerid = common.get_server_autoid()  --玩家全局id

    --检测数据库刷新
    local query_obj = accountdatabase:syn_query_sql(account_sql.select_maxid)
    if query_obj then
        local query_table = query_obj[1]
        if query_table and query_table["max(playerid)"] then
            global_playerid = math.max(global_playerid, query_table["max(playerid)"])
        end
    end
    if clusterext.iscluster() then
        clusterext.send(get_cluster_service().worldservice, "lua", "register_server", serverconfig.serverid, serverconfig.network_ip, serverconfig.network_port)
    end
end

--登录某帐号
function CMD.gm_login_account(playerid)
    --print(string.format("%s is login of mask", playerid))
    local msg
    local query_obj = accountdatabase:syn_query_sql(account_sql.select_account, playerid)
    if query_obj then
        local query_table = query_obj[1]
        if query_table and query_table["account"] then 
            msg = query_table
            msg.playerid = playerid
        end
    end
    
    if msg then
        local last = user_list[msg.account]
	    if not last then
            last = raw_create_user(msg.account)
	    end
        return clusterext.call(last.address, "lua", "gm_login_account", msg)
    end
end

--注册网关服务
function CMD.register_gate(name, address, ip, port)
	-- todo: support cluster
    server_list[name] = {
        name = name,
        address = address,
        ip = ip,
        port = port,
        onlinenum = 0,
    }
end

--账号登出
function CMD.logout(account)
	local u = user_list[account]
	if u and u.subid then
		print(string.format("%s@%s is logout", account, u.server))
        u.subid = nil
	end
end

--释放账号 
function CMD.release(arrlist)
    for _,account in pairs(arrlist) do
	    local u = user_list[account]
	    if u then
		    print(string.format("logind %s@%s is release", account, u.server))
            local s = assert(server_list[u.server])
            s.onlinenum = s.onlinenum - 1
            user_list[account] = nil
	    end
    end
end

function CMD.delete_account(playerid)
    accountdatabase:syn_query_sql(account_sql.delete_account, playerid)
end

function CMD.facebook_invate(account, invatecode)
    if invatecode and string.len(invatecode) > 0 then
        local ret = CMD.check_account(account, invatecode)
        if ret.playerid then
            interaction.send(ret.playerid, "lua", "facebook_invate", invatecode)
        end
    end
end

--检测账号是否存在  不存在则直接添加
function CMD.check_account(account, invatecode)
    local ret = {}
    local query_obj = accountdatabase:syn_query_sql(account_sql.select_playerid, account)
    if query_obj then
        local query_table = query_obj[1]
        if query_table then 
            ret = query_table
            ret.account = account
            if invatecode and tonumber(invatecode) ~= ret.playerid and (not ret.invatecode or string.len(ret.invatecode) == 0) then --更新invatecode
                ret.invatecode = invatecode
                accountdatabase:asyn_query_sql(account_sql.update_invatecode, invatecode, account)
            end
        else
            global_playerid = global_playerid + 1
            ret.playerid = global_playerid
            if invatecode and tonumber(invatecode) == ret.playerid then
                invatecode = nil
            end
            ret.invatecode = invatecode
            ret.account = account
            accountdatabase:asyn_query_sql(account_sql.insert_account, account, global_playerid, 0, (invatecode or ""))
        end
    end
    return ret
end

function CMD.get_account_playerid(account)
    local query_obj = accountdatabase:syn_query_sql(account_sql.select_playerid, account)
    if query_obj then
        local query_table = query_obj[1]
        if query_table then
            return query_table["playerid"]
        end
    end
end
function CMD.get_account_player(account)
    local ret
    local query_obj = accountdatabase:syn_query_sql(account_sql.select_playerid, account)
    if query_obj then
        local query_table = query_obj[1]
        if query_table then
            local playerid = query_table["playerid"]
            local info = cacheinterface.call_get_player_info(playerid, {"level", "name", "roleid"})
            ret = info[playerid]
        end
    end
    return ret
end

--注册指令
function serverconf.command_handler(command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(serverconf)