<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$code = 0;
	$arr = $_POST;
	$serverid = isset($arr['serverid']) ? $arr['serverid'] : NULL;
	if ($serverid != null) {
		unset($arr['serverid']);
	}

	if (!updateServer($arr, $serverid)) {
		$code = 1;
	}

	echo $code;
?>