local chatproto = {}


chatproto.type = [[
.voiceinfo { #语音信息
    key 0 : integer
    voicetime 1 : integer
}

.chatplayer {
    playerid    0 : integer     #玩家ID
    name        1 : string      #名字
}

.chat { #聊天数据
    chnl        1 : integer     #频道
    tagid       2 : integer     #私聊对象玩家ID
    player      3 : chatplayer  #玩家信息
    msg         4 : chatmsg
}

.chatmsg {
    type        0 : integer     #聊天类型(语音, 文本)
    content     1 : string      #聊天文本
    voice       2 : voiceinfo   #语音信息
    time        3 : integer     #时间
    node        4 : *string     #特殊文本节点
}
]]

chatproto.c2s = chatproto.type .. [[
#聊天 1101 ～ 1200
gmcommand 1101 { #GM命令
	request {
        content 0 : string      #内容
	}
    response {
        code    0 : integer        #返回码
        content 1 : string      #内容
    }
}


reqchannelchat 1102 { #频道聊天
	request {
        chnl    0 : integer         #频道
        msg     1 : chatmsg         #聊天信息
	}                            
    response {                   
        chnl    0 : integer         #频道
        code    1 : integer         #返回码
    }
}

reqprivatechat 1103 { #私聊
	request {
        playerid    0 : integer     #玩家ID
        msg         1 : chatmsg     #聊天信息
	} 
    response {                   
        code        0 : integer     #返回码
        playerid    1 : integer     #玩家ID
    }                           
}

reqchatrecord 1104 { #请求离线私聊
}


.trans_tab {
    text        0 : string  #翻译文本
    btrans      1 : boolean #是否翻译
}

reqtranslate 1105 { #请求翻译
    request {
        tab         0 : *trans_tab #翻译table
    }
    response {
        tab         0 : *trans_tab #翻译table
        code        1 : integer #返回码
        from        2 : string  #来源语种
        to          3 : string  #目标语种
    }
}

]]

chatproto.s2c = chatproto.type .. [[
#聊天 1151 ～ 1200
syncchannelchat 1151 { #同步聊天信息
	request {
        chats 0 : *chat
	}                            
}

syncprivatechat 1152 { #同步私聊信息
	request {
        chats 0 : *chat    #私聊数据
	}                          
}

channelvoicechatret 1153 { #频道语音返回
    request {
        key  0 : integer          #语音索引   
        code 1 : integer          #返回码
        chnl 2 : integer          #频道
        token 3 : string
    }
}

privatevoiceret 1154 { #私聊语音返回
    request {
        key  0 : integer          #语音索引   
        tagid 1 : integer         #
        token 2 : string
    }
}

gmzmd 1155 { #GM走马灯
    request {
        tid     0 : string #TID
        text    1 : string  #自定义文本

        param1  2 : string #参数1
        param2  3 : string #参数2
        param3  4 : string #参数3
    }
}

]]
return chatproto