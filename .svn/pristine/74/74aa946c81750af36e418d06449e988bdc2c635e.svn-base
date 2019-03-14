<?php 
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);

	$serverid = $_GET['serverid'];
	$key = $_GET['key'];
	$filetype = $_GET['filetype'];
	if($filetype == "image") {
		$filepath=sprintf('./%d/%d.png', $serverid, $key);
	} else {
		$filepath=sprintf('./%d/%d.amr', $serverid, $key);
	}

	$image = file_get_contents($filepath);
	
	echo $image;
	return;
?>