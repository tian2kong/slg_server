local class = require "class"
local tcommon = require "task.taskcommon"
local tobj = require "task.task_obj"
local config = require "robotconfig"
local IRobotModule = require "irobotmodule"

local RobotTask = class("RobotTask", IRobotModule)

function RobotTask:ctor(robot)
    self.robot = robot
	self._tasks = {}
	self.action = tcommon.action.ACTION_REQ_TASK
	self.time = os.time() + 1
	self.chattimer = os.time() + 5

	self.taskai = config.getai("maintask")
end

function RobotTask:init()
end

function RobotTask:run(frame)
	local current = os.time()
	if current >= self.time then 
		self.time = current + 1
		if self.taskai then 
			if self.action == tcommon.action.ACTION_REQ_TASK then 
				self:SetWait()
				self:reqtask()
				
			elseif self.action == tcommon.action.ACTION_DO_TAGERT then
				self:SetWait()
				local pa = self:GetParam()
				self.robot:scenemodule():walk_to_npc(pa.npcid, pa.type)
				
			elseif self.action == tcommon.action.ACTION_DELIVERY then
				self:SetWait()
				local pa = self:GetParam()
				self:dotask(pa)
			end
		end
	end
	if current >= self.chattimer then
		self.chattimer = current + 5
		if self:GetTaskID(1) ~= 0 then
			local lcl_cont = string.format("当前频道: 主线任务进度[%d]",  self:GetTaskID(1))
			self.robot.net:send_request("channelchat", { chnl = 1, content = lcl_cont } ) --当前频道
			self.robot.net:send_request("channelchat", { chnl = 4, content = "世界频道: HELLO MOTO "} ) --世界频道
		end
	end
end

function RobotTask:online()
	
end

--请求任务
function RobotTask:reqtask()
	if self.taskai then 
		self.robot.net:send_request("reqmaintask") --请求主线任务
	end
end

--做任务
function RobotTask:dotask(npc)
	if self.taskai then --做主线任务
		self:DoTaskP(tcommon.type.MAIN_TASK_TYPE, npc)
	end
end

--更新任务
function RobotTask:UpDateTask(args)
	if tcommon.type.begin > args.info.type or args.info.type > tcommon.type.ends then 
		return
	end
	
	
	local obj = self._tasks[args.info.type]
	if not obj then 
		obj = tobj.new()
		self._tasks[args.info.type] = obj
	end
	self:dotagert(args, obj)

end

 


-----privity-------------------------------

--执行主线任务
function RobotTask:DoTaskP(type, npc)
	local taskinfo = self:GetTaskDataByType(type)
	if not taskinfo then
		return
	end
	if taskinfo.data.status == tcommon.status.TASK_DELIVERY then 
		printf("11111111111111")
		self:delivetasktRequest( taskinfo.data, npc.npctype, npc.id)
	else 
		local tagcfg = get_static_config().task_target[taskinfo.data.target.tagid]
		if self:IsGatherTask(tagcfg.TargetType) then 
			self:docollect(npc.npctype, npc.id)
		else 
			self:reqtaskactionRequest(taskinfo.data, npc.npctype, npc.id)
		end
	end
end

--获取npcid
function RobotTask:GetNpcIdAndType(taggid)
	local cfg =  get_static_config.task_target[taggid]
	assert(cfg)
	if not cfg.TargetNpcId then 
		return 0, 0
	end

end

--交任务
function RobotTask:delivetasktRequest(data, nNpctype, nNpcobjid)
	printf(debug.traceback())
    self.robot.net:send_request("delivetask", { type = data.type, taskid = data.taskid, npctype = nNpctype, npcobjid = nNpcobjid})
end


--请求执行动作
function RobotTask:reqtaskactionRequest(data, nNpctype, nNpcobjid)
    self.robot.net:send_request("reqtaskaction", { type = data.type, taskid = data.taskid, npctype = nNpctype, npcobjid = nNpcobjid})
end

--执行采集
function RobotTask:docollect(nNpctype, nNpcobjid)
	self.robot.net:send_request("collectnpc", {npctype = nNpctype, id  = nNpcobjid})
end

--执行目标
function RobotTask:dotagert(args, obj)
	local data = args.info
	local curdata = self:GetTaskDataByType(data.type).data
	if curdata and not table.empty(curdata) then 
		if curdata.taskid == data.taskid and curdata.status == data.status and 
		-- curdata.target.tagid == data.target.tagid and curdata.target.status = data.target.status  and
		 curdata.cursor == data.cursor then 
			printf("same status .....")
			return 
		end
	end
	
	obj:update(args)
	
	if data.status == tcommon.status.TASK_FINISH then 
		return 
	end
	if data.status == tcommon.status.TASK_DELIVERY then 
		local tcfg = get_static_config().task[data.taskid]
		assert(tcfg)
		if tcfg.TaskFinishNpcId then 
			self.robot:scenemodule():walk_to_npc(tcfg.TaskFinishNpcId, 3)
		elseif taskcfg.TaskFinishNpcTalk then 
			self:delivetasktRequest(data, 0, 0)
		else 
			assert(false)
		end
		return
	end
	
	if not data.target then 
		printf("no tagcfg at dotagert...........")
		return
	end
	if not data.target.tagid then 
		printf("no tagcfg id.. at dotagert...........")
		return 
	end
	
	local tagcfg = get_static_config().task_target[data.target.tagid]
	if not tagcfg then 
		assert(false)
	end
	if tagcfg.TargetNpcId then 
		self:SetDoTagert()
		self:SetParam({npcid = tagcfg.TargetNpcId, type = 3})
		--self.robot:scenemodule():walk_to_npc(tagcfg.TargetNpcId, 3)
	else 
		self.robot:taskmodule():SetDeliveryTask()
		self.robot:taskmodule():SetParam({npctype = 0, id= 0})
	end
end

--是否是采集任务
function RobotTask:IsGatherTask(tasktype)
	if tasktype == tcommon.tagtype.TAGTYPE_GATHER then
		return true
	end
	return false
end

--再次执行任务，。。。。 等级不够 gm命令返回后执行，，，
function RobotTask:ReDoTask()
	self.robot:taskmodule():SetDeliveryTask()
end
--------------------------------------------


---获取设置--------------------
function RobotTask:GetTaskDataByType(type)
	if tcommon.type.begin > type or type > tcommon.type.ends then 
		return 
	end
	return self._tasks[type]
end


--设置请求任务
function RobotTask:SetReqTask()
	self.action = tcommon.action.ACTION_REQ_TASK
end

--设置做目标
function RobotTask:SetDoTagert()
	self.action = tcommon.action.ACTION_DO_TAGERT
end

--设置交任务
function RobotTask:SetDeliveryTask()
	self.action = tcommon.action.ACTION_DELIVERY
end

--设置等待
function RobotTask:SetWait()
	self.action = tcommon.action.ACTION_WAIT
end

--设置参数
function RobotTask:SetParam(v)
	self.param = v
end

--获取参数
function RobotTask:GetParam()
	return self.param
end


function RobotTask:GetTaskID(type)
	if self._tasks[type] then
		return self._tasks[type]:gettaskid()
	end
	return 0
end

return RobotTask
 