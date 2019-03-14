local skynet = require "skynet"
local timext = require "timext"
local common = require "common"

local gamelog = {}
local gamelogd

local function get_gamelog()
    if not gamelogd then
        gamelogd = skynet.localname(".gamelogd")
    end
    return gamelogd
end

object_action = {
    unkown = 0,--策划未提供

    ----------------------------------------------------------------- 获得action
    action1008 = 1008,      --开启普通藏宝图获得
    action1009 = 1009,      --开启高级藏宝图获得
    action1010 = 1010,      --GM指令获得
    -- action1011 = 1011,      --任务获得
    action1012 = 1012,      --开启宝箱获得
    action1013 = 1013,      --物品合成获得 compoundthing
    action1014 = 1014,      --物品购买获得
    action1016 = 1016,      --摆摊购买获得 trademodule
    action1017 = 1017,      --摆摊出售获得
    action1018 = 1018,      --宠物抽卡获得
    action1020 = 1020,      --玩家招募获得伙伴
    action1028 = 1028,      --通过邮件获得道具
    action1029 = 1029,      --通过邮件获得货币
    action1030 = 1030,      --帮派强盗击杀获得
    action1032 = 1032,      --水陆大会获得
    action1033 = 1033,      --许愿池建筑获得
    action1034 = 1034,      --炼药获得
    action1035 = 1035,      --铸币所获得
    action1036 = 1036,      --远征奖励获得
    action1037 = 1037,      --竞技场单场奖励获得
    action1038 = 1038,      --竞技场每日结算获得
    action1039 = 1039,      --竞技场每周结算获得
    action1040 = 1040,      --点赞别人获得
    action1041 = 1041,      --被人点赞获得
    action1042 = 1042,      --被人送花获得
    action1043 = 1043,      --主线任务获得
    action1044 = 1044,      --大雁塔获得
    action1045 = 1045,      --大理答对六题
    action1046 = 1046,      --推荐任务
    action1047 = 1047,      --5v5竞技场首胜
    action1048 = 1048,      --5v5竞技场5胜
    action1049 = 1049,      --200获得
    action1050 = 1050,      --大理寺答题答对获得
    action1051 = 1051,      --大理寺答题答错获得
    --action1052 = 1052,      --抓鬼获得
    action1053 = 1053,      --抓鬼每轮结算获得
    --action1054 = 1054,      --天庭降妖获得
    action1055 = 1055,      --天庭降妖每轮结算获得
    action1056 = 1056,      --神秘妖王获得
    action1057 = 1057,--转生任务获得
    action1058 = 1058,--升级礼包获得
    action1059 = 1059,--首充礼包获得
    action1060 = 1060,--签到获得
    action1061 = 1061,--签到补签获得
    action1062 = 1062,--领取活跃度奖励
    action1063 = 1063,--修改宠物训养次数获得
    --action1064 = 1064,--收集奖励数据 获得
    action1065 = 1065,--五行合成物品获得
    --action1066 = 1066,--奖励道具获得  --- 这个跟 openchest 在useitemlogic 重复了
    action1067 = 1067,--交易回退物品获得
    action1068 = 1068,--小猪赛跑获得
    --action1069 = 1069,--排行榜奖励库领取
    action1070 = 1070,--福利获得好心值
    --action1071 = 1071,--建筑征收资源获得
    action1072 = 1072,--支线任务获得
    action1073 = 1073,--人气排行榜领奖获得
    action1074 = 1074,--帮派任务获得
    action1075 = 1075,--师门任务获得
    action1076 = 1076,--混元顶获得
    action1077 = 1077,--小妖队长奖励
    action1078 = 1078,--妖王队长奖励
    action1079 = 1079,--充值
    action1080 = 1080,--累积充值
    action1081 = 1081,--充值活动
    action1082 = 1082,--邀请礼包奖励
    action1083 = 1083,--邀请成长返利
    action1084 = 1084,--邀请充值返利
    action1085 = 1085,--五灵同贺获得 
    action1086 = 1086,--大义伏魔获得
    action1087 = 1087,--摆摊仙玉换银两获得
    action1088 = 1088,--世界答题获得
    action1089 = 1089,--青云志获得
    action1090 = 1090,--系统赠送宠物

    action1091 = 1091,--抢红包获得
    action1092 = 1092,--红包过期获得

    action1093 = 1093,--结婚获得奖励
    action1094 = 1094,--采集结婚脚本结束后出现的礼物获得
    action1095 = 1095,--累计登录礼包领取
    action1096 = 1096,--变强基金仙玉获得
    action1097 = 1097,--普天同庆红包获得

    action1098 = 1098,--老玩家回归奖励
    action1099 = 1099,--捕捉获得宠物
    action1101 = 1101,--宠物商店购买
    action1102 = 1102,--主线任务获得宠物
    action1500 = 1500,--礼包开启获得
    action1501 = 1501,--市场购买
    action1502 = 1502,--市场出售
    action1503 = 1503,--宠物合成
    action1504 = 1504,--生活技能生产
    action1505 = 1505,--装备打造
    action1506 = 1506,--帮派抢红包
    action1507 = 1507,--帮派签到
    action1508 = 1508,--帮派周礼包
    action1509 = 1509,--绑定FB奖励
    action1510 = 1510,--竞技场战斗获得
    action1511 = 1511,--竞技场PVE获得
    action1512 = 1512,--竞技场每日礼包获得
    action1513 = 1513,--竞技场赛季礼包获得
    action1514 = 1514,--36天罡击杀获得
    action1515 = 1515,--帮派战获得
    action1516 = 1516,--情花任务获得
    action1517 = 1517,--夫妻日常任务获得
    action1518 = 1518,--5v5竞技场奖励获得
    action1519 = 1519,--丝绸之路结算获得
    action1520 = 1520,--首席争霸获得
    action1521 = 1521,--竞速活动获得
    action1522 = 1522,--封妖获得
    action1523 = 1523,--世界BOSS获得
    action1524 = 1524,--赏金任务获得
    action1525 = 1525,--英雄战场获得
    action1526 = 1526,--神武妖王获得
    action1527 = 1527,--帮派攻城战获得
    action1528 = 1528,--英雄战场精英获得
    action1529 = 1529,--青云志-精英获得
    action1530 = 1530,--200环奖励获得
    action1531 = 1531,--修炼宝箱获得
    action1532 = 1532,--丝绸之路获得
    action1535 = 1535,--开启铜宝箱
    action1536 = 1536,--离婚获得



    action8888 = 8888, --特惠重置获得

    ----------------------------------------------------------------- 消耗action
    action5001 = 5001,-- 改名消耗
    action5002 = 5002,-- 技能升级消耗
    action5003 = 5003,-- 染色消耗
    --action5004 = 5004,-- 消耗经验药道具
    action5005 = 5005,-- 消耗更换徽章道具
    --action5006 = 5006,-- 角色加点消耗自由属性点
    action5007 = 5007,-- 角色加点兑换消耗角色经验
    action5008 = 5008,-- 角色切换双属性消耗
    action5009 = 5009,-- 角色转职消耗
    action5010 = 5010,-- 删除物品
    action5011 = 5011,-- 物品使用消耗
    action5012 = 5012,-- 物品合成消耗
    action5013 = 5013,-- 扩充背包消耗
    action5014 = 5014,-- 战斗使用消耗
    action5015 = 5015,-- 开启储物箱仓库消耗
    action5016 = 5016,-- 开启储物格消耗
    action5017 = 5017,-- 购买商店物品消耗
    action5018 = 5018,-- 摆摊购买消耗
    action5019 = 5019,-- 物品上架消耗
    action5020 = 5020,-- 宠物合成消耗
    action5021 = 5021,-- 宠物吃经验消耗
    action5022 = 5022,-- 战斗中使用实际未消耗
    action5023 = 5023,-- 宠物吃龙骨消耗
    action5024 = 5024,-- 宠物吃抗性修炼丹消耗
    action5025 = 5025,-- 宠物驯养消耗
    action5026 = 5026,-- 伙伴招募消耗师贡
    action5027 = 5027,-- 伙伴抗性修炼消耗
    action5028 = 5028,-- 伙伴升级消耗
    --action5029 = 5029,-- 伙伴装备升级    
    action5030 = 5030,-- 合成仙器消耗银两
    action5031 = 5031,-- 合成仙器消耗物品
    action5032 = 5032,-- 装备升级
    action5033 = 5033,-- 普通/高级装备升级消耗道具
    action5034 = 5034,-- 二级以上神兵升级消耗装备
    action5035 = 5035,-- 仙器升级消耗装备
    action5036 = 5036,-- 装备重铸消耗银两
    --action5037 = 5037,-- 装备重铸消耗道具
    action5038 = 5038,-- 装备炼化消耗银两
    --action5039 = 5039,-- 装备炼化消耗道具
    action5040 = 5040,-- 装备修理消耗
    action5041 = 5041,-- 宝石合成消耗
    action5042 = 5042,-- 创建帮派消耗
    action5043 = 5043,-- 修改公告消耗
    action5044 = 5044,-- 帮派升级消耗
    action5045 = 5045,-- 帮派升级消耗
    action5046 = 5046,-- 角色抗性修炼消耗
    action5047 = 5047,-- 角色抗性修炼消耗
    action5048 = 5048,-- 角色抗性修炼重置消耗
    --action5049 = 5049,-- 帮派强盗惩罚
    action5050 = 5050,-- 五行修炼消耗
    action5051 = 5051,-- 五行修炼消耗
    action5052 = 5052,-- 属性卡激活消耗
    action5053 = 5053,-- 属性卡激活消耗
    action5054 = 5054,-- 建筑升级消耗
    action5055 = 5055,-- 喇叭聊天消耗
    action5056 = 5056,-- 竞技场购买次数消耗
    action5057 = 5057,-- 空间购买礼物消耗
    action5058 = 5058,-- 送花消耗
    action5059 = 5059,-- 200环消耗
    --action5060 = 5060,-- 200环战斗类型任务消耗
    --action5061 = 5061,-- 抓鬼战斗消耗
    --action5062 = 5062,-- 降妖战斗消耗
    --action5063 = 5063,-- 神秘妖王战斗消耗
    --action5064 = 5064,-- 转生任务战斗消耗
    action5065 = 5065,-- 竞技场被攻击失败   
    action5066 = 5066,-- 竞技场刷新对手列表   
    action5067 = 5067,-- 远征消耗
    action5068 = 5068,-- 还原卡片加成消耗
    action5069 = 5069,-- 宠物洗练消耗
    action5070 = 5070,-- 宠物开启格子消耗
    action5071 = 5071,-- 角色重置属性点消耗
    action5072 = 5072,-- 宝石镶嵌消耗
    action5073 = 5073,-- 宝石卸下获得 
    action5074 = 5074,-- 穿戴装备获得多余宝石
    action5075 = 5075,-- 五行合成物品消耗
    action5076 = 5076,-- 帮派重置任务消耗
    --action5077 = 5077,-- 远征消耗
    action5078 = 5078,-- 帮派喊话消耗银两
    action5079 = 5079,-- 宠物重置属性加点消耗
    action5080 = 5080,-- 宠物重置修炼加点
    action5081 = 5081,-- 宠物飞升消耗
    action5082 = 5082,-- 宠物重置飞升点数消耗
    action5083 = 5083,-- 宠物遗忘技能消耗
    action5084 = 5084,-- 宠物锁定技能消耗
    action5085 = 5085,-- 宠物恢复技能消耗
    action5086 = 5086,-- 宠物学习神兽技能消耗

    action5087 = 5087,-- 摆摊仙玉换银两消耗
    action5088 = 5088,-- 大胃王投注银两消耗

    action5089 = 5089,-- 伙伴转移消耗
    action5090 = 5090,-- 发红包消耗

    action5091 = 5091,-- 协议离婚银两消耗
    action5092 = 5092,-- 单人强制离婚银两消耗    
    action5093 = 5093,-- 修炼宝箱消耗    
    action5094 = 5094,-- 宠物商店出售获得师贡    
    action5095 = 5095,-- 特殊获得宠物道具消耗    
    action5096 = 5096,-- 使用资质元宵消耗    
    action5097 = 5097,-- 使用资质丹炼骨消耗    
    action5098 = 5098,-- 使用副宠炼骨消耗    
    action5099 = 5099,--摆摊刷新
    action5100 = 5100,--市场购买消耗
    action5101 = 5101,--市场出售消耗
    action5102 = 5102,--竞拍预出价消耗
    action5103 = 5103,--竞拍返还
    action5104 = 5104,--物品赠送消耗
    action5105 = 5105,--被动修炼
    action5106 = 5106,--被动修炼消耗
    action5107 = 5107,--生活技能升级消耗
    action5108 = 5108,--生活技能生产消耗
    action5109 = 5109,--世界聊天消耗
    action5110 = 5110,--伙伴装备重置消耗
    action5111 = 5111,--伙伴装备宝石消耗
    action5112 = 5112,--阵法开启消耗
    action5113 = 5113,--阵法升级消耗
    action5114 = 5114,--装备打造消耗
    action5115 = 5115,--装备启灵消耗
    action5116 = 5116,--宝石镶嵌消耗
    action5117 = 5117,--装备属性转换消耗
    action5118 = 5118,--装备修理消耗
    action5119 = 5119,--帮派发红包消耗
    action5120 = 5120,--领取帮派周礼包消耗
    action5121 = 5121,--帮派祈福消耗
    action5122 = 5122,--竞技场购买次数消耗
    action5123 = 5123,--刷新对手消耗
    action5124 = 5124,--远征商店购买消耗
    action5125 = 5125,--丝绸之路消耗
    action5126 = 5126,--赏金任务刷新消耗
    action5130 = 5130,--伙伴装备升级
    action5150 = 5150,--远征清空
    action5151 = 5151,--开启36天罡
    action5152 = 5152,--开启妖王消耗
    action5153 = 5153,--结婚消耗戒指
    action5154 = 5154,--离婚消耗获得
    action5155 = 5155,--情花宝箱
    action5156 = 5156,--宠物洗练神奇
    action5157 = 5157,--脱离工会
}

gamelog.object_type = {
    playerexp = 1,      --  玩家经验
    petext = 2,         --  宠物经验
    xianyu = 3,         --  仙玉
    yinliang = 4,       --  银两
    banggong = 5,      --  帮贡
    shigong = 6,       --  师贡（绑定银两）
    arenapoint = 7,     --  竞技场点数
    guildbuild = 8,    --  帮派建设度
    yuanzheng = 9,     --  远征代币
    item = 10,          --  道具（包括技能书、装备）
    title = 11,         --  称号
    pet = 12,           --  宠物
    activity = 13,      --  活跃度
    huoli = 14,         --  活力
    partner = 15,       --  伙伴
    passiveexp = 16,    --  修炼经验
    shuilugongji = 17,  --  pk积分
    qiling = 18,        --  装备启灵
    relation = 19,      --  好友度
    popularity = 20,    --  人气值
    sysxianyu = 21,     --  系统水晶
    xiayi = 22,         --  好心值


    dayantajifen = 30,   --  大雁塔积分（降魔）
    flower = 31,        --  花数
    chengjian = 33,    --  城建代币
}

event_action = {
    unkown = 0,--策划未提供
    --------------------------------------- 角色 event
    action10001 = 10001,    -- 角色升级
    action10002 = 10002,    -- 角色升阶
    action10003 = 10003,    -- 更换升阶徽章
    action10004 = 10004,    -- 角色转职业
    action10005 = 10005,    -- 创建角色

    --------------------------------------- 装备 event
    action11001 = 11001,    -- 宝石镶嵌

    --------------------------------------- 帮派 event
    action12001 = 12001,    -- 帮派加入
    action12002 = 12002,    -- 帮派解散
    action12003 = 12003,    -- 帮派职位变更

    --------------------------------------- 邮件 event
    action13001 = 13001,    -- 接收邮件

    --------------------------------------- 五行 event
    action14001 = 14001,    -- 五行等级提升

    --------------------------------------- 主城系统 event
    action15001 = 15001,    -- 建筑解锁
 
    --------------------------------------- 活动 event
    action19001 = 19001,    -- 帮派强盗刷新
    action19002 = 19002,    -- 帮派强盗失败
    action19003 = 19003,    -- 参加远征活动
    action19004 = 19004,    -- 放弃远征
    action19005 = 19005,    -- 远征完结    

    --------------------------------------- 好友 event
    action19006 = 19006,    -- 添加好友
    action19007 = 19007,    -- 删除好友

    --------------------------------------- 主线任务 event
    action19008 = 19008,    -- 战斗失败

    action19009 = 19009,    -- 地煞星匹配
    action19010 = 19010,    -- 地煞星战斗失败
    action19011 = 19011,    -- 地煞星战斗胜利
    action19012 = 19012,    -- 地煞星观战
    action19013 = 19013,    -- 大雁塔战斗失败
    action19014 = 19014,    -- 大雁塔战斗胜利
    action19015 = 19015,    -- 寻芳战斗失败
    action19016 = 19016,    -- 寻芳战斗胜利
    action19017 = 19017,    -- 200环战斗胜利
    action19018 = 19018,    -- 200环战斗失败
    action19019 = 19019,    -- 200环上交物品
    action19026 = 19026,    -- 刷出神秘妖王
    action19027 = 19027,    -- 转生任务战斗胜利
    action19028 = 19028,    -- 转生任务战斗失败
    action19029 = 19029,    -- 首充礼包

    action19030 = 19030,    -- 运营评分活动记录    
    action19031 = 19031,    -- FB分享成功    
    action19032 = 19032,    -- 发送FB邀请成功
    action19033 = 19033,    -- 小猪赛跑报名
    action19034 = 19034,    -- 小猪赛跑投注    

    action19035 = 19035,    -- 结婚成功
    action19036 = 19036,    -- 协议离婚成功
    action19037 = 19037,    -- 强制离婚成功
    action19038 = 19038,    -- 参加夫妻日常活动
    action19039 = 19039,    -- 完成夫妻日常活动
    action19040 = 19040,    -- 累计登录礼包领取
    action19041 = 19041,    -- 购买变强基金
    action19042 = 19042,    -- 普天同庆礼包领取
    action19043 = 19043,    -- 抓鬼活动结算
    action19044 = 19044,--36天罡击杀
    action19045 = 19045,--帮战结算
    action19046 = 19046,--帮战擂台挑战
    action19047 = 19047,--帮派攻城战结束
    action19048 = 19048,--竞拍实际成交
    action19049 = 19049,--伙伴装备重置成功
    action19050 = 19050,--刷新赏金任务
    action19051 = 19051,--装备打造
    action19052 = 19052,--战斗中使用实际未消耗

    action20001 = 20001,    -- 登入
    action20002 = 20002,    -- gm指令
}

gamelog.event_type = {
    player = 1,     -- 角色
    equip = 2,      -- 装备
    guild = 3,      -- 帮派
    mail = 4,       -- 邮件
    fiveline = 5,   -- 五行系统
    city = 6,       -- 主城系统
    pet = 7,        -- 宠物系统
    partner = 8,    -- 伙伴系统
    friends = 9,    -- 好友系统
    activity = 10,  -- 活动
    task = 11,      -- 任务系统
    space = 12,     -- 空间系统
    rank = 13,      -- 排行榜系统
    recharge = 14,  -- 充值系统
    facebookshare = 15, --fb分享
    facebookinvate = 16, --fb邀请
    gift = 17,      -- 礼包系统
    login = 20,     -- 登录记录
    gm = 21,        --gm
    marry = 22,     -- 结婚相关的
    severlogin = 23,-- 7日登入礼包的
    chargefund = 24,    --变强基金
}


--物品日志,字段详细说明请参考策划文档
--[[
param => {
    objtype, 对象类型 gamelog.object_type
    object_id, 对象在相关表中的ID 物品id 或者 gamelog.object_type
    change_num, 变化数量
    left_num, 变化后，相同ID的对象所剩余的量。
    action_id, 操作ID 见object_action
    bind, 物品的绑定信息：1为绑定 0为不绑定 对于有期限的道具，填的是到期时间点
    para, {} 经分附加参数
    parastr, {} 经分附加参数 1~5=>para_str1 ~para_str5
}
]]
function gamelog.write_object_log(player, param)
    do
        return
    end
    if not param.change_num or param.change_num == 0 then
        LOG_ERROR("error object log: %s", tostring(debug.traceback()))
        return
    end
    local key = "object"
    param.para = param.para or {}
    param.parastr = param.parastr or {}
    local objcfg = get_static_config().datatext_coin[param.objtype]
    local actcfg = nil
    if param.action_id then
        actcfg = get_static_config().datatext_obj[param.action_id]
    end
    local insert_sql = [[
        insert into `#name`(time,accounts,userid,uuid,name,level,object_type,object_id,object_name,change_type,change_num,left_num,action_id,action_name
        ,para_int1,para_int2,para_int3,para_int4,para_int5,para_str1,para_str2,para_str3,para_str4,para_str5,bind_info,job,equip_value,speed,pet_type,pet_value) 
        values('%s','%s',%d,'%s','%s',%d,%d,%d,'%s',%d,'%s',%d,%d,'%s',%d,%d,%d,%d,%d,'%s','%s','%s','%s','%s',%d,%d,%d,%d,%d,%d);
    ]]
    local playerbase = player:playerbasemodule()
    local sql = string.format(insert_sql
        , timext.to_unix_time_stamp()
        , player:getaccount()
        , player:getplayerid()
        , player:getaccount()
        , common.mysqlEscapeString(playerbase:get_name())
        , playerbase:get_level()
        , param.objtype
        , param.object_id or 0
        , common.mysqlEscapeString(objcfg and objcfg.text or "")
        , (param.change_num > 0 and 1 or 0)
        , math.abs(param.change_num)
        , param.left_num
        , param.action_id or 0
        , common.mysqlEscapeString(actcfg and actcfg.action_name or "")
        , param.para[1] or 0
        , param.para[2] or 0
        , param.para[3] or 0
        , param.para[4] or 0
        , param.para[5] or 0
        , common.mysqlEscapeString(param.parastr[1] or "")
        , common.mysqlEscapeString(param.parastr[2] or "")
        , common.mysqlEscapeString(param.parastr[3] or "")
        , common.mysqlEscapeString(param.parastr[4] or "")
        , common.mysqlEscapeString(param.parastr[5] or "")
        , param.bind or 0
        , playerbase:get_role_id()
        , 0--player:thingmodule().clothes:getscore()
        , player:playerbasemodule():get_speed()
        , petid or 0
        , petscore or 0
    )
    GameLogInst():Log(key, sql)
end

--事件日志,字段详细说明请参考策划文档
--[[
    1、param => {
        event_type  事件类型，给事件定义其分类类型 , gamelog.event_type 中
        action_id   事件ID 配置表中的 event_id
        para, {} 经分附加参数 1~5=>para_int1 ~ para_int5
        parastr, {} 经分附加参数 1~5=>para_str1 ~para_str5
    }
    2、para_str1 ~ para_str5 这5个str记录其实是没有使用的
]]
function gamelog.write_event_log(player, param)
    do
        return
    end
    local key = "event"
    local para = param.para or {}
    local parastr = param.parastr or {}

    local actioncfg = get_static_config().datatext_event[param.action_id]
    if  not actioncfg then
        LOG_ERROR("gamelog event not found action id: %s", tostring(param.action_id))
        return 
    end
    
    local account, playerid
    local server_id, name, level
    local job, equip_value, speed, petid, petscore
    if  player then
        account = player:getaccount()
        playerid = player:getplayerid()

        local playerbase = player:playerbasemodule()
        if  playerbase then
            server_id = playerbase:get_server_id()
            name = playerbase:get_name()
            level = playerbase:get_level()
        end

        job = player:playerbasemodule():get_role_id()
    end


    local insert_sql = [[
        insert into `#name`(time,accounts,user_id,server_id,name,level,event_type,action_type_name,action_id,action_name
        ,para_int1,para_int2,para_int3,para_int4,para_int5,para_str1,para_str2,para_str3,para_str4,para_str5
        ,job,equip_value,speed,pet_type,pet_value) 
        values('%s','%s',%d, %d,'%s',%d, %d, '%s', %d, '%s'
            , %d, %d, %d, %d, %d, '%s','%s','%s','%s','%s'
            , %d, %d, %d, %d, %d);
    ]]
    local sql = string.format(insert_sql
        , timext.to_unix_time_stamp()
        , account or ""
        , playerid or 0
        , server_id or 0
        , common.mysqlEscapeString(name or "")
        , level or 0
        , param.event_type  -- event 类型
        , "action_type_name"-- action_type_name
        , param.action_id   -- action_id
        , common.mysqlEscapeString(actioncfg.action_name or "")
        , para[1] or 0
        , para[2] or 0
        , para[3] or 0
        , para[4] or 0
        , para[5] or 0
        , common.mysqlEscapeString(parastr[1] or "")
        , common.mysqlEscapeString(parastr[2] or "")
        , common.mysqlEscapeString(parastr[3] or "")
        , common.mysqlEscapeString(parastr[4] or "")
        , common.mysqlEscapeString(parastr[5] or "")
        , job or 0
        , equip_value or 0
        , speed or 0
        , petid or 0
        , petscore or 0
    )
    
    GameLogInst():Log(key, sql)
end

return gamelog