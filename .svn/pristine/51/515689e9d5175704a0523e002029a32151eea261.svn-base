local thingproto = {}

thingproto.type = [[

]]

thingproto.c2s = thingproto.type .. [[
#物品 101 ～ 200
reqthings 101 {#请求所有物品数据
    response {
        info 0 : *thingdata(cfgid)
    }
}

userewarditem 102 {#使用资源类道具
    request {
        cfgid 0 : integer   #配置id
        num 1 : integer     #数量
        auto 2 : boolean    #数量不够自动消耗元宝补足
    }
    response {
        code 0 : integer    #返回码
        token 1 : tokendata #获取的代币数据
        auto 2 : boolean    #数量不够自动消耗元宝补足
    }
}

usegiftitem 103 {#使用礼包类道具
    request {
        cfgid 0 : integer   #配置id
        num 1 : integer     #数量
    }
    response {
        code 0 : integer    #返回码
        info 1 : *thingdata(cfgid) #获取的物品数据
    }
}

]]


thingproto.s2c = thingproto.type .. [[
#物品 101 ～ 200
updatethings 151 {#更新物品 物品数量为0时删除物品
    request {
        info 0 : *thingdata(cfgid)
    }
}
]]

return thingproto