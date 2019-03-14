local client_request = require "client_request"

function  client_request.reqalltitle(player)
	return player:titlemodule():get_title_message()
end

function client_request.reqcurtitle(player)
	player:titlemodule():sync_current_titile()
end

function client_request.settitle(player,msg)
	return {ret = player:titlemodule():reset_title(msg)}
end

function client_request.activetitle(player,msg)
	return {ret = player:titlemodule():active_title(msg)}
end

