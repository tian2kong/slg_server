local class = require "class"
local interaction = require "interaction"
local mailcommon = require "mailcommon"
local timext = require "timext"
local thinginterface = require "thinginterface"
local msgqueue = require "skynet.queue"

local PlayerMail = class("PlayerMail")

--[[
    self.mails[id] 来保存确切的一份邮件
    邮件id 由 playermailid 中记录并分配
]]
function PlayerMail:ctor(playerid, manager)    
    self.mails = {}
    self.playerid = playerid
    self.manager = manager

    self.mailtypes = {}
    self.extractqueue = msgqueue()
end

function PlayerMail:run()
    local current = timext.current_time()
    local del = {}
    for k,v in pairs(self.mails) do
        if  v:get_field("expire") > 0 and current > v:get_field("expire") then
            table.insert(del, k)
        end
    end
    self:del_mail(del)
end

function PlayerMail:add_mail(mail)
    local mail_id = mail:get_key_value("id")
    self.mails[mail_id] = mail
    
    -- 判断取得同邮件类型，最早的邮件
    local type = mail:get_field("mailtype")
    self.mailtypes[type] = (self.mailtypes[type] or 0) + 1
    -- 超出同类型邮件保存上限，删除最早的邮件
    if self.mailtypes[type] > get_static_config().globals.maillimit[type] then--超出上限 删掉最早的
        local expireid = nil
        for k,v in pairs(self.mails) do            
            if v:get_field("mailtype") == mail:get_field("mailtype") then
                if not expireid or expireid > v:get_key_value("id") then                    
                    expireid = v:get_key_value("id")
                end
            end
        end
        self:del_mail({ expireid })
    end
end

function PlayerMail:get_mail(mailid)
    return self.mails[mailid]
end

function PlayerMail:get_all_mail()
    return self.mails
end

--打开邮件
function PlayerMail:open_mail(id)
    local mail = self:get_mail(id)
    if  mail then
        mail:open_mail()
    end
end

--提取邮件
function raw_extract_mail(self, id)
    local code = mailcommon.message_code.no_mail
    local mail = self:get_mail(id)
    if mail then
        code = mail:extract_mail()
    end
    return code
end
function PlayerMail:extract_mail(id)
    return self.extractqueue(raw_extract_mail, self, id)
end

--删除邮件
function PlayerMail:del_mail(arrid, check)
    if not table.empty(arrid) then
        for _,id in pairs(arrid) do
            local mail = self.mails[id]
            if mail and (not check or not mail:have_annex()) then
                mail:delete_mail()
                self.mails[id] = nil

                local type = mail:get_field("mailtype")
                self.mailtypes[type] = self.mailtypes[type] - 1
            end
        end
    end
end

return PlayerMail