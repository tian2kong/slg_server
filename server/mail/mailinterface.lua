local clusterext = require "clusterext"
local skynet = require "skynet"
require "cluster_service"

local mailinterface = BuildInterface("mailinterface")

--[[给指定玩家发送一封邮件
params : 参数数组
tokens : 货币数据 currency -> value
thingdata : 为物品数据 cfgid -> num
]]
function mailinterface.send_mail(playerid, mailid, params, tokens, thingdata)
    clusterext.send(get_cluster_service().mailserver, "lua", "send_mail", playerid, mailid, params, tokens, thingdata)
end

return mailinterface