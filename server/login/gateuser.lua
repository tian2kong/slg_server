local timext = require "timext"
local common = require "common"

local GateUser = class("GateUser")

--[[@obj:
    account,
    serverid,
    playerid,
    gm,
]]
function GateUser:ctor(obj)
    self._secret = nil --密匙
    self._fd = nil --socket连接
    self._online = nil --在线标志
    self._timer = nil --定时器
    self._agent = nil --玩家服务
    self._playerid = nil --角色id
    self._mqlen = 0--消息队列
    self._obj = obj --登录的信息
    self._ip = nil --登录地址
end

function GateUser:set_ip(ip)
    self._obj.ip = ip
end

function GateUser:get_ip()
    return self._obj.ip
end

function GateUser:set_fd(fd)
    self._fd = fd
end

function GateUser:get_fd()
    return self._fd
end

function GateUser:is_online()
    return self._online
end

function GateUser:set_online(flag)
    self._online = flag
end

function GateUser:get_agent()
    return self._agent
end

function GateUser:set_agent(address)
    self._agent = address
end

function GateUser:update_obj(obj)
    self._obj = obj
end

function GateUser:get_obj()
    return self._obj
end

function GateUser:get_account()
    return self._obj.account
end

function GateUser:get_playerid()
    return self._obj.playerid
end

function GateUser:get_serverid()
    return self._obj.serverid
end

function GateUser:get_secret()
    return self._secret
end

function GateUser:set_secret(secret)
    self._secret = secret
end

function GateUser:clear_timer()
    self._timer = nil
end

function GateUser:start_timer(time)
    time = time or common.offline_cache_time
    if self._timer then
        self._timer:update(time)
    else
        self._timer = timext.create_timer(time)
    end
end

function GateUser:expire()
    return self._timer and self._timer:expire()
end

function GateUser:sub_mqlen(len)
    self._mqlen = self._mqlen - len
    if self._mqlen < 0 then
        self._mqlen = 0
    end
end

function GateUser:add_mqlen(len)
    self._mqlen = self._mqlen + len
end

function GateUser:get_mqlen()
    return self._mqlen
end

return GateUser