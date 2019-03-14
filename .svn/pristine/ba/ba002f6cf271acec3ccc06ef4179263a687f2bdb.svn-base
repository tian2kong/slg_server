local thinginterface = BuildInterface("thinginterface")

--[[@thingdata: 
{
    [cfgid] = num,
}
]]
function thinginterface.get_thing_messagedata(thingdata)
    local data = {}
    for k,v in pairs(thingdata) do
        data[k] = { cfgid = k, amount = v }
    end
    return data
end

function thinginterface.get_thing_config(cfgid)
    return get_static_config().item[cfgid]
end

return thinginterface