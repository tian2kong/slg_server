<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";
	
	$sign = isset($_GET['sign']) ? $_GET['sign'] : NULL;
	$datetime = isset($_GET['datetime']) ? $_GET['datetime'] : NULL;
	$account = isset($_GET['account']) ? $_GET['account'] : NULL;
	if ($sign == null or $datetime == null or $account == null) {
		die(sprintf("server sign error param sign[%s] datetime[%s] account[%s]", $sign, $datetime, $account));
	}
	date_default_timezone_set('UTC');
	$curent = time();
	$tempsign = request_sign(array('account'=> $account, 'datetime' => $datetime), APPKEY);
	if ($tempsign != $sign) {
		die("server sign error sign");
	}
	if ($curent - $datetime > SIGNTIME) {
		die("server sign expire");
	}
	$deviceret = found_account($account, false);
	if (!$deviceret) {
		die("server sign not found " . $account);
	} 

	echo json_encode($deviceret['platform']);
?>