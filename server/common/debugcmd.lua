local skynet = require "skynet"
local skynetext = require "skynetext"
local codecache = require "skynet.codecache"

--[[
注册新的后台命令到debug_console:
help为debug后台help命令额外显示的命令说明
cmd为debug后台额外增加的命令
]]

local help = {
    hotfix_static = "hotfix static config",
    dup2out = "dup2 stdout",
    closeserver = "close skynet server",
    hotfix = "hotfix file",
    systime = "show time",
}

local cmd = {}
cmd.hotfix_static = [[
    return function()
        local skynet = require "skynet"
        local configd = skynet.queryservice("configd")
        if not configd then
            print("no found static config service")
        else
            skynet.call(configd, "lua", "hotfix")
        end
        skynet.call(".launcher", "lua", "GC")
    end
]]

cmd.dup2out = [[
    return function(fd, tty)
        local core = require "dup2.core"
        core.dup2(tty)
    end
]]

cmd.systime = [[
    return function(fd, ...)
        require "cluster_service"
        init_cluster_service()
        local clusterext = require "clusterext"
        local list = {...}
        if table.empty(list) then
            local curtime = clusterext.call(get_cluster_service().interactionhubd, "lua", "get_current_time")
            return os.date("!%Y-%m-%d %X", curtime)
        else
            local param = table.concat(list, " ")
            clusterext.send(get_cluster_service().interactionhubd, "lua", "gm_system_time", param)
        end
    end
]]


cmd.closeserver = [[
    return function()
        local interaction = require "interaction"
        interaction.close_server()
    end
]]

cmd.hotfix = [[
    return function(service, file)
        require "cluster_service"
        init_cluster_service()
        local skynet = require "skynet"
        local clusterext = require "clusterext"
        local function hotfix_func(service, file)
            if service == "logind" then
                clusterext.call(get_cluster_service()[service], "lua", "hotfix_file", file)
            else
                clusterext.send(get_cluster_service()[service], "lua", "hotfix_file", file)
            end
        end
        if not file then
            file = service
            service = nil
        end
        if service then
            hotfix_func(service, file)
        else
            for k,v in pairs(get_cluster_service()) do
                hotfix_func(k, file)
            end
        end
        skynet.call(".launcher", "lua", "GC")
    end
]]


local debugcmd = {}
function debugcmd.init(console)
    for k,v in pairs(cmd) do
        skynet.send(console, "lua", "register_command", k, v)
    end
    for k,v in pairs(help) do
        skynet.send(console, "lua", "register_help", k, v)
    end
end

--热更新
local function raw_hotfix_file(file)
    if package.loaded[file] then
        codecache.clear()
        package.loaded[file] = nil
        require(file)
        skynet.error(string.format("hotfix_file success %#x", skynet.self()))
    end
end
function debugcmd.hotfix_file(file)
    print('hotfix', file)
    local ok, err = xpcall(raw_hotfix_file, debug.traceback, file)
    if not ok then
        LOG_ERROR("hotfix_file error %s", tostring(err))
    end
end

--注册回调函数
function debugcmd.register_debugcmd(CMD, func)
    CMD.hotfix_file = func or debugcmd.hotfix_file
end

return debugcmd