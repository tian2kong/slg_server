local chatcommon = BuildCommon("chatcommon")

chatcommon.chat_message_code = {
    unkown          = 0     , 
    success         = 1     ,
    full_channel    = 2     ,   --频道人数已满
    no_channel      = 3     ,   --没有找到频道
    channel_cd      = 4     ,   --频道聊天cd中
    whisper_cd      = 5     ,   --私聊cd
    sendtoself      = 6     ,   --不能发给自己
    shieldself      = 7     ,   --不能屏蔽自己
    hadshield       = 8     ,   --已经屏蔽
    noshield        = 9     ,   --没有屏蔽该对象
    shieldlimit     = 10    ,   --屏蔽列表已达上限
    same_channel    = 11    ,   --相同的频道
    no_found_player = 12    ,   --没有找到玩家
    pm_command      = 13    ,   --pm命令
    param_error     = 14    ,   --参数错误
    less_token      = 15    ,   --缺少代币
    no_team         = 16    ,   --不在队伍中
    no_guild        = 17    ,   --没有帮派
    lock_speak      = 18    ,   --被禁言
    less_thing      = 19    ,   --缺少物品
    send_voicefail  = 20    ,   --发送语音失败
    be_silence      = 21    ,   --被gm禁言了
    no_gm           = 22    ,   --不是GM号

    --语音 101 ~ 150
    voice_largest   = 101   ,   --语音过大
    no_voice        = 102   ,   --没有该语音

    --验证字符 501 ~ 550
    word_nil        = 501   ,   --字符为空
    shield_word     = 502   ,   --非法字符
    escape_string   = 503   ,   --非法字符
    too_long        = 504   ,   --字符过长

    --私聊 551~600
    no_player       = 551   ,   --没有该玩家
    set_refuse      = 552   ,   --该玩家设置陌生人拒接
    send_suc        = 553   ,   --发送成功
    send_fail       = 554   ,   --发送失败
    is_offline      = 555   ,   --玩家不在线上

    --翻译 701~750
    trans_typeerror = 701   ,   --类型错误
    trans_toolarge  = 702   ,   --文本太大
    trans_empty     = 703   ,   --为空
}

chatcommon.chat_type = {
    content = 1, --文本聊天
    voice   = 2, --语音
}

--频道类型
chatcommon.chat_chnl = {
	chnl_world	        = 4	,	-- 世界频道
	chnl_servertyphon	= 5 ,	-- 全服喇叭
	chnl_worldtyphon	= 6 ,	-- 世界喇叭(有走马灯)

	chnl_system	        = 8	,	-- 系统消息(纯系统消息)[[客户端识别频道专用]]
}

--系统类型
chatcommon.system_type = {
    st_message          = 1 ,    --系统消息
    st_tips             = 2 ,    --系统提示
    st_typhon           = 3 ,    --系统喇叭（走马灯）
    st_guild            = 4 ,    --帮派系统
}

chatcommon.voice_type = {
    voic_channel        = 1,    --不存库，直接存放内存
    voic_private        = 2,    --私人留言,到时删除
    voic_space          = 3,    --空间留言,不可删除
}

chatcommon.synofflineprivatenum = 10--一次同步离线私聊数据10条
chatcommon.synofflineprivatevoicenum = 3--一次同步离线语音私聊数据3条
chatcommon.chat_size = 1024 * 2--聊天信息限制数
chatcommon.typhon_size = 512 * 1--喇叭信息限制（喇叭是没有链接, 防止假包）
chatcommon.voice_size = 1024 * 20--语音信息限制 (20KB)
chatcommon.chnl_voice_refresh_time = 60 * 30--频道语音清除刷新时间
chatcommon.private_voice_refresh_time = 3600 * 24--私聊语音清除刷新时间
chatcommon.chnl_voice_count = 1000--频道语音上限数量
chatcommon.cry_item = 7112
chatcommon.chnl_voice_expire = 60 * 60 * 24 --频道语音过期时间
chatcommon.translate_size = 256

--区分私聊库中语音和文本
chatcommon.whisper_type = {
    text  = 1,
    sound = 2,
    system = 3,--系统信息
}

chatcommon.translate_type = {
    [1] = "zh", --中文
    [2] = "en", --英文
}

--[[
-------------------------------私聊系统信息参数说明-------------------------------
    type : 系统类型
    oldname   ： 旧名字
    newname   ： 新名字
    oldroleid ： 旧职业
    newroleid ： 新职业

    changename:  type,  oldname,newname
    changerole:  type,  oldroleid,newroleid
    
---------------------------------------------------------------------------]]
chatcommon.private_sys_type = {
    changename = 1, --改名  
    changerole = 2, --转职  
    marry = 3,      --结婚成功消息
}

return chatcommon