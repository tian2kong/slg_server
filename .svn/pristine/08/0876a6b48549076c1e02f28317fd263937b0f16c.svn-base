local class = require "class"
local tcommon = require "task.taskcommon"


local obj = class("task_obj")


function obj:ctor()
	self.data = {}
end

function obj:update(args)
	if args.info.status == tcommon.status.TASK_FINISH then --删除任务
		printf("del task ...................")
		self.data = {}
	elseif table.empty( self.data ) or args.info.taskid ~= self.data.taskid then  --新任务
        self.data.taskid = args.info.taskid
        self.data.type = args.info.type
        self.data.status = args.info.status
        self.data.target = args.info.target
        self.data.cursor = args.info.cursor

    else 										--状态更新
        if self.data.cursor ~=  args.info.cursor then 
           
        end  
        self.data.type = args.info.type
        self.data.status = args.info.status
        self.data.target = args.info.target
        self.data.cursor = args.info.cursor    
    end
end

function obj:gettaskid()
    if self.data and self.data.taskid then
        return self.data.taskid
    end
    return 0
end



return obj