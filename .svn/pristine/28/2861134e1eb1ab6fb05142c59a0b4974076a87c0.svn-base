local class = require "class"
local timext = require "timext"
local common = require "common"

local RechargeActive = class("RechargeActive")

local ActiveStatus = {
	open = 1,
	close = 2,
}

function RechargeActive:ctor()
	self.opentime = nil
	self.closetime = nil
	self.status = ActiveStatus.close
	self.group = nil
	self.times = nil
	self.openservertime = nil
end

function RechargeActive:init(opentime)
	self.openservertime = opentime
	self:cal_active_status()
end

function RechargeActive:cal_active_status()
	self.status = ActiveStatus.close

	local refreshtime = timext.system_refresh_time()
	local current = timext.current_time()
	local zero1 = timext.day_zero_time(current)
	local zero2 = timext.day_zero_time(self.openservertime)
	local diffday = math.floor((zero1 - zero2) / (24 * 60 * 60))
	local cfg = get_static_config().globals.recharge_open_close_time
	if diffday <= cfg.opentime then
		self.opentime = zero1 + (cfg.opentime - diffday) * 24 * 60 * 60 + refreshtime
		self.closetime = self.opentime + cfg.lasttime * 24 * 60 * 60
		self.group = 1
		self.times = 1
	else
		diffday = diffday - cfg.opentime
		self.times = math.floor(diffday / (cfg.lasttime + cfg.closetime)) + 1
		local size = table.size(get_static_config().recharge_activity)
		self.group = self.times % size
		if self.group == 0 then
			self.group = size
		end
		local day = diffday % (cfg.lasttime + cfg.closetime)
		if day == 0 then
			day = cfg.lasttime + cfg.closetime
		end
		if (day < cfg.lasttime) or (day == cfg.lasttime and (current - zero1) < refreshtime) then
			self.closetime = zero1 + (cfg.lasttime - day) * 24 * 60 * 60 + refreshtime
			self.opentime = self.closetime - cfg.lasttime * 24 * 60 * 60
		else
			day = day - cfg.lasttime
			self.opentime = zero1 + (cfg.closetime - day) * 24 * 60 * 60 + refreshtime
			self.closetime = self.opentime + cfg.lasttime * 24 * 60 * 60
		end
	end
	if current >= self.closetime then
		LOG_ERROR("RechargeActive load open server time error diffday %d", diffday)
		return 
	end
	if not get_static_config().recharge_activity[self.group] then
		LOG_ERROR("RechargeActive load error group %d", self.group)
		return 
	end

	if current > self.opentime then
		self.status = ActiveStatus.open
	end
end

function RechargeActive:run(frame)
	if not self.openservertime then
		return
	end
	local update = nil
	local current = timext.current_time()
	if (self.status == ActiveStatus.open and current >= self.closetime)
		or (self.status == ActiveStatus.close and current >= self.opentime) then
		self:cal_active_status()
		update = true
	end
	return update
end

function RechargeActive:is_open()
	return self.status == ActiveStatus.open
end

function RechargeActive:get_group()
	return self.group
end

function RechargeActive:get_times()
	return self.times
end

function RechargeActive:get_over_time()
	return self.closetime
end

return RechargeActive