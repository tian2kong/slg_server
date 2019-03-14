<?php
// 参数
// d_regid="注册token"
// tz_timezone="时区"
// d_country="国家" 
// d_language="语言"
// d_adid="Google 广告ID"
// d_android_id="设备唯一标示"
// d_serial_id="android sdk"
// d_ios_server_id=1 IOS服务器ID
// d_android_server_id  安卓服务器ID
// d_ios_id 苹果设备唯一标示

	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	include_once "fcm_common.php";

	$token = isset($_GET['d_regid']) ? $_GET['d_regid'] : NULL;
	$language = isset($_GET['d_language']) ? $_GET['d_language'] : $language_us; //默认英文

	$serverid = 1;
	$device = NULL;
	if ( isset($_GET['d_ios_server_id']) ) { //区分安卓
		$serverid = $_GET['d_ios_server_id'];
		$device = isset($_GET['d_ios_id']) ? $_GET['d_ios_id'] : NULL;
	} 
	elseif ( isset($_GET['d_android_server_id']) ) { // IOS
		$serverid = $_GET['d_android_server_id'];
		$device = isset($_GET['d_android_id']) ? $_GET['d_android_id'] : NULL;
	}

	if ( $token and $device and strlen($token) > 20 ) { //过滤异常token
		register_token($device, $token, $language, $serverid);
		echo 0;
	}
?>