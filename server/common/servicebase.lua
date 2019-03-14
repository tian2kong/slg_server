local skynet = require "skynet"
local interaction = require "interaction"
local debugcmd = require "debugcmd"
local class = require "class"
local Database = class("Database")

local ServiceBase = class("ServiceBase")

function ServiceBase:ctor(clustername, quitweight)
    assert(clustername)
    self.clustername = clustername
    self.quit_weight = quitweight or 0
end

function ServiceBase:service_init()
end

function ServiceBase:safe_quit()
end

function ServiceBase:service_init_over()
end

function ServiceBase:safe_quit_over()
end

function ServiceBase:hotfix_file(file)
    debugcmd.hotfix_file(file)
end

function ServiceBase:start(CMD, nores)
    interaction.register_service_event(self.clustername, { safe_quit = self.quit_weight, service_init = true, service_init_over = true })
    CMD.hotfix_file = register_command(self, "hotfix_file")
    CMD.service_init = register_command(self, "service_init", not nores and true)
    CMD.service_init_over = register_command(self, "service_init_over", not nores and true)
    CMD.safe_quit = register_command(self, "safe_quit", not nores and true)
    CMD.safe_quit_over = register_command(self, "safe_quit_over", not nores and true)
end

return ServiceBase