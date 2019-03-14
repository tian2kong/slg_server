<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$platform = isset($_GET['platform']) ? $_GET['platform'] : NULL;
	$signture = isset($_GET['signture']) ? $_GET['signture'] : NULL;
	$email = isset($_GET['email']) ? $_GET['email'] : NULL;
	$account = isset($_GET['account']) ? $_GET['account'] : NULL;

	if (!$account or !$platform or !$signture) {
		die("bind account error param");
	}
	$code = 1;
	do {
		$key = null;
		/*
		if ($email && $signture) {
			PRedis::setarray(PLATFORMCACHE, array($email=>$signture), PLATFORMTIME);
		}
		*/
		if ($platform == "gamecenter") {
			$key = gamecenter_verify($signture, $email);
		} else if ($platform == "googleplay") {
			$key = googleplay_verify($signture, $email);
		} else if ($platform == "facebook") {
			$key = facebook_verify($signture, $email);
		} else {
			$code = 4;
			break;
		}
		if (!$key) {
			$code = 3;
			break;
		}
		$code = bind_account_info($account, $platform, $key);
	} while(false);

	/*
	{
		code：1成功，2已经绑定过，3失效的token，4不识别平台
	}
	*/
	echo $code;
?>