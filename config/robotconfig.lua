local randomwalk = {
    name = "randomwalk",
    param = {
        { sceneid = 1011, pos = { x = 147, y = 78 } },
        { sceneid = 1011, pos = { x = 18, y = 78 } },
        { sceneid = 1011, pos = { x = 11, y = 53 } },
        { sceneid = 1011, pos = { x = 8, y = 10 } },
        { sceneid = 1011, pos = { x = 80, y = 20 } },
        { sceneid = 1011, pos = { x = 117, y = 6 } },
        { sceneid = 1011, pos = { x = 155, y = 17 } },
        { sceneid = 1011, pos = { x = 160, y = 50 } },
        { sceneid = 1011, pos = { x = 79, y = 47 } },
    }
}
local findnpc = {
    name = "findnpc",
    param = { 90001, 90003, 15001 }
}

--主线任务
local maintask = {
	name = "maintask",
	param = {},
}

local createguild = {
    name = "createguild",
    param = {},
}

local guildwar = {
    name = "guildwar",
    param = {},
}

--交易系统
local trade = {
	name = "trade",
	param = {cnt = 1, thingid = { {id = 5103, cnt = 100}, {id = 5103, cnt = 1} } }
}

local gmcommand = {
    name = "gmcommand",
    param = "/pve 10001201",
}

local pvefight = {
    name = "pvefight",
    param = "/pve 2",
}

--协议工具
local ptool = {
	name = "ptoll",
	param = require "protoconf",
}

local config = {
    serverip = "192.168.1.3",
    port = 8001,
    template = "qingxiu",
    num = 500,
    ai = {},
    debuginfo = false,  --是否输出printf打印
	daemon = false,--后台开启
    httphost = "192.168.1.5:8002",
}
local aiset = {}
local function loadai(ai)
    aiset[ai.name] = ai.param
end

do--加载ai
    --loadai(maintask)
    --loadai(pvefight)
    loadai(randomwalk)
end

--获取ai
function config.getai(name)
    return aiset[name]
end

return config
