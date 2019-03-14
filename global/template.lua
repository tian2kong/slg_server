--代码模版（有点像c里面的宏但其实不好用）。可以让 lua 在编译期做一些计算
--具体可看云风blog   http://blog.codingnow.com/2008/08/compile_time_calculation_in_lua.html
local select=select
local setmetatable=setmetatable
local load=load
local type=type
local tostring=tostring
local next=next
local unpack=table.unpack
local assert=assert
local string=string
local table=table
local io=io
 
local function result(...)
	return select("#",...),select(1,...)
end
 
local args_code = setmetatable({},{
	__mode="v",
	__index=function(t,k)
		local ret="local __arg_"
		for i=1,k-1 do
			ret=ret..tostring(i)..",__arg_"
		end
		ret=ret..tostring(k).."=...\n"
		t[k]=ret
		return ret
	end})
 
function compile(code)
	local is_code=string.sub(code,1,1)~="|"
	local codes={""}
	local args={}
	local args_cache={}
	local E=setmetatable({
		include = function(filename)
			local f=assert(io.open(filename))
			local ret=f:read "*a"
			f:close()
			return ret
		end
	},{__index=_ENV})
	for v in string.gmatch(code,"[^|]+") do
		if is_code then
			table.insert(codes,v)
		elseif string.sub(v,1,1)=="#" then
			local v=assert(load("return "..string.sub(v,2), nil, "bt", E))()
			assert(type(v)=="string")
			table.insert(codes,v)
		else
			local f,err=load(v)
			if f==nil then
				f,err=load("return "..v, nil, "bt", E)
			end
			local n,value=result(assert(f,err)())
			if n>0 then
				local t=type(value)
				if t=="nil" or t=="number" or t=="boolean" then
					table.insert(codes,tostring(value))
				elseif t=="string" then
					table.insert(codes,"[=["..value.."]=]")
				else
					local n=args_cache[value]
					if not n then
						table.insert(args,value)
						n=#args
						args_cache[value]=n
					end
					table.insert(codes,"__arg_"..tostring(n))
				end
			end
		end
		is_code=not is_code
	end
 
	if next(args) then
		codes[1]=args_code[#args]
	end
 
	local code_string=table.concat(codes)
 
--	print(code_string)
 
	assert(load(code_string, nil, "bt", E))(unpack(args))
end

--[==[测试代码
test.lua
require "template"
 
compile [[
function test(t)
	for _,v in ipairs(|{"one","two","three"}|) do
		print(v,t[v])
	end
end
]]
 
compile [[
|ALPHA=2*math.pi|
function test2()
	return |ALPHA|
end
]]
 
print(test({one=1,two=2,three=3}))
print(test2)




hehe.lua
local a="I'm local"


foo.lua
require "template"
 
compile [[
|#include "hehe.lua"|
print(a)
]]
]==]