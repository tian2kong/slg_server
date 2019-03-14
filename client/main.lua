local socket = require "socket"
local proto = require "proto"
local timesync = require "timesync"
require "luaext"

local IP = "127.0.0.1"

local fd = assert(socket.login {
	host = IP,
	port = 8801,
	server = "sample",
	user = "hello",
	pass = "password",
})


fd:connect(IP, 9999)

local function request(fd, type, obj, cb)
	local data, tag = proto.request(type, obj)
	local function callback(ok, msg)
		if ok then
			print(tostring(proto.response(tag, msg)))
			if cb then
				return cb(proto.response(tag, msg))
			end
		else
			print("error:", msg)
		end
	end
	fd:request(data, callback)
end

local function dispatch(fd)
	local cb, ok, blob = fd:dispatch(0)
	if cb then
		cb(ok, blob)
	end
end

local udp

function requestcb (obj)
	obj.secret = fd.secret
	udp = socket.udp(obj)
	udp:sync()
end

request(fd, "join", { room = 1 } , requestcb)
--request(fd, "reqcontainer", { containertype = 1 })
--request(fd, "thingsplit", { containertype = 1, position = 1, num = 10 })
--request(fd, "thingmove", { containertype = 1, srcpos = 1, tarpos = 2 })
--request(fd, "thingdrop", { position = 3})
request(fd, "thingtidy", { containertype = 1 })
request(fd, "storagestore", { position = 1 })
request(fd, "storagestore", { position = 2 })
request(fd, "storageextract", { position = 1 })

for i=1,1000 do
	timesync.sleep(1)
	if (i == 100 or i == 200 or i ==300 or i == 600) and udp then
		local gtime = timesync.globaltime()
		if gtime then
			print("send time", gtime)
			udp:send ("Hello" .. i .. ":1")
			udp:send ("Hello" .. i .. ":2")
			udp:send ("Hello" .. i .. ":3")
		end
	end
	if udp then
		local time, session, data = udp:recv()
		if time then
			print("UDP", "time=", time, "session =", session, "data=", data)
		end
	end
	dispatch(fd)
end
