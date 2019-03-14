local IPlayerModule = require "iplayermodule"
local class = require "class"
require "static_config"
local titlecommon = require "titlecommon"
local timext = require "timext"
local mailinterface = require "mailinterface"
local Title = require "title"

local decode = table.decode
local encode = table.encode

local PlayerTitleModule = class("PlayerTitleModule", IPlayerModule)

local title_tab = {
	table_name = "player_title",
    key_name = {"playerid"},
    field_name = {
       "curtitleid",		--当前称号id
	   "prevtitle",			--上一个称号  
       "activetitle",       --激活称号
    },
}

function PlayerTitleModule:ctor(player)
	self._player = player
	self.alltitle = {}
    self.curtitle = {} --当前称号
    self.pretitle = {} --上一个称号
    self.acttitle = {} --激活的称号
end

function PlayerTitleModule:loaddb()
	self._record = self._player:getplayerdb():create_db_record(title_tab, self._player:getplayerid())
    self._record:syn_select()
    if self._record:insert_flag() then
        local str = self._record:get_field("curtitleid")
        if str then
            self.curtitle = table.decode(str)
        end
        str = self._record:get_field("prevtitle")
        if str then
            self.pretitle = table.decode(str)
        end
        str = self._record:get_field("activetitle")
        if str then
            self.acttitle = table.decode(str)
        end
    end

    --读取自己的称号
    local t_records = self._player:getplayerdb():select_db_record(Title.s_title_table, string.format( Title.s_title_table.select_where, self._player:getplayerid()))
    for _, record in pairs(t_records) do
        local title = Title.new(record) 
        self.alltitle[title:get_title_id()] = title        
    end    
end

function PlayerTitleModule:online()    
end

function PlayerTitleModule:offline()
end

function PlayerTitleModule:run()
	local cur_time = timext.current_time()
    local del_title = {}

	for _,v in pairs(self.alltitle) do  
        local time = v:get_field("time")
		if time and time ~=0 and time < cur_time then             		
            table.insert(del_title, v:get_title_id())
		end
	end
    for _, id in pairs(del_title) do
        self:delete_title(id)
    end
end

--增加普通称号
function PlayerTitleModule:add_title(id, param, issave, addtime)
    local cfg = get_static_config().title_dat[id] 
    if not cfg then 
        return  
    end

    local time = cfg.time
    if time and time[2] then
        if timext.current_time() > timext.tosectime(time[2][1]) then 
            return  --限时称号，没到时间 不能加
        end
    end

    if self.alltitle[id] then
        return  --不要重复加同一个称号
    end
    local record = self._player:getplayerdb():create_db_record(Title.s_title_table, {self._player:getplayerid(), id})
    local title = Title.new(record)
    title:set_field("time", self:cal_title_time(cfg, addtime))
    title:set_field("param", param or "")
	if  not title then 
		return 
    end
    
    local update = nil
    if cfg.DelTitleIds then    --需要删除不兼容的称号
        for _, id in pairs(cfg.DelTitleIds) do
            if  self.alltitle[id] then
                local curtitle = self:GetCurTitle(cfg.Type)
                if curtitle == id then
                    self:SetPrevTitle(cfg.Type, curtitle)
                    self:SetCurTitle(cfg.Type, title:get_title_id())
                    update = true
                end
                local actid = self:GetActiveTitle(cfg.Type)
                if actid == id then
                    self:SetActiveTitle(cfg.Type, title:get_title_id())
                    self._player:playerbasemodule():change_attribute()
                    update = true
                end
                self._player:send_request("sysdeltitle", { id = id })
                self.alltitle[id]:delete()
                self.alltitle[id] = nil
            end
        end 
    end

    local curtitle = self:GetCurTitle(cfg.Type)
    if cfg.Force and curtitle ~= title:get_title_id() then
        self:SetPrevTitle(cfg.Type, curtitle)
        self:SetCurTitle(cfg.Type, title:get_title_id())
        update = true
    end
    self.alltitle[title:get_title_id()] = title
    if update then
        self:save()
        self:sync_current_titile()
    end

    self._player:send_request("sysnewtitle", {info = title:pack_msg()})
    if issave then
        title:savedb()
    end
end

--删除一个称号
--@force    称号是主动删除(不触发称号时效到期的 邮件事件)
function PlayerTitleModule:delete_title(id)
	local v = self.alltitle[id] 
	if not v then 
		return 
	end

    --需要先删除监听，防止新的称号直接加监听
    self.alltitle[id]:delete()
	self.alltitle[id] = nil	

    --要删除称号了，触发的发邮件、后续称号的处理
    local title_cfg = get_static_config().title_dat[id]
    if title_cfg and title_cfg.MailId then        
        mailinterface.send_mail(self._player:getplayerid(), title_cfg.MailId)
    end
    if title_cfg and title_cfg.NextId then
        self:add_title(title_cfg.NextId, v:get_field("param"), true)
    end

    local update = nil
	if self:GetCurTitle(title_cfg.Type) == id then
        local preid = self:GetPrevTitle(title_cfg.Type)
		if preid then 
			local prev = self:get_title_by_id(preid)
			if not prev then 
				self:SetPrevTitle(title_cfg.Type, nil)
                self:SetCurTitle(title_cfg.Type, nil)
			else
				self:SetCurTitle(title_cfg.Type, prev:get_title_id())
			end
		else
			self:SetCurTitle(title_cfg.Type, nil)
		end
        update = true 
	end
    if self:GetActiveTitle(title_cfg.Type) == id then
        self:SetActiveTitle(title_cfg.Type, nil)
        self._player:playerbasemodule():change_attribute()
        update = true
    end
    if update then
        self:sync_current_titile()
        self:save()
    end
    	
	self._player:send_request("sysdeltitle", { id = id })
end

--获取所有称号信息
function PlayerTitleModule:get_title_message()
	local t = {}
	for k, v in pairs(self.alltitle) do 
		table.insert(t,v:pack_msg())
	end
	return {info = t}
end

--激活或者取消称号
function PlayerTitleModule:active_title(msg)
    local cfg = get_static_config().title_dat[msg.id]
    if not cfg or not cfg.AttrBonus then 
        return titlecommon.ret.UNKNOWN_ERROR
    end
    local title = self:get_title_by_id(msg.id) 
    if not title then 
        return titlecommon.ret.NO_TITLE
    end

    if msg.op then 
        local time = title:get_field("time")
        if  time and time ~= 0 and time < timext.current_time() then 
            return titlecommon.ret.LOSE_EFFICACY
        end
    
        local curtitle = self:GetActiveTitle(cfg.Type)
        if curtitle == msg.id then 
            return titlecommon.ret.DOUBLE_SET 
        end
        self:SetActiveTitle(cfg.Type, title:get_title_id())
    else    --取消称号--    
        if self:GetActiveTitle(cfg.Type) ~= msg.id then 
            return titlecommon.ret.ERROR_TITLE
        end
        
        self:SetActiveTitle(cfg.Type, nil)
    end
    self:sync_current_titile()
    self._player:playerbasemodule():change_attribute()
    self:save()
    return titlecommon.ret.SUCCESS
end

--设置或者取消称号
function PlayerTitleModule:reset_title(msg)
	local cfg = get_static_config().title_dat[msg.id]
	if not cfg then 
		return titlecommon.ret.UNKNOWN_ERROR
	end
	
    if self._player:activitymodule():get_guild_war():is_in_guildwar_scene() then
        return titlecommon.ret.IN_GUILDWAR
    end

	if msg.op then 
		local title = self:get_title_by_id(msg.id) 
		if not title then 
			return titlecommon.ret.NO_TITLE
		end
		
        local time = title:get_field("time")
		if time and time ~= 0 and time < timext.current_time() then 
			return titlecommon.ret.LOSE_EFFICACY
		end
	
        local curtitle = self:GetCurTitle(cfg.Type)
		if curtitle == msg.id then 
			return titlecommon.ret.DOUBLE_SET 
		end
        self:SetPrevTitle(cfg.Type, curtitle)
		self:SetCurTitle(cfg.Type, title:get_title_id())
	else    --取消称号--	
        if self:GetCurTitle(cfg.Type) ~= msg.id then 
			return  titlecommon.ret.ERROR_TITLE
		end
		
		if cfg.force then 
			return titlecommon.ret.NOT_OP
		end
		
		self:SetCurTitle(cfg.Type, nil)
	end
    self:save()
    self:sync_current_titile()
    return titlecommon.ret.SUCCESS
end

function PlayerTitleModule:sync_current_titile()
    self._player:send_request("syscurtitle", {
        info = self:get_current_title(),
        active = table.values(self.acttitle),
    })   
end
function PlayerTitleModule:get_current_title()
    local ret = {}
    for _,titleid in pairs(self.curtitle) do
        local title = self:get_title_by_id(titleid)
        if title then
            table.insert(ret, title:pack_msg())
        end
    end
    return ret
end

--计算称号时间
function PlayerTitleModule:cal_title_time(temp, addtime)        
	local time = temp.Time 
	if time then
    	if time[1] then
    		return timext.current_time() + time[1]        
    	end
    	if time[2] then 
    		return timext.tosectime(time[2][2])
    	end
        if time[3] then
            return (addtime or timext.current_time()) + time[3]
        end
    end
	return 0 --0是永久称号
end

--获取称号
function PlayerTitleModule:get_title_by_id(id)
	return self.alltitle[id]
end

--------------------------------- 数据库操作 ----------------------------------------------------------------
--存库
function PlayerTitleModule:save()
    self._record:set_field("curtitleid", table.encode(self.curtitle))
    self._record:set_field("prevtitle", table.encode(self.pretitle))
    self._record:set_field("activetitle", table.encode(self.acttitle))
	self._record:asyn_save()
end

--获取设置当前称号id	
function PlayerTitleModule:SetCurTitle(type, v)
    self.curtitle[type] = v
    self._player:update_observer("title", self:get_current_title())
end

function PlayerTitleModule:GetCurTitle(type)
    return self.curtitle[type] or 0
end

--获取设置上一个称号
function PlayerTitleModule:SetPrevTitle(type, v)
    self.pretitle[type] = v
end
function PlayerTitleModule:GetPrevTitle(type)
    return self.pretitle[type] or 0
end

--获取设置激活的称号
function PlayerTitleModule:GetActiveTitle(type)
    return self.acttitle[type] or 0
end
function PlayerTitleModule:SetActiveTitle(type, v)
    self.acttitle[type] = v
end

return PlayerTitleModule