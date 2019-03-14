local module = player:thingmodule()

--获取物品对象 thing.lua
module:get_thing(cfgid)

--获取物品数量
module:get_thing_num(cfgid)

--[[参数定义
    @param: 物品数据
    { 
        [cfgid] = num, ... 
    } 

    @logparam: 经分配置
    {
        action_id, 经分id
        para, {} 经分附加参数
        parastr, {} 经分附加参数 1~5=>para_str1 ~para_str5
    }
]]
--增加多个物品
module:add_multiple_thing(param, logparam)

--消耗多个物品
module:consume_multiple_thing(param, logparam)

--增加物品
module:add_thing(cfgid, num, logparam)

--消耗物品
module:consume_thing(cfgid, num, logparam)

--是否可以使用指定数量物品 返回 是否成功和global_code
module:can_use_thing(cfgid, num)