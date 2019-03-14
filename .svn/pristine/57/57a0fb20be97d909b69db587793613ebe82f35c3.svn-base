local playerproto = {}

playerproto.type = [[
.rolebase {#角色基础属性
    id 0 : integer          #角色id
    shape 1 : integer       #头像
    name 2 : string         #角色名字
    level 3 : integer       #等级
    exp 4 : integer         #经验
    roleid 5 : integer     #职业id
    lastname 6 : string     #曾用名
    account 7 : string      #账号
    language 8 : integer    #语言
    offlinetime 9 : integer   #上次离线时间
}
]]

playerproto.c2s = playerproto.type .. [[
#角色 401 ～ 500
reqrolebase 401 {#请求玩家基本信息
    response {
        info 0 : rolebase       #角色基础属性
    }
}

changeprofession 411 {#转换职业
    request {
        id 0 : integer       #转职id
        notice 1 : boolean      #是否通知好友
    }
    response {
        code 0 : integer     #返回码
        info 1 : rolebase    #角色基础属性(替换部分属性)
        notice 2 : boolean   #是否通知好友
    }
}

changerolename 412 {#角色改名
    request {
        name 0 : string         #名字
        notice 1 : boolean      #是否通知好友
    }
}

reqdetailplayerinfo 418 {#请求角色详细信息
    request {
        playerid 0 : integer    #角色id
    }
}
]]


playerproto.s2c = playerproto.type .. [[
#角色 401 ～ 500
syncrolebase 451 {#同步角色基础 替换角色属性
    request {
        info 0 : rolebase        #角色基础属性
	}
}

changerolenameret 464 {#角色改名返回
    request {
        code 0 : integer        #返回码
        name 1 : string         #名字
        notice 2 : boolean      #是否通知好友
    }
}

.detailplayerinfo {
    playerid        0 : integer     #玩家ID
    level           2 : integer     #等级
    name            3 : string      #名字
    roleid          4 : integer     #角色roleid
    title           5 : *titleinfo  #称号
}
syncdetailplayerinfo 465 {#角色详细信息返回
    request {
        info        0 : detailplayerinfo   #玩家信息
        code        1 : integer            #返回码
    }
}
]]

return playerproto