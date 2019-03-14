<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$code = 0;
	if (!addServer($_POST)) {
		$code = 1;
	}

	echo $code;
?>