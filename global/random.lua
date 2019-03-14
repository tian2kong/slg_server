
local Random = {}

-- 此函数用法等价于math.random
-- Random.Get(m,n)
do
	local randomtable
	local tablesize = 97

	function Random.Get(m, n)
		-- 初始化随机数与随机数表，生成97个[0,1)的随机数
		if not randomtable then
			-- 避免种子过小
			math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
			randomtable = {}
			for i = 1, tablesize do
				randomtable[i] = math.random()
			end
		end

		local x = math.random()
		local i = 1 + math.floor(tablesize*x)	-- i取值范围[1,97]
		x, randomtable[i] = randomtable[i], x	-- 取x为随机数，同时保证randomtable的动态性

		if not m then
			return x
		elseif not n then
			n = m
			m = 1
		end

		--if not Check(m <= n) then return end

		local offset = x*(n-m+1)
		return m + math.floor(offset)
	end
end

-- 取得[m, n]连续范围内的k个不重复的随机数
function Random.GetRange(m, n, k)
	
	--if not Check(m <= n) then return end
	--if not Check(k <= m-n+1) then return end

	local t = {}
	for i = m, n do
		t[#t + 1] = i
	end

	local size = #t
	for i = 1, k do
		local x = Random.Get(i, size)
		t[i], t[x] = t[x], t[i]		-- t[i]与t[x]交换
	end

	local result = {}
	for i = 1, k do
		result[#result + 1] = t[i]
	end

	return result
end

-- 问题描述:"有N个物品,每个物品都有对应的被选中的概率,求随机选出k个物品"
-- data是一个数组,每一个元素是这样的table{ id = 0, rate = 0 }, 其中id表示物品的id,
-- rate表示物品被选中的概率.所有元素的rate值加起来为1
-- 返回被选中的物品id
function Random.GetIds(t, k)
	--if not Check(k <= #t) then return end

	local rate_left = 1
	for i = 1, k do
		local x = Random.Get() * rate_left
		local rate = 0
		local n
		for j = 1, #t do
			--Check(t[j].rate)
			rate = rate + t[j].rate
			if rate >= x then
				n = j
				break
			end
		end
		--if not Check(n, x) then return end
		-- t[i]与t[n]交换
		--[[local tmp = t[n]
		t[n] = t[i]
		t[i] = tmp--]]

		t[i], t[n] = t[n], t[i]
		rate_left = rate_left - t[i].rate
	end

	local result = {}
	for i = 1, k do
		--Check(t[i].id)
		result[#result + 1] = t[i].id
	end

	return result
end



-- 问题描述:"有N个物品,每个物品都有对应的被选中的概率,求随机选出1个物品"
-- data是一个数组,每一个元素是这样的table{ id = 0, rate = 0 }, 其中id表示物品的id,
-- rate表示物品被选中的概率.所有元素的rate值加起来为1
-- 返回被选中的物品id
function Random.GetId(t)
	local ids = Random.GetIds(t, 1)
	return ids[1]
end


--问题描述：从一列无序的集合t中随机选择n个数 如：{1，233，abc, 100}
--可用于随机打乱先后顺序
function Random.GetSets(t, n)
	local size = #t
    n = n or size
    if n > size then
        n = size
    elseif n == 0 then
    	return t
    end

    local result = {}
    local indexs = Random.GetIndexs(t,n)
    for k,v in pairs(indexs) do
        table.insert(result, t[v])
    end
    return result
end

--返回Key
function Random.GetIndexs(t, n)
    local tmp = {}
    for k,_ in pairs(t) do
        table.insert(tmp, k)--记录key
    end
    
    --[[
    利用洗牌的原理，将n个数(0至n-1)按次序排好，依次让每个数和一个随机挑选出的位子进行互换，
    这样肯定不会重复，而且次序被打乱，具有随机性。 只用交换k次，就可以取出k个小于n的互不相同的随机数。
    ]]
    local result = {}
    for i = 1, n do 
        local index = Random.Get(i, #tmp)
        table.insert(result, tmp[index])
        tmp[index] = tmp[i]
    end
    return result
end

--求概率
function Random.dice(rate, max)
	--默认万分比
	max = max or 10000

    if rate >= max then
        return true
    elseif rate <= 0 then
        return false
    end

    local rd = Random.Get(1, max)
    print("rd === [%d]", rd)
    return rd <= rate
end

return Random

