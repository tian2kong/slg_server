local class = require "class"
local common = require "common"
local crypt = require "crypt"
local ImageDBMgr = class("ImageDBMgr")


local image_sql = {
    ins_sql     = "insert into image(imageid,image) values (%d,'%s')" ,
    sel_sql     = "select * from image where imageid = %d" ,
    del_sql     = "delete from image where imageid = %d" ,
    updt_sql    = "update image set image = '%s' where imageid = %d" ,
    maxid_sql   = "select max(imageid) from image" ,
}

function ImageDBMgr:ctor(db)
    self._db = db
    self.maxid = 0
end

function ImageDBMgr:init()
    --获取最大key
    local tabmaxindex = self._db:syn_query_sql(image_sql.maxid_sql)   
    if tabmaxindex and tabmaxindex[1] then
        self.maxid = tabmaxindex[1]["max(imageid)"] or 0
    end 
end

--获取新的id
local function get_newkey(self) 
    self.maxid = self.maxid + 1
    return self.maxid 
end

--添加图片
function ImageDBMgr:add(image)
    if not image then
        return 0
    end    
    local id = get_newkey(self)

    local code = crypt.base64encode(image)--转成可识别字符
    local sql = string.format(image_sql.ins_sql, id, common.mysqlEscapeString(code))
    self._db:asyn_query_sql(sql)
    return self.maxid
end

--删除图片
function ImageDBMgr:del(id)
    local sql = string.format(image_sql.del_sql, id)
    self._db:asyn_query_sql(sql)
end

--获取图片
function ImageDBMgr:get(id)
    local image = nil
    local sql = string.format(image_sql.sel_sql, id)
    local query_obj = self._db:syn_query_sql(sql)
    if query_obj then
        query_obj = query_obj[1]
        if query_obj and query_obj["image"] then
            image = query_obj["image"]
        end
    end
    if image then
        image = crypt.base64decode(image)
    end
    return image
end

--更新图片
function ImageDBMgr:update(id, image)
    if not id or not image then
        return 
    end    
    local sql = string.format(image_sql.updt_sql, common.mysqlEscapeString(image), id)
    self._db:asyn_query_sql(sql)
end

return ImageDBMgr
