<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$code = 0;
	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;
	if ($serverid == null) {
		$code = 1;
	} elseif (!delServer($serverid)) {
		$code = 1;
	}
	echo $code;
?>