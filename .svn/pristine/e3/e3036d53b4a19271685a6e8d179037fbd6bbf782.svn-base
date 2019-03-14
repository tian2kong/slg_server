local class = require "class"
local sqlmanager = require "sqlmanager"
local skynet = require "skynet"
local msgqueue = require "skynet.queue"
local config = require "config"
local interaction = require "interaction"
local timext = require "timext"
local DBMgr = class("DBMgr")

local mydb_set = {}
local heartimer = nil --心跳定时器
local connectinfo = { } --连接数据
local queryqueue, queryempty = msgqueue()
local max_connect_times = 3
local quit_co = nil

function DBMgr:ctor()
end

local function connect_db(dbname, check)
    local connect = assert(connectinfo[dbname])
    connect.reconnect = true
    local cfg = connect.cfg
    mydb_set[dbname] = {}
    if #cfg > 0 then
        local i = 0
        for _,database in pairs(cfg) do
            local db = sqlmanager.connectdb(database)
            mydb_set[dbname][i] = db
            if check then
                sqlmanager.check_db(db, dbname, database)
            end
            i = i + 1
        end
    else
        local db = sqlmanager.connectdb(cfg)
        mydb_set[dbname][0] = db
        if check then
            sqlmanager.check_db(db, dbname, cfg)
        end
    end
    connect.reconnect = nil
end

function DBMgr:connect_database(dbname, check)
	local dbname = dbname
    local dbconfig = config.get_db_config()
    local cfg = assert(dbconfig[dbname])
    local connect = {
    	cfg = cfg,
    	dbname = dbname,
	}
	connectinfo[dbname] = connect
	connect_db(dbname, check)
end

local function query(dbname, dbindex, sql)
	local connect = assert(connectinfo[dbname])
	local db = assert(mydb_set[dbname])
    db = db[dbindex]
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
        if not connect.close and times < max_connect_times then
            times = times + 1
            LOG_ERROR("connect mysql[%s] times[%d]", connect.dbname, times)
            ok,ret = xpcall(connect_db, debug.traceback)
            if not ok then
                LOG_ERROR("mysql reconnect error %s", ret)
            end
            db = mydb_set[dbname][dbindex]
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
        if not quit_co then
            interaction.close_server()
        end
        connect.close = true
        return nil
    end
    if ret["errno"] then
        LOG_ERROR("mysql query[%s] error[%s] errno[%d]", sql, ret["err"], ret["errno"])
        return nil
    end
    return ret
end

--心跳
local heart_time = 60 * 60
local function run(frame)
    if heartimer:expire() then
        heartimer:update(heart_time)
        for dbname, connect in pairs(connectinfo) do
        	if not connect.reconnect then
	            --保持与数据库建立连接 心跳
	            for dbname,mydb in pairs(mydb_set) do
	            	for _,db in pairs(mydb) do
	            		local ret = db:query("select 1")
		                if ret["errno"] then
		                    LOG_ERROR("mysql query[select 1] error[%s]", ret["err"])
		                end
	            	end
	            end
	        end
        end
    end
    if quit_co and queryempty() then
        timext.close_clock()
        skynet.wakeup(quit_co)
        --skynet.exit()
    end
end

function DBMgr:asyn_query(sql, dbname, dbindex)
	--fork协程, 执行阻塞query
	skynet.fork(function()
		queryqueue(query, dbname, dbindex, sql)
	end)
end

function DBMgr:syn_query(sql, dbname, dbindex)
    return queryqueue(query, dbname, dbindex, sql)
end

function DBMgr:safe_quit()
	assert(not quit_co)
   	quit_co = coroutine.running()
	skynet.wait(quit_co)
end

skynet.init(function()
	heartimer = timext.create_timer(heart_time)
    timext.open_clock(run)--开启时钟
end)

return DBMgr