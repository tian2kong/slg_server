local skynet = require "skynet"
local MailManager = require "mailmanager"
local timext = require "timext"
local thinginterface = require "thinginterface"
require "static_config"
local debugcmd = require "debugcmd"

local s_mail_manager = MailManager.new()

local CMD = {}

CMD.send_mail = register_command(s_mail_manager, "send_mail")
CMD.request_mail = register_command(s_mail_manager, "request_mail", true)
CMD.extract_mail = register_command(s_mail_manager, "extract_mail", true)
CMD.del_mail = register_command(s_mail_manager, "del_mail")
CMD.open_mail = register_command(s_mail_manager, "open_mail")
CMD.player_online = register_command(s_mail_manager, "player_online")
CMD.player_offline = register_command(s_mail_manager, "player_offline")

skynet.init(function()
    debugcmd.register_debugcmd(CMD)
    
    s_mail_manager:init()
    local function clock_func()
        s_mail_manager:run()
    end
    timext.open_clock(clock_func)
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd])
        f(...)
	end)
end)