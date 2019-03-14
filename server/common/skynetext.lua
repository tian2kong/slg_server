local skynet = require "skynet"

--skynet扩展
local skynetext = {}

--自定义skynet消息类型
skynetext.db_protocol = 101
skynetext.db_protocol_name = "db"

skynetext.agent_protocol = 104
skynetext.agent_protocol_name = "agent"

skynetext.agentgroup_protocol = 105
skynetext.agentgroup_protocol_name = "agentgroup"

return skynetext