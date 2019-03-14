local client_request = require "client_request"
local config_func = require "static_config"
local common = require "common"
local shopcommon = require "shopcommon"
local clusterext = require "clusterext"

function client_request.reqtreasureshop(player, msg)
	player:shopmoudle():sync_treasure()
end

function client_request.reqshopbuytimes(player, msg)
	player:shopmoudle():sync_buy_times()
end

--购买物品
function  client_request.shopbuy(player, msg)
	local ret = player:shopmoudle():BuyItem(msg)
	return ret
end