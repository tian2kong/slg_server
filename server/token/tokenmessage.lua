local client_request =  require "client_request"
local tokencommon = require "tokencommon"

--聊天消息
function client_request.reqtoken(player, msg)
    return { data = player:tokenmodule():get_token_message() }
end