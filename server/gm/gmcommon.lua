local gmcommon = BuildCommon("gmcommon")

gmcommon.clock_type = { --定时推送类型
	Loop 	= 1,	--周期性推送
	Alarm 	= 2, 	--具体时间点推送
}

gmcommon.push_weektype = { --后台推送周类型
	every 	= 0, --每周
	single 	= 1, --单周
	double 	= 2, --双周
}

gmcommon.push_language = { --推送语种, 与language.lua配置相同
	en_US = 1, --英语
	cn_CH = 2, --中国大陆
}

gmcommon.push_event_type = {
	guildwar_1 = 1,
	guildwar_2 = 2,
	guildwar_3 = 3,
}

return gmcommon