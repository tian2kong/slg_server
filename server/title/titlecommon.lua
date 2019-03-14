local titlecommon = BuildCommon("titlecommon")

titlecommon.ret = {
    UNKNOWN_ERROR		= 0,				--非法参数
    SUCCESS             = 1,                --成功
	NO_TITLE			= 2,				--没有这个称号
	LOSE_EFFICACY		= 3,				--称号已过期无法带
	NOT_OP				= 4,				--强制称号 不能写下
	DOUBLE_SET			= 5,				--已经是这个称号 不能重复设置
    IN_GUILDWAR         = 6,                --在帮战地图中，不能修改称号
    ERROR_TITLE         = 7,                --错误称号
}

titlecommon.FOOT_TITLE = 1 --脚底称号
titlecommon.HEAD_TITLE = 2 --头衔

return titlecommon