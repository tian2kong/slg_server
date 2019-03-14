local chargeproto = {}

chargeproto.type = [[
.chargefund {
	id 0 : string 	#基金id
	level 1 : *integer #已领取等级奖励
}
]]

chargeproto.c2s = chargeproto.type .. [[
#充值4001～4100
.chargegoods {
	productid 0 : string	#商品id
	priority 1 : integer	#优先级
	currency 2 : integer 	#货币类型
	number 3 : string		#货币数量 会有浮点
	xianyu 4 : integer		#购买将获得的仙玉
	xianyuext 5 : integer	#首充返还仙玉  nil表示已购买过
}
reqchargegoods 4001 {#获取充值商品
	request {
		country 0 : string		#国家
	}
	response {
		country 0 : string		#国家
		goods 1 : *chargegoods	#商品
	}
}

chargeship 4002 {#充值发货
	request {
		purchase 0 : string		#客户端回传的 INAPP_PURCHASE_DATA 对应的数据
		signature 1 : string 	#客户端回传的 INAPP_DATA_SIGNATURE 对应的数据
	}
}

reqchargereward 4003 {#获取充值奖励信息
	request {

	}
	response {
		totalcharge 0 : integer		#累积充值的数量
		receiveid 1 : *integer		#领取过的累积充值奖励id
	}
}

receivechargereward 4004 {#领取累积充值奖励
	request {
		id 0 : integer		#奖励id
	}
	response {
		code 0 : integer	#返回码
		id 1 : integer		#奖励id
	}
}

reqchargeactive 4005 {#请求充值活动数据
	request {

	}
}

reqchargefund 4006 {#请求变强基金
	request {

	}
	response {
		info 0 : *chargefund 		#基金数据
	}
}

receivechargefund 4007 {#领取变强基金
	request {
		id 0 : string 		#基金id
		level 1 : integer   #等级
	}
	response {
		code 0 : integer	#返回码
		info 1 : chargefund #基金id
	}
}

reqpromotioninfo 4008 {#获取促销信息
	request {

	}
}

]]


chargeproto.s2c = chargeproto.type .. [[
#充值4001～4100
chargeshipret 4051 {#充值发货返回
	request {
		code 0 : integer	#返回码
		purchase 1 : string		#客户端回传的 INAPP_PURCHASE_DATA 对应的数据
	}
}

syncchargeactive 4052 {#同步充值活动数据
	request {
		group 0 : integer		#组id
		index  1 : integer		#索引id
		endtime 2 : integer		#结束时间
		close 3 : boolean		#活动是否关闭 如果关闭就没有上面的数据
	}
}

chargeactivereward 4053 {#充值活动奖励
	request {
		group 0 : integer		#组id
		index  1 : integer		#索引id
		close 3 : boolean		#活动是否关闭
		next 4 : integer		#进入下一索引id
	}
}

synchargefund 4054 {#同步变强基金
	request {
		info 0 : chargefund #基金id
	}
}

syncpromotioninfo 4055 {#同步促销信息
	request {
		status 0 : integer	#促销状态 0关闭 1开启
		time 1 : integer	#促销状态结束时间点 即活动关闭时指下次开启时间  活动开启时指活动关闭时间
	}
}

]]

return chargeproto