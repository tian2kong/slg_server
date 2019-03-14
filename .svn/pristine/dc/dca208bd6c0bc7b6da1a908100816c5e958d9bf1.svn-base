local client_request =  require "client_request"
local thinginterface = require "thinginterface"
local cityinterface = require "cityinterface"
local citycommon = require "citycommon"

local message_code = {
    unkown = 0,
    success = 1,
    lock_land = 2,--地块未解锁
    land_developed = 3,--地块已开拓
    limit_num = 4,--建筑数量上限
    unkown_build = 5,--没有找到建筑配置
    limit_level = 6,--主堡等级限制
    limit_quest = 7,--任务限制
    unkown_facility = 8,--没有找到设施
    limit_buildlv = 10,--前置建筑等级不足  Upgrade_buildlv 字段
    no_empty_queue = 11,--没有空队列
    error_thing = 12,--错误的物品
    have_thing = 13,--背包游物品无需购买
    in_building = 14,--设施正在建造升级中
    unkown_next_build = 15,--没有下一级建筑的配置
}

function client_request.reqmycity(player, msg)
    local citymod = player:citymodule()
    return {
        land = citymod:get_land_message(),
        facility = citymod:get_facility_message(),
        queue = citymod:get_queue_message(),
    }
end

function client_request.developland(player, msg)
    local citymod = player:citymodule()
    local code = message_code.unkown
    local state = citymod:get_land_state(msg.cfgid)
    local land
    if not state then
        code = message_code.lock_land
    elseif state == citycommon.land_state.developed then
        code = message_code.land_developed
    else
        citymod:develop_land(msg.cfgid)
        citymod:unlock_land_event()
        code = message_code.success
        land = {
            cfgid = msg.cfgid,
            state = citymod:get_land_state(msg.cfgid)
        }
    end
    return { code = code, land = land }
end

--是否可建造设施
local function can_create_facility(player, buildcfg)
    if not buildcfg then
        return message_code.unkown_build
    end
    if not get_static_config().building[buildcfg.Build_type][buildcfg.Level + 1] then
        return message_code.unkown_next_build
    end
    local tokenmod = player:tokenmodule()
    if buildcfg.Water and not tokenmod:cansubtoken("Water", buildcfg.Water) then
        return global_code.less_water
    end
    if buildcfg.Food and not tokenmod:cansubtoken("Food", buildcfg.Food) then
        return global_code.less_food
    end
    if buildcfg.Iron and not tokenmod:cansubtoken("Iron", buildcfg.Iron) then
        return global_code.less_iron
    end
    if buildcfg.Gas and not tokenmod:cansubtoken("Gas", buildcfg.Gas) then
        return global_code.less_gas
    end
    local thingmod = player:thingmodule()
    if buildcfg.Item and thingmod:can_consume_multiple_thing(buildcfg.Item) then
        return global_code.less_thing
    end

    if buildcfg.Upgrade_buildlv then
        local citymod = player:citymodule()
        for k,v in pairs(buildcfg.Upgrade_buildlv) do
            if citymod:get_facility_level(k) < v then
                return message_code.limit_buildlv
            end
        end
    end
    return message_code.success
end
--建造消耗
local function create_facility_consume(player, buildcfg)
    local tokenmod = player:tokenmodule()
    if buildcfg.Water and buildcfg.Water > 0 then
        tokenmod:subtoken("Water", buildcfg.Water)
    end
    if buildcfg.Food and buildcfg.Food > 0 then
        tokenmod:subtoken("Food", buildcfg.Food)
    end
    if buildcfg.Iron and buildcfg.Iron > 0 then
        tokenmod:subtoken("Iron", buildcfg.Iron)
    end
    if buildcfg.Gas and buildcfg.Gas > 0 then
        tokenmod:subtoken("Gas", buildcfg.Iron)
    end
    local thingmod = player:thingmodule()
    if buildcfg.Item then
        thingmod:consume_multiple_thing(buildcfg.Item)
    end
end

function client_request.createfacility(player, msg)
    local citymod = player:citymodule()
    local code = message_code.unkown
    local cfg = get_static_config().build_num[msg.type]
    local num = citymod:get_facility_num(msg.type)
    local castlelv = citymod:get_castle_level()
    local data
    if not cfg then
        code = message_code.unkown_build
    elseif num >= cfg.Num then
        code = message_code.limit_num
    elseif (cfg.Mainlevel[num + 1] or cfg.Mainlevel[#cfg.Mainlevel]) > castlelv then
        code = message_code.limit_level
    --elseif msg.pos then --验证原点坐标是否合法
    else
        local buildcfg = get_static_config().building[msg.type][cfg.OriginLevel]
        code = can_create_facility(player, buildcfg)
        if code == message_code.success then
            local _time = cityinterface.get_build_time(player, buildcfg.Time)
            if _time > 0 and not citymod:get_empty_queue(_time) then
                code = message_code.no_empty_queue
            else
                create_facility_consume(player, buildcfg)
                local level = cfg.OriginLevel
                if _time <= 0 then
                    level = level + 1
                end
                local facility = citymod:create_facility(msg.type, msg.pos.x, msg.pos.y, level)
                data = facility:get_message_data()
                if _time > 0 then
                    citymod:add_build_queue(facility, _time)
                end
            end
        end
    end
    return { code = code, facility = data }
end

function client_request.editfacility(player, msg)
    local citymod = player:citymodule()
    local code = message_code.success
    for _,v in pairs(msg.info) do
        --验证坐标合法性
        local facility = citymod:get_facility(v.id)
        if not facility then
            code = message_code.unkown_facility
            break
        --elseif then--验证坐标原点
        end
    end
    if code == message_code.success then
        for _,v in pairs(msg.info) do
            --验证坐标合法性
            local facility = citymod:get_facility(v.id)
            facility:set_origin(v.pos.x, v.pos.y)
        end
    end
    return { code = code, info = info }
end

function client_request.upgradefacility(player, msg)
    local citymod = player:citymodule()
    local tokenmod = player:tokenmodule()
    local code = message_code.unkown
    repeat 
        local facility = citymod:get_facility(msg.id)
        if not facility then
            code = message_code.unkown_facility
            break
        end
        if citymod:is_facility_building(msg.id) then
            code = message_code.in_building
            break
        end
        local buildcfg = facility:get_config()
        code = can_create_facility(player, buildcfg)
        if code ~= message_code.success then
            break
        end
        local needmoney = 0
        local _time = cityinterface.get_build_time(player, buildcfg.Time)
        if _time > 0 then
            if msg.quick then
                needmoney = cityinterface.get_time_price(_time)
                if needmoney > 0 and not tokenmod:cansubtoken("Money", needmoney) then
                    code = global_code.less_money
                    break
                end
            elseif not citymod:get_empty_queue(_time) then
                code = message_code.no_empty_queue
                break
            end
        end
        code = message_code.success
        create_facility_consume(player, buildcfg)
        if needmoney > 0 then
            tokenmod:subtoken("Money", needmoney)
        end
        if _time <= 0 or msg.quick then
            local oldlv = facility:get_level()
            local newlv = oldlv + 1
            facility:set_level(newlv)
            facility:savedb()
            citymod:upgrade_build_event(msg.id, oldlv, newlv)
            citymod:sync_facility(citycommon.update_type.building, facility)
        else
            citymod:add_build_queue(facility, _time)
        end
    until 0
    return { code = code }
end

function client_request.buybuildqueue(player, msg)
    local citymod = player:citymodule()
    local thingmod = player:thingmodule()
    local tokenmod = player:tokenmodule()
    local code = message_code.unkown
    repeat
        local cfg = thinginterface.get_thing_config(msg.item)
        if not get_static_config().globals.Add_queueitem[msg.item] or not cfg or not cfg.extdata_add_queue then
            code = message_code.error_thing
            break
        end
        local ret
        ret, code = thingmod:can_use_thing(msg.item, msg.num, msg.auto)
        if not ret then
            break
        end
        thingmod:use_thing(msg.item, msg.num, msg.auto)
        
        code = message_code.success
        citymod:upgrade_build_queue(cfg.extdata_add_queue * msg.num)
    
    until 0
    
    return { code = code, item = msg.item, num = msg.num, auto = msg.auto }
end