<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";
	
	$param = $_POST;
	$sign = $_POST['sign'];
	unset($param['sign']);
	$checksign = request_sign($param, CHARGEKEY);
	try {
		$jsonobj  = json_decode($param['app_callback_ext']);
		if ($sign != $checksign) {
			echo "error sign";
		} else if (!$jsonobj or !isset($jsonobj->orderid) or !isset($jsonobj->uid)) {
			echo "error callback info";
		} else {
			$server = getServerCfg($param['app_zone_id']);
			if (!$server) {
				throw new Exception("charge not found server " . $param['app_zone_id']);
			}
			$host = 'http://' . $server['http_host'] . ':' . $server['http_port'];
			$url=sprintf('/getorderpay?orderid=%s', $jsonobj->orderid);
			$ret = file_get_contents($host . $url);
			if ($ret != $param['pay_amount']) {
				echo "eror pay amount";
			} else {
				$temp = array(
					'playerid' => $param['app_player_id'], 
					'serverid' => $param['app_zone_id'],
					'account' => $jsonobj->uid,
					'device' => '',
					'productId' => $jsonobj->orderid,
					'orderId' => $param['order_id'],
					'tester' => $param['sandbox']
				);
				paylogic('feiyu', $temp);
				echo "ok";
			}
		}
	} catch (Exception $e) {   
		PRedis::ERROR($e->getMessage());
		echo "server error";
	}
?>