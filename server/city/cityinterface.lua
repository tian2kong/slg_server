local cityinterface = BuildInterface("cityinterface")

function cityinterface.get_build_time(player, _time)
    if not _time then
        return 0
    end
    --加速公式ultimate_time =original_time/(1+ building_speed_add/1000)
    local building_speed_add = 0
    _time = _time / (1 + building_speed_add / 1000)
    return _time
end

function cityinterface.get_time_price(_time)
    local price = 0
    local index = #get_static_config().speedup_price
    while index > 0 do
        local cfg = get_static_config().speedup_price[index]
        if cfg.time < _time then
            price = math.ceil(_time * cfg.price / cfg.time)
            break
        end
        index = index - 1
    end
    return price
end

return cityinterface