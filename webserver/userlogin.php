<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#用户登录
	include_once "common.php";

	$param = $_GET;
	$param["shortlogin"] = (bool)$param["shortlogin"];
	$param["app_id"] = APPID;
	$param["sign"] = request_sign($param, APPKEY);
	
	$url='http://api.dc.737.com/da/v2.0/login?';
	$str = '';
	foreach ($param as $key => $value) {
		$str .= '&' . $key . '=' . $value;
	}
	$url .= substr($str, 1);

	$ret = file_get_contents($url);
	
	echo $ret;
?>