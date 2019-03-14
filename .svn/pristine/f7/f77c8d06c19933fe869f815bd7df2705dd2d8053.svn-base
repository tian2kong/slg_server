<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$db = new PMysql($WEB_DB);

	echo "Welcome to DH web!<br><br>the history log:<br>";
	PRedis::showlog();

?>