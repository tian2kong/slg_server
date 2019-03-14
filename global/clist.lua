local calss = require "class"
CList = calss("CList") 

function CList:ctor() 
	self:ReSet()
end 
function CList:PushFront(value) 
    local first = self.m_list.first - 1 
    self.m_list.first = first 
    self.m_list[first] = value 
end 
function CList:PushBack(value) 
    local last = self.m_list.last + 1 
    self.m_list.last = last 
    self.m_list[last] = value 
end 
function CList:PopFront() 
    local first = self.m_list.first 
    if first > self.m_list.last then return nil end 
    local value = self.m_list[first] 
    self.m_list[first] = nil 
    self.m_list.first = first + 1 
    return value 
end 
function CList:PopBack() 
    local last = self.m_list.last 
    if self.m_list.first > last then return nil end 
    local value = self.m_list[last] 
    self.m_list[last] = nil 
    self.m_list.last = last - 1 
    return value 
end 
function CList:GetSize() 
    if self.m_list.first > self.m_list.last then 
        return 0 
    else 
        return math.abs(self.m_list.last - self.m_list.first) + 1 
    end 
end 
function CList:ReSet()
	self.m_list = { first = 0, last = -1 } 
end
function CList:GetFirst()
	local first = self.m_list.first 
	return self.m_list[first]
end

return CList