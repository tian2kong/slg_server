<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#获取服务器配置
	include_once "servermgr.php";

	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;
	$playerid = isset($_GET['playerid']) ? $_GET['playerid'] : NULL;
	$xianyu = isset($_GET['xianyu']) ? $_GET['xianyu'] : NULL;

	if (!$serverid or !$playerid or !$xianyu) {
		die("error param");
	}
	$server = getServerCfg($serverid);
	if (!$server) {
		die("not found server");
	}
	$host = 'http://' . $server['http_host'] . ':' . $server['http_port'];
	$url=sprintf('/gmxianyu?playerid=%d&xianyu=%s', $playerid, $xianyu);
	$ret = file_get_contents($host . $url);
	if ($ret == 1) {#成功
		echo "gm add xianyu success";
	} else {
		echo "gm add xianyu failure";
	}
?>