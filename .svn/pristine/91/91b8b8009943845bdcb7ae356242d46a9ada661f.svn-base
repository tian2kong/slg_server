<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";
	
	$purchase = isset($_POST['purchase']) ? $_POST['purchase'] : NULL;
	$signature = isset($_POST['signature']) ? $_POST['signature'] : NULL;
	$serverid = isset($_POST['serverid']) ? $_POST['serverid'] : NULL;
	$playerid = isset($_POST['playerid']) ? $_POST['playerid'] : NULL;
	$account = isset($_POST['account']) ? $_POST['account'] : NULL;
	$deviceid = isset($_POST['deviceid']) ? $_POST['deviceid'] : NULL;
	
	$code = 0;
	if ($purchase == null or $signature == null or $serverid == null or $playerid == null or $account == null or $deviceid == null) {
		$code = 2;
	} else {
		$public_key = "-----BEGIN PUBLIC KEY-----\n" . chunk_split(GOOGLEKEY, 64, "\n") . "-----END PUBLIC KEY-----";

		$public_key_handle = openssl_get_publickey($public_key);

		$code = openssl_verify($purchase, base64_decode($signature), $public_key_handle, OPENSSL_ALGO_SHA1);
		if (1 === $code) {// 支付验证成功！
			$temp = json_decode($purchase, true);
			$box = isChargeTester($deviceid);
			$param = array(
				'playerid' => $playerid, 
				'serverid' => $serverid,
				'account' => $account,
				'device' => $deviceid,
				'productId' => $temp['productId'],
				'orderId' => $temp['orderId'],
				'tester' => ($box ? 1 : 0)
			);
			paylogic('android', $param);
		}
	}

	/*
	{
		code：0验证失败, 1成功，2参数错误
	}
	*/
	$ret = array('code' => $code);
	echo json_encode($ret);
?>