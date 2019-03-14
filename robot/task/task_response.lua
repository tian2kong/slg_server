local response = require "response"

function response.reqmaintask(robot, args)
	robot:taskmodule():UpDateTask(args)
	local taskinfo = robot:taskmodule():GetTaskDataByType(args.info.type)
	taskinfo.data.id = args.id
end

