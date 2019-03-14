<?php
	include "mysql.php";
	date_default_timezone_set('UTC'); //去处date()警告
	
	define("FCM_LIMIT_CNT", 500);	#FCM 单次上限发送量

	//语种
	$language_android_zh = "zh"; 		//简体中文
	$language_ios_TWzh = "zh_Hant_TW"; 	//简体中文(繁体)
	$language_ios_zh = "zh-Hans-CN"; 	//简体中文

	$language_us = "us"; //英文


	#FCM注册
	function register_token($device, $token, $language, $serverid) {
		global $WEB_DB;
		$db = new PMysql($WEB_DB);
		$sql="replace into fcm_token (device,token,language,serverid) values('%s','%s','%s', %d)";
		$result = $db->query($sql, $device, $token, $language, $serverid);
		return $result;
	}

	function unregister_token($device) {
		global $WEB_DB;
		$db = new PMysql($WEB_DB);
		$sql="delete from fcm_token where device='%s'";
		$result = $db->query($sql, $device);
		return $result;
	}

	#FCM后台推送相关
	function record_fcmlog($str_ret, $arr_data) {
		if ( !$str_ret or !$arr_data ) {
			$str_ret = "fcm ret is nil";
		}

		$path = "../log/";
		$name = $path . "fcm_" . date("Ymd") . ".log";

		$header = "\n\n\n[[-----------------" . date("Y-m-d h:i:s") . "----------------- ]]\n";
		$ret = json_decode( $str_ret, true );
		if ( is_array( $ret ) and isset($ret['results']) ) {
			foreach ($ret['results'] as $key => &$value) {
				$value['device'] = isset( $arr_data[$key] ) ? $arr_data[$key]['device'] : NULL;
			}
			$str_ret = json_encode($ret);
		}

		$content = $header . $str_ret . "\n";
		return file_put_contents($name, $content, FILE_APPEND);
	}

	function raw_sendFCM($title, $message, $tokens) {
		$url = 'https://fcm.googleapis.com/fcm/send';
	    $fields = array (
	            'registration_ids' => $tokens,

	            'data' => array (//android
	                    "message" => $message,
	                    "title" => $title,
	            ),

	           'notification' => array ( //IOS
	                    "body" => $message,
	                    "title"=> $title,
						"sound" => 'default',
	            ),
	    );
		$fields = json_encode ( $fields );
		$keyTemp = "AIzaSyC9X0xLqJqLlA9gYS-c1jRlDXH2axkuuV8";
		//var_dump($fields);
	    $headers = array (
	            'Authorization: key='.$keyTemp,
	            'Content-Type: application/json'
	    );
		
		//var_dump($headers);
		
    	$ch = curl_init ();
		// $proxy = "http://192.168.1.119:8118";
		// curl_setopt( $ch, CURLOPT_PROXY, $proxy);
	    curl_setopt ( $ch, CURLOPT_URL, $url );
		curl_setopt ( $ch, CURLOPT_TIMEOUT,10);
	    curl_setopt ( $ch, CURLOPT_POST, true );
	    curl_setopt ( $ch, CURLOPT_HTTPHEADER, $headers );
	    curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 ); //以字符流返回
	    curl_setopt ( $ch, CURLOPT_POSTFIELDS, $fields );
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
		$result = curl_exec ( $ch );
		$curl_errno = curl_errno($ch);
		curl_close ( $ch );	
		return $result;
	}

	//最多只能FCM_LIMIT_CNT个
	function sendFCM($title, $message, $data) {
		$tmp = array();
		$log = array();
		$cnt = 0;
		foreach ($data as $device => $token) {
			$cnt += 1;
			$index = floor($cnt / FCM_LIMIT_CNT);
			if ( !isset( $tmp[$index] ) ){
			 	$tmp[$index] = array();
			 	$log[$index] = array();
			}
			array_push($tmp[$index], $token);
			array_push($log[$index], array( 'device' => $device, 'token' => $token ));
		}

		$info = array();
		foreach ($tmp as $index => $tab) {
			$ret = raw_sendFCM($title, $message, $tab);
			record_fcmlog($ret, $log[$index]);
			array_push($info, $ret);
		}
		return $info;
	}

	function get_all_fcmdb($serverid = NULL) { //取所有数据
		global $WEB_DB;
		$db = new PMysql($WEB_DB);
		$sql = NULL;
		if ( $serverid ) {
			$sql = sprintf("select * from fcm_token where serverid = %d", $serverid);
		} else {
			$sql = "select * from fcm_token";
		}
		return $db->query($sql);
	}

	function get_part_fcmdb($devices, $serverid = NULL) { //取指定设备数据
		global $WEB_DB;
		$db = new PMysql($WEB_DB);
		$str = NULL;
		foreach($devices as $v) {
			$v = "'" . $v . "'";
			if ( $str == NULL ) {
				$str = $v;
			} else {
				$str .= "," . $v;	
			}
		}
		if ( $str ) {
			$sql = NULL;
			if ( $serverid ) {
				$sql = sprintf("select * from fcm_token where device in (%s) and serverid = %d", $str, $serverid);
			} else {
				$sql = sprintf("select * from fcm_token where device in (%s)", $str); // 防止‘被转义,放在外围
			}
			return $db->query($sql);
		}
	}

	function remove_token($tokens) {
		global $WEB_DB;
		$db = new PMysql($WEB_DB);
		$str = NULL;
		foreach($tokens as $v) {
			$v = "'" . $v . "'";
			if ( $str == NULL ) {
				$str = $v;
			} 
			else {
				$str .= "," . $v;	
			}
		}
		if ( $str ) {
			$sql="delete from fcm_token where token in (%s)";
			$sql = sprintf($sql, $str); //防止‘被转义,放在外围
			return $db->query($sql);
		}
	}

?>