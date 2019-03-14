local t = {}


-------任务类型枚举
t.type = {
	begin						= 0,
	
	TASK_TYPE_UNLAWFUL			= 0,					--非法类型
	MAIN_TASK_TYPE				= 1,					--主线任务	
	BANGPAI_TASK_TYPE			= 2,					--帮派任务
	SHIMEN_TASK_TYPE			= 3,					--师门任务
	WUHUAN_TASK_TYPE			= 4,					--五环任务
	XUNBAO_TASK_TYPE			= 5,					--藏宝图任务
	ERBAIHUAN_TASK_TYPE			= 6,					--200环任务
	COPYMAP_TASK_TYPE			= 7,					--副本任务
	TASK_TYPE_REI				= 8,					--转生任务
	TASK_TYPE_ZHUO_GUI			= 9,					--捉鬼
	TASK_TYPE_XIANG_YAO			= 10,					--降妖
	TASK_TYPE_YAO_WANG			= 11,					--妖王任务
    BRANCH_TASK_TYPE            = 12,                   --支线任务
	
	ends						= 12,
}

--目标类型
t.tagtype = {
	TAGTYPE_SAY_TASK						= 1,		--对话任务
	TAGTYPE_SAY_TASK_UI						= 2,		--要弹ui的任务，前端用。。
	TAGTYPE_GATHER							= 3,		--采集任务
	TAGTYPE_BATTLE							= 4,		--战斗任务
	TAGTYPE_BATTLE_UI						= 5,		--点击npc弹ui，，在进入战斗
	TAGTYPE_GATHER_UI						= 6,		--点击npc弹采集，采集结束在进战斗
	TAGTYPE_HANDED_THING					= 7,		--上交物品
	TAGTYPE_HANDED_THING_UI					= 8,		--先弹ui ..上交物品
	TAGTYPE_GO_TO_USE_TAGTYPE_GATHER		= 9,		--使用任务物品，在采集,在上交
	TAGTYPE_GO_TO_PATROL					= 10,		--去巡视,到地点即可
	TAGTYPE_GO_TO_PATROL_BATTLE				= 11,		--去巡视,进入随机战斗
	TAGTYPE_USE_THING						= 12,		--使用物品
	TAGTYPE_GO_TO_USE_THING					= 13,		--去巡视,到地点后用物品
	TAGTYPE_CLICK_NPC						= 14,
	TAGTYPE_QUESTION						= 15,		--答题类型
	TAGTYPE_HANDED_THING_BY_TYPE			= 16,		--上交某个类型的物品
	TAGTYPE_HANDED_THING_BY_ID				= 17,		--上交制定id物品， 非任务
	TAGTYPE_COLL_KILL_TASK					= 18,		--杀多少个怪的任务， 需要每个模块自己处理
	TAGTYPE_AUTO_COMPLETE_TASK				= 19,		-- 一接收,自动完成(剧情任务)
	TAGTYPE_NULL_TASK           			= 20,		--空的任务,由外围控制完成
	TAGTYPE_CLIENT							= 21,		--客户端任务 不处理直接完成
}

t.status = {
	TASK_BEGIN						= 1,		--任务开始
	TASK_DELIVERY					= 2,		--任务可交付
	TASK_FAILED						= 3,		--任务失败
	TASK_FINISH						= 4,		--任务完成
	


}

t.action = {
	ACTION_REQ_TASK					= 1,	--请求任务
	ACTION_DO_TAGERT				= 2,	--做目标
	ACTION_DELIVERY					= 3,	--交付任务
	ACTION_WAIT						= 0xFFFF,		--等待状态

}

return  t