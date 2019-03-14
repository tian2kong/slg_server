local class = require "class"
local timext = require "timext"
local chatcommon = require "chatcommon"
local common = require "common"
local clusterext = require "clusterext"

local VoiceMgr = class("VoiceMgr")

--[[
统一管理语音:

频道语语音在内存中管理,上限chatcommon.chnl_voice_count条数,
每隔chatcommon.chnl_voice_refresh_time会清理过期数据,
chnl_voicelist：保存频道语音数据,索引为ID
chnl_sort_list:同上,索引为按照时间顺序排序的正序列,时间越晚,越靠前,
此table为了方便按顺序遍历,也更方便控制上限,避免每次增加都要遍历
remove_voice();不负责删除频道语音,因为每次删除都要遍历self.chnl_sort_list,造成开销
]]

local voice_sql = {
    ins_sql     = "insert into voice(id,type,posttime,lasttime) values (%d,%d,%d,%d)" ,
    del_sql     = "delete from voice where id = %d" ,
    maxid_sql   = "select max(id) from voice" ,
    load_sql   = "select id,posttime,type from voice" , --select出局部字段保存在内存中,建立索引,
    sel_sql   = "select lasttime,posttime from voice where id = %d" , --select出局部字段保存在内存中,建立索引,
}

local clear_chnl_timer
function VoiceMgr:ctor(db)
    self._db = db
    self.chnl_voicelist = {}    --频道语音数据        [id]-->id,voice,lasttime,posttime
    self.voice_list = {}        --所有语音数据索引    [id]-->id,posttime,type,lasttime
    self.private_list = {}      --私聊语音索引`       [id]-->id,posttime,type方便遍历

    --已按照时间顺序排序
    self.chnl_sort_list = {} --频道语音数据   [1]-->id,voice,lasttime,posttime
    self.event = {} --事件处理
end

function VoiceMgr:init()
    clear_chnl_timer = timext.create_timer(chatcommon.chnl_voice_refresh_time)
end

function VoiceMgr:loaddb()
    local query_obj = self._db:syn_query_sql(voice_sql.load_sql)   
    if query_obj then
        for _,data in pairs(query_obj) do 
            local tmp = {}
            tmp.id = data.id
            tmp.posttime = data.posttime
            tmp.type = data.type
            if data.id then
                self.voice_list[data.id] = tmp
                if data.type == chatcommon.voice_type.voic_private then--方便遍历
                    self.private_list[data.id] = tmp
                end 
            end          
        end
    end 
end

function VoiceMgr:run()
    if clear_chnl_timer and clear_chnl_timer:expire() then
        local fresh_time = timext.current_time() - chatcommon.chnl_voice_refresh_time
        for k,v in ipairs(self.chnl_sort_list) do--已排序,可以省去很多不必要的比较
            if not v.posttime or fresh_time > v.posttime then
                local id = v.id
                self.voice_list[id] = nil
                self.chnl_sort_list[k] = nil
                self.chnl_voicelist[id] = nil
            end
        end
        clear_chnl_timer:update(chatcommon.chnl_voice_refresh_time)
    end
end

function VoiceMgr:dayrefresh()
    local refreshtime = timext.current_time() - chatcommon.private_voice_refresh_time
    for k,v in pairs(self.private_list) do
        if not v.posttime or refreshtime >= v.posttime then
            self:remove_voice(v.id)
        end
    end
end

function VoiceMgr:insert_voice(id, lasttime, type)
    if not id or not lasttime or not type or self.voice_list[id] then
        return false
    end
    
    local data = {}
    local posttime = timext.current_time()
    data.posttime = posttime
    data.type = type
    self.voice_list[id] = data
    if type == chatcommon.voice_type.voic_space or type == chatcommon.voice_type.voic_private 
        --[[or type == chatcommon.voice_type.voic_channel]] then
        print("voice type = ", type)
        --空间,私聊等入库
        local sql = string.format(voice_sql.ins_sql, id, type, posttime, lasttime)
        --print(sql)
        self._db:asyn_query_sql(sql)   
    end

    if type == chatcommon.voice_type.voic_private then--私聊语音做个独立的索引,方便定时清理
        self.private_list[id] = data
    elseif type == chatcommon.voice_type.voic_channel then--频道聊天
        local tmp = {}
        tmp.id = id
        tmp.posttime = posttime
        tmp.type = type
        tmp.lasttime = lasttime
        table.insert(self.chnl_sort_list, 1, tmp)--头插
        self.chnl_voicelist[id] = tmp
        self:del_chnlvoice_tail()--去尾
    end
    return true
end

--该接口不负责删除频道语音
function VoiceMgr:remove_voice(id)
     if self.voice_list[id] then
        local type = self.voice_list[id].type
        if type == chatcommon.voice_type.voic_private then --清理内存
           self.voice_list[id] = nil
           self.private_list[id] = nil
        end

        if type == chatcommon.voice_type.voic_private or --清理库
           type == chatcommon.voice_type.voic_space then
            local sql = string.format(voice_sql.del_sql, id)
            print(sql)
            self._db:asyn_query_sql(sql) 
       end
       clusterext.send(get_cluster_service().imageserver, "lua", "remove_buffer", id)
    end
end

function VoiceMgr:get_voice(id)
    local data = {}
    if self.voice_list[id] then
        local type = self.voice_list[id].type
        if type == chatcommon.voice_type.voic_channel then --频道聊天,直接取内存数据
            data.index = self.chnl_voicelist[id].id
        else
            local sql = string.format(voice_sql.sel_sql, id)
            print(sql)
            local query_obj =  self._db:syn_query_sql(sql)
            if query_obj then
                data.index = id
            end
        end
    end
    return data
end

--删除频道语音超额部分
function VoiceMgr:del_chnlvoice_tail()
    local dt = self.chnl_sort_list[chatcommon.chnl_voice_count]
    if dt then
        local id = dt.id
        self.voice_list[id] = nil
        self.chnl_voicelist[id] = nil
        self.chnl_sort_list[chatcommon.chnl_voice_count] = nil
        clusterext.send(get_cluster_service().imageserver, "lua", "remove_buffer", id) --通知过去
    end
end

return VoiceMgr