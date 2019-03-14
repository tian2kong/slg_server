local class = require "class"
local IPlayerModule = require "iplayermodule"
local httprequest = require "httprequest"
local cacheinterface = require "cacheinterface"
local gamelog = require "gamelog"
local timext = require "timext"
local Random = require "random"
local mailinterface = require "mailinterface"

local PlayerChargeModule = class("PlayerChargeModule", IPlayerModule)

local PromotionSection = {--促销状态
	close = 0,
	open = 1,
}

--构造函数
function PlayerChargeModule:ctor(player)
	self._player = player
	self._record = nil
	self.firstcharge = {} --首充奖励
	self.chargereward = {} --累积充值奖励
	self.chargefund = {} --充值基金
	self.promotiontimer = nil --促销定时器
end

--
function PlayerChargeModule:loaddb()
	local player_charge_table = 
    {
        table_name = "player_charge",
        key_name = "playerid",
        field_name = {
            "history",--历史充值
            "firstcharge",--首充记录
            "chargereward",--累积充值奖励
            "activetimes",--活动次数
            "activegroup",--活动group
            "activeindex",--活动index
            "chargefund",--充值基金
            "promotionstatus",--促销活动状态
            "promotiontime",--促销剩余时间
        },
    }
	self._record = self._player:getplayerdb():create_db_record(player_charge_table, self._player:getplayerid())
	self._record:syn_select()
    
    if self._record:insert_flag() then
	    local str = self._record:get_field("firstcharge")
	    if str then
	    	self.firstcharge = table.decode(str) or {}
	    end
	    local str = self._record:get_field("chargereward")
	    if str then
	    	self.chargereward = table.decode(str) or {}
	    end
	    local str = self._record:get_field("chargefund")
	    if str then
	    	self.chargefund = table.decode(str) or {}
	    end
	else
		--self:set_promotion_cd(get_static_config().globals.limit_recharge_nopaycd, true)
	end
end

function PlayerChargeModule:init()
end

--AI
function PlayerChargeModule:run(frame)
	--self:promotion_logic()
end

--上线处理
function PlayerChargeModule:online()
	httprequest.requset_charge(self._player)
	self:cal_promotion_timer()
	--self:promotion_logic(true)
end

--下线处理
function PlayerChargeModule:offline()
	--促销下线保存
	if self:get_promotion_status() == PromotionSection.open then
		self:set_promotion_time(self.promotiontimer:remain())
		self:savedb()
	end
	
end


function PlayerChargeModule:get_group()
	return self._record:get_field("activegroup") or 1
end

function PlayerChargeModule:get_index()
	return self._record:get_field("activeindex") or 0
end

function PlayerChargeModule:get_history_charge()
	return self._record:get_field("history") or 0
end

function PlayerChargeModule:set_histroy_charge(num)
	self._record:set_field("history", num)
end

function PlayerChargeModule:is_first_charge(priority)
	return not self.firstcharge[priority]
end

function PlayerChargeModule:savedb()
	self._record:set_field("firstcharge", table.encode(self.firstcharge))
	self._record:set_field("chargereward", table.encode(self.chargereward))
	self._record:set_field("chargefund", table.encode(self.chargefund))
	self._record:asyn_save()
end

function PlayerChargeModule:set_first_charge(priority)
	self.firstcharge[priority] = 1
end

function PlayerChargeModule:receive_charge_reward(id)
	self.chargereward[id] = 1
end

function PlayerChargeModule:is_receive_reward(id)
	return self.chargereward[id]
end

function PlayerChargeModule:get_reward_message()
	return table.indices(self.chargereward)
end

function PlayerChargeModule:get_charge_fund()
	return self.chargefund
end

--普通充值
function PlayerChargeModule:raw_charge(productid, platform)
	local tokennum
	local cfg = get_static_config().recharge_ext[productid]
	if cfg then
		tokennum = cfg.xianyu_value
		self._player:tokenmodule():chargemoney(cfg.xianyu_value, object_action.action1079, cfg.priority, platform)
		if self:is_first_charge(cfg.priority) then
			self._player:tokenmodule():addtoken("XianYu", cfg.shouchong_xianyu, object_action.action1079, cfg.priority, platform)
			self:set_first_charge(cfg.priority)
		end
	end
	return tokennum
end

--充值活动
function PlayerChargeModule:raw_charge_active(productid, platform)
	local tokennum
	local cfg = get_static_config().appstoreid[productid]
	if cfg then
		local groupcfg = get_static_config().recharge_activity[self:get_group()]
		if not groupcfg then
			LOG_ERROR("recharge active unkown active group[%d]", self:get_group())
		elseif cfg.index ~= self:get_index() + 1 then
			LOG_ERROR("recharge active error player[%d] oldindex[%d] chargeindex[%d]", self._player:getplayerid(), self:get_index() + 1, cfg.index)
		else
			local indexcfg = groupcfg[cfg.index]
			if not indexcfg then
				LOG_ERROR("recharge active unkown active group[%d] index[%d]", self:get_group(), cfg.index)
			else
				tokennum = indexcfg.xianyu_value
				self._player:tokenmodule():chargemoney(indexcfg.xianyu_value, object_action.action1081, cfg.index, platform)

				local reward = indexcfg.reward[0]
				if not reward then
					local roleid = self._player:playerbasemodule():get_role_id()
					reward = indexcfg.reward[roleid]
				end
				local param = {
					id = reward,
		            num = 1,
		            action_id = object_action.action1081,
		            para = {
		            	cfg.index,
		            	platform,
		        	}
				}
				local msg = {}
				msg.reward = rewardlib.receive_award(self._player, param)
				msg.group = self:get_group()
				msg.index = cfg.index
				msg.next = self:get_index() + 1
				if cfg.index > self:get_index() then
					self._record:set_field("activeindex", cfg.index)
					msg.next = cfg.index + 1
				end
				msg.close = self:is_active_close()
				self._player:send_request("chargeactivereward", msg)
			end
		end
	end
	return tokennum
end

--充值基金
function PlayerChargeModule:raw_charge_fund(productid, platform)
	local tokennum
	local cfg = get_static_config().recharge_bianqiangjijin[productid]
	if cfg and not self.chargefund[cfg.Id] then
		tokennum = cfg.xianyu
		self.chargefund[cfg.Id] = {}
		self._player:send_request("synchargefund", { info = { id = cfg.Id, level = {} }})
		local level = self._player:playerbasemodule():get_level()
		local param = {
			event_type = gamelog.event_type.chargefund,
			action_id = event_action.action19041,
			para = {
				level,
				cfg.index,
				platform,
			}
		}
		gamelog.write_event_log(self._player, param)
	end
	return tokennum
end

--促销充值
function PlayerChargeModule:raw_charge_promotion(productid, platform)
	local tokennum
	local cfg = get_static_config().limit_recharge[productid]
	if cfg then
		tokennum = cfg.xianyu_value
		self._player:tokenmodule():chargemoney((cfg.xianyu_value + cfg.shouchong_xianyu), object_action.action1079, cfg.priority, platform)

		self:set_promotion_cd(get_static_config().globals.limit_recharge_paycd)
	end
	return tokennum
end

--特惠充值
function PlayerChargeModule:raw_charge_discount(productid, platform)
	local tokennum
	local cfg = get_static_config().daily_recharge[productid]
	if not cfg then 
		return 
	end 

	local refreshtime = timext.system_refresh_time()
    local t = os.date("!*t", timext.current_time() - refreshtime)
	local wday = t.wday
	local bagid = cfg.dailyBag[wday]
	if not bagid then
		LOG_ERROR("daily_recharge error playerid=[%d], wday=[%d], productid=[%s]",
			self._player:getplayerid(), wday, productid)
		return
	end
	local bagcfg = get_static_config().dayliBag[bagid]
	if not bagcfg or not bagcfg.reward then
		LOG_ERROR("dayliBag error, playerid=[%d], bagid=[%d], productid=[%s]",
			self._player:getplayerid(), bagid, productid)
	end

	local roleid = self._player:playerbasemodule():get_role_id()
	local rewardid = bagcfg.reward[roleid] or bagcfg.reward[0]
	local rewardparam = {
		id = rewardid,
		num = 1,
		action_id = object_action.action8888,
	}
	local reward = rewardlib.receive_award(self._player, rewardparam)
	self._player:send_request("syncdiscountchargereward", { reward = reward })
	--发奖励
	self._player:shopmoudle():add_discounttimes(productid)

	tokennum = cfg.xianyu_value
	self._player:tokenmodule():chargemoney(cfg.xianyu_value, object_action.action8888, cfg.priority, platform)
	return tokennum
end

--充值回调
function PlayerChargeModule:charge_ship(productid, platform)
	local tokennum
	if not tokennum then
		tokennum = self:raw_charge(productid, platform)
	end
	if not tokennum then
		tokennum = self:raw_charge_active(productid, platform)
	end
	if not tokennum then
		tokennum = self:raw_charge_fund(productid, platform)
	end
	if not tokennum then
		tokennum = self:raw_charge_promotion(productid, platform)
	end
	if not tokennum then
		tokennum = self:raw_charge_discount(productid, platform)
	end
	if tokennum then
		if self:get_history_charge() == 0 then
			--self._player:giftmodule():first_charge_event() --首冲事件
			--首充邮件
			local platform = self._player:get_bind_platform()
			if table.empty(platform) then
				local shouchong_mail = 1107
				mailinterface.send_mail(self._player:getplayerid(), shouchong_mail)
			end
		end
		self:set_histroy_charge(self:get_history_charge() + tokennum)

		self._player:operatemodule():recharge_event(tokennum)
	end
	
	self:savedb()
	return true
end


-------------------------------------------------促销活动-----------------------------------------------------------------------
--获取/设置促销
function PlayerChargeModule:get_promotion_status()
	return self._record:get_field("promotionstatus")
end
function PlayerChargeModule:get_promotion_time()
	return self._record:get_field("promotiontime")
end
function PlayerChargeModule:set_promotion_status(status)
	self._record:set_field("promotionstatus", status)
end
function PlayerChargeModule:set_promotion_time(time)
	self._record:set_field("promotiontime", time)
end
--促销进入cd
function PlayerChargeModule:set_promotion_cd(cfg, noinit)
	local cd = Random.Get(cfg[1], cfg[2])
	self:set_promotion_status(PromotionSection.close)
	self:set_promotion_time(timext.current_time() + cd)
	self.promotiontimer = nil
	self:savedb()
	if not noinit then
		self:sync_promotion()
	end
end
--开启促销活动
function PlayerChargeModule:open_promotion(noinit)
	self:set_promotion_status(PromotionSection.open)
	self:set_promotion_time(get_static_config().globals.limit_rechargetime)
	self:savedb()
	self:cal_promotion_timer()
	if not noinit then
		self:sync_promotion()
	end
end
--同步促销信息
function PlayerChargeModule:sync_promotion()
	local time
	local status = self:get_promotion_status()
	if status == PromotionSection.open then
		time = timext.current_time() + self.promotiontimer:remain()
	elseif status == PromotionSection.close then
		time = self:get_promotion_time()
	end
	self._player:send_request("syncpromotioninfo", { status = status, time = time })
end
--设置促销定时器
function PlayerChargeModule:cal_promotion_timer()
	if self:get_promotion_status() == PromotionSection.open then
		self.promotiontimer = timext.create_timer(self:get_promotion_time())
	end
end
--促销逻辑
function PlayerChargeModule:promotion_logic(noinit)
	local status = self:get_promotion_status()
	if status == PromotionSection.open then
		if not self.promotiontimer or self.promotiontimer:expire() then
			if not self.promotiontimer then
				LOG_ERROR("promotion_logic error timer")
			end
			self:set_promotion_cd(get_static_config().globals.limit_recharge_nopaycd, noinit)
		end
	elseif status == PromotionSection.close then
		local curtime = timext.current_time()
		if curtime >= self:get_promotion_time() then
			self:open_promotion(noinit)
		end
	end
end

return PlayerChargeModule