<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";
	
	$ip = isset($_GET['ip']) ? $_GET['ip'] : NULL;
	$flag = isset($_GET['flag']) ? $_GET['flag'] : NULL;
	
	$code = 0;
	if ($ip == null or $flag == null) {
		$code = 1;
	} else {
		if ($flag != 0 and !PRedis::iskey(LOCKIP, $ip)) {
			PRedis::addkey(LOCKIP, $ip);
		} elseif ($flag == 0 and PRedis::iskey(LOCKIP, $ip)) {
			PRedis::removekey(LOCKIP, $ip);
		}
	}

	echo $code;
?>