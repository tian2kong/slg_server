<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	include_once "common.php";
	include_once "mysql.php";

	// $ENUM_CODE = array (
	// 		0 => "suc",
	// 		1 => "error_param",
	// 		2 => "too_short", //文本太少
	//		3 => "too_long", 
	//  	4 => "unknown",
	// 	);

	// $ENUM_QATYPE = array(  //QATYPE 类型
	// 		1 => "login",
	// 		2 => "charge",
	// 		3 => "account",
	// 		4 => "default",
	// 		5 => "advice",
	// 	);


	$ENUM_SOURCE_TYPE = array( //反馈来源
			"client" => 1, 
			"web" => 2,
		);

	$CODE = 0;
	$CONTENT = isset( $_GET["CONTENT"] ) ? $_GET["CONTENT"] : NULL;
	$ACCOUNT = isset( $_GET["ACCOUNT"] ) ? $_GET["ACCOUNT"] : NULL; 
	$QATYPE = isset( $_GET["QATYPE"] ) ? $_GET["QATYPE"] : 4;
	$SERVERID = isset( $_GET["SERVERID"] ) ? $_GET["SERVERID"] : 0;
	$SOURCETYPE = isset( $_GET["SOURCETYPE"] ) ? $_GET["SOURCETYPE"] : $ENUM_SOURCE_TYPE['client'];

	do {
		if ( !$ACCOUNT or !$CONTENT ) {
			$CODE = 1;
			break;
		}

		
		$len = strlen($CONTENT);
		if ( $len < 30 ) {
			$CODE = 2;
			break;
		}

		if ( $len > 2048 ) {
			$CODE = 3;
			break;
		}

		global $WEB_DB;
		$db = new PMysql($WEB_DB);
		$sel_maxid_sql = "select max(id), min(time) from feedback where account = '%s'";
		$result = $db->query($sel_maxid_sql, $ACCOUNT);
		if ( !isset( $result ) or empty($result[0])) {
			$CODE = 4;
			break;
		}

		$result = $result[0];
		$maxid = isset( $result["max(id)"] ) ? $result["max(id)"] : 0;
		$maxtime = isset( $result["max(time)"] ) ? $result["max(time)"] : 0;

		$next_id =$maxid + 1;
		$time = time();

		$ins_sql = "replace into feedback(account, id, qatype, serverid, content, time, status, sourcetype) values('%s', %d, %d, %d, '%s', %d, %d, %d)";
	    $db->query($ins_sql, $ACCOUNT, $next_id, $QATYPE, $SERVERID, $CONTENT, $time, 0, $SOURCETYPE); // status = 0:未答复
	} while (false);

	$ret = array(
				"CODE" => $CODE,	
			);
	echo json_encode($ret);
?>