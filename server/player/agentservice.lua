local skynet = require "skynet"
require "static_config"
local socket = require "socket"
local interaction = require "interaction"
local clusterext = require "clusterext"
local common = require "common"
local skynetext = require "skynetext"
local timext = require "timext"
local AgentManager = require "agentmanager"
local GameLogMgr = require "gamelogmgr"
local cluster_service = require "cluster_service"
local debugcmd = require "debugcmd"
do--注册消息
    require "thingmessage"
    require "chatmessage"
    require "tokenmessage"
    require "playermessage"
    require "chargemessage"
    require "mailmessage"
    require "citymessage"
    require "titlemessage"
    require "mapmessage"
    --require "guildmessage"
    -- require "scenemessage"
    -- require "teammessage"
    --require "petmessage"
    --require "partnermessage"
    -- require "equipmessage"
    -- require "fightmessage"
    -- require "friendmessage"
	-- require "shopmessage"
	-- require "spacemessage"
	-- require "trademessage"
	--require "taskmessage"
	-- require "activitymessage"
	-- require "titlemessage"
	-- require "killbossmessage"
	--require "copymapmessage"
	--require "rankmessage"
	--require "arenamessage"
	--require "boonmessage"
	-- require "cardmessage"
    --require "citymessage"
    --require "burnmessage"
    -- require "giftmessage"
    -- require "airshipmessage"
    -- require "waterlandmessage"
    -- require "guidemessage"
    --require "followermessage"
    --require "advanturemessage"
    --require "guildwarmessage"
    -- require "flowermessage"
    -- require "operatemessage"
    -- require "qingyuzhimessage"
    -- require "bigstomachmessage"
    -- require "tianguanmessage"
    -- require "marrymessage"
    --require "guildredbagmessage"
    -- require "marryactivitymessage"
    --require "guildextmessage"
    -- require "huiwumessage"
    -- require "shouximessage"
    -- require "silkmessage"
    -- require "worldbossmessage"
    -- require "horsemessage"
    -- require "summonmessage"
end
do--注册远程消息
    require "cache_interaction"
    require "thing_interaction"
    require "mail_interaction"
    require "chat_interaction"
    -- require "relation_interaction"
    --require "pet_interaction"
    --require "guild_interaction"
	--require "arena_interaction"
	--require "rank_interaction"
	--require "boon_interaction"
    -- require "flower_interaction"
    --require "partner_interaction"
end


local gateserver, servername = ...
local s_agentmgr = AgentManager.new(gateserver, servername)

local CMD = {}
CMD.load_player = register_command(s_agentmgr, "load_player", true)
CMD.login_player = register_command(s_agentmgr, "login_player", true)
CMD.check_login_sign = register_command(s_agentmgr, "check_login_sign", true)
CMD.is_create_role = register_command(s_agentmgr, "is_create_role", true)
CMD.disconnect_player = register_command(s_agentmgr, "disconnect_player", true)
CMD.kick_player = register_command(s_agentmgr, "kick_player", true)
CMD.release_player = register_command(s_agentmgr, "release_player", true)
CMD.reconnect_player = register_command(s_agentmgr, "reconnect_player", true)
CMD.service_init = register_command(s_agentmgr, "service_init")
CMD.safe_quit_over = register_command(s_agentmgr, "safe_quit_over", true)

function AgentManagerInst()
    return s_agentmgr
end

local s_gamelog = GameLogMgr.new()
function GameLogInst()
    return s_gamelog
end
skynet.init(function()
    debugcmd.register_debugcmd(CMD)

    s_agentmgr:init(gateserver)
    --时钟
    local function clock_func(frame)
        s_agentmgr:run(frame)
    end
    timext.open_clock(clock_func)

    s_gamelog:init()
end)

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = assert(CMD[cmd], "unkown agent command " .. cmd)
        f(...)
	end)
end)