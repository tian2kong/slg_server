local titleproto = {}

titleproto.type  = [[
]]

titleproto.c2s =  titleproto.type .. [[
#称号 1801 ~ 1850
reqcurtitle 1801 {#请求当前称号
    request {
       
    }
}

reqalltitle 1802 {#请求所有称号
    request {
       
    }
    response {
      info			0 : *titleinfo		#所有称号信息
    }
}

settitle 1803 {#设置称号
	request {
		id			0 : integer			#id
		op			1 : boolean			# false 取消 ture设置
	}
	response {
		ret		0 : integer 		#非0位失败
	}
}

activetitle 1804 {#激活称号属性
	request {
		id			0 : integer			#id
		op			1 : boolean			# false 取消 ture设置
	}
	response {
		ret		0 : integer 		#非0位失败
	}
}

]]


titleproto.s2c =  titleproto.type .. [[
syscurtitle 1830 {
	request {
		info		0 : *titleinfo 		#当前称号
		active  	1 : *integer		#激活的称号id
	}
}

sysnewtitle 1831 { #新增称号
	request {
		info		0 : titleinfo 		#新的称号
	}
}

sysdeltitle 1832 { #删除称号
	request {
      	id			0 : integer			#id
	}
}

]]

return titleproto