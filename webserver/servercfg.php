<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#获取服务器配置
	include_once "servermgr.php";

	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;

	$ret = array();
	if ($serverid) {
		$ret["game"] = getServerCfg($serverid);
		$ret["world"] = getWorldCfg($ret["game"]["worldid"]);
	}
	echo json_encode(array_values($ret));
?>