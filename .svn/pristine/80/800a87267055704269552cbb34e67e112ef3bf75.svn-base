local class = require "class"
local IPlayerModule = require "iplayermodule"
local mailinterface = require "mailinterface"
local clusterext = require "clusterext"

local PlayerMailModule = class("PlayerMailModule", IPlayerModule)

--构造函数
function PlayerMailModule:ctor(player)
    self._player = player
end

--读库
function PlayerMailModule:loaddb()
end

--初始化
function PlayerMailModule:init()
end

--AI
function PlayerMailModule:run(frame)
end

--上线处理
function PlayerMailModule:online()
    clusterext.send(get_cluster_service().mailserver, "lua", "player_online", self._player:getplayerid())
end
 
--下线处理
function PlayerMailModule:offline()
    clusterext.send(get_cluster_service().mailserver, "lua", "player_offline", self._player:getplayerid())
end

--0点刷新
function PlayerMailModule:dayrefresh()
end

--周一0店刷新
function PlayerMailModule:weekrefresh()
end

return PlayerMailModule