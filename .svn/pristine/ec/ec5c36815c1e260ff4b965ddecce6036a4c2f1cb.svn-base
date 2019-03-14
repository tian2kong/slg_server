local skynet = require "skynet"
local skynetext = require "skynetext"
local config = require "config"

local s_slave = {}
local s_instance = 8
local s_sourcekey = {}
local s_blance = 0

local CMD = {}
local quitflag = nil

function CMD.get_hash_slave_index(source, dbname)
    local server = s_slave[dbname]
    local index
    if server then
        local s = server
        if type(server) == "table" then
            index = s_sourcekey[source]
            if not index then
                index = s_blance
                s_sourcekey[source] = index
                s_blance = s_blance + 1
                if s_blance >= s_instance then
                    s_blance = 1
                end
            end
        end
    end
    skynet.retpack(index)
end

function CMD.connect_database(dbname)
    if not s_slave[dbname] then
        local dbconfig = config.get_db_config()
        local cfg = dbconfig[dbname]
        if #cfg > 0 then
            s_slave[dbname] = {}
            for i=0,(s_instance-1) do
                local s = skynet.newservice("dbslave", dbname)
                skynet.call(s, "lua", "open", cfg, dbname)
                s_slave[dbname][i] = s
            end
        else
            local s = skynet.newservice("dbslave", dbname)
            skynet.call(s, "lua", "open", cfg, dbname)
            s_slave[dbname] = s
        end
    end
    skynet.retpack(s_slave[dbname])
end

function CMD.safe_quit()
    if not quitflag then
        quitflag = true
        for k,v in pairs(s_slave) do
            if type(v) == "table" then
                local s = table.remove(v)
                while s do
                    skynet.call(s, "lua", "safe_quit")
                    s = table.remove(v)
                end
            else
                skynet.call(v, "lua", "safe_quit")
            end
            s_slave[k] = nil
        end
    end
    skynet.retpack(true)
end

function CMD.service_init()
    for k,v in pairs(s_slave) do
        if type(v) == "table" then
            for _,s in pairs(v) do
                skynet.send(s, "lua", "service_init")
            end
        else
            skynet.send(v, "lua", "service_init")
        end
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = assert(CMD[cmd])
        f(...)
    end)
end)