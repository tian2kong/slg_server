local core = require "aoi.core"

--Area Of Interest

local aoi = {}

--创建aoi管理  返回space
function aoi.create()
    return core.create(0)
end

--释放
function aoi.release(space)
    core.release(space)
end

--更新活物id信息   
function aoi.update(space, id, mode, x, y, radis)
    core.update(space, id, mode, x, y, radis)
end

--定期调用 message 函数。每次调用称为一个 tick 。在这个 tick 里，会把发生的 AOI 事件以回调函数的形式发出来，func(watcher, marker)
function aoi.run(space, func)
    core.run(func, space)
end

--计算距离
function aoi.DIST2(obj1, obj2)
    return (obj1.posx - obj2.posx) * (obj1.posx - obj2.posx) + (obj1.posy - obj2.posy) * (obj1.posy - obj2.posy)
end

return aoi