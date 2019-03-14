local class = require "class"
local IPlayerModule = require "iplayermodule"

local PlayerFightModule = class("PlayerFightModule", IPlayerModule)

--构造函数
function PlayerFightModule:ctor(player)
    self._player = player
end

--读库
function PlayerFightModule:loaddb()
end

--初始化
function PlayerFightModule:init()
end

--从服务那边初始化数据
function PlayerFightModule:init_service()
	
end

--不需要online就执行的ai逻辑
function PlayerFightModule:init_run()

end

--AI
function PlayerFightModule:run(frame)
end

--上线处理
function PlayerFightModule:online()
end

--暂离处理
function PlayerFightModule:away()
end
 
--下线处理
function PlayerFightModule:offline()
end

--系统时间点刷新
function PlayerFightModule:dayrefresh()
end

--周一0店刷新
function PlayerFightModule:weekrefresh()
end

--摧毁服务
function PlayerFightModule:destroy()

end

return PlayerFightModule