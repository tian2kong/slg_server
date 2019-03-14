local cityproto = {}

cityproto.type = [[
.origin {#原点
    x 0 : integer           #x坐标
    y 1 : integer           #y坐标
}
.unlockland {#解锁地块信息
    cfgid 0 : integer   #配置id
    state 1 : integer   #状态 0可开拓  1已开拓
}
.cityfacility {#设施信息
    id 0 : integer          #流水idxc
    type 1 : integer        #建筑类型
    level 2 : integer       #等级
    pos 3 : origin          #原点坐标
}
.buildqueue {#建筑队列信息
    id 0 : integer          #对应的设施id nil则为空闲
    time 1 : integer        #完成的时间 有可能为nil
    expire 2 : integer      #过期时间  有可能为nil
}
]]

cityproto.c2s = cityproto.type .. [[
#城建 301 ～ 400
reqmycity 301 {#请求城建信息
    response {
        land 0 : *unlockland(cfgid)     #地块信息
        facility 1 : *cityfacility(id)  #设施信息
        queue 2 : *buildqueue           #建筑队列信息
    }
}

developland 302 {#开拓地块
    request {
        cfgid 0 : integer       #
    }
    response {
        code 0 : integer        
        land 1 : unlockland     #解锁的地块信息
    }
}

createfacility 303 {#创建新的设施
    request {
        type 0 : integer        #建筑类型
        pos 1 : origin          #原点坐标
    }
    response {
        code 0 : integer            #
        facility 1 : cityfacility   #新的设施信息
    }
}

.facilityorigin {#设施原点坐标
    id 0 : integer          #流水id
    pos 1 : origin     #原点坐标
}
editfacility 304 {#编辑设施
    request {
        info 0 : *facilityorigin    #编辑后的设施原点坐标
    }
    response {
        code 0 : integer            #返回码
        info 1 : *facilityorigin    #编辑后的设施原点坐标
    }
}

upgradefacility 305 {#升级建筑
    request {
        id 0 : integer      #流水id
        quick 1 : boolean   #立即完成
    }
    response {
        code 0 : integer        #返回码
        quick 1 : boolean       #立即完成
        id 2 : integer      #流水id
    }
}

buybuildqueue 306 {#购买临时队列
    request {
        item 0 : integer            #物品id
        num 1 : integer             #数量
        auto 2 : boolean            #数量不够自动消耗元宝
    }
    response {
        code 3 : integer            #返回码
        item 0 : integer            #物品id
        num 1 : integer             #数量
        auto 2 : boolean            #数量不够自动消耗元宝
    }
}
]]


cityproto.s2c = cityproto.type .. [[
#城建 301 ～ 400
updateland 351 {#更新地块信息
    request {
        land 0 : *unlockland(cfgid)
    }
}

updatebuildqueue 352 {#同步建筑队列信息
    request {
        queue 0 : *buildqueue           #建筑队列信息
    }
}

updatefacility 353 {#同步设施信息
    request {
        type 0 : integer            #类型 1完成建造
        facility 1 : cityfacility   #更新的设施信息
    }
}
]]

return cityproto