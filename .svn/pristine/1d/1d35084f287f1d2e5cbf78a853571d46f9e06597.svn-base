<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "common.php";
	include_once "redis.php";

	$account = isset($_GET['account']) ? $_GET['account'] : NULL;
	$name = isset($_GET['name']) ? $_GET['name'] : NULL;
	$roleid = isset($_GET['roleid']) ? $_GET['roleid'] : NULL;
	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;
	$level = isset($_GET['level']) ? $_GET['level'] : NULL;
	if ($account == null or $name == null or $roleid == null or $serverid == null or $level == null) {
		die("serverlist upload player info error");
	}
	
	$player = array(
		"account"=>$account,
		"serverid"=>$serverid,
		"level"=>$level,
		"roleid"=>$roleid,
		"name"=>$name
	);
	
	PRedis::setarray(accountkey($serverid, $account), $player);
	$key = defaultkey($account);
	PRedis::setstring($key, $serverid);
	echo 1;
?>