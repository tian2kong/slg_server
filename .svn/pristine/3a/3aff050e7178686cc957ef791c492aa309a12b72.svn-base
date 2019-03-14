<?php
	include_once "baidu_transapi.php";

	$BAIDU_TOKEN = array(
			1 => "en",
			2 => "zh",
		);

	$GOOGLE_TOKEN = array(
		);

	$TOKEN = $BAIDU_TOKEN; //默认百度API todox 写个宏定义开关

	$src = isset($_GET['text']) ? $_GET['text'] : NULL;
	$index  = isset($_GET['language']) ? $_GET['language'] : 2; //默认英文
	$to = $TOKEN[$index] ? $TOKEN[$index] : $TOKEN[1];

	$tmp = translate($src, "auto", $to);
	$ret = array();
	if ( $tmp ) {
		$ret["from"] = $tmp["from"];
		$ret["to"] = $tmp["to"];
		$ret["text"] = $tmp["trans_result"] ? $tmp["trans_result"][0]["dst"] : $src;
	}
	echo urldecode(json_encode($ret));
?>