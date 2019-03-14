<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#服务器列表
	include_once "servermgr.php";

	$account = isset($_GET['account']) ? $_GET['account'] : NULL;
	$onlycreate = isset($_GET['onlycreate']) ? $_GET['onlycreate'] : NULL;
	$groupid = isset($_GET['groupid']) ? $_GET['groupid'] : NULL;
	
	$ret = array();
	if ($onlycreate) {
		$ret = getAccountList($account);
	} else if ($groupid) {
		$ret = getGroupList($account, $groupid);
	} else {
		$ret = getServerList($account);
	}
	echo json_encode($ret);
?>