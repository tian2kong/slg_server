local skynet = require "skynet"
local timext = require "timext"
local interaction = require "interaction"
local sqlmanager = require "sqlmanager"
local msgqueue = require "skynet.queue"

local CMD = {}

local s_db
local quitresp = nil
local heartimer = nil --心跳定时器
local connectinfo = { } --连接数据
local queryqueue, queryempty = msgqueue()
local max_connect_times = 3

local function query_empty()
    return skynet.mqlen() == 0 and queryempty()
end

local function connect_db(check)
    connectinfo.reconnect = true
    local cfg = connectinfo.cfg
    local dbname = connectinfo.dbname
    local db = sqlmanager.connectdb(cfg)
    s_db = db
    if check then
        sqlmanager.check_db(db, dbname, cfg)
    end
    connectinfo.reconnect = nil
end

local function query(sql)
    local db = s_db
    if not db then
        LOG_ERROR("mysql query[%s] not found db", sql)
        return nil
    end
    local times = 0
    local ok, ret = xpcall(db.query, debug.traceback, db, sql)
    local reconnect = nil
    if not ok or ret["errno"] == 1046 then
        reconnect = true
    end
    while reconnect do
        LOG_ERROR("mysql xpcall query[%s] error[%s]", sql, ret)
        if not connectinfo.close and times < max_connect_times then
            times = times + 1
            LOG_ERROR("connect mysql[%s] times[%d]", connectinfo.dbname, times)
            ok,ret = xpcall(connect_db, debug.traceback)
            if not ok then
                LOG_ERROR("mysql reconnect error %s", ret)
            end
            db = s_db
        else
            break
        end
        if db then
            reconnect = nil
            ok, ret = xpcall(db.query, debug.traceback, db, sql)
            if not ok or ret["errno"] == 1046 then
                reconnect = true
            end
        end
    end
    if not ok then
        LOG_ERROR("mysql xpcall query[%s] error[%s]", sql, ret)
        if not quitresp then
            interaction.close_server()
        end
        connectinfo.close = true
        return nil
    end
    if ret["errno"] then
        LOG_ERROR("mysql query[%s] error[%s] errno[%d]", sql, ret["err"], ret["errno"])
        return nil
    end
    return ret
end

function CMD.asyn_query(sql, dbname)
    --print("[asyn_query]", dbname, sql)
    local ret = queryqueue(query, sql)
end

function CMD.syn_query(sql, dbname)
    --print("[syn_query]", dbname, sql)
    local ret = queryqueue(query, sql)
    skynet.retpack(ret)
end

--心跳
local heart_time = 60 * 60
local function run(frame)
    if heartimer:expire() then
        heartimer:update(heart_time)
        if not connectinfo.reconnect then
            --保持与数据库建立连接 心跳
            local ret = s_db:query("select 1")
            if ret["errno"] then
                LOG_ERROR("mysql query[select 1] error[%s]", ret["err"])
            end
        end
    end
    if quitresp and query_empty() then
        timext.close_clock()
        quitresp(true, true)
        --skynet.exit()
    end
end
function CMD.open(cfg, dbname)
    connectinfo.cfg = cfg
    connectinfo.dbname = dbname
    connect_db(true)
    skynet.retpack(true)
end

function CMD.service_init()
    heartimer = timext.create_timer(heart_time)
    timext.open_clock(run)--开启时钟
end

function CMD.safe_quit()
    if query_empty() then
        skynet.retpack(true)
    else
        quitresp = skynet.response()
    end
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd])
		f(...)
	end)
end)