local class = require "class"
local config = require "robotconfig"
local Rand = require "random"
local sproto = require "sproto"
local parser = require "sprotoparser"
local protos = require "protos"
local IRobotModule = require "irobotmodule"

--sproto协议默认结构
local request_default = {}
local default_struct = {}

local RobotPToll = class("RobotPToll", IRobotModule)

function RobotPToll:ctor(robot, spo)
	self.robot = robot
	self.sproto = spo
	self.protoarr = parser.getprotot(protos.c2s)
	self.aiparam = config.getai("ptoll")
end

function RobotPToll:init()
	self.wait_time = os.time()
	self.curindex = 1
	self.max = #self.protoarr
	self.maxarr = 200
end

function RobotPToll:online()
	
end

--主循环
function RobotPToll:run(frame)
	if not self.aiparam then
		return 
	end
	local ctime = os.time()
	if self.wait_time < ctime then 
		if self.curindex > self.max then 
			self.curindex = 1
			self.rand = true
		end
		if self.rand  then
			self:runrand(ctime) 		--发随机
		else
			self:runconf(ctime)
		end
	
		self.wait_time = ctime + 0
	end
		
end

--发配置的
function RobotPToll:runconf(ctime)
	for i = self.curindex, self.max do
		self.curindex = self.curindex + 1
		local p = self.protoarr[i]
		local pname = p[1]
		if p.type == "protocol" and pname ~= "logout" then
			local default = self.sproto:default(pname, "REQUEST") 
			self.robot.net:send_request(pname, default) --发默认参数
			if default then
				self:sendconfn(pname)		--发配置的数字
				self:sendconfs(pname)		--发送配置的字符串
			end
			break
		end
	end

end

--发随机的
function RobotPToll:runrand(ctime)
	for i = self.curindex, self.max do
		self.curindex = self.curindex + 1
		local p = self.protoarr[i]
		local pname = p[1]
		if p.type == "protocol" and pname ~= "logout" then
			local default = self.sproto:default(pname, "REQUEST")
			if default then
				self:sendrand(pname)
				break
			end
		end
	end
end


-----------------------------------------------
--发送随机的
function RobotPToll:sendrand(pname)
	local rpa = self.aiparam.rnparam
	local default = self.sproto:default(pname, "REQUEST") 
	if default then 
		for _, v in pairs(rpa) do 
			self:InitRandParam(default, v)
		end
		self.robot.net:send_request(pname, default)
	end
end

--发送配置的数字
function RobotPToll:encodeargs(default, k, first, values)
	for k1, v in pairs(default) do 
		if type(v) == "table" then 
			local temp
			if v.__type then 
				temp = self.sproto:default(v.__type)
				default[k1] = temp
				self:encodeargs(temp, k, first, values)
				v.__type = nil
			end
			
			if v.__arr then 
				temp = self.sproto:default(v.__arr)
				local rand = Rand.Get(1, self.maxarr)
				default[k1] = {}
				for i= 1, rand do 
					table.insert(default[k1], temp)
				end
				for k, v in pairs(default[k1]) do 
					self:encodeargs(v, k, first, values)
				end
				
				v.__arr = nil
			end
			
			if not v.__arr and not v.__type then 
				temp = v
				self:encodeargs(temp, k, first, values)
			end

		else 
			if k1 == k then 
				if type(v) == "boolean" then 
					default[k1] = self:RandBool()
				elseif type(v) == "string" then 
					default[k1] = tostring(first)
				else 
					default[k1] = first
				end
			else 
				if type(v) == "boolean" then 
					default[k1] = self:RandBool()
				elseif type(v) == "string" then 
					default[k1] = tostring(values)
				else 
					default[k1] = values
				end
			end
		end
	end
end
function RobotPToll:sendconfn(pname)
	local default = self.sproto:default(pname, "REQUEST") 
	if default then 
		local pa =  self.aiparam.nparam
		for k, v in pairs(default) do 
			for _, v1 in pairs(pa) do 
				self:encodeargs(default, k, v1, v1)
				self.robot.net:send_request(pname, default)
			end
		end
	end
end

--发送配置的字符串
function RobotPToll:sendconfs(pname)
	local default = self.sproto:default(pname, "REQUEST") 
	if default then 
		self:findstr(pname, default, default)
	end
end



------------------private-----------

function RobotPToll:RandNum(t)
	return Rand.Get(t[1], t[2])
end

function RobotPToll:RandStr()
	local sarr =  self.aiparam.rsmaram
	local result = ""
	local max = #sarr
	local len = Rand.Get(1, self.aiparam.rslen)
	if not self.isrand then 
		len = 30
	end
	for i = 1, len do 
		local str = sarr[Rand.Get(1, max)]
		result = result .. str
	end
	return result
end

function RobotPToll:RandBool()
	local tem = Rand.Get(1, 2)
	return  (tem == 1 and true) or false
end


function RobotPToll:InitRandParam(default, numt)
	for k, v in pairs(default) do 
		if type(v) == "table" then 
			local temp
			if v.__type then 
				temp = self.sproto:default(v.__type)
				default[k] = temp
				self:InitRandParam(temp, numt)
				v.__type = nil
			end
			
			if v.__arr then 
				temp = self.sproto:default(v.__arr)
				local rand = Rand.Get(1, self.maxarr)
				default[k] = {}
				for i= 1, rand do 
					table.insert(default[k], temp)
				end
				for k, v in pairs(default[k]) do 
					self:InitRandParam(temp, numt)
				end
			
				v.__arr = nil
			end
			
			if not v.__arr and not v.__type then 
				temp = v
				self:InitRandParam(temp, numt)
			end

		elseif type(v) == "string" then 
			default[k] = self:RandStr()
		elseif type(v) == "boolean" then 
			default[k] = self:RandBool()
		else 
			default[k] =  self:RandNum(numt)
		end
	end

end


function RobotPToll:findstr(pname, t, default)
	for k, v in pairs(t) do 
		if type(v) == "table" then 
			local temp
			if v.__type then 
				temp = self.sproto:default(v.__type)
				t[k] = temp
				self:findstr(pname, temp, default)
				v.__type = nil
			end
			
			if v.__arr then 
				temp = self.sproto:default(v.__arr)
				t[k] = {temp}
				self:findstr(pname, temp, default)
				v.__arr = nil
			end
			
			
		elseif type(v) == "string" then 
			self:sendstr(pname, k, default)
		end
	end
end

function RobotPToll:replacekey(t, key, value)
	for k, v in pairs (t) do 
		if type(v) == "table" then 
			self:replacekey(v, key, value)
		elseif  type(v) == "string" and  k == key then 
			t[key] = value
		end
	end

end

function RobotPToll:sendstr(pname, k, default)
	local spa = self.aiparam.sparam
	for _, str in pairs(spa) do 
		self:InitRandParam(default, {1, 200})
		self:replacekey(default, k, str)
		self.robot.net:send_request(pname, default)
	end
end



return RobotPToll
 