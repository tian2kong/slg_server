local class = require "class"
local scenecommon = require "scenecommon"
local config = require "robotconfig"
local Random = require "random"
local astarmanager = require "astarmanager"
local IRobotModule = require "irobotmodule"
local mapconfig = require "mapconfig"

do--取消挡格
    mapconfig.isCollision = function() 
        return false
    end
end

local RobotScene = class("RobotScene", IRobotModule)

local walk_type = {
    random = 1,
    find_npc = 2,
	dotask = 3
}

function RobotScene:ctor(robot)
    self.robot = robot
    self.sceneid = nil   --场景id
    self.pos = nil       --位置
    self.objid = nil     --自身活物id
    self.targetpos = nil --目标点
    self.walkstep = nil  --移动路径
    self.walking = nil   --移动标记
    self.privatenpc = {} --私有npc objid -> { objid, npcid, pos, sceneid }
    self.npcobjs = {}    --npc活物
    self.walk2npc = nil
    self.walktype = nil  --移动类型

    self.warlkai = config.getai("randomwalk")
    self.findnpcai = config.getai("findnpc")

    self.speed = scenecommon.grid_speed + 1
end

function RobotScene:init()
    
end

function RobotScene:run(frame)
    self:walk_logic(frame)
end

function RobotScene:online()
    --进入场景
    self.robot.net:send_request("reqprivatenpc")
    self.robot.net:send_request("reqplayerscene")
    self.robot.net:send_request("reqsceneobjects")
end

--随机行走
function RobotScene:ai_randomwalk()
    if self.warlkai then
        local rnd = Random.Get(#self.warlkai)
        self.targetpos = self.warlkai[rnd]
        self.walktype = walk_type.random
    end
end
--找npc
function RobotScene:ai_findnpc()
    if self.findnpcai then
        local rnd = Random.Get(#self.findnpcai)
        self:walk_to_npc(self.findnpcai[rnd], walk_type.find_npc)
    end
end

--设置场景
function RobotScene:set_scene(sceneid, pos, objid)
    self.sceneid = sceneid
    self.pos = scenecommon.string2pos(pos)
    self.objid = objid
    if not self.targetpos then
        self:ai_randomwalk()
        self:ai_findnpc()
    end
    self:walkto()
end

--A星查询路径
function RobotScene:astar_find_path()
	if not self.targetpos then 
		return
	end
    local path = astarmanager.find_path(self.targetpos.sceneid, self.pos, self.targetpos.pos)
    if path and not table.empty(path) then
        self.walkstep = path
        for k,v in pairs(path) do
            path[k] = scenecommon.pos2string(v)
        end
        self.robot.net:send_request("characterwalk", { actionid = 0, pos = path })
        self.walking = nil
    else
        --找不到路径  直接飞得了
        local str = string.format("/fly %d %f %f", self.targetpos.sceneid, self.targetpos.pos.x, self.targetpos.pos.y)
        self.robot:gm_commond(str)
    end
end

function RobotScene:clear_walk()
    self.walkstep = nil  --移动路径
    self.walking = nil   --移动标记
end

--切换场景
function RobotScene:change_scene(sceneid)
    self:clear_walk()
    self.npcobjs = {}
    self.robot.net:send_request("chgworldscene", { sceneid = sceneid })
end

--走路
function RobotScene:walkto()
    if not self.targetpos or not self.sceneid then
        return
    end
    local destscene = self.targetpos.sceneid
    if destscene ~= self.sceneid then
        self:change_scene(destscene)
    else
        if scenecommon.distance(self.targetpos.pos, self.pos) < 2 then
            self:arrive()
        else
            self:astar_find_path()
        end
    end
end

--走路回包
function RobotScene:walk_return(code, pos)
    if code == scenecommon.message_code.success then
        self.walking = true
    else
        self.pos = scenecommon.string2pos(pos)
        self:astar_find_path()
    end
end

--到达目的地
function RobotScene:arrive()
	printf("arrive npc ...... ..... .... at RobotScene:arrive().....")
    if self.walktype == walk_type.random then
        --到达目的地 再走一个点
        self:ai_randomwalk()
        self:walkto()
    elseif self.walktype == walk_type.find_npc then
        --找到npc
        self:ai_findnpc()
	elseif self.walktype == walk_type.dotask then 
		--到达任务npc
		self.robot:taskmodule():SetDeliveryTask()
		self.robot:taskmodule():SetParam(self.walk2npc)
    end
end


function RobotScene:walk_logic(frame)
    if not self.walking or not self.walkstep or table.empty(self.walkstep) then
        return 
    end
	local cur_position = self.pos
	local tar_position = self.walkstep[1]
	-- 当前位置与当前的目标路径点路径的长度
	local dist_to_target = scenecommon.distance(cur_position, tar_position)

	-- 这一帧可移动的路径长度
	local move_dist = self.speed * frame
	-- 如果这一帧可移动的路径长度小于当前位置到当前的目标路径点路径长度
	while true do
		if move_dist > dist_to_target then
			move_dist = move_dist - dist_to_target
			cur_position = tar_position
            table.remove(self.walkstep, 1)
			if table.empty(self.walkstep) then
				--到达目的地
				self.pos = cur_position
				self:arrive()
				break
			else
				tar_position = self.walkstep[1]
				dist_to_target = scenecommon.distance(cur_position, tar_position)
			end
		else
			if dist_to_target > scenecommon.ROUNDING_ERROR_f32 then
				-- 用向量和三角形相似的性质，不用三角函数，更快
				cur_position.x = cur_position.x + (move_dist * (tar_position.x - cur_position.x)) / dist_to_target
				cur_position.y = cur_position.y + (move_dist * (tar_position.y - cur_position.y)) / dist_to_target
			else
				cur_position = tar_position
			end
			self.pos = cur_position
			break
		end
	end
end

function RobotScene:add_private_npc(info)
    info.pos = scenecommon.string2pos(info.pos)
    self.privatenpc[info.objid] = info
end

function RobotScene:del_private_npc(key)
    for _,v in pairs(key) do
        self.privatenpc[v.objid] = nil
    end
end

function RobotScene:add_scene_object(objects)
    if objects.npc then
        for k,v in pairs(objects.npc) do
            v.pos = scenecommon.string2pos(v.pos)
            self.npcobjs[v.objid] = v
            if self.walktype == walk_type.find_npc and v.npcid ==  self.walk2npc.npcid then
                self.walk2npc.id = v.objid
                self.targetpos = {sceneid = self.sceneid, pos = v.pos}
                self:walkto()
            end
        end
    end
end

function RobotScene:del_scene_object(key)
    for _,v in pairs(key) do
        if v.type == scenecommon.ObjectType.npc then
            self.npcobjs[v.objid] = nil
        end
    end
end

--移动到某个NPC
function RobotScene:walk_to_npc(npcid, walk_type)
	printf("go to npc ... npc id is ... " .. npcid)
    --移动到某个npc
    local npccfg = get_static_config().npc[npcid]
    if not npccfg then
        printf("unkown npc ", npcid)
        return 
    end
    self:clear_walk()
    if not npccfg.NpcType then
        self.walktype = walk_type
        self.walk2npc = { npctype = 0, id = npcid }
        self.targetpos = { sceneid = npccfg.SceneType, pos = { x = math.round(npccfg.Position[1] / scenecommon.grid_pixels, 2), y = math.round(npccfg.Position[2] / scenecommon.grid_pixels, 2)}}
        self:walkto()
    elseif npccfg.NpcType  == 1 then
        local find = nil
        for k,v in pairs(self.privatenpc) do
            if v.npcid == npcid then
                find = true
                self.walktype = walk_type
                self.walk2npc = { npctype = 1, id = v.objid }
                self.targetpos = {sceneid = v.sceneid, pos = v.pos}
                self:walkto()
                break
            end
        end
        if not find then
            printf("not found private npc ", npcid)
        end
    elseif npccfg.NpcType  == 2 then
        self.walktype = walk_type
        self.walk2npc = { npctype = 2, id = nil, npcid = npcid }
        local find = nil
        for k,v in pairs(self.npcobjs) do
            if v.npcid ==  npcid then
                find = true
                self.walk2npc.id = v.objid
                self.targetpos = {sceneid = self.sceneid, pos = v.pos}
                self:walkto()
                break
            end
        end
        if not find then
            self.targetpos = { sceneid = npccfg.SceneType, pos = { x = math.round(npccfg.Position[1] / scenecommon.grid_pixels, 2), y = math.round(npccfg.Position[2] / scenecommon.grid_pixels, 2)}}
            self:walkto()
        end
    end
end

return RobotScene