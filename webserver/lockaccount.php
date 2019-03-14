<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";
	
	$account = isset($_GET['account']) ? $_GET['account'] : NULL;
	$flag = isset($_GET['flag']) ? $_GET['flag'] : NULL;
	
	$code = 0;
	if ($account == null or $flag == null) {
		$code = 1;
	} else {
		if ($flag != 0 and !PRedis::iskey(LOCKACCOUNT, $account)) {
			PRedis::addkey(LOCKACCOUNT, $account);
		} elseif ($flag == 0 and PRedis::iskey(LOCKACCOUNT, $account)) {
			PRedis::removekey(LOCKACCOUNT, $account);
		}
	}

	echo $code;
?>