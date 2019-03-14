local class = require "class"
local Database = require "database"
local config = require "config"
local timext = require "timext"
local skynet = require "skynet"
local config = require "config"
local clusterext = require "clusterext"
local worldcommon = require "worldcommon"

local WorldTimeMgr = class("WorldTimeMgr")

local s_time_table = {
    table_name = "systemtime",
    key_name = {"id"},
    field_name = {
        "time",
    },
}
local db_key = 1
local update_time = 60 * 5 --五分钟更新一次

function WorldTimeMgr:ctor()
	self.db = nil
	self._record = nil
	self.opentime = nil
	self.timer = nil
end

function WorldTimeMgr:loaddb()
	self.db = Database.new("world")

	self._record = self.db:create_db_record(s_time_table, db_key)
    self._record:syn_select()

    --如果服务器时间小于物理时间 则取物理时间
    local worldcfg = config.get_world_config()
    local curtime = math.floor(skynet.starttime() + worldcfg.gmt * 60 * 60)
    if self:get_system_time() < curtime then
    	self:set_system_time(curtime)
    end
	self.opentime = self:get_system_time()
	skynet.setenv(worldcommon.TIME_ENV, self.opentime)
end

function WorldTimeMgr:get_system_time()
	return self._record:get_field("time") or 0
end
function WorldTimeMgr:set_system_time(time)
	self._record:set_field("time", time)
end

function WorldTimeMgr:init()
	self.timer = timext.create_timer(update_time)
end

function WorldTimeMgr:run()
	if self.timer:expire() then
		self.timer:update(update_time)

		self:savedb()
	end
end

function WorldTimeMgr:get_current_time()
	return math.floor(self.opentime + skynet.now()/100)
end

function WorldTimeMgr:savedb()
	self:set_system_time(self:get_current_time())
	self._record:asyn_save()
end

--修改时间
function WorldTimeMgr:gm_system_time(str)
	local tm = {}
	do--日期
		local temp = string.match(str, "%d+-%d+-%d+")
		if temp then
			local t = {}
			for w in string.gmatch(temp, "%d+") do
				table.insert(t, w)
			end
			tm.year = tonumber(t[1]) 
		    tm.month = tonumber(t[2])
		    tm.day = tonumber(t[3])
		else
			local curtime = self:get_current_time()
    		local t = os.date("!*t", curtime)
    		tm.year = t.year
    		tm.month = t.month
    		tm.day = t.day
		end
	end
	do--时间
		local temp = string.match(str, "%d+:%d+:%d+")
		if temp then
			local t = {}
			for w in string.gmatch(temp, "%d+") do
				table.insert(t, w)
			end
			tm.hour = tonumber(t[1]) 
		    tm.min = tonumber(t[2])
		    tm.sec = tonumber(t[3])
		else
			tm.hour = 0
		    tm.min = 0
		    tm.sec = 0
		end
	end

	local newtime = timext.ostime(tm)
	self.opentime = newtime - math.floor(skynet.now()/100)
	self:savedb()
	skynet.setenv(worldcommon.TIME_ENV, self.opentime)
	self:notice_world_time()
end

function WorldTimeMgr:notice_world_time()
	--服务器开启
    local gamelist = config.get_gamelist_config()
	for k, v in pairs(gamelist) do
		local address = get_remote_service(k).interactionhubd
		local ok, err = xpcall(clusterext.send, debug.traceback, address, "lua", "notice_world_time", self:get_current_time())
    end
end

return WorldTimeMgr