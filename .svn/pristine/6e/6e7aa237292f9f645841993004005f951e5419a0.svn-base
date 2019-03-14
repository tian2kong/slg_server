local shopproto = {}

shopproto.type = [[
.shopbuytimes {
    key 0 : integer     #商品key
    times 1 : integer   #已购买次数
}
]]

shopproto.c2s = shopproto.type .. [[
#场景 1001 ～ 1050
shopbuy 1002 {#购买物品
    request {
        buykey 0 : integer     #购买的商品key
		buycount 2 : integer   #购买数量
    }
    response {
        result		 0 : integer        #购买结果
		thingcfgid 	 2 : integer		#不是礼包， 会买到的物品id
		amount		 3 : integer		#不是礼包，这里是买的数量
        thingid      4 : integer        #物品id
    }
}

reqshopbuytimes 1008 {#请求商店限购商品已购买次数
    request {
    }
}

reqtreasureshop 1009 {#请求珍宝商店商品
    request {   
    }
}

]]


shopproto.s2c = shopproto.type .. [[
retshopbuytimes 1030 {#返回商店限购商品已购买次数
    request {
        info 0 : *shopbuytimes
    }
}

updateshopbuytimes 1031 {#同步商店限购商品已购买次数
    request {
        info 0 : shopbuytimes  
    }
}

.treasuregoods {#珍宝商品
    key 0 : integer             #商品key
    price 1 : integer           #价格
}
synctreasureshop 1032 {#同步珍宝商店商品
    request {
        info 0 : *treasuregoods       #商品信息
    }
}
]]

return shopproto