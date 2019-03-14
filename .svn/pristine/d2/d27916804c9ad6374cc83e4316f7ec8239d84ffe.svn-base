local client_request = {}

local loaded = {}
setmetatable(client_request, {
    __newindex = function(t, key, value)
        if loaded[key] then
            LOG_ERROR("reset client_request method " .. key)
        end
        rawset(loaded, key, value)
    end,
    __index = loaded,
})

function client_request.test(player, msg)
    print(msg.value)
    return { value = msg.value }
end

return client_request