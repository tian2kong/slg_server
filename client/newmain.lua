package.cpath = "skynet/luaclib/?.so;luaclib/?.so"


local socket = require "client.socket"

local crypt = require "client.crypt"
local sproto = require "sproto"
local protoloader = require "protoloader"
local game_proto = require "game_proto"
require "luaext"
local curl = require "lcurl"

local g_user, g_ip, g_port = ...
g_ip = "192.168.1.3"
g_user = g_user or "yxx007"
g_port = 10008


-- g_ip = "192.168.1.5"
-- g_user ="1000208"
-- g_port = 3333

-- g_ip = "192.168.1.5"
-- g_user ="nn01"
-- g_port = 10231


-- g_ip = "119.28.86.12"
-- g_user ="92eb266437ba1f0c6f7b2e10edf6d904"
-- g_port = 10001
print(g_user, g_ip, g_port)

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

---------------------------------------------------------------------------
local httpret = nil
-- HTTP Get
curl.easy{
    url = 'http://192.168.1.5:8002/accountserver.php?device=' .. g_user,
    --url = 'http://dh2-feimi-api.vrseastar.com/accountserver.php?device=' .. g_user,
    writefunction = function(t)
			httpret = table.decode(t)
			
		end
  }
  :perform()
:close()

-------------------------loginserver--------------------------------------
local token = {
	server = "sample",
	user = httpret.account,
	pass = "password",
}
local result
--for i=1, 100 do 
    local fd = assert(socket.connect(g_ip or "192.168.1.3", g_port or 10007))

    local function writeline(fd, text)
	    socket.send(fd, text .. "\n")
    end

    local function unpack_line(text)
	    local from = text:find("\n", 1, true)
	    if from then
		    return text:sub(1, from-1), text:sub(from+1)
	    end
	    return nil, text
    end

    local last = ""

    local function unpack_f(f)
	    local function try_recv(fd, last)
		    local result
		    result, last = f(last)
		    if result then
			    return result, last
		    end
		    local r = socket.recv(fd)
		    if not r then
			    return nil, last
		    end
		    if r == "" then
			    error "Server closed"
		    end
		    return f(last .. r)
	    end

	    return function()
		    while true do
			    local result
			    result, last = try_recv(fd, last)
			    if result then
				    return result
			    end
			    socket.usleep(100)
		    end
	    end
    end

    local readline = unpack_f(unpack_line)

    local challenge = crypt.base64decode(readline())

    local clientkey = crypt.randomkey()
    writeline(fd, crypt.base64encode(crypt.dhexchange(clientkey)))
    local secret = crypt.dhsecret(crypt.base64decode(readline()), clientkey)

    print("sceret is ", crypt.hexencode(secret))

    local hmac = crypt.hmac64(challenge, secret)
    writeline(fd, crypt.base64encode(hmac))


    local function encode_token(token)
	    return string.format("%s@%s:%s",
		    crypt.base64encode(token.user),
		    crypt.base64encode(token.server),
		    crypt.base64encode(token.pass))
    end

    local etoken = crypt.desencode(secret, encode_token(token))
    local b = crypt.base64encode(etoken)
    writeline(fd, crypt.base64encode(etoken))

    result = readline()
    print("result = " .. result)
    local code = tonumber(string.sub(result, 1, 3))
    assert(code == 200)
    socket.close(fd)
--end

local subid = crypt.base64decode(string.sub(result, 5))

print("login ok, subid=", subid)

local _, gameip, gameport = string.match(subid, "(%w+)@(%g+):(%w+)")
print("login game server :", gameip, gameport)
----------------------------gameserver-------------------------------------------------

local host = sproto.new(game_proto.s2c):host "package"
local request = host:attach(sproto.new(game_proto.c2s))

local fd = assert(socket.connect(gameip, tonumber(gameport)))

local function bin2hex(s)
  s=string.gsub(s,"(.)",function (x) return string.format("%02X ",string.byte(x)) end)
  return s
end

local function send_message (fd, msg)
	local package = string.pack (">s2", msg)
	socket.send(fd, package)
end

local session = {}
local session_id = 0
local function send_request (name, args)
	print ("send_request", name)
	session_id = session_id + 1
	local str = request (name, args, session_id)
	send_message (fd, str)
	session[session_id] = { name = name, args = args }
end

local function unpack (text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte (1) * 256 + text:byte (2)
	if size < s + 2 then
		return nil, text
	end

	return text:sub (3, 2 + s), text:sub (3 + s)
end

local function recv (last)
	local result
	result, last = unpack (last)
	if result then
		return result, last
	end
	local r = socket.recv (fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error (string.format ("socket %d closed", fd))
	end

	return unpack (last .. r)
end

local function handle_request (name, args, response)
    print(tostring(name))
    print(tostring(args))
end

local RESPONSE = {}

function RESPONSE:handshake (args)
	print ("RESPONSE.handshake")
end
local index = 0
local function handle_response (id, args)
	local s = assert (session[id])
	session[id] = nil
	local f = RESPONSE[s.name]
	if f then
		f (s.args, args)
	else
		print "response"
		print (tostring(args))
        index = index + 1
        print(index)
	end
end

local function handle_message (t, ...)
	if t == "REQUEST" then
		handle_request (...)
	else
		handle_response (...)
	end
end

local last = ""
local function dispatch_message ()
	while true do
		local v
		v, last = recv (last)
		if not v then
			break
		end

		handle_message (host:dispatch (v))
	end
end

local version = 1
local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(subid) , version)
local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

local vtoken = handshake .. ":" .. crypt.base64encode(hmac)

send_request("login", { token = vtoken, datetime = httpret.datetime, sign = httpret.sign })
send_request("createrole", {name = "123", roleid=1001})
send_request("entergameok")


local HELP = {}

local function handle_cmd (line)
	local cmd
	local p = string.gsub (line, "([%w-_]+)", function (s) 
		cmd = s
		return ""
	end, 1)

	if string.lower (cmd) == "help" then
		for k, v in pairs (HELP) do
			print (string.format ("command:\n\t%s\nparameter:\n%s", k, v()))
		end
		return
	end

	local t = {}
	local f = load (p, "=" .. cmd, "t", t)
	if f then
		f ()
	end

	if not next (t) then
		t = nil
	end

	if cmd then
		local ok, err = pcall (send_request, cmd, t)
		if not ok then
			print (string.format ("invalid command (%s), error (%s)", cmd, err))
		end
	end
end

function HELP.character_create ()
	return [[
	name: your nickname in game
	race: 1(human)/2(orc)
	class: 1(warrior)/2(mage)
]]
end

print ('type "help" to see all available command.')
while true do
	dispatch_message ()
	local cmd = socket.readstdin ()
	if cmd then
		handle_cmd (cmd)
	else
		socket.usleep (100)
	end
end