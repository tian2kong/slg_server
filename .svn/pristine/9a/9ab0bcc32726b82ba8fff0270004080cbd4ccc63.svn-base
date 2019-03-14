<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";

	$device = isset($_GET['device']) ? $_GET['device'] : NULL;#设备号
	$platform = isset($_GET['platform']) ? $_GET['platform'] : NULL;#平台
	$sign = isset($_GET['sign']) ? $_GET['sign'] : NULL;#平台验证信息
	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;#服务器id

	$ret = array("code" => 0, "msg" => "success", "account" => $device);
	do {
		if (!$device or !$serverid) {
			$ret["code"] = 1;
			$ret["msg"] = sprintf("error param");
			break;
		}
		$server = getServerCfg($serverid);
		if (!$server) {
			$ret["code"] = 2;
			$ret["msg"] = sprintf("not found server ");
			break;
		}
		if ($platform) {
			if ($platform == "gamecenter") {
				$param = json_decode($sign);
				$result = gamecenter_login($param);
				if ($result != "success") {
					$ret["code"] = 3;
					$ret["msg"] = $result;
					break;
				}
			}
		}
		$ret["password"] = rand(1000,9999);
	} while (false);
	
	echo json_encode($ret);
?>