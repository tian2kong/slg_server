local class = require "class"
local interaction = require "interaction"
local common = require "common"
local chatcommon = require "chatcommon"
local IPlayerModule = require "iplayermodule"
local chatinterface = require "chatinterface"
local timext = require "timext"
local clusterext = require "clusterext"
local storagecommon = require "storagecommon"
local PlayerChatModule = class("PlayerChatModule", IPlayerModule)
local Database = require "database"
local gamelog = require "gamelog"


local private_cd = 20 --1秒(10毫秒级别)
local lock_time = 15

--构造函数
function PlayerChatModule:ctor(player)
    self._player = player

    self.locktimer = nil --定时器,避免LOGIC错误导致锁死

    --各频道定时器
    self.chnl_timer = {}
    --私聊定时器
    self.private_timer = nil

    self.globaldb = Database.new("global")
end

function PlayerChatModule:gmcommand_log(str)
    -- gm指令，记录经分
    local event_log = {
        event_type = gamelog.event_type.gm,
        action_id = event_action.action20002,
        parastr = {
            str,   -- 指令
        },
    }
    gamelog.write_event_log(self._player, event_log)
end

--锁操作
function PlayerChatModule:islock()
    return self.locktimer
end

function PlayerChatModule:lock()
    self.locktimer = timext.create_timer(lock_time)
end

function PlayerChatModule:unlock()
    self.locktimer = nil
end


function PlayerChatModule:loaddb()
end

--初始化
function PlayerChatModule:init()
    --private_cd = get_static_config().globals.chat_inteval_private * 100 --10毫秒级
end

--AI
function PlayerChatModule:run(frame)
    if self.locktimer and self.locktimer:expire() then
        self:unlock()   
    end
end

--上线处理
function PlayerChatModule:online()
end

--下线处理
function PlayerChatModule:offline()
end

--5点刷新
function PlayerChatModule:dayrefresh()
end

--发送离线类消息
function PlayerChatModule:req_chatrecord()
    local playerid = self._player:getplayerid()
    local chatrecords = clusterext.call(get_cluster_service().chatserver, "lua", "req_chatrecord", playerid)
    if chatrecords then
        local chatize = 10 --单个包上限10条
        local count = #chatrecords 
        local index = 1
        while( index > count ) do 
            local chats = {}
            local endindex = index + chatsize
            if endindex > count then
                endindex = count
            end
            for i=index,endindex do
                table.insert(chats, chatrecords[i])
            end
            self._player:send_request("syncprivatechat", { chats = chats }) --分包发送, 单个包上限10条

            index = endindex + 1
        end
    end
end

--聊天文本检测
function PlayerChatModule:check_word(content)
    local code = chatcommon.chat_message_code.success
    if not content then
        code = chatcommon.chat_message_code.word_nil
    elseif common.check_shield_word(content) then--屏蔽词
        code = chatcommon.chat_message_code.shield_word
    end
    return code
end

--聊天文本过滤
function PlayerChatModule:filter_word(chnl, content)
    local maxlen = chatcommon.chat_size
    --[[服务端限制文本大小统一]]
    if chnl == chatcommon.chat_chnl.chnl_servertyphon or chnl == chatcommon.chat_chnl.chnl_worldtyphon then 
        maxlen = chatcommon.typhon_size
    end
    local str = common.escape_string(content, maxlen)--截取过长字符
    return str
end

--频道聊天
function PlayerChatModule:send_channel_chat(chnl, chatmsg)
    local args = {
        player = chatinterface.extract_chatplayer(self._player),
        chnl = chnl,
        msg = chatmsg,
    }
    args.msg.time = timext.current_time()
    clusterext.send(get_cluster_service().chatserver, "lua", "channel_chat", chnl, args, self._player:get_address())
end


--各频道逻辑过滤（统一整合）
function PlayerChatModule:check_channel_logic(chnl)
    local code, consume = chatcommon.chat_message_code.success, {}
    repeat
        --检测各频道CD
        if self:on_channel_cd(chnl) then 
            code = chatcommon.chat_message_code.channel_cd
            break
        end

        --世界频道
        if chnl == chatcommon.chat_chnl.chnl_world then 
            --消耗判断
            -- consume.tokentype = "YinLiang"
            -- consume.needtoken = get_static_config().globals.world_chat_need_shigong
            -- if not self._player:tokenmodule():cansubshigongconsume.needtoken) then
            --     code = chatcommon.chat_message_code.less_token
            --     break
            -- end

        elseif chnl == chatcommon.chat_chnl.chnl_servertyphon then --全服喇叭
            if not self._player:is_gm() then --不是GM号
                code = chatcommon.chat_message_code.no_gm
            end

        elseif chnl == chatcommon.chat_chnl.chnl_worldtyphon then --世界喇叭
            --消耗判断
            consume.needitem = chatcommon.cry_item 
            consume.neednum = 1
            if not self._player:thingmodule().bag:canconsume(consume.needitem, consume.neednum) then
                return chatcommon.chat_message_code.less_thing
            end

        end

    until 0;
    return code, consume    
end

--开启频道定时
function PlayerChatModule:open_channel_timer(chnl)
    local refreshtimer = 60
    if chnl == chatcommon.chat_chnl.chnl_world then --世界频道
        refreshtimer = get_static_config().globals.chat_inteval_world
    elseif chnl == chatcommon.chat_chnl.chnl_servertyphon then --全服喇叭
        refreshtimer = get_static_config().globals.chat_inteval_world
    elseif chnl == chatcommon.chat_chnl.chnl_worldtyphon then --世界喇叭
        refreshtimer = get_static_config().globals.chat_inteval_world
    else
        return
    end

    self.chnl_timer[chnl] = timext.create_timer(refreshtime)
end

--是否在CD中
function PlayerChatModule:on_channel_cd(chnl)
    return self.chnl_timer[chnl] and not self.chnl_timer[chnl]:expire() 
end

function PlayerChatModule:on_private_cd()
    if self.private_timer then
        return not self.private_timer:expire()
    end
    return false
end 

--私聊cd定时器
function PlayerChatModule:create_private_timer()
    self.private_timer = timext.create_skynettimer(private_cd)
end

--发送私聊文本 同步
function PlayerChatModule:call_send_private_chat(targetid, chatmsg)
    local playerid = self._player:getplayerid()
     local args = {
        player = chatinterface.extract_chatplayer(self._player),
        msg = chatmsg,
        tagid = targetid,
    }
    args.msg.time = timext.current_time()

    --阻塞
    self:lock() --加锁
    local code = clusterext.call(get_cluster_service().chatserver, "lua", "private_chat", playerid, targetid, args, self._player:get_address())
    self:unlock() 
    return code
end

return PlayerChatModule