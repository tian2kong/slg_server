local sharedata = require "sharedata"

local config = {}

local _config = nil

local function load_config()
	_config = sharedata.query("config")
end

--获取服务器端口配置
function config.get_server_config()
	if not _config then
		load_config()
	end
	return _config.serverconfig
end

--获取数据库配置
function config.get_db_config()
	if not _config then
		load_config()
	end
	return _config.dbconfig
end

return config