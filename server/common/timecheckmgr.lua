local timext = require "timext"
local class = require "class"
local TimeCheckMgr = class("TimeCheckMgr")

--[[
    检查队列的时间配置
    checkCfg = {1,300,3600} -- 1秒、5分钟、1小时三级检查队列
]]
local pairs = pairs

local normal_checkCfg = {1, 300, 3600}

function TimeCheckMgr:ctor(checkCfg, completeHandler)
    self._checkCfg = checkCfg or normal_checkCfg
    self._checkList = {}
    self._checkTimer = {}
    -- 默认完成调用的方法
    self._completeHandler = completeHandler
    if not completeHandler then
       LOG_ERROR("TimeCheckMgr create err")
    end
    for index, _ in ipairs(self._checkCfg) do
        self._checkList[index] = {}
    end
end

function TimeCheckMgr:run(current_time)
    -- 检查锁队列
    current_time = current_time or timext.current_time()
    
    -- 遍历队列
    for index = #self._checkCfg, 1, -1 do
        if self._checkTimer[index] and self._checkTimer[index]:expire() then
            self._checkTimer[index]:update(self._checkCfg[index])
            local check_time = self._checkCfg[index] + current_time
            local array = self._checkList[index]
            for key, data in pairs(array) do
                print(index,key, data.endTime, check_time)
                if data.endTime <= check_time then
                    array[key] = nil
                    if self._checkList[index - 1] then
                        self._checkList[index - 1][key] = data
                    else
                        if data.completeHandler then
                            data.completeHandler(key, data.data)
                        else
                            self._completeHandler(key, data.data)
                        end
                    end
                end
            end
        end
    end
end

--[[
    添加检查对象
    key     对象唯一key
    data    中转数据
    endTime 到期时间
    completeHandler 完成调用的方法，如果不传，则调用默认完成方法
]]
function TimeCheckMgr:addCheckItem(key, data, endTime, completeHandler)
    local curTime = timext.current_time()
    -- if curTime >= endTime then
    --     return false
    -- end

    -- 检查下是否已经有这个key了
    for _, arr in pairs(self._checkList) do
        if arr[key] then
            return false
        end
    end

    local remaintime = endTime - curTime
    -- 遍历放进适合的队列中
    for index = #self._checkCfg, 1, -1 do
        local check_second = self._checkCfg[index]
        if check_second <= remaintime then
            self._checkList[index][key] = {
                data = data,
                endTime = endTime,
                completeHandler = completeHandler,
            }
            if not self._checkTimer[index] then
                self._checkTimer[index] = timext.create_timer(check_second)
            end
            -- log.Dump("timecheckmgr", self._checkList, "TimeCheckMgr.addCheckItem._checkList:")
            return true
        end
    end

    -- 如果都没有加上，直接放在第一层
    do
        local check_second = self._checkCfg[1]
        self._checkList[1][key] = {
            data = data,
            endTime = endTime,
            completeHandler = completeHandler,
        }
        if not self._checkTimer[1] then
            self._checkTimer[1] = timext.create_timer(check_second)
        end
        return true
    end
end

function TimeCheckMgr:removeCheckItem(key)
    -- 检查下是否已经有这个key了
    for _, arr in pairs(self._checkList) do
        if arr[key] then
            arr[key] = nil
            return true
        end
    end

    return false
end

function TimeCheckMgr:changeEndTime(key, endTime)
    for index, arr in pairs(self._checkList) do
        repeat
            local data = arr[key]
            if not data then
                break
            end

            local curtime = timext.current_time()
            data.endTime = endTime
            local remaintime = endTime - curTime
            for i = #self._checkCfg, 1, -1 do
                local check_second = self._checkCfg[index]
                if check_second <= remaintime then
                    if index ~= i then
                        self._checkList[i][key] = data
                        arr[key] = nil
                        if not self._checkTimer[i] then
                            self._checkTimer[index] = timext.create_timer(check_second)
                        end
                    end                 
                end
            end
            return true
        until 0;
    end
end

return TimeCheckMgr