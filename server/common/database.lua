local skynet = require "skynet"
local snax = require "snax"
local Record = require "record"
local class = require "class"
local skynetext = require "skynetext"

local Database = class("Database")

local dbmanager
local function init_dbmgr()
    skynet.register_protocol {
        id = skynetext.db_protocol,
        name = skynetext.db_protocol_name,
        pack = skynet.pack,
        unpack = skynet.unpack,
    }
    dbmanager = skynet.queryservice("dbservice")
end

function Database.get_dbservice()
    return dbmanager
end

--db服务列表
local s_dbslave = {}
function Database:ctor(dbname, dbindex, queuekey)
    self._dbname = dbname or "global"
    self._dbindex = dbindex or 0
    self._db = nil
    if not dbmanager then
        init_dbmgr()
    end
    if not s_dbslave[self._dbname] then
        s_dbslave[self._dbname] = skynet.call(dbmanager, "lua", "connect_database", self._dbname)
    end
    self:init_dbslave(queuekey)
    assert(self._db, string.format("error database %s", dbname))
end

--
function Database:init_dbslave(queuekey)
    local server = s_dbslave[self._dbname]
    if server then
        local s = server
        if type(server) == "table" then
            local size = #server
            local index
            if self._queuekey then
                index = math.floor(self._queuekey / size) % size
            else
                index = skynet.call(dbmanager, "lua", "get_hash_slave_index", skynet.self(), self._dbname)
            end
            s = server[index]
        end
        self._db = s
    end
end

--创建一个唯一键的record
function Database:create_record(table_name, key_name, field_name, key_value)
    return Record.new(self, table_name, key_name, field_name, key_value)
end
function Database:create_db_record(db_table, key_value)
    assert(db_table.table_name and db_table.key_name and db_table.field_name, tostring(debug.traceback()))
    return self:create_record(db_table.table_name, db_table.key_name, db_table.field_name, key_value)
end

--查询复合主键的record 阻塞接口
function Database:select_db_record(db_table, sql_where)
    assert(db_table.table_name and db_table.key_name and db_table.field_name, tostring(debug.traceback()))
    return self:select_record(db_table.table_name, db_table.key_name, db_table.field_name, sql_where)
end
function Database:select_record(tb_name, key_name, field_name, sql_where)
    local sql = ""
    if type(key_name) ~= "table" then
        key_name = {key_name}
    end
    local colums = table.concat(key_name, ",")

    if field_name and not table.empty(field_name) then
        colums = colums .. "," .. table.concat(field_name, ",")
    end
    sql = "select " .. colums .. " from " .. tb_name .. " "
    if sql_where then
        sql = sql .. sql_where .. ";"
    end
    local query_obj = self:syn_query_sql(sql)
  
    local t_record = {}
    if query_obj then
        for _,query_table in pairs(query_obj) do
            local key_value = {}
            for _,v in pairs(key_name) do
                table.insert(key_value, query_table[v])
            end
            local newrecord = self:create_record(tb_name, key_name, field_name, key_value)            
            for k,v in pairs(field_name) do                
                newrecord._field[v] = query_table[v] or false
            end
            newrecord._insert = true
            table.insert(t_record, newrecord)
        end
    end
    return t_record
end

--异步执行sql语句
function Database:asyn_query_sql(fmt, ...)
	local sql
    if ... then 
		sql = string.format(fmt, ...)
	else
		sql = fmt
	end
    skynet.send(self._db, "lua", "asyn_query", sql, self._dbname, self._dbindex)
end

--同步执行sql语句 阻塞接口
function Database:syn_query_sql(fmt, ...)
	local sql
	if ... then 
		sql = string.format(fmt, ...)
	else
		sql = fmt
	end
    return skynet.call(self._db, "lua", "syn_query", sql, self._dbname, self._dbindex)
end

skynet.init(function()
    if not dbmanager then
        init_dbmgr()
    end
end)

return Database