local client_request =  require "client_request"
local httprequest = require "httprequest"

-- local summoncommon = require "summoncommon"
local message_code = {
	unkown = 0,
	success = 1,
	no_deploy = 2,--没有找到配置
	have_receive = 3,--已经领取过该奖励
	bag_full = 4,--背包满了
	petbag_full = 5,--宠物背包满了
	no_reward = 6,--无法领取
	less_level = 7,--等级不足
}

function client_request.reqchargegoods(player, msg)
	local cfg = get_static_config().recharge[msg.country]
	local goods = {}
	if cfg then
		local chargemod = player:chargemodule()
		for k,v in pairs(cfg) do
			table.insert(goods, {
				productid = v.id,
				priority = v.priority,
				currency = v.money_type,
				number = tostring(v.need_money),
				xianyu = v.xianyu_value,
				xianyuext = (chargemod:is_first_charge(v.priority) and v.shouchong_xianyu or nil),
			})
		end
	end
	return { country = msg.country, goods = goods }
end

function client_request.chargeship(player, msg)
	--httprequest.charge(player, purcharse, sign)
end

function client_request.reqchargereward(player, msg)
	local chargemod = player:chargemodule()
	return {
		totalcharge = chargemod:get_history_charge(),
		receiveid = chargemod:get_reward_message(),
	}
end

function client_request.receivechargereward(player, msg)
	local code = message_code.unkown
	local chargemod = player:chargemodule()
	local cfg = get_static_config().total_recharge_reward[msg.id]
	local reward
	if not cfg then
		code = message_code.no_deploy
	elseif chargemod:is_receive_reward(msg.id) then
		code = message_code.have_receive
	else
		local eventid = cfg.reward[0]
		if not eventid then
			local roleid = player:playerbasemodule():get_role_id()
			eventid = cfg.reward[roleid]
		end
		if not eventid then
			code = message_code.no_deploy
		else
			local bagret, petbagret = rewardlib.can_receive_award(player, eventid, 1)
			if not bagret then
				code = message_code.bag_full
			elseif not petbagret then
				code = message_code.petbag_full
			else
				code = message_code.success
				chargemod:receive_charge_reward(msg.id)
				chargemod:savedb()

				local param = {
					id = eventid,
		            num = 1,
		            action_id = object_action.action1080,
		            para = {
		            	msg.id,
		        	}
				}
				reward = rewardlib.receive_award(player, param)

				-- local summonmgr = player:summonmodule():get_summonmgr()
				-- if msg.id == 2 then
				-- 	summonmgr:add_drawevent(summoncommon.draw_event.leiji_charge_2)
				-- 	summonmgr:savedb()
				-- elseif msg.id == 4 then
				-- 	summonmgr:add_drawevent(summoncommon.draw_event.leiji_charge_4)
				-- 	summonmgr:savedb()
				-- end
			end
		end
	end
	
	return { code = code, id = msg.id, reward = reward }
end

function client_request.reqchargeactive(player, msg)
	local chargemod = player:chargemodule()
	chargemod:sync_recharge_active()
end

function client_request.reqchargefund(player, msg)
	local fund = player:chargemodule():get_charge_fund()
	local info = {}
	for k,v in pairs(fund) do
		table.insert(info, {id = k, level = v})
	end
	return { info = info }
end

function client_request.receivechargefund(player, msg)
	local fund = player:chargemodule():get_charge_fund()
	local code = message_code.unkown
	local base = player:playerbasemodule()
	local info = {}
	if not fund[msg.id] then
		code = message_code.no_reward
	elseif base:get_formt_cfg_level() < msg.level then
		code = message_code.less_level
	else
		code = message_code.success
		for k,v in pairs(fund[msg.id]) do
			if v == msg.level then
				code = message_code.have_receive
				break
			end
		end
		if code == message_code.success then
			local cfg = get_static_config().recharge_bianqiangjijin[msg.id]
			if not cfg or not cfg.Gems[msg.level] then
				code = message_code.no_deploy
			else
				player:tokenmodule():addtoken("XianYu", cfg.Gems[msg.level], object_action.action1096, cfg.index)
				code = message_code.success
				table.insert(fund[msg.id], msg.level)
				player:chargemodule():savedb()
				info = { id = msg.id, level = fund[msg.id] }
			end
		end
	end

	return { code = code, info = info }
end

function client_request.reqpromotioninfo(player, msg)
	player:chargemodule():sync_promotion()
end