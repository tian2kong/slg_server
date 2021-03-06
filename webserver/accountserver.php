<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$device = isset($_GET['device']) ? $_GET['device'] : NULL;
	$platform = isset($_GET['platform']) ? $_GET['platform'] : NULL;
	$signture = isset($_GET['signture']) ? $_GET['signture'] : NULL;
	$email = isset($_GET['email']) ? $_GET['email'] : NULL;
	$invation = isset($_GET['invation']) ? $_GET['invation'] : NULL;
	$clientos = isset($_GET['clientos']) ? $_GET['clientos'] : NULL;
	$subplatform = isset($_GET['subplatform']) ? $_GET['subplatform'] : NULL;

	if (strcasecmp($platform ,'nil') == 0) {
		$platform = null;
		$signture = null;
		$email = null;
	}

	$ip = $_SERVER["REMOTE_ADDR"];

	$code = 0;
	$msg = "success";
	$result = null;
	do {
		#验证平台
		if (!$device) {
			$device = "unkown device";
			if (!$platform) {
				$code = 1;
				$msg = "error device";
				break;
			}
		}
		$ip = getClientIP();
		if (PRedis::iskey(LOCKIP, $ip)) {
			$code = 5;
			$msg = "lock ip";
			break;
		}
		$platformkey = null;
		if ($platform) {
			/*
			if ($email && $signture) {
				PRedis::setarray(PLATFORMCACHE, array($email=>$signture), PLATFORMTIME);
			}
			*/
			if ($platform == "gamecenter") {
				$platformkey = gamecenter_verify($signture, $email);
			} else if ($platform == "googleplay") {
				$platformkey = googleplay_verify($signture, $email);
			} else if ($platform == "facebook") {
				$platformkey = facebook_verify($signture, $email);
			} else if ($platform == "feiyu") {
				$platformkey = feiyu_verify($signture, $subplatform, $email);
			} else {
				$code = 3;
				$msg = "unkown platform " . $platform;
				break;
			}
			if (!$platformkey) {
				$code = 2;
				$msg = "platform verify error";
				break;
			}
		}
		$result = get_account_info($device, $platform, $platformkey, $subplatform);
	} while(false);
	if ($code == 0 && !$result) {
		$code = 4;
		$msg = "server busy!";
	} else if (PRedis::iskey(LOCKACCOUNT, $result['account'])) {
		$code = 6;
		$msg = "lock account!";
	}
	$ret = array();
	if ($code == 0) {
		$ret = getAccountServer($result['account'], $clientos);
		$ret['bind'] = $result['platform'];
		date_default_timezone_set('UTC');
		$ret['datetime'] = time();
		$ret['account'] = $result['account'];
		$ret['sign'] = request_sign(array('account'=> $result['account'], 'datetime' => $ret['datetime']), APPKEY);
	}
	$ret['code'] = $code;
	$ret['msg'] = $msg;
	$ret['platform'] = $platform;

	#ip白名单
	if ($code == 0) {
		if ($ip) {
			$ret['status'] = 1;
		}
	}
	
	/*
	{
		code：0成功，1没有设备号，2平台验证失败，3不识别平台，4服务器繁忙，5ip被封，6账号被封
		msg：错误信息
		platform：平台 gamecenter、googleplay
	}
	*/
	echo json_encode($ret);
?>