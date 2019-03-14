local clusterext = require "clusterext"
local account_sql = require "accountsql"
local Database = require "database"
local interaction = require "interaction"
local cacheinterface = require "cacheinterface"
local common = require "common"
local crypt = require "skynet.crypt"
local timext = require "timext"
local skynet = require "skynet"
local config = require "config"

local LoginManager = class("LoginManager")

function LoginManager:ctor()
    self._server_list = {} --服务器列表
    self._global_playerid = 0
    self._accountdb = nil   --账号库
    self._account_list = {} --账号列表
    self._player_list = {}  --根据playerid索引的account表
    self.closeflag = nil
    self._hash_db = {}
end

function LoginManager:init()
    --在节点上打开
    if clusterext.iscluster() then
        timext.open_clock(function() 
            self:run()
        end)
    end
end

function LoginManager:run()
    if skynet.sign_kill() then
        if self.closeflag then
            return
        end
        self.closeflag = true
        
        --退出进程
        skynet.abort()
    end
end

--获取负载均衡游戏服务器
function LoginManager:get_balancing_server(account)
    local server
    local last = self._account_list[account]
    if last then
        server = self._server_list[last.serverid]
        if not server then
            error(string.format("user %s game server %d close", account, last.serverid))
        end
    else
        _, server = next(self._server_list)
    end
    if not server then
        error(string.format("user %s not found game server", account))
    end
    return server
end

function LoginManager:_insert_account(obj)
    self._account_list[obj.account] = obj
    self._player_list[obj.playerid] = obj
end

function LoginManager:_save_account(obj)
    if not obj.save then
        self._accountdb:asyn_query_sql(account_sql.insert_account, obj.account, obj.playerid, obj.serverid)
        obj.save = true
    else
        self._accountdb:asyn_query_sql(account_sql.update_account, obj.serverid, obj.playerid)
    end
end

function LoginManager:_change_account_server(obj, serverid)
    if obj.serverid ~= serverid then
        local last = self._server_list[obj.serverid]
        if not last then
            LOG_ERROR("_change_account_server not found last server %d", obj.serverid)
        else
            clusterext.send(last.address, "lua", "change_account_server", obj)
        end

        obj.serverid = serverid
        self:_save_account(obj)
    end
end

function LoginManager:_get_new_playerid()
    local index = 0
    local num = #config.get_db_config().player
    if num > 0 then
        local least
        for i=0,num-1 do
            local temp = self:_get_db_num(i)
            if not least or least > temp then
                least = temp
                index = i
            end
        end
    end
    local maxid = self:_get_db_maxid(index)
    local newid = math.floor((maxid + 1) * common.player_db_mark + index)
    self:_hash_playerid(newid)
    return newid
end

function LoginManager:_get_db_num(index)
    local info = self._hash_db[index]
    if info then
        return info.num
    end
    return 0
end

function LoginManager:_get_db_maxid(index)
    local info = self._hash_db[index]
    if info then
        return info.maxid
    end
    return 0
end

function LoginManager:_hash_playerid(playerid)
    local index = common.get_player_db(playerid)
    local info = self._hash_db[index]
    if not info then
        info = {
            num = 0,
            maxid = 0,
        }
        self._hash_db[index] = info
    end

    local id = math.floor(playerid / common.player_db_mark)
    if id > info.maxid then
        info.maxid = id
    end
end

function LoginManager:_create_account(account, serverid)
    local last = self._account_list[account]
    if last then
        self:_change_account_server(last, serverid)
        return last
    else
        local obj = {
            account = account,
            serverid = serverid,
            playerid = self:_get_new_playerid(),
            gm = nil,
            save = nil,
        }
        self:_insert_account(obj)
        self:_save_account(obj)
        return obj
    end
end

--账号登录
function LoginManager:login_handler(serverid, account, secret, addr)
    serverid = tonumber(serverid)
	print(string.format("%s is login server %d, secret is %s", account, serverid, crypt.hexencode(secret)))
    
    -- only one can login, because disallow multilogin
    local server
    if serverid ~= 0 then
        server = self._server_list[serverid]
    end
    if not server then
        server = self:get_balancing_server(account)
    end
    local obj = self:_create_account(account, server.serverid)
    local subid = clusterext.call(server.address, "lua", "secret", obj, secret, addr)
	return string.format("%d@%s:%d",subid,server.ip,server.port)
end

function LoginManager:load_account_list(serverid)
    local ret = {}
    for _, v in pairs(self._account_list) do
        if v.serverid == serverid then
            ret[v.playerid] = v.account
        end
    end
    return ret
end

function LoginManager:open()
    --连接账号数据库
    self._accountdb = Database.new("world")

    --检测数据库刷新
    local query_obj = self._accountdb:syn_query_sql(account_sql.select_account)
    if query_obj then
        for _,obj in pairs(query_obj) do
            obj.save = true
            self:_insert_account(obj)
            self:_hash_playerid(obj.playerid)
        end
    end

    --服务器开启
    local gamelist = config.get_gamelist_config()
    for k, v in pairs(gamelist) do
        local serverid = tonumber(v.serverid)
        self._server_list[serverid] = {
            ip = v.network_ip,
            port = v.network_port,
            address = get_remote_service(k).gateservice,
            serverid = serverid,
        }
    end
end

function LoginManager:delete_account(account)
    local user = self._account_list[account]
    if user then
        self._accountdb:syn_query_sql(account_sql.delete_account, account)
        return user.playerid
    end
end

--登录某帐号
function LoginManager:gm_login_account(playerid)
    --print(string.format("%s is login of mask", playerid))
    local obj = self._player_list[playerid]
    if not obj then
        LOG_ERROR("gm_login_account not found playerid %d", playerid)
        return
    end
    local server = self._server_list[obj.serverid]
    if not server then
        LOG_ERROR("gm_login_account not found player server %d", obj.serverid)
        return
    end
    return clusterext.call(server.address, "lua", "gm_login_account", obj)
end

--获取玩家服务
function LoginManager:_get_player_server(playerid)
    local obj = self._player_list[playerid]
    if not obj then
        LOG_ERROR("_get_player_server not found player %s", tostring(debug.traceback()))
        return
    end
    local server = self._server_list[obj.serverid]
    if not server then
        LOG_ERROR("_get_player_server not found player server %s", tostring(debug.traceback()))
        return
    end
    return server
end

--查询玩家地址
function LoginManager:get_agent_addr(playerid)
    local server = self:_get_player_server(playerid)
    if server then
        return clusterext.call(server.address, "lua", "get_agent_addr", playerid)
    end
end

--玩家消息
function LoginManager:agent_interaction(response, playerid, ...)
    local ret
    local server = self:_get_player_server(playerid)
    if server then
        if response then
            ret = clusterext.call(server.address, "lua", "agent_interaction", true, playerid, ...)
        else
            clusterext.send(server.address, "lua", "agent_interaction", false, playerid, ...)
        end
    end
    if response then
        skynet.retpack(ret)
    end
end

--玩家消息
function LoginManager:group_interaction(group, ...)
    local temp = {}
    for _, playerid in pairs(group) do
        local server = self:_get_player_server(playerid)
        if server then
            temp[server.serverid] = temp[server.serverid] or {}
            table.insert(temp[server.serverid], playerid)
        end
    end
    for serverid, arr in pairs(temp) do
        local server = self._server_list[serverid]
        clusterext.send(server.address, "lua", "group_interaction", arr, ...)
    end
end

return LoginManager