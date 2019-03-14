<?php
	ini_set("display_errors", "On");
	error_reporting(E_ALL | E_STRICT);
	
	#上传玩家数据
	include_once "servermgr.php";

	$record = array();
	if (isset($_GET['device'])) {
		$record['device'] = $_GET['device'];
	}
	if (isset($_GET['step'])) {
		$record['step'] = $_GET['step'];
	}
	if (isset($_GET['playid'])) {
		$record['playid'] = $_GET['playid'];
	}
	if (isset($_GET['serverid'])) {
		$record['serverid'] = $_GET['serverid'];
	}
	if (isset($_GET['openid'])) {
		$record['openid'] = $_GET['openid'];
	}
	if (isset($_GET['deviceinfo'])) {
		$record['deviceinfo'] = $_GET['deviceinfo'];
	}
	if (isset($_GET['platform'])) {
		$record['platform'] = $_GET['platform'];
	}
	date_default_timezone_set('UTC');
	$record['time'] = date('Y-m-d H:i:s', time());

	$db = new PMysql($WEB_DB);
	$tbname = substr($record['time'], 0, 10);
	$tbname .= "-loginlog";
	$sql = sprintf("
		-- ----------------------------
		-- Table structure for loginlog
		-- ----------------------------
		CREATE TABLE IF NOT EXISTS `%s` (
		  `id` int(11) NOT NULL AUTO_INCREMENT,
		  `serverid` int(11) NOT NULL DEFAULT '0',
		  `step` int(11) NOT NULL DEFAULT '0',
		  `playid` int(11) unsigned NOT NULL DEFAULT '0',
		  `device` char(255) COLLATE utf8_unicode_ci DEFAULT '',
		  `openid` char(255) COLLATE utf8_unicode_ci DEFAULT '',
		  `deviceinfo` char(255) COLLATE utf8_unicode_ci DEFAULT '',
		  `platform` int(11) NOT NULL DEFAULT '0',
		  `time` datetime DEFAULT NULL,
		  PRIMARY KEY (`id`), KEY `step` (`step`), KEY `device` (`device`), KEY `openid` (`openid`)
		) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
	", $tbname);
	$db->query($sql);
	$result = $db->insert($record, $tbname);


	if ($record['step'] == 1 and !PRedis::iskey(SETUP, $record['device'])) {
		$setup = array(
			'device'=>$record['device'], 
			'time'=>$record['time'], 
		);
		if (isset($_GET['openid'])) {
			$setup['openid'] = $_GET['openid'];
		}
		if (isset($_GET['deviceinfo'])) {
			$setup['deviceinfo'] = $_GET['deviceinfo'];
		}
		PRedis::addkey(SETUP, $record['device']);
		$result = $db->insert($setup, "setup");
	}
?>