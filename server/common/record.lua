local class = require "class"
local common = require "common"

local Record = class("Record")

local function quoteStrVal(val)
    if type(val) == "string" then
        return '"' .. common.mysqlEscapeString(val) .. '"'
    else
        return val
    end
end

function Record:ctor(database, tb_name, key_name, field_name, key_value)
    self._dirty_flag = {}
    self._database = database
    self._tb_name = tb_name
    self._field = {}
    for _,v in pairs(field_name) do
        self._field[v] = false
    end

    self:reset_key(key_name, key_value)
end

-- 重置 database
function Record:reset_database(database)
    self._database = database
end

--重置key
function Record:reset_key(key_name, key_value)
    self._key = {}
    self._key_str = ""
    if not key_name or not key_value then
        return 
    end
    if type(key_value) ~= "table" then
        key_value = { key_value }
    end
    if type(key_name) ~= "table" then
        key_name = { key_name }
    end
    if #key_name ~= #key_value then
        LOG_ERROR("sql table[%s] key error", self._tb_name)
    else
        local str = " "
        for i=1,#key_name do
            self._key[key_name[i]] = key_value[i]
            if i ~= 1 then
                str = str .. " and "
            end
            str = str .. key_name[i] .. " = " .. quoteStrVal(key_value[i])
        end
        self._key_str = str
    end
end

--保存数据
function Record:asyn_save()
    if self._insert then
        self:asyn_update()
    else
        self:asyn_insert()
        self._insert = true
    end
end

--同步保存数据
function Record:syn_save()
    if self._insert then
        self:syn_update()
    else
        self:syn_insert()
        self._insert = true
    end
end

--获取是否已插入标记
function Record:insert_flag()
    return self._insert
end

--查询数据
function Record:syn_select()
    local sql = ""
  
    local temp = {}
    for k,_ in pairs(self._field) do
        table.insert(temp, k)
    end
    sql = table.concat(temp, ",")
  
    sql = "select ".. sql .. " from " .. self._tb_name .. " where " .. self._key_str
    local query_obj = self._database:syn_query_sql(sql)
    local query_table = query_obj[1]
    if(query_table) then
        for k, v in pairs(query_table) do
            self._field[k] = v
            self._insert = true
        end
    end
  
end

--组装update语句
local function update(self)
    if table.empty(self._dirty_flag) then
        return
    end

    local sql = ""
    
    for k,_ in pairs(self._dirty_flag) do
        if string.len(sql) > 0 then
            sql = sql .. ", "
        end
		assert(self._field[k], "record update not have field" .. k)
        sql = sql .. k .. "=" .. quoteStrVal(self._field[k])
    end
    if sql == "" then
        return
    end
  
    sql = "update " .. self._tb_name .. " set " .. sql .. " where " .. self._key_str
    return sql
end

--更新数据
function Record:asyn_update()
    local sql = update(self)
    if not sql then
        return
    end
    self:clear_dirty_flag()
    self._database:asyn_query_sql(sql)
end

function Record:syn_update()
    local sql = update(self)
    if not sql then
        return
    end
    self:clear_dirty_flag()
    self._database:syn_query_sql(sql)
end

--删除数据
function Record:asyn_delete()
    if self:insert_flag() then
        local sql = "delete from "..self._tb_name.." where ".. self._key_str
        self._database:asyn_query_sql(sql)
    end
end

--组装insert sql语句
local function insert(self)
    if table.empty(self._dirty_flag) then
        LOG_ERROR("%s insert db no dirty flag", self._tb_name)
        return
    end
    local temp_key_names = {}
    local temp_key_values = {}
    for _key, _value in pairs(self._key) do
        table.insert(temp_key_names, _key)
        table.insert(temp_key_values, _value)
    end

    for _key, _ in pairs(self._dirty_flag) do
        assert(self._field[_key] ~= nil, "record not found field " .. _key)
        table.insert(temp_key_names, _key)
        table.insert(temp_key_values, quoteStrVal(self._field[_key]))
    end

    local sql = " (" .. table.concat(temp_key_names, ",") .. ") values (" .. table.concat(temp_key_values, ",") .. ")"
  
    sql = "insert into ".. self._tb_name .. sql

    return sql
end

--插入数据
function Record:asyn_insert()
    local sql = insert(self)
    if not sql then
        return
    end

    self:clear_dirty_flag()
    self._database:asyn_query_sql(sql)
end 

--插入数据(同步)
function Record:syn_insert()
    local sql = insert(self)
    if not sql then
        return
    end

    self:clear_dirty_flag()
    self._database:syn_query_sql(sql)
end 

--获取字段数据
function Record:get_field(k)
    return self._field[k] or nil
end
function Record:get_all_field()
    return self._field
end

--修改字段数据
function Record:set_field(k, data)
    assert(self._field[k] ~= nil)
    assert(data ~= nil,k)
    self._field[k] = data
    self._dirty_flag[k] = true
end

--修改字段数据
function Record:set_plural_field(data)
    for k,v in pairs(data) do
        assert(self._field[k] ~= nil)
        self._field[k] = v
        self._dirty_flag[k] = true
    end
end

--清楚脏标记
function Record:clear_dirty_flag()
    self._dirty_flag = {}
end

--获取键值
function Record:get_key_value(k)
    return self._key[k]
end

--获取表名
function Record:get_table_name()
	return self._tb_name
end

--获取数据库
function Record:get_db()
	return self._database
end

--获取key值
function Record:get_key_str()
	return self._key_str
end

--是否为脏数据
function Record:is_dirty()
    return not table.empty(self._dirty_flag)  
end

return Record