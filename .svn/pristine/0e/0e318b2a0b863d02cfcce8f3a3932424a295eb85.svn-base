local request = require "request"
local tcommon = require "task.taskcommon"


--更新任务
function request.updatataskinfo(robot, args)
	robot:taskmodule():UpDateTask(args)
end

--更新主线任务
function request.sysmaintask(robot, args)
	local taskinfo = robot:taskmodule():GetTaskDataByType(tcommon.type.MAIN_TASK_TYPE)
	assert(taskinfo)
	taskinfo.data.id = args.id
end

--请求交互返回
function request.sysreqtaskaction(robot, args)
	if args.ret == 2 then 
		robot:gm_commond("/addlevel 1")
	end
end


--主线任务结束
function request.sysmaintaskfinish(robot, args)
    if args.code == 5 then --飞艇系统返回码,表示当前关卡结束,可进入下一关
	    robot:taskmodule():SetReqTask()
    end
end
