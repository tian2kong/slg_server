local class = require "class"

local MapMgrBase = class("MapMgrBase")

--管理基类
function MapMgrBase:ctor()
end

function MapMgrBase:loaddb()
end

function MapMgrBase:init()
end

function MapMgrBase:initcomplete( ... )
	-- body
end

function MapMgrBase:run()
	-- body
end

function MapMgrBase:serverquit()
end

return MapMgrBase