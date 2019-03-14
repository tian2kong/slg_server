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

	$CODE = 0;
	$INFO = array();
	$ACCOUNT = isset( $_GET["ACCOUNT"] ) ? $_GET["ACCOUNT"] : NULL; 
	do {
		if ( !$ACCOUNT  ) {
			$CODE = 1;
			break;
		}

		global $WEB_DB;
		$db = new PMysql($WEB_DB);
		$sel_maxid_sql = "select * from feedback where account = '%s' order by time desc limit 0, 30";
		$result = $db->query($sel_maxid_sql, $ACCOUNT);
		if ( !isset( $result ) ) {
			$CODE = 4;
			break;
		}

		foreach ($result as $record) {
			$tmp = array(
					"TIME" => $record["time"],
					"QATYPE" => $record["qatype"],
					"SERVERID" => $record["serverid"],
					"REPLY" => $record["reply"],
					"STATUS" => $record["status"],
					"CONTENT" => $record["content"],
					"SOURCETYPE" => $record["sourcetype"]
				);

			array_push($INFO, $tmp);
		}

	} while (false);
	$ret = array(
			"CODE" => $CODE,
			"INFO" => $INFO,
		);
	echo json_encode($ret);
?>