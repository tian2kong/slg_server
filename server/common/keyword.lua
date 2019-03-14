local keyword = {}

function keyword.check_shield_word(str)
    for _,word in pairs(get_static_config().shieldword) do--全字屏蔽
        if string.find(str, word, 1, true) then
            print(word, str)
            return true
        end
    end
    for _,word in pairs(get_static_config().patternword) do--通配符
        if string.find(str, word) then
            print(word, str)
            return true
        end
    end
    return false
end

return keyword