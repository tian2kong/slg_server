local class = require "class"
local timext = require "timext"
local mailcommon = require "mailcommon"
local interaction = require "interaction"
local Database = require "database"
local common = require "common"
local tokencommon = require "tokencommon"
local PlayerMail = require "playermail"
local Mail = require "mail"
local PlayerMailId = require "playermailid"

local MailManager = class("MailManager")

--[[
    1、self.playermail[playerid] 来保存于玩家对应的邮件信息
    2、邮件物品，随邮件创建（thing,保存在 item 和 equip 表）
        是属于 playerid = 0 的记录
        ps. trade 交易系统使用 playerid = 1 作为记录
]]
function MailManager:ctor()
    self.db = nil
    self.maxthingid = 0
    self.playermail = {}    --玩家的邮件（上下线，读取/释放）
    self.player_mailid = {} --玩家邮件id管理
end

local function serialize_mailthing(things)
    local t = {}
    for _,v in pairs(things) do
        table.insert(t, v:getthingid())
    end
    return table.encode(t)
end

local function deserialize_mailthing(things, str)
    local t = table.decode(str)
    local ret = {}
    for _,v in pairs(t) do
        local id = tonumber(v)
        local thing = things[id]
        if not thing then
            LOG_ERROR("unkown mail thing[%d]", id)
        else
            table.insert(ret, thing)
        end
    end
    return ret
end

--获取玩家邮件管理
function MailManager:get_player(playerid)
    return self.playermail[playerid]
end
function MailManager:create_player(playerid)
    local mgr = self:get_player(playerid)
    if not mgr then
        mgr = PlayerMail.new(playerid, self)
        self.playermail[playerid] = mgr        

        local mails = {}
        local t_mail_record = self.db:select_db_record( Mail.s_Mail_table, string.format( Mail.s_Mail_table.select_where, playerid))
        if  t_mail_record then
            for _, record in pairs(t_mail_record) do
                local newmail = Mail.new(record)
                local params = table.decode( newmail:get_field("params"))
                do--邮件要加上语言
                    local k, v = table.first(params)
                    if type(v) ~= "table" then
                        params = { { language = "", content = params } }
                    end
                end
                newmail:set_params(params)
                newmail:set_tokens(table.decode( newmail:get_field("tokens")))
                newmail:set_things(table.decode( newmail:get_field("things")))
                table.insert(mails, newmail)
            end
        end
    end
    return mgr
end
function MailManager:delete_player(playerid)
    if  self.playermail[playerid] then        
        self.playermail[playerid] = nil
    end
end

function MailManager:get_db()
    return self.db
end

function MailManager:loaddb()

    --玩家邮件id使用管理
    local t_records = self.db:select_db_record(PlayerMailId.s_PlayerMailId_table)
    for _, record in pairs(t_records) do
        local player_mail_id = PlayerMailId.new(record)        
        self.player_mailid[(player_mail_id:getplayerid())] = player_mail_id
    end
end

function MailManager:init()
    self.db = Database.new("global")
    self:loaddb()
end

function MailManager:release()    
end

function MailManager:run()
    for k,v in pairs(self.playermail) do
        v:run()
    end
end

function MailManager:get_new_mailid(playerid)
    if  not self.player_mailid[playerid] then
        local record = self.db:create_db_record(PlayerMailId.s_PlayerMailId_table, playerid)
        local player_mail_id = PlayerMailId.new(record)
        self.player_mailid[playerid] = player_mail_id
    end
    return self.player_mailid[playerid]:get_new_id()
end

--发送邮件
-- 通过 mailinterface 的sendmail 接口，
-- 走到 mailserver的 send_mail 接口，最终走到这里 
function MailManager:raw_send_mail(playerid, mailid, params, tokens, thingdata)
    params = params or {}
    local things = {}
    do--邮件要加上语言
        local k, v = table.first(params)
        if type(v) ~= "table" then
            params = { { language = "", content = params } }
        end
    end
        
    local cfg = get_static_config().mail[mailid]
    if cfg then
        --获得玩家的一个新的邮件id
        local new_mail_id = self:get_new_mailid(playerid)

        -- 创建新的邮件对象
        local expire = 0
        if  cfg.Type == mailcommon.MailType.arena or cfg.Type == mailcommon.MailType.system then
            expire = timext.get_refresh_time(mailcommon.expire_time)
        end

        local new_record =  self.db:create_record(Mail.s_Mail_table.table_name, Mail.s_Mail_table.key_name, Mail.s_Mail_table.field_name,
                                {playerid, new_mail_id})
        local new_mail = Mail.new(new_record)
        new_mail:set_field("mailid",    mailid)
        new_mail:set_field("mailtype",  cfg.Type)
        new_mail:set_field("params",    table.encode(params))
        new_mail:set_field("tokens",    table.encode(tokens))
        new_mail:set_field("things",    table.encode(thingdata))
        new_mail:set_field("open",      0)
        new_mail:set_field("sendtime",  timext.current_time())
        new_mail:set_field("expire",    expire)

        new_mail:set_params(params)
        new_mail:set_tokens(tokens)
        new_mail:set_things(thingdata)
        new_mail:savedb()

        local mgr = self:get_player(playerid)
        if  mgr then
            mgr:add_mail(new_mail)
        end

        local address = interaction.call_agent_address(playerid)
        if address then
            interaction.send(address, "lua", "sync_mail", new_mail:get_mail_message())
        end
    else
        LOG_ERROR("unkown mail[%d]", mailid)
    end
end

-----------------------------------------------接口-----------------------------------------------------------------
function MailManager:request_mail(playerid)
    local playermgr = self:get_player(playerid)
    if  not playermgr then
        playermgr = self:create_player(playerid)
    end
    local ret = {}
    if playermgr then
        local mails = playermgr:get_all_mail()
        if mails then
            for _,mail in pairs(mails) do
                table.insert(ret, mail:get_mail_message())
            end
        end
    end
    
    return ret
end

function MailManager:extract_mail(playerid, id)
    local playermgr = self:get_player(playerid)
    if  not playermgr then
        playermgr = self:create_player(playerid)
    end
    local ret
    if playermgr then
        ret = playermgr:extract_mail(id)
    end
    return ret
end

function MailManager:send_mail(arrid, mailid, params, tokens, thingdata)
    if type(arrid) ~= "table" then
        arrid = { arrid }
    end
    tokens = tokens or {}
    for k,v in pairs(tokens) do
        if not tokencommon.check_field[k] then
            tokens[k] = nil
        end
    end
    for _,playerid in pairs(arrid) do
        self:raw_send_mail(playerid, mailid, params, tokens, thingdata)
    end
end

function MailManager:del_mail(playerid, arrid)
    local playermgr = self:get_player(playerid)
    if  not playermgr then
        playermgr = self:create_player(playerid)
    end
    if playermgr then
        playermgr:del_mail(arrid, true)
    end
end

function MailManager:open_mail(playerid, id)
    local playermgr = self:get_player(playerid)
    if  not playermgr then
        playermgr = self:create_player(playerid)
    end
    if playermgr then
        playermgr:open_mail(id)
    end
end

function MailManager:player_online(playerid)
    --玩家上线，加载玩家邮件到内存中
    self:create_player(playerid)    
end

function MailManager:player_offline(playerid)
    self:delete_player(playerid)
end

return MailManager