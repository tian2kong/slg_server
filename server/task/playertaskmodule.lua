local class = require "class"
local IPlayerModule = require "iplayermodule"

local PlayerTaskModule = class("PlayerTaskModule", IPlayerModule)

--构造函数
function PlayerTaskModule:ctor(player)
    self._player = player
end

--读库
function PlayerTaskModule:loaddb()
end

--初始化
function PlayerTaskModule:init()
end

--从服务那边初始化数据
function PlayerTaskModule:init_service()
	
end

--不需要online就执行的ai逻辑
function PlayerTaskModule:init_run()

end

--AI
function PlayerTaskModule:run(frame)
end

--上线处理
function PlayerTaskModule:online()
end

--暂离处理
function PlayerTaskModule:away()
end
 
--下线处理
function PlayerTaskModule:offline()
end

--系统时间点刷新
function PlayerTaskModule:dayrefresh()
end

--周一0店刷新
function PlayerTaskModule:weekrefresh()
end

--摧毁服务
function PlayerTaskModule:destroy()

end

return PlayerTaskModule