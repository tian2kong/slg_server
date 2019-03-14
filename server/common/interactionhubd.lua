local skynet = require "skynet"
local clusterext = require "clusterext"
require "skynet.manager"
local timext = require "timext"
local worldcommon = require "worldcommon"
require "cluster_service"

local CMD = {}
local service_list = {} -- 公共服信息

local closeflag = nil
--注册公共服事件
function CMD.register_service_event(address, event)
    if event.safe_quit and type(event.safe_quit) ~= "number" then
        event.safe_quit = 0
    end
    local info = event
    event.address = address
    info[address] = event
    table.insert(service_list, info)
end

function CMD.init_over()
    for k,v in pairs(service_list) do
        if v.service_init then
            skynet.call(v.address, "lua", "service_init")
        end
    end
    for k,v in pairs(service_list) do
        if v.service_init_over then
            skynet.call(v.address, "lua", "service_init_over")
        end
    end
    skynet.retpack(true)
end

function CMD.close_server()
    if closeflag then
        return
    end
    closeflag = true
    local t = {}
    for k,v in pairs(service_list) do
        if v.safe_quit then
            table.insert(t, v)
        end
    end
    table.sort(t, function(a1, a2) 
        return a1.safe_quit > a2.safe_quit
    end)
    for k,v in ipairs(t) do
        skynet.call(v.address, "lua", "safe_quit")
    end
    for k,v in ipairs(t) do
        skynet.call(v.address, "lua", "safe_quit_over")
    end
    --退出进程
    skynet.abort()
end

--通知世界时间
function CMD.notice_world_time(_time)
    _time = _time - math.floor(skynet.now()/100)
    skynet.setenv(worldcommon.TIME_ENV, _time)
end


local function run(frame)
    --关闭skynet通知
    if skynet.sign_kill() then
        CMD.close_server()
    end
end
skynet.init(function()
    local _time = clusterext.call(get_cluster_service().worldservice, "lua", "get_current_time")
    CMD.notice_world_time(_time)

    timext.open_clock(run)
end)

skynet.start(function()

    skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd])
		f(...)
	end)
end)
