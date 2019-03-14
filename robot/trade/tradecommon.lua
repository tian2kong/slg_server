local t = {}


-------任务类型枚举
t.ret = {
	OK					= 0,				--成功
	UNKNOWN_ERROR		= 1,				--非法参数
	NO_MONEY			= 2,				--钱不够
	BAG_FULL			= 3,				--背包满了
	NO_THING			= 4,				--没有这个物品
	THING_INSUFFICIENCY = 5,				--物品不足
	THING_IS_BIND		= 6,				--绑定物品不能交易
	PET_IS_WAR			= 7,				--参战宠物
	TRADING_TOO_FREQUENTLY  = 8,			--交易太频繁啦
	MAX_TRADE_GRID			= 9,			--摆摊格子超过8个了
	CONFIG_ERROR			= 10,			--配置错误
	NO_PRICE				= 11,			--不是合理的价钱
	HAVE_GEM				= 12,			--有宝石不能卖
	PET_NOT_VALUABLE		= 13,			--非珍品宠物不能卖
	NOT_SELF_THING			= 14,			--不是自己的东西
	NOT_COUNT				= 15,			--数量不对
	ILLICIT_PRICE			= 16,			--非法价格
	AUDIT_NOT_PASSED		= 17,			--审核不通过
	HUMAN_AUDIT				= 18,			--人工审核
	BUY_BAG_FULL			= 19,			--买的物品太多了，请先到领取面板先领取
	MULTIPLY_BUY			= 20,			--多人购买，等待结果
	REPETITION_BUY			= 21,			--多人购买，重复购买
	IS_ITEM					= 22,			--物品不能下架
	NOT_DRAW_TIME			= 23,			--没到领取时间
	TRADEING				= 24,			--正在交易中的物品不能下架,或者重新上架
}


	t.BUY_THING					= 1			--买东西
	t.SALE_THING 				= 2			--卖东西
	t.QUERY_OTHER_THING			= 3			--查看别人的东西
	t.QUERY_SELF_THING			= 4			--查看自己的东西
	t.UNSALE_THING				= 5			--下架东西
	t.QUERY_FACTOR				= 6			--查看波动因子
	t.QUERY_BUYTHINT			= 7			--查看自己买到的东西
	t.DRAW_THING				= 8			--领取自己买的东西
	t.ADD_THING					= 9			--加东西
	t.QUERRY_LOG				= 10		--看日志
	t.ATTENTION					= 11		--关注物品
	t.UNATTENTION				= 12		--取消关注
	t.GETATTENTION				= 13		--获取关注列表
	
	t.WAIT						= 0xFFFFFFF		--等待状态



return  t