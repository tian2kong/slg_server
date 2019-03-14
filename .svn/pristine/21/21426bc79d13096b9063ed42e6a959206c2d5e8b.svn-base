<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	$key 		= $_GET['key'];
    $serverid	= $_GET['serverid'];

    $filedir=sprintf('./%d/%d.png', $serverid, $key);
	echo unlink($filedir);
?>