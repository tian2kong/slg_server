<?php
	
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);

	//测试专用
	include "fcm_common.php";
	include "servermgr.php";

	$title = isset($_GET["title"]) ? $_GET["title"] : NULL ; 
	$text = isset($_GET["text"]) ? $_GET["text"] : NULL ; 
	$account = isset($_GET["account"]) ? $_GET["account"] : NULL ; 

	$ret = array();
	$code = 0;
	do {
		if ( !$title or !$text or !$account  ) {
			$code = 1;
			break;
		}

		$info = found_account($account, true);
		if ( !$info or !isset($info["lastdevice"]) ) {
			$code = 2;
			break;
		}
		
		$device = $info['lastdevice'];
		if ( !isset( $info['lastdevice'] ) or $info['lastdevice'] == '') { //最近登录设备字段有可能为空
			$device = $info['device'];
		}		
		$device = array( $device );
		$result = get_part_fcmdb($device);
		if ( !$result ) {
			$code = 3;
			break;
		}

		if ( empty($result) ) {
			$code = 4;
			break;
		}

		$data = array();
		foreach ($result as $v) {
			$data[$v['device']] = $v["token"];
		}
		$res = sendFCM($title, $text, $data);
		if ( !$res or !$res[0]) {
			$code = 5;
			break;
		}

		$tmp = json_decode($res[0], true);
		if ( $tmp['success'] != 1) { //发送失败
			$code = 6;
			break;
		} 
	} while (false);
	$ret['code'] = $code;
	echo json_encode($ret);
?>