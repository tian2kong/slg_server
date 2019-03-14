<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";
	
	$ip = isset($_GET['ip']) ? $_GET['ip'] : NULL;
	$code = 0;
	if ($ip != null and PRedis::iskey(LOCKIP, $ip)) {
		$code = 1;
	}

	echo $code;
?>