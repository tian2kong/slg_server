--region *.lua
--Date 2016/9/8
--此文件由[BabeLua]插件自动生成

--  这是具体的邮件对象的类
--  邮件系统层级 mailmanager - 管理一个playermail list
--  玩家邮件 playermail 管理 一个 mail list
--  邮件 mail 就是一个单一邮件，与 数据库 mail 表对应
--endregion

local class = require "class"
local mailcommon = require "mailcommon"
local tokencommon = require "tokencommon"
local interaction = require "interaction"
local thinginterface = require "thinginterface"

local Mail = class("Mail")

Mail.s_Mail_table = {
    table_name = "mail",
    key_name = {"playerid","id"},    
    select_where = " where playerid=%d",
    field_name = {
        "mailid",
        "mailtype",
        "params",   -- string -> table
        "tokens",   -- string -> table 不同类型的货币
        "things",   -- string -> table cfgid -> num
        "open",     -- int -> boolean
        "sendtime",
        "expire",
    }
}

-- 构造函数
function Mail:ctor(record)
    self._record = record

    self.params = {}    
    self.tokens = {}
    self.things = {}    -- 该邮件对象发放的 thing 的对象
end

-- 打开邮件
function Mail:open_mail()
    self:set_field("open",1)
    self:savedb()
end

-- 提取邮件
function Mail:extract_mail()
    local code = mailcommon.message_code.success
    local reward = {}
    reward.token = self.tokens
    reward.thing = self.things
    if not table.empty(reward.token) or not table.empty(reward.thing) then
        local ret = interaction.call(self:get_key_value("playerid"), "lua", "extract_mail", reward, self:get_field("mailid"), self:get_key_value("id"), self:get_field("sendtime"))
        if ret then
            self:clear_annex()
            self:set_field("things", table.encode(self.things))
            self:set_field("tokens", table.encode(self.tokens))
            self:savedb()
        else
            code = mailcommon.message_code.bag_full
        end
    end
    return code
end

function Mail:clear_annex()
    self.things = {}
    self.tokens = {}
end

-- 删除邮件
function Mail:delete_mail()    
    self:clear_annex()

    -- 删除db记录
    self:deletedb()
end

-- 获取邮件描述信息（专成协议的信息）
function Mail:get_mail_message()
    return {
        id =        self:get_key_value("id"),
        mailid =    self:get_field("mailid"),
        param =     self:get_params(),
        token =     self.tokens,
        thing =     thinginterface.get_thing_messagedata(self.things),
        open =      self:get_field("open") == 1,
        sendtime =  self:get_field("sendtime"),
    }
end

--是否有附件
function Mail:have_annex()
    return not table.empty(self.tokens) or not table.empty(self.things)
end

-- 设置 params 数据
function Mail:set_params(params)
    self.params = params or {}
end
function Mail:get_params()
    return self.params
end

-- 设置 token 数据
function Mail:set_tokens(tokens)
    self.tokens = tokens  or {}
end
function Mail:get_tokens()
    return self.tokens
end

-- 设置解析出来的 things 数据
function Mail:set_things(things)
    self.things = things  or {} 
end
function Mail:get_things()
    return self.things
end

-- 获得key的数据
function Mail:get_key_value(k)
    return self._record:get_key_value(k)
end

-- 获得 _field 数据
function Mail:get_field(k)
    return self._record:get_field(k)
end

-- 设置 _field 数据
function Mail:set_field(k,v)
    self._record:set_field(k,v) 
end

-- 保存数据
function Mail:savedb()
    self._record:asyn_save()
end

-- 删除记录
function Mail:deletedb()
    self._record:asyn_delete()
end

return Mail