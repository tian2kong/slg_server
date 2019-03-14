local class = require "class"

local IPlayerModule= class("IPlayerModule")

--构造函数
function IPlayerModule:ctor(player)
    self._player = player
end

--读库
function IPlayerModule:loaddb()
end

--初始化
function IPlayerModule:init()
end

--从服务那边初始化数据
function IPlayerModule:init_service()
	
end

--不需要online就执行的ai逻辑
function IPlayerModule:init_run()

end

--AI
function IPlayerModule:run(frame)
end

--上线处理
function IPlayerModule:online()
end

--暂离处理
function IPlayerModule:away()
end
 
--下线处理
function IPlayerModule:offline()
end

--系统时间点刷新
function IPlayerModule:dayrefresh()
end

--周一0店刷新
function IPlayerModule:weekrefresh()
end

--摧毁服务
function IPlayerModule:destroy()

end

--
function IPlayerModule:update_field(field, value)
    
end

return IPlayerModule