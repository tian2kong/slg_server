<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	include_once "servermgr.php";
	$TID 		= isset($_GET["TID"]) ? $_GET["TID"] : NULL;
	$TID_PARAM 	= isset($_GET["TID_PARAM"]) ? $_GET['TID_PARAM'] : NULL;
	$SERVERS 	= isset($_GET["SERVERS"]) ? json_decode($_GET['SERVERS'], true) : NULL;
	$TEXT 		= isset($_GET["TEXT"]) ? $_GET["TEXT"] : NULL;
	$TIME_DELAY = isset($_GET["TIME_DELAY"]) ? $_GET["TIME_DELAY"] : NULL;

	if ( empty($SERVERS) or ( !$TID and !$TEXT ) ) { 
		die("gm_zmd error SERVERS = " . $SERVERS . $TID . $TEXT);
	}

	$param = array(
			"SERVERS" => $SERVERS,
			"TEXT" => $TEXT,
			"TID" => $TID,
			"TID_PARAM" => $TID_PARAM,
		);

	GM_ZMD($param);
?>	