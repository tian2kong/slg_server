<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";

	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;
	$playerid = isset($_GET['playerid']) ? $_GET['playerid'] : NULL;
	$account = isset($_GET['account']) ? $_GET['account'] : NULL;
	
	if (!$serverid or !$playerid or !$account) {
		die("reqplayercharge error param" . $serverid . $playerid . $account);
	}
	
	requestcharge($serverid, $playerid);
	echo 1;
?>