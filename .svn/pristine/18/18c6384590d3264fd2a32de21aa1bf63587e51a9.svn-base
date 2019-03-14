local mailproto = {}

mailproto.type = [[
.mailparam {
    language 0 : string     #语言
    content 1 : *string     #参数
}
.mailbean {
    id 0 : integer          #流水id
    mailid 1 : integer      #邮件配置id
    param 3 : *mailparam    #文本参数
    token 4 : tokendata     #货币数据
    thing 5 : *thingdata(cfgid)    #物品数据
    open 6 : boolean        #是否已查看
    sendtime 7 : integer    #邮件发送时间
}

]]

mailproto.c2s = mailproto.type .. [[
#邮件 1601 ～ 1700
reqmail 1601 {#请求邮件数据
    
}

extractmail 1602 {#提取邮件附件
    request {
        id 0 : integer      #流水id
    }
}

delmail 1603 {#删除邮件
    request {
        id 0 : *integer      #流水id
    }
    response {
        code 0 : integer    #返回码
        id 1 : *integer     #
    }
}

openmail 1604 {#查看一封邮件
    request {
        id 0 : integer      #流水id
    }
    response {
        code 0 : integer    #返回码
        id 1 : integer      #流水id
    }
}

]]


mailproto.s2c = mailproto.type .. [[
#邮件 1601 ～ 1700
syncmail 1651 {#同步邮件数据
    request {
        info 0 : *mailbean  #邮件数据
    }
}
extractmailret 1652 {#提取邮件返回
    request {
        code 0 : integer                #返回码
        id 1 : integer                  #
        token 2 : tokendata             #货币数据
        thing 3 : *thingdata(cfgid)     #物品数据
    }
}
syncnewmail 1655 {#同步新邮件
    request {
        info 0 : mailbean   #邮件数据
    }
}
]]

return mailproto