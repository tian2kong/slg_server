local skynet = require "skynet"
local Database = require "database"
local timext = require "timext"
local interaction = require "interaction"
local config = require "config"
local clusterext = require "clusterext"
local storagemgr = require "storagemgr"
local storagecommon = require "storagecommon"
local debugcmd = require "debugcmd"
local httprequest = require "httprequest"
local s_storage_mgr

--[[
大文件服务
]]

local CMD = {}

--
function CMD.apply_key(args)
    local key = s_storage_mgr:apply_key(args)
    local token
    local serverid = config.get_server_config().serverid
    -- 获取TOKEN
    token = httprequest.token(key, serverid)
    skynet.retpack({ key = key, token=token })
end

function CMD.recv_buff(id, data)
    local code = s_storage_mgr:recv(id, data)
    skynet.retpack({ code = code })
end

--
function CMD.req_buffer(address, id)
    local code = storagecommon.code.unknow
    local buffer = s_storage_mgr:get_buffer_info(id)
    if not buffer then
        code = storagecommon.code.no_find
    else
        --发送buffer
        local size = string.len(buffer)
        local factor = size / storagecommon.package_size
        local cnt = math.ceil(factor)
        if factor == 0 then --能整除
            cnt = cnt - 1
        end
        for i = 1, cnt do
            local beg_pos = (i - 1)* storagecommon.package_size + 1
            local end_pos = beg_pos + storagecommon.package_size - 1
            end_pos = end_pos > size and size or end_pos
            local str = string.sub(buffer, beg_pos, end_pos)
            local buffer = {
                size = size,
                buff = str,
                btail = (i == cnt),
            }
            --用CALL 可以保证顺序
            interaction.call(address, "lua", "send2client", "syncbuffer", { key = id, buffer = buffer, code = storagecommon.code.success }) 
        end
        code = storagecommon.code.send_suc   
    end
    skynet.retpack(code)
end

function CMD.remove_buffer(key)
    s_storage_mgr:remove_buffer(key)
end

--上传结果
function CMD.uploadresult(key)
    local code = s_storage_mgr:check_uploadresult(key)
    local bsuspend = false --当前携程是否挂起
    local args = {}
    if code == storagecommon.code.upload_suc then --已经成功了
        args = {
            bsuc = true
        }
    elseif code == storagecommon.code.wait then --等待上传
        if s_storage_mgr:get_upload_response(key) then --已经有携程挂起了 。。
            LOG_ERROR("uploadresult : coroutine already suspend, key = [%d]", key)
        else --挂起携程
            bsuspend = true
            s_storage_mgr:add_upload_response(key, skynet.response())
        end
    else
        LOG_ERROR("uploadresult error : code = [%d], key = [%d]", code, key)
    end

    if not bsuspend then
        skynet.retpack(args)
    end
end

skynet.init(function()
    debugcmd.register_debugcmd(CMD)
    
    local globaldb = Database.new("global")

    s_storage_mgr = storagemgr.new(globaldb)
    s_storage_mgr:init()


    local function run()
        s_storage_mgr:run()
    end

    timext.open_clock(run, 100)
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = assert(CMD[cmd])
        f(...)
    end)
end)


