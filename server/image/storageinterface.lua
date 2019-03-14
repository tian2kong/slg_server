local clusterext = require "clusterext"
local storageinterface = BuildInterface("storageinterface")

--请求数据索引key 占坑
function storageinterface.callback_apply_key(bsave, cb)
    clusterext.callback(get_cluster_service().imageserver, "lua", "apply_key", bsave, cb)
end

function storageinterface.call_apply_key(bsave)
    return clusterext.call(get_cluster_service().imageserver, "lua", "apply_key", bsave)
end


return storageinterface