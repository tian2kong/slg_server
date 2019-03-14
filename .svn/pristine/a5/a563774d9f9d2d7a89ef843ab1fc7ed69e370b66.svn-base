local class = require "class"
local IPlayerModule = require "iplayermodule"
local Facility = require "facility"
local citycommon = require "citycommon"
local timext = require "timext"

local PlayerCityModule = class("PlayerCityModule", IPlayerModule)

--主城表
local city_tab = {
    table_name = "player_city",
    key_name = {"playerid"},
    field_name = {
       "land",           --地块信息
       "buildqueue",     --建筑队列
    },
}


--构造函数
function PlayerCityModule:ctor(player)
    self._player = player
    self._record = nil
    self._unlockland = {}       --解锁的矩形地块
    self._facilitys = {}        --设施列表
    self._maxid = 0
    self._typefacilitys = {}    --根据类型区分的设施
    self._buildqueue = {}       --建筑队列
end

function PlayerCityModule:savedb()
   self._record:asyn_save() 
end

--读库
function PlayerCityModule:loaddb()
    local db = self._player:getplayerdb()
    self._record = db:create_db_record(city_tab, self._player:getplayerid())
    self._record:syn_select()
    local str = self._record:get_field("land")
    if str then
        self._unlockland = table.decode(str) or {}
    end
    str = self._record:get_field("buildqueue")
    if str then
        self._buildqueue = table.decode(str) or {}
    end

    local record_list = db:select_db_record(Facility.facility_tab, string.format(" where playerid=%d", self._player:getplayerid()))
    for _, record in pairs(record_list) do
        local facility = Facility.new(record)
        self:_insert_facility(facility)
        if facility:get_id() > self._maxid then
            self._maxid = facility:get_id()
        end
    end
end

--初始化
function PlayerCityModule:init()
    for _,cfg in pairs(get_static_config().build_num) do
        if cfg.Originbuild then--初始化建筑
            local list = self._typefacilitys[cfg.Buildtype]
            if not list or table.empty(list) then
                self:create_facility(cfg.Buildtype, cfg.OriginStation[1], cfg.OriginStation[2])
            end
        end
    end
    self:unlock_land_event(true)

    --如果队列列表为空  则加入一个空队列
    if table.empty(self._buildqueue) then
        table.insert(self._buildqueue, {})
    end

    self:refresh_queue(true)
end

--不需要online就执行的ai逻辑
function PlayerCityModule:init_run(frame)
    self:refresh_queue(not self._player:is_online())
end

--AI
function PlayerCityModule:run(frame)
end

--上线处理
function PlayerCityModule:online()
end
 
--下线处理
function PlayerCityModule:offline()
end

--系统时间点刷新
function PlayerCityModule:dayrefresh()
end

--周一0店刷新
function PlayerCityModule:weekrefresh()
end

--摧毁服务
function PlayerCityModule:destroy()
end

-------------------------------------------------城建设施-----------------------------------------------------------
function PlayerCityModule:get_facility(id)
    return self._facilitys[id]
end

--获取设施数量
function PlayerCityModule:get_facility_num(_type)
    local list = self._typefacilitys[_type]
    if list then
        return #list
    else
        return 0
    end
end

--获取设施等级
function PlayerCityModule:get_facility_level(_type)
    local level = 0
    local list = self._typefacilitys[_type]
    if list then
        for _,facility in pairs(list) do
            if facility:get_level() > level then
                level = facility:get_level()
            end
        end
    end
    return level
end

function PlayerCityModule:_insert_facility(facility)
    self._facilitys[facility:get_id()] = facility
    local list = self._typefacilitys[facility:get_type()]
    if not list then
        list = {}
        self._typefacilitys[facility:get_type()] = list
    end
    table.insert(list, facility)
end

function PlayerCityModule:create_facility(_type, _x, _y, _level)
    local cfg = get_static_config().build_num[_type]
    self._maxid = self._maxid + 1
    local id = self._maxid
    local record = self._player:getplayerdb():create_db_record(Facility.facility_tab, { self._player:getplayerid(), id })
    local facility = Facility.new(record)
    facility:set_type(_type)
    facility:set_origin(_x, _y)
    facility:set_level(_level or cfg.OriginLevel)
    facility:savedb()
    self:_insert_facility(facility)
    return facility
end

function PlayerCityModule:get_facility_message()
    local msg = {}
    for k,v in pairs(self._facilitys) do
        msg[k] = v:get_message_data()
    end
    return msg
end

--获取主堡等级
function PlayerCityModule:get_castle_level()
    local list = self._typefacilitys[citycommon.castle_type]
    assert(not table.empty(list), "player not castle")
    local castle = list[1]
    return castle:get_level()
end

function PlayerCityModule:sync_facility(type, facility)
    self._player:send_request("updatefacility", {
        type = type,
        facility = facility:get_message_data(),
    })
end

-------------------------------------------------城建地块-----------------------------------------------------------
--地块解锁事件
function PlayerCityModule:unlock_land_event(nosync)
    local castlelevel = self:get_castle_level()
    local questid = 1001
    local update = false
    for _,cfg in pairs(get_static_config().build_unlockbase) do
        if not self._unlockland[cfg.Base_id] then
            local unlock = true
            if cfg.Unlock_last and self._unlockland[cfg.Unlock_last] ~= citycommon.land_state.developed then
                unlock = false
            elseif cfg.Open_quest and cfg.Open_quest > questid then
                unlock = false
            elseif cfg.Open_buildlv and cfg.Open_buildlv > castlelevel then
                unlock = false
            end
            if unlock then
                local state = citycommon.land_state.developable  
                if not cfg.Unlock_last and not cfg.Open_quest and not cfg.Open_buildlv then
                    state = citycommon.land_state.developed
                end
                self._unlockland[cfg.Base_id] = state

                update = true
            end
        end
    end
    if update then
        self._record:set_field("land", table.encode(self._unlockland))
        self:savedb()
    end
    if not nosync then
        self:sync_unlock_land()
    end
    print("unlock_land_event", self._unlockland)
end

function PlayerCityModule:get_land_message()
    local msg = {}
    for k,v in pairs(self._unlockland) do
        msg[k] = { cfgid = k, state = v }
    end
    return msg
end

function PlayerCityModule:get_land_state(cfgid)
    return self._unlockland[cfgid]
end

function PlayerCityModule:develop_land(cfgid)
    if self._unlockland[cfgid] then
        self._unlockland[cfgid] = citycommon.land_state.developed
        self._record:set_field("land", table.encode(self._unlockland))
        self:savedb()
    end
end

function PlayerCityModule:sync_unlock_land()
    self._player:send_request("updateland", { land = self:get_land_message() })
end


-------------------------------------------------城建队列-----------------------------------------------------------
function PlayerCityModule:is_facility_building(id)
    local ret = false
    for _, _queue in ipairs(self._buildqueue) do
        if _queue.id == id then
            ret = true
            break
        end
    end
    return ret
end

--是否有可容纳建造时间的空闲队列
function PlayerCityModule:get_empty_queue(_time)
    local curtime = timext.current_time()
    for _, _queue in ipairs(self._buildqueue) do
        if _queue.id then
            --队列被占用
        elseif _queue.expire and _queue.expire < curtime + _time then
            --队列被占用
        else
            return _queue
        end
    end
end

--增加临时队列时间
function PlayerCityModule:upgrade_build_queue(_time)
    local _queue = self._buildqueue[2]
    local curtime = timext.current_time()
    if not _queue then
        _queue = { expire = curtime }
        self._buildqueue[2] = _queue
    end
    _queue.expire = _queue.expire + _time
    self._record:set_field("buildqueue", table.encode(self._buildqueue))
    self:savedb()
    self:sync_build_queue()
end

--增加到建筑队列
function PlayerCityModule:add_build_queue(facility, _time)
    local _queue = self:get_empty_queue(_time)
    _queue.id = facility:get_id()
    _queue.time = timext.current_time() + _time
    self._record:set_field("buildqueue", table.encode(self._buildqueue))
    self:savedb()
    self:sync_build_queue()
end

function PlayerCityModule:sync_build_queue()
    self._player:send_request("updatebuildqueue", { queue = self:get_queue_message() })
end

function PlayerCityModule:get_queue_message()
    return self._buildqueue
end

--刷新建筑队列
function PlayerCityModule:refresh_queue(nosync)
    local update = false
    local curtime = timext.current_time()
    for _, _queue in pairs(self._buildqueue) do
        if _queue.id and _queue.time < curtime then
            local facility = self:get_facility(_queue.id)
            local oldlv = facility:get_level()
            local newlv = oldlv + 1
            facility:set_level(newlv)
            facility:savedb()
            self:upgrade_build_event(_queue.id, oldlv, newlv)

            _queue.id = nil
            _queue.time = nil
            update = true
            if not nosync then
                self:sync_facility(citycommon.update_type.building, facility)
            end
        end
    end
    local loop = true
    while loop do
        loop = false
        for k, _queue in pairs(self._buildqueue) do
            if _queue.expire and _queue.expire < curtime then
                table.remove(self._buildqueue, k)
                loop = true
                update = true
                break
            end
        end
    end
    if update then
        self._record:set_field("buildqueue", table.encode(self._buildqueue))
        self:savedb()
        if not nosync then
            self:sync_build_queue()
        end
    end
end

--建筑升级事件
function PlayerCityModule:upgrade_build_event(id, oldlv, newlv)
    if id == citycommon.castle_type then --城堡升级, 检索地块解锁
        self:unlock_land_event()
    end
end
return PlayerCityModule