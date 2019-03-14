<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";
	
	$serverid = isset($_GET['serverid']) ? $_GET['serverid'] : NULL;
	$playerid = isset($_GET['playerid']) ? $_GET['playerid'] : NULL;
	$account = isset($_GET['account']) ? $_GET['account'] : NULL;
	$deviceid = isset($_GET['deviceid']) ? $_GET['deviceid'] : NULL;
	$purchase = isset($_POST['purchase']) ? $_POST['purchase'] : NULL;

	function getReceiptData($receipt, $isSandbox) {  
        if ($isSandbox) {  
            $endpoint = 'https://sandbox.itunes.apple.com/verifyReceipt';  
        } else {  
            $endpoint = 'https://buy.itunes.apple.com/verifyReceipt';  
        }  

        $postData = json_encode(array('receipt-data' => $receipt));
        $ch = curl_init($endpoint);  
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);  
        curl_setopt($ch, CURLOPT_POST, true);  
        curl_setopt($ch, CURLOPT_TIMEOUT, 60);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);  
        curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, 0); 
        curl_setopt ($ch, CURLOPT_SSL_VERIFYHOST, 0);  
  
        $response = curl_exec($ch);
        $errno    = curl_errno($ch);
        $errmsg   = curl_error($ch);
        curl_close($ch);
        if ($errno != 0) {
        	PRedis::ERROR($errmsg . $errno);
            return null;
        }  
  
        $data = json_decode($response, true);
        if (!isset($data['status']) || $data['status'] != 0) {  
            PRedis::ERROR(sprintf('Apply pay invalid receipt sandbox[%d]', ($isSandbox and 1 or 0)));
            return null;
        }
        return $data;
	}

	$code = 0;
	if ($purchase == null or $serverid == null or $playerid == null or $account == null or $deviceid == null) {
		$code = 2;
	} else {
		$box = false;
		if (isChargeTester($deviceid)) {
			$box = true;
		}
		$data = getReceiptData($purchase, false);
		if ($data) {
			$temp = $data['receipt'];
			$code = 1;
			$param = array(
				'playerid' => $playerid, 
				'serverid' => $serverid,
				'account' => $account,
				'device' => $deviceid,
				'productId' => $temp['product_id'],
				'orderId' => $temp['transaction_id'],
				'tester' => ($box ? 1 : 0)
			);
			paylogic('ios', $param);
		}
	}

	/*
	{
		code：0验证失败, 1成功，2参数错误
	}
	*/
	$ret = array('code' => $code);
	echo json_encode($ret);

?>
