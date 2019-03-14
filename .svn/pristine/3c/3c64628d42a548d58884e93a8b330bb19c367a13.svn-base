local class = require "class"
local timext = require "timext"
local interaction = require "interaction"

local GM_Mgr = class("GM_Mgr")

function GM_Mgr:ctor()
	self.zmd = {}	--延时走马灯
end

function GM_Mgr:run()
	for k,v in pairs(self.zmd) do
		if v.timer and v.timer:expire() then
			interaction.send_online_player("send2client", "gmzmd", v.info )
			self.zmd[k] = nil
		end
	end
end

function GM_Mgr:gm_zmd(param)
	if not param then
		LOG_ERROR("gm_zmd param is nil")
		return 
	end

	local tid = param.tid
	local text = param.text
	local t_param = param.tid_param and table.decode(param.tid_param) or {}
	local time_delay = param.time_delay and tonumber(param.time_delay) or 1 
	local info = {
		tid = param.tid,
		text = param.text,
		param1 = t_param[1],
		param2 = t_param[2],
		param3 = t_param[3],
	}

	local timer = timext.create_timer(time_delay)
	local data = {
		timer = timer,
		info = info,
	}

	table.insert(self.zmd, data)
end




return GM_Mgr