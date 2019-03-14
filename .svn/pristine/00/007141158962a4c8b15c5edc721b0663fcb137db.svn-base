local systemproto = {}

systemproto.c2s = [[
# 登录 1 ~ 50
login 2 {
	request {  
		token 0 : string		# encryped token
        did 1 : string          #设备id
        channel_id 2 : string   #渠道id
        datetime 3 : integer    #时间
        sign 4 : string         #验证码
        model 5 : string        #机型
        memory 6 : string       #内存容量
	}
    response {
        code 0 : integer        #返回码 5还未创建角色
	}
}

back 3 {
	request {  
		token 0 : string		# encryped token
        did 1 : string          #设备id
        channel_id 2 : string   #渠道id
        model 3 : string        #机型
        memory 4 : string       #内存容量
	}
    response {
        code 0 : integer        #返回码
	}
}

createrole 5 {#创建角色
    request {
        roleid 0 : integer      #默认角色id
        name 1 : string         #名字
    }
    response {
        code 2 : integer        #返回码
        roleid 0 : integer      #默认角色id
        name 1 : string         #名字
    }
}

reqsysteminit 6 {#请求系统初始数据
    response {
        current 0 : integer     #当前系统时间
        gmt 1 : integer         #时区
    }
}

keepalive 7 {#心跳包
    response {
        current 0 : integer     #当前系统时间
    }
}

entergameok 8 {#客户端登录游戏完成
    response {
        code 0 : integer        #返回码
    }
}

logout 9 {#登出
    response {
        code 0 : integer        #返回码
    }
}

reqworldlevel 11 {#请求服务器等级

}

.systemoption {
    qiecuo 0 : boolean      #是否接收切磋
    fightcmd 1 : boolean    #战斗指令显示
    systempush 2 : boolean  #系统推送
    refusestranger 3 : boolean #拒绝陌生人消息
    privacy 4 : boolean     #隐私
    refuseteam 5 : boolean  #是否拒绝组队
    language 6 : integer    #语种
}
reqsystemoption 12 {#请求系统选项
    response {
        info 0 : systemoption #系统选项
        info1 1 : serverinfo  #服务器信息
    }
}
resetsystemoption 13 {
    request {
        info 0 : systemoption #系统选项
    }
    response {
        info 0 : systemoption #系统选项
    }
}

bindaccount 24 {#绑定账号
    request {
        platform 0 : string         #平台
        signture 1 : string         #密匙
        email 2 : string            #邮箱
    }
    response {
        code 0 : integer        #返回码
    }
}

]]

systemproto.s2c = [[

syncworldlevel 15 {#同步世界等级
    request {
        level 0 : integer   #服务器等级
        time 1 : integer    #下一次服务器等级开启的时间
    }
}

dayrefresh 16 {#每日刷新时间通知
    request {
        time 0 : integer    #linux时间戳
    }
}
]]

return systemproto