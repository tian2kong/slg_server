local playerinterface = BuildInterface("playerinterface")

function playerinterface.get_detail_playerinfo(player)
    local info = {}
    if player then
        local base = player:playerbasemodule() --角色基础

        info.playerid           = player:getplayerid() --角色属性
        info.level              = base:get_level()
        info.name               = base:get_name()
        info.roleid             = base:get_role_id()
        info.title              = player:titlemodule():get_current_title()
    end
    return info
end

return playerinterface