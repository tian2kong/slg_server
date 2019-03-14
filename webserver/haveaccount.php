<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#查询account数据
	include_once "servermgr.php";
	
	$account = isset($_GET['account']) ? $_GET['account'] : NULL;
	$code = 0;
	if ($account != null and found_account($account, true) != null) {
		$code = 1;
	}

	echo $code;
?>