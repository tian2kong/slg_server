local class = require "class"
local timext = require "timext"
local Database = require "database"
local gamelogsql = require "sql.gamelogsql"

local GameLogMgr = class("GameLogMgr")

function GameLogMgr:ctor()
    self._db = nil
    self.db_table = {}
end

function GameLogMgr:init()
    self._db = Database.new("gamelog")
    --取出所有表名
    local query_obj = self._db:syn_query_sql("select distinct(table_name) from information_schema.columns where table_schema in (select database());")
    for _, v in pairs(query_obj) do
        self.db_table[v["table_name"]] = true
    end
    self:update_date()

    local function zero_event_func()
        self:update_date()
    end
    timext.reg_time_event(zero_event_func)--注册0点事件
end

function GameLogMgr:create_db_table(key, name)
    local create_sql = gamelogsql[key]
    if not create_sql then
        LOG_ERROR("not found create gamelog table: ", key)
        return 
    end
    create_sql = string.format(create_sql, name)
    self._db:syn_query_sql(create_sql)

    self.db_table[name] = true
    return true
end

function GameLogMgr:get_table_name(key)
    local name = today .. "-" .. key
    if not self.db_table[name] then
        LOG_ERROR("not gamelog table: ", name)
        return nil
    end
    return name
end

function GameLogMgr:check_date_table(day)
    local t = {"object", "event"}
    for _,key in pairs(t) do
        local name = day .. "-" .. key
        if not self.db_table[name] then
            if not self:create_db_table(key, name) then
                return 
            end
        end
    end
end

function GameLogMgr:update_date()
    local tt = timext.current_time()
    today = os.date("!%Y-%m-%d", tt)
    self:check_date_table(today)

    --预创建第二天的日志表，防止0点的时候表没创建，日志丢失
    tt = tt + 24 * 60 * 60
    local tomorrow = os.date("!%Y-%m-%d", tt)
    self:check_date_table(tomorrow)
end

function GameLogMgr:Log(key, sql)
    local table_name = self:get_table_name(key)
    if not table_name then
        return 
    end
    sql = string.gsub(sql, "#name", table_name, 1)

    self._db:asyn_query_sql(sql)
end

return GameLogMgr