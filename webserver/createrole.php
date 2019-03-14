<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#创角推送
	include_once "common.php";

	$param = $_GET;
	$param["app_id"] = APPID;
	$param["sign"] = request_sign($param, APPKEY);
	
	$url='http://api.dc.737.com/da/v2.0/player?';
	$str = '';
	foreach ($param as $key => $value) {
		$str .= '&' . $key . '=' . $value;
	}
	$url .= substr($str, 1);

	$ret = file_get_contents($url);
	
	echo $ret;
?>