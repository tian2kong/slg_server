<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	include_once "fcm_common.php";
	$code = 0; 
	do {
		$device = NULL;
		if ( isset($_GET['d_ios_id']) ) { 
			$device = isset($_GET['d_ios_id']) ? $_GET['d_ios_id'] : NULL;
		} 
		elseif ( isset($_GET['d_android_id']) ) {
			$device = isset($_GET['d_android_id']) ? $_GET['d_android_id'] : NULL;
		}

		if ( !$device ) {
			$code = 1;
			break;
		}

		unregister_token($device);
	} while (false);

	echo $code;
?>