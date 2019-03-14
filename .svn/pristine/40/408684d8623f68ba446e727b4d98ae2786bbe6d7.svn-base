local mysql = require "mysql"

local dbtable = {}
dbtable.gamesql = require "gamesql"
dbtable.globalsql = require "globalsql"

local manager = {}

local version_sql = {
    select_version = "select version_number from `%s`",
    update_version = "update `%s` set version_number = %d",
    insert_version = "insert into `%s`(version_number) values(%d)",
}

--连接db
function manager.connectdb(database)
    local db = mysql.connect{
        host=database.host,
        port=database.port,
        user=database.user,
        password=database.password,
        max_packet_size = database.max_packet_size,
    }
      
    if not db then
        LOG_ERROR("failed to connect sql")
        return 
    end

    db:query(string.format("CREATE DATABASE IF NOT EXISTS %s default charset utf8 COLLATE utf8_unicode_ci; use %s;", database.dbname, database.dbname))

    db:query("set names utf8")
    return db
end
--导出数据结构
local function dump_sql_info(database, name)
    local tempname = "tempsql.wiki"
    os.execute(string.format("./depends/mysqldump -h%s -P%s -u%s -p%s -d %s>%s", 
        database.host,
        database.port,
        database.user,
        database.password,
        database.dbname,
        tempname))
    local tempfile = io.open(tempname)
    assert(tempfile, "mysqldump file not found")
    local filename = string.format("./server/sql/%s.wiki", name)
    local newfile = io.open(filename, "w")
    assert(newfile, "sql describe file not found")
    for line in tempfile:lines("L") do
        if not string.find(line, "/*") or not string.find(line, "*/") then
            newfile:write(line)
        end
    end
    tempfile:close()
    newfile:close()
end
--检测db版本
local check_db_info = {
    player = { name = "gamesql", field = "gameversion" },
    global = { name = "globalsql", field = "globalversion" },
}
function manager.check_db(db, cfgname, database)
    local info = check_db_info[cfgname]
    if info then
        local sql = dbtable[info.name]
        if manager.check_version(db, sql, info.field) then
            --[[不dump了
            local ok,err = xpcall(dump_sql_info, debug.traceback, database, info.name)
            if not ok then
                LOG_ERROR(err)
            end
            ]]
        end
    end
end

--检测数据库版本  刷到最新
function manager.check_version(db, serversql, tbname)
    local version
    local query_ret = db:query(string.format(version_sql.select_version, tbname))
    if query_ret then
        local ret = query_ret[1]
        if ret then
            version = ret["version_number"]
        end
    end
    local lastversion
    local j = version or 0
    for j=j+1,#serversql do
        local sql = serversql[j]
        if sql and string.match(sql, "%g") then
            local ret = db:query(sql)
            if ret["errno"] then
                LOG_ERROR("mysql check_version version[%d] query[%s] error[%s]", j, sql, ret["err"])
                break 
            end
            lastversion = j
        end
    end
    if lastversion then
        if version and version > 0 then
            db:query(string.format(version_sql.update_version, tbname, lastversion))
        else
            db:query(string.format(version_sql.insert_version, tbname, lastversion))
        end
        return true
    end
end

return manager