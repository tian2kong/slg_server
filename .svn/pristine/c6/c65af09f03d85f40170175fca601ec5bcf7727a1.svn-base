local List = {}

function List.new()
	return {first = 0, last = -1}
end

function List.push_front(list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

function List.push_back(list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.pop_front(list)
	local first = list.first
	if first > list.last then
		error("list is empty")
        return nil
	end
	local value = list[first]
	list[first] = nil
	list.first = first + 1
	return value
end

function List.pop_back(list)
	local first = list.first
	if first > list.last then
		error("list is empty")
        return nil
	end
	local value = list[list.last]
	list[list.last] = nil
	list.last = list.last - 1
	return value
end
--顺序遍历队列
function List.traversal(list)
    local index = list.first - 1
    return function() 
        index = index + 1
        return list[index]
    end
end
--逆序遍历队列
function List.reverse(list)
    local index = list.last + 1
    return function() 
        index = index - 1
        return list[index]
    end
end
--返回队列大小
function List.size(list)
    return list.last + 1 - list.first
end

function List.empty(list)
    return list.first > list.last
end

return List