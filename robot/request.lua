local request = {}

function request.syncplayerscene(robot, args)
    robot:scenemodule():set_scene(args.sceneid, args.pos, args.objid)
end

function request.characterwalkret(robot, args)
    robot:scenemodule():walk_return(args.code, args.pos)
end

function request.syncrolebase(robot, args)
    robot:rolemodule():set_role_date(args.info)
end

function request.addprivatenpc(robot, args)
    robot:scenemodule():add_private_npc(args.info)
end

function request.delprivatenpc(robot, args)
    robot:scenemodule():del_private_npc(args.key)
end

function request.syncobjects(robot, args)
    robot:scenemodule():add_scene_object(args)
end

function request.removeobject(robot, args)
    robot:scenemodule():del_scene_object(args.key)
end

function request.synccontainerpos(robot, args)
    robot:thingmodule():update_container_thing(args.data)
end

function request.sysactivitynotice(robot, args)
    robot:thingmodule():update_container_thing(args.data)
end

function request.syncguildlistret(robot, args)
    robot:guildmodule():sync_guild_list(args)
end

function request.syncreqapplyguildret(robot, args)
    print("syncreqapplyguildret ", args)
end

function request.synallwarbuilding(robot, args)
	robot:guildmodule():enter_guild_war()
end

function request.syncplayerguildbaseinfo(robot, args)
	robot:guildmodule():init_guild(args)
end

function request.syncteaminfo(robot, args)
	robot:teammodule():init_team(args)
end

return request