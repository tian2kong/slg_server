local module = player:tokenmodule()

--[[参数定义
@currency：（货币类型字符串）
"Food",         --食物
"Water",        --水
"Iron",         --铁
"Gas",          --天然气
"Money",        --元宝
"BangGong",     --帮贡
"ArenaScore",   --竞技场积分

@logparam: 经分配置
{
    action_id, 经分id
    para, {} 经分附加参数
    parastr, {} 经分附加参数 1~5=>para_str1 ~para_str5
}
]]
--获取货币
module:gettoken(currency)

--添加货币数量
module:addtoken(currency, num, logparam)

--添加可掠夺货币数量
module:addsystoken(currency, num, logparam)

--减少货币数量
module:subtoken(currency, num, logparam)

--是否可消耗货币
module:cansubtoken(currency, num)

--代币是否会溢出
module:is_token_overflow(currency, num)