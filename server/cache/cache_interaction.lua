local agent_interaction = require "agent_interaction"

function agent_interaction.update_player_info(player, playerid, field, old, new)
    --好友上线提示
    local module = player:playerrelationmodule()
    local target = module:gettargetlist()
    if target[playerid] and field == "online" then
        module:notice_player_friendmsg(playerid, new)
    end
end

function agent_interaction.update_word_lv(player, level, worldlvtime)
    local module = player:cachemodule()
    print("update_word_lv", level)
    module:alter_worldlv(level, worldlvtime)
    module:sync_world_level()
end