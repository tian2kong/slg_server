local class = require "class"
local timext = require "timext"
local gmcommon = require "gmcommon"
local httprequest = require "httprequest"
local Database = require "database"
local clusterext  = require "clusterext"

---------------------------------------

local FCM_Mgr = class("FCM_Mgr")

function FCM_Mgr:ctor()
	self.t_player = {} 

	self.looptimer = {}
	self.alarmtimer = {}
end

function FCM_Mgr:init()
	local db = Database.new("global")
	local query_ret = db:syn_query_sql("select playerid, account from account")
	local cnt = 0
	if query_ret then
		for k,v in pairs(query_ret) do
			self.t_player[v.playerid] = v.account	
	 		cnt = cnt + 1
		end
	end

	self:calc_looptimer()
	self:calc_alarmtimer()

	--测试
	-- print(self:broadcast_all(3))
	-- assert(false)
end

local function is_same_day(t_wday, day)
	for _, v in pairs(t_wday) do 
		if v == day then 
			return true
		end
	end
	return false
end 


function FCM_Mgr:calc_looptimer()
	self.looptimer = {}
	local zero_time = timext.day_zero_time()
	local cur_time = timext.current_time()
	local pass_time = cur_time - zero_time
	assert(pass_time >= 0)

	local t = os.date("!*t", cur_time)
	local weekday = t.wday
	local single_flag = false --是否单周

	local t_configs = get_static_config().clock_push[gmcommon.clock_type.Loop]
	if not t_configs then
		return
	end

	for _,cfg in pairs(t_configs) do
		repeat
			if not is_same_day(cfg.Week, weekday) then --同一天
				break
			end

			--todox
			if not single_flag and cfg.WeekType == gmcommon.push_weektype.single then
				break
			elseif single_flag and cfg.WeekType == gmcommon.push_weektype.double  then
				break
			end

			local clock = cfg.PassTime - pass_time
			if clock < 0 then --超过当天触发时间
				break
			end


			local id = cfg.Id
			self.looptimer[id] = timext.create_timer(clock)
		until 0;
	end
end

function FCM_Mgr:calc_alarmtimer()
	local cur_time = timext.current_time()
	local t_configs = get_static_config().clock_push[gmcommon.clock_type.Alarm]
	if not t_configs then
		return
	end

	for _,v in pairs(t_configs) do --定时推送
		assert(v.TimeFormat)
		local id = cfg.Id
		local tt = timext.ostime(v.TimeFormat)
		local clock = tt - cur_time
		if clock >= 0 then
			self.alarmtimer[id] = timext.create_timer(clock)
		end
	end
end

--零点刷新
function FCM_Mgr:zerorefresh()
	--重新计算
	self:calc_looptimer()
end

function FCM_Mgr:run()
	--定时推送
	for id,v in pairs(self.looptimer) do
		if v:expire() then
			--先置空
			self.looptimer[id] = nil
			--阻塞推送
			self:broadcast_all(id)
		end
	end
end

function FCM_Mgr:register_player(playerid, account)
	self.t_player[playerid] = account
end

function FCM_Mgr:get_account(t_playerid)
	local ret = {}
	for _,playerid in pairs(t_playerid) do
		table.insert(ret, self.t_player[playerid])
	end
	return ret
end

--全服推送
function FCM_Mgr:broadcast_all(id)
	local package = self:package_content(id)
	return httprequest.FCM_Broadcast_All(package)
end

--部分推送
function FCM_Mgr:broadcast_part(id, t_playerid)
	local package = self:package_content(id)
	local accounts = self:get_account(t_playerid)
	return httprequest.FCM_Broadcast_Part(accounts, package)
end

---
function FCM_Mgr:event_broadcast(eventType, t_playerid, allflag)
	local cfg = get_static_config().event_push[eventType]
	if not cfg then
		LOG_ERROR("event_broadcast type is error type = [%d]", eventType)
		return 
	end

	local id = cfg.Id
	if allflag then --全服推送
		self:broadcast_all(id)
	elseif t_playerid and not table.empty(t_playerid) then
		self:broadcast_part(id, t_playerid)			
	end

end

--组装后台文本
function FCM_Mgr:package_content(id)
	local cfg = get_static_config().push[id]
	assert(cfg)
	local package = {
		NameCh = cfg.NameCh,
		TextCh = cfg.TextCh,
		NameEn = cfg.NameEn,
		TextEn = cfg.TextEn,

	}
	return package
end

----------------------------------------------------各种推送事件------------------------------------------------------------
--帮派战后台推送事件
function FCM_Mgr:guildwar_push(type, limitlv)
    local guildwar_event = {
        [1] = "guildwar_1",--帮派战第一场
        [2] = "guildwar_2",--帮派战第二场
        [3] = "guildwar_3",--帮派战第三场
    }

    if not guildwar_event[type] then
        return 
    end

    local t_playerid = clusterext.call(get_cluster_service().cacheservice, "lua", "get_all_player", limitlv, nil)
    self:event_broadcast(gmcommon.push_event_type[ guildwar_event[type] ], t_playerid) 
end

return FCM_Mgr