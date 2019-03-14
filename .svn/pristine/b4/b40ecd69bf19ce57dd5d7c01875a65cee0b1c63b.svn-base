local socket = require "clientsocket"
local crypt = require "crypt"
local config = require "robotconfig"
local class = require "class"
local sproto = require "sproto"
local protoloader = require "protoloader"
local game_proto = require "game_proto"
local RobotAI = require "robotai"
local curl = require "lcurl"

local RobotClient = class("RobotClient")

function RobotClient:ctor(user)
    self.device = user
    self.httpret = nil
    self.fd = nil
    self.session = {}
    self.session_id = 0
    self.host = sproto.new(game_proto.s2c):host "package"
	self.sproto = sproto.new(game_proto.c2s)
    self.request = self.host:attach(self.sproto)
    self.logic = nil
end

function RobotClient:send_request (name, args)
    print(name, args)
	self.session_id = self.session_id + 1
	local str = self.request(name, args, self.session_id)

    local package = string.pack (">s2", str)
	socket.send(self.fd, package)

	self.session[self.session_id] = { name = name, args = args }
end

function RobotClient:login()
	-------------------------------------------------------------------------
	-- HTTP Get
	curl.easy{
	    url = string.format('http://%s/accountserver.php?device=%s', config.httphost, self.device),
	    writefunction = function(t)
				self.httpret = table.decode(t)
			end
	  }
	  :perform()
	:close()

    -------------------------loginserver--------------------------------------
    local result
    local token = {
	    server = "sample",
	    user = self.httpret.account,
	    pass = "password",
    }

    local fd = assert(socket.connect(config.serverip, config.port))

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
    local code = tonumber(string.sub(result, 1, 3))
    assert(code == 200)
    socket.close(fd)

    local subid = crypt.base64decode(string.sub(result, 5))

    local _, gameip, gameport = string.match(subid, "(%w+)@(%g+):(%w+)")

    ----------------------------gameserver-------------------------------------------------

    self.fd = assert(socket.connect(gameip, tonumber(gameport)))

    local version = 1
    local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(subid) , version)
    local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

    local vtoken = handshake .. ":" .. crypt.base64encode(hmac)

    self.logic = RobotAI.new(self.device, self, vtoken, self.sproto, self.httpret)
    self.logic:init()
end

function RobotClient:run(frame)
    local function unpack(text)
	    local size = #text
	    if size < 2 then
		    return nil, text
	    end
	    local s = text:byte(1) * 256 + text:byte(2)
	    if size < s + 2 then
		    return nil, text
	    end
	    return text:sub(3, 2 + s), text:sub(3 + s)
    end
    local function recv (last)
	    local result
	    result, last = unpack(last)
	    if result then
		    return result, last
	    end
	    local r = socket.recv (self.fd)
	    if not r then
		    return nil, last
	    end
	    if r == "" then
		    error(string.format ("socket %d closed", self.fd))
	    end

	    return unpack(last .. r)
    end
    local function handle_response(id, args)
	    local s = assert (self.session[id])
	    self.session[id] = nil
        self.logic:server_response(s.name, args)
    end

    local function handle_request(name, args, response)
        self.logic:server_request(name, args)
    end

    local function handle_message(t, ...)
	    if t == "REQUEST" then
		    handle_request(...)
	    else
		    handle_response(...)
	    end
    end

    local last = ""
    local function dispatch_message()
	    while true do
		    local v
		    v, last = recv(last)
		    if not v then
			    break
		    end

		    handle_message(self.host:dispatch(v))
	    end
        socket.usleep (100)
    end

    dispatch_message()

    self.logic:run(frame)
end

return RobotClient