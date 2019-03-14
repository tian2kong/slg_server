local timext = require "timext"
local storagecommon = require "storagecommon"
local crypt = require "crypt"
local common = require "common"
local class = require "class"
local StorageMgr = class("StorageMgr")

local time_free = 60--N分钟检测
local time_over = 5 --超时时间(拼接的数据)
local time_default = 60 * 1 --默认时间
local overtime_coroutine = time_over * 2 --挂起的携程超时时间(要比time_over大)
local upper_size = 1024 * 256 --(N KB)

local data_type = {
	mem = 1, --内存
	db = 2,	 --DB
}

local data_status = {
	wait = 1,		--等待
	complete = 2,	--完成
	abandon = 3, 	--丢弃
}

local selkey_sql 	= "select id from file"
local sel_sql 		= "select * from file where id = %d"
local del_sql 		= "delete from file where id = %d"
local ins_sql 		= "insert into file(id, type, buffer) values(%d, %d, '%s')"

function StorageMgr:ctor(db)
	self._db = db
	self.products = {} --[id] -> {} --未拼装好的数据段 { [1], [2] ..  timer, status, dt_type, size, len}  timer:超时定时器
	self.memory = {} --保存在内存中的大数据 [id] -> { buffer = "" , freetime } 放置在内存中的都必须要有一个销毁时间
	self.maxid = 0

	self.keys = {} --[id] --dt_type

	--挂起的消息队列
	self.upload_response = {}

	self.free_timer = timext.create_timer(time_free)
end


function StorageMgr:init()
	local tab = self._db:syn_query_sql(selkey_sql)
	if tab then
		for _,data in pairs(tab) do
			local id = data.id
			self.keys[id] = data_type.db
			self.maxid = self.maxid < id and id or self.maxid
		end
    end 
end

function StorageMgr:run()

	do 	--上传文件超时检测
		local remove_t = {}
		for k,v in pairs(self.products) do
			if not v.timer or v.timer:expire() then
				v.status = data_status.abandon
				remove_t[k] = true
			end
		end
		for k,v in pairs(remove_t) do
			self:over(k)
		end
	end
	

	--定时清理过期内存语音, 挂起的协程超时检测
	local curtime = timext.current_time()
	if self.free_timer:expire() then
		self:clear_memory()

		for k,v in pairs(self.upload_response) do
			if not v.overtime or v.overtime <= curtime then
				LOG_ERROR("coroutine is overtime, key = [%d]", k)
				v.response(false)
				self:remove_upload_response(k) --移除
			end  			
		end
	end
end

--清理内存
function StorageMgr:clear_memory()
	local curtime = timext.current_time()
	for id,v in pairs(self.memory) do
		if not v.freetime or v.freetime <= curtime then
			self.memory[id] = nil
			self.keys[id] = nil
		end	
	end
end

--请求一个key值
function StorageMgr:apply_key(args)
	if not args then
		return nil
	end

	local bsave = args.bsave
	local type = args.type or storagecommon.type.other_unknow

	local id = self.maxid + 1

	local t = {}
	t.timer = timext.create_timer(time_over)	
	t.dt_type = bsave and data_type.db or data_type.mem
	t.status = data_status.wait
	t.type = type
	t.len = 0 --buffer的长度
	t.expired = args.expired --到期时间

	self.products[id] = t
	self.maxid = id
	return id
end

function StorageMgr:get_product(id)
	return self.products[id]
end

function StorageMgr:remove_product(id)
	self.products[id] = nil
end

function StorageMgr:recv(id, data)
    local code = storagecommon.code.success
	repeat
		local buff = data.buff
		local size = data.size
		local btail = data.btail --是否为尾节点
		if not id or not buff or not size then
			LOG_ERROR("StorageMgr:recv() param is error")
            code = storagecommon.code.param_error
			break
		end

		local pro = self:get_product(id)
		if not pro then
			print("no find product, key = [%d]", id)
            code = storagecommon.code.no_find
			break
		end

		if pro.status ~= data_status.wait then
			print("product status no wait , key = [%d], status = [%d]", id, pro.status)
            code = storagecommon.code.no_wait
			break
		end

		pro.len = pro.len + string.len(buff) --文件过大,干掉他.
		if pro.len >= upper_size then
			pro.status = data_status.abandon
			self:over(id)
			code = storagecommon.code.large_size
			break							
		end

        table.insert(pro, buff)
        pro.size = size
		if btail then
			--todox检测, 入库 
			pro.status = data_status.complete
			code = self:over(id)
		else
			--接着等待
            code = storagecommon.code.wait
		end

	until 0;

    return code
end

--结束接收
function StorageMgr:over(id)
    local code = storagecommon.code.upload_suc
	repeat 
		local pro = self:get_product(id)
		if not pro then
            code = storagecommon.code.no_find
			break
		end
	
		local status = pro.status

		if status == data_status.wait then
            code = storagecommon.code.status_error
			break
		end

		if status == data_status.abandon then
			self:remove_product(id)
			self:handle_upload_response(id, false)
            code = storagecommon.code.abandon_suc
			break
		end

		if status ~= data_status.complete then
			code = storagecommon.code.status_error
		end

		local buffer = table.concat(pro)--拼接字符流
		local type = pro.type
		local dt_type = pro.dt_type
        
		if pro.len ~= pro.size then--长度验证
			print("over ...  size is error  size = [%d], currentsize = [%d]",  pro.size, size)
			self:remove_product(id)
			self:handle_upload_response(id, false)
			code = storagecommon.code.size_error
			break
		end

		if dt_type == data_type.mem then
			local tmp = {}
			tmp.buffer = buffer
			tmp.freetime = timext.current_time() + ( pro.expired or time_default )
			self.memory[id] = tmp

		elseif dt_type == data_type.db then
			--todox 存库
            self:insert(id, type, buffer)
		else
			print("product no dt_type, key = [%d]", id)
            code = storagecommon.code.type_error
			break
		end

		self.keys[id] = dt_type
		self:remove_product(id)	
		self:handle_upload_response(id, true)
		code = storagecommon.code.upload_suc
		break
	until 0;
    return code
end

function StorageMgr:insert(id, type, buffer)
	local b64_buffer = crypt.base64encode(buffer)--转成可识别字符
	print("insert", string.len(b64_buffer))
	self._db:asyn_query_sql(string.format(ins_sql, id, type, common.mysqlEscapeString(b64_buffer)))
end

function StorageMgr:select(id)
	local dbtable = self._db:syn_query_sql(string.format(sel_sql, id))
	if dbtable and dbtable[1] then
		print(string.len(dbtable[1].buffer)) 
    	return crypt.base64decode(dbtable[1].buffer)--转成可识别字符
	end
	return nil
end

function StorageMgr:remove_buffer(id)
    local type = self.keys[id]
    self.keys[id] = nil
	if type == data_type.mem then
        self.memory[id] = nil
    elseif type == data_type.db then
	    self._db:asyn_query_sql(string.format(del_sql, id))
    end
end

function StorageMgr:get_buffer_info(id)
    local type = self.keys[id]
	if type == data_type.mem then
        return self.memory[id] and self.memory[id].buffer or nil
    elseif type == data_type.db then
        return self:select(id)
    end

    return nil
end

--检测上传结果
function StorageMgr:check_uploadresult(key)
	local code = storagecommon.code.unknow
	local pro = self:get_product(key)
	if self.keys[key] then --上传完毕
		code = storagecommon.code.upload_suc
	elseif pro then --等待队列
		code = storagecommon.code.wait
	elseif not pro then
		code = storagecommon.code.no_find
	end
	return code
end

function StorageMgr:get_upload_response(key)
	return self.upload_response[key]
end

function StorageMgr:add_upload_response(key, response)
	self.upload_response[key] = {
		response = response,
		overtime = timext.current_time() + overtime_coroutine,
	}
end

function StorageMgr:remove_upload_response(key)
	self.upload_response[key] = nil
end

function StorageMgr:handle_upload_response(key, bsuc)
	local tmp = self.upload_response[key]
	if tmp and tmp.response then
		self:remove_upload_response(key) --移除

		print("handle_upload_response ... ")

		local args = {
			bsuc = bsuc,
		}
        tmp.response(true, args)
	end
end

return StorageMgr