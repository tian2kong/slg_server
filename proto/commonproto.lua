local commonproto = {}

commonproto.type = [[
.bufferinfo {
    size 0 : integer 
    buff  1 : string    #      
    btail  2 : boolean  #是否尾包 
}
]]

commonproto.c2s = commonproto.type .. [[
# 3601~3700
reqbuffer 3601 { #请求buffer
    request {
        key 0 : integer          
    }    
}

uploadbuffer 3602 { #上传BUFF
    request {
        key 0 : integer    
        buffer 1 : bufferinfo         
    }            
}
]]


commonproto.s2c = commonproto.type .. [[
syncbuffer 3651 { #同步buf
    request {
        key 0 : integer    
        buffer 1 : bufferinfo     
        code 2 : integer #返回码        
    }    
}

retuploadbuffer 3652 { #上传buff 返回
    request { 
        code 0 : integer #返回码        
        key 1 : integer #key
    }   
}

reqbufferret 3653 { #请求buffer返回
    request {
        key 0 : integer          
        code 1 : integer #返回码     
    }
}

]]

return commonproto