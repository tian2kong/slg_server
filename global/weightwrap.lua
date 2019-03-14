local Random = require "random"
local weightwrap = {}
--[[
取权重,field为权重字段名
t必须为二级结构表，二级表中要包含field字段
函数将返回随机到的二级表以及它在一级表中的key
]]
function weightwrap.random(t, field)
    local max = 0
    local temp = {}
    field = field or "weight"
    for k,v in pairs(t) do
        max = max + v[field]
        table.insert(temp, {max = max, key = k})
    end

    local key
    local rand = Random.Get(max)
    for _,v in ipairs(temp) do 
        if rand <= v.max then
            key = v.key
            break
        end
    end
    if key then
        return t[key], key
    end
    return nil
end

--[[
取权重，限定t格式为1级表  key为值， value为权重
]]
function weightwrap.table_random(t)
    local max = 0
    local temp = {}
    for k,v in pairs(t) do
        max = max + v
        table.insert(temp, {max = max, key = k})
    end
    local key
    local rand = Random.Get(max)
    for _,v in ipairs(temp) do 
        if rand <= v.max then
            key = v.key
            break
        end
    end
    return key
end


--二分查找
function weightwrap.binfind(t, rand)  
	assert(#t > 0)
	local left = 1
	local right = #t
    while left <= right do  
        local mid = left + ((right - left ) >> 1)
		if mid == 1 and  t[mid].rate >= rand then 
			return t[mid]
		end
		if t[mid].rate < rand and t[mid +1].rate >= rand then 
			return t[mid +1]
        elseif  t[mid].rate >= rand then 
			right = mid - 1
        else
			left = mid + 1
		end
    end
end  


--二分查找求权重
--t格式如下 {{id=1， rate=30}, {id=1， rate=30 }
function weightwrap.binrand(t)
	local poll = {}
	local max = 0
	for _, v in pairs(t) do 
		local t1 = {}
		max = max + v.rate
		t1.id = v.id
		t1.rate = max
		table.insert(poll, t1)
	end

	local  rand =Random.Get(0, max)
	--二分查找， 找出第一个大于ran的数，取前一个
	return  weightwrap.binfind(poll, rand)
end

return weightwrap