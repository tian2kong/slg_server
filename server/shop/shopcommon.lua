
local shopcommon = BuildCommon("shopcommon")

--商店类型，参见 shop 配置表
shopcommon.SHOP_TYPE_TREASURE						= 103		--珍宝商店

--购买返回值解释
shopcommon.BUY_OK									= 0 	--购买成功
shopcommon.ERROR									= 1		--通用错误
shopcommon.NO_ITEM									= 2   	--没有这个物品
shopcommon.COUNT_IS_ZERO							= 3		--购买数量不能小于1
shopcommon.SHOP_ITEM_OUT							= 4		--商品已经下架
shopcommon.SHOP_ITEM_OUT							= 5		--商品已经下架
shopcommon.BAG_FULL									= 6		--背包空间不足
shopcommon.NOT_A_NUMBER_OF_TIMES 					= 7		--没次数了
shopcommon.NO_MONEY 								= 8		--代币不足
shopcommon.CONFIG_ERROR								= 9		--配置错误

--卖返回值
shopcommon.SELL_OK									= 0 	--卖出物品ok
shopcommon.SELL_INSUFFICIENCY 						= 1		--物品不足
shopcommon.SELL_NO_ITEM								= 2		--没有这个物品
shopcommon.MAX_CNT									= 3 	--一次不能卖这么多东西


--记录购买次数类型
shopcommon.WEEK_BUY_TIMES							= 1		--每周购买次数
shopcommon.DAY_BUY_TIMES							= 2		--每日购买次数

return shopcommon