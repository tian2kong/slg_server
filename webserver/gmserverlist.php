<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;
	
	$ret = array();
	if ($serverid == null) {
		$ret = getAllServerCfg();
	} else {
		array_push($ret, getServerCfg($serverid));
	}

	echo json_encode($ret);
?>