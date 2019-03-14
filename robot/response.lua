local config = require "robotconfig"

local response = {}

function response.createrole(robot, args)
    if args.code == 1 then
        --创角成功
    end
    robot:online()
end

function response.reqrolebase(robot, args)
    robot:rolemodule():set_role_date(args.info)
end

function response.reqprivatenpc(robot, args)
	if args.info then 
		for _,v in pairs(args.info) do
			robot:scenemodule():add_private_npc(v)
		end
	end
end

local profession = {
    1001,   --男人
    1002,   --女人
    2003,   --男仙
    2004,   --女仙
    3005,   --男魔
    3006,   --女魔
    4007,   --男鬼
    4008,   --女鬼
}
local i = 1
function response.login(robot, args)
    if args.code == 5 then--还未创建角色
        local index = (i % (#profession - 1)) + 1
        i = i + 1
        robot.net:send_request("createrole", {name = config.template, roleid= profession[index]})
    else
        robot:online()
    end
end

function response.gmcommand(robot, args)
    if args.content then
	    local temp = string.split(string.sub(args.content, 2), " ")
	    if temp[1] == "addlevel" then 
		    robot:taskmodule():ReDoTask()
	    elseif temp[1] == "addthing" then 
		    robot:trademodule():AfterAddThing(tonumber( temp[2] ))
	    end
    end
end

function response.reqcontainer(robot, args)
	robot:thingmodule():init_container(args)
end

function response.chgworldscene(robot, args)
    
end

function response.reqopenactivity(robot, args)
    robot:activitymodule():init_activitys(args)
end

function response.reqplayerguildbaseinfo(robot, args)
    robot:guildmodule():init_guild(args)
end

return response