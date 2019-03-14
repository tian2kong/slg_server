local tokenproto = {}

tokenproto.c2s = [[
#代币 201 ～ 250
reqtoken 201 {#请求代币数据
    response {
        data 0 : tokendata  #代币数据
    }
}

]]


tokenproto.s2c = [[
#代币 201 ～ 250
synctoken 211 {#同步代币
    request {
        data 0 : tokendata  #代币数据
	}
}
]]

return tokenproto