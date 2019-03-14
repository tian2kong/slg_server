local thingcommon = require "thingcommon"
local thinginterface = require "thinginterface"
local client_request =  require "client_request"
local weightwrap = require "weightwrap"

--物品消息
local message_code = {
	--未知错误
	unkown = 0,
	--成功
    success = 1,

    limit_use = 2,--已达到使用上限
    Food_overflow = 3,--食物溢出
    Water_overflow = 4,--水溢出
    Iron_overflow = 5,--铁溢出
    Gas_overflow = 6,--天然气溢出
    Money_overflow = 7,--元宝溢出
    error_thing = 8,--错误的物品
}

function client_request.reqthings(player, msg)
    return { info = player:thingmodule():get_thing_message() }
end

function client_request.userewarditem(player, msg)
    local thingmod = player:thingmodule()
    local tokendata = {}
    local cfg = thinginterface.get_thing_config(msg.cfgid)
    if cfg.item_type ~= thingcommon.item_type.token_item or not cfg.extdata_res then
        code = message_code.error_thing
    else
        local ret
        ret, code = thingmod:can_use_thing(msg.cfgid, msg.num, msg.auto)
        if ret then
            code = message_code.success
            local tokenmod = player:tokenmodule()
            for k,v in pairs(cfg.extdata_res) do
                tokendata[string.capitalize(k)] = v * msg.num
            end
            for currency, num in pairs(tokendata) do
                if tokenmod:is_token_overflow(currency, num) then
                    local key = currency .. "_overflow"
                    code = message_code[key]
                    break
                end
            end
            if code == message_code.success then
                thingmod:use_thing(msg.cfgid, msg.num, msg.auto)

                for k,v in pairs(tokendata) do
                    tokenmod:addtoken(k, v)
                end
            end
        end
    end
    return { code = code, token = tokendata }
end

function client_request.usegiftitem(player, msg)
    local thingmod = player:thingmodule()
    local data = {}
    local ret, code = thingmod:can_use_thing(msg.cfgid, msg.num)
    if ret then
        local thing = thingmod:get_thing(msg.cfgid)
        local cfg = thing:getconfig()
        if cfg.item_type ~= thingcommon.item_type.gift_item or not cfg.extdata_add_giftbox then
            code = message_code.error_thing
        else
            code = message_code.success
            thingmod:consume_thing(msg.cfgid, msg.num)

            local reward = {}
            for i=1,msg.num do
                local v, k = weightwrap.random(cfg.extdata_add_giftbox, 2)
                reward[k] = (reward[k] or 0) + v[1]
            end

            thingmod:add_multiple_thing(reward)
            data = thinginterface.get_thing_messagedata(reward)
        end
    end
    return { code = code, info = data }
end