<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	include_once "fcm_common.php";
	include_once "servermgr.php";

	$code = 0;
	do {
		$accounts = isset($_POST['accounts']) ? json_decode(urldecode( $_POST['accounts'] ), true) : NULL;
		$package = isset($_POST['package']) ? json_decode(urldecode( $_POST['package'] ), true) : NULL;
		$all = isset($_POST['allflag']) ? $_POST['allflag'] : NULL;
		$serverid = isset($_POST['serverid']) ? $_POST['serverid'] : NULL;

		if ( !$package ) {
			$code = 1;
			break;
		}
		$result = null;
		if ( $all ) {// 全服通知
			$result = get_all_fcmdb($serverid);
			// var_dump($result);
		} elseif ( !$all and !empty($accounts) ) {
			$infos = found_accounts($accounts, true);
			$devices = array();
			foreach ($infos as $data) {
				$dev = null;
				if ( !isset( $data['lastdevice'] ) or $data['lastdevice'] == '') { //最近登录设备字段有可能为空
					$dev = $data['device'];
				} else {
					$dev = $data['lastdevice'];
				}
				array_push($devices, $dev);
			}
			$result = get_part_fcmdb($devices, $serverid);
			// var_dump($devices);
			// var_dump($result);
		} else {
			$code = 2;
			break;
		}

		if ( empty($result) ) {
			$code = 3;
			break;
		}

		$tk_China = array();
		$tk_English = array();
		foreach ($result as $v) {
			$language = isset( $v["language"] ) ? $v["language"] : NULL ;
			if ( $language == $language_android_zh or //中文
				 $language == $language_ios_TWzh or 
				 $language == $language_ios_zh ) {
				$tk_China[$v['device']] = $v["token"];
			}
			else { //默认英文
				$tk_English[$v['device']] = $v["token"];
			}
		}

		if ( !empty($tk_China) and $package["TextCh"] ) { //发送
			$title = $package["NameCh"];
			$text = $package["TextCh"];
			sendFCM($title, $text, $tk_China);
		}

		if ( !empty($tk_English) and $package["TextEn"] ) {
			$title = $package["NameEn"];
			$text = $package["TextEn"];
			sendFCM($title, $text, $tk_English);
		}
	} while (false);
	echo $code;
?>