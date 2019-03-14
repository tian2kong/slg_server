-- ----------------------------
-- Table structure for charge_dh
-- ----------------------------
DROP TABLE IF EXISTS `charge_dh`;
CREATE TABLE `charge_dh` (
  `serverid` int(10) unsigned NOT NULL DEFAULT '0', 
  `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
  `account` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `device` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `orderId` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `productId` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `purchaseTime` datetime DEFAULT NULL,
  `status` int(10) unsigned NOT NULL DEFAULT '0', 
  `tester` int(10) unsigned NOT NULL DEFAULT '0',
  `platform` char(64) COLLATE utf8_unicode_ci DEFAULT '',
  PRIMARY KEY (`platform`, `orderId`), KEY `player` (`serverid`, `playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- ----------------------------
-- Table structure for charge_tester
-- ----------------------------
DROP TABLE IF EXISTS `charge_tester`;
CREATE TABLE `charge_tester` (
  `device` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  PRIMARY KEY (`device`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- ----------------------------
-- Table structure for webaccount
-- ----------------------------
DROP TABLE IF EXISTS `webaccount`;
CREATE TABLE `webaccount` (
  `uid` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `device` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `googleplay` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `gamecenter` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `facebook` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `lastdevice` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `feiyu` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `subplatform` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  PRIMARY KEY (`uid`), KEY `device` (`device`), KEY `googleplay` (`googleplay`), KEY `gamecenter` (`gamecenter`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- ----------------------------
-- Table structure for loginlog
-- ----------------------------
DROP TABLE IF EXISTS `loginlog`;
CREATE TABLE `loginlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serverid` int(11) NOT NULL DEFAULT "0",
  `step` int(11) NOT NULL DEFAULT "0",
  `playid` int(11) unsigned NOT NULL DEFAULT "0",
  `device` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `openid` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `deviceinfo` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `time` datetime DEFAULT NULL,
  `platform` int(11) NOT NULL DEFAULT "0",
  PRIMARY KEY (`id`), KEY `step` (`step`), KEY `device` (`device`), KEY `openid` (`openid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- ----------------------------
-- Table structure for setup
-- ----------------------------
DROP TABLE IF EXISTS `setup`;
CREATE TABLE `setup` (
  `device` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `openid` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `deviceinfo` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `platform` int(11) NOT NULL DEFAULT "0",
  `time` datetime DEFAULT NULL,
  PRIMARY KEY (`device`), KEY `openid` (`openid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `sc_partition_server`;
CREATE TABLE `sc_partition_server` (
  `client_version` int(11) DEFAULT '0',
  `http_port` int(11) DEFAULT NULL,
  `serverid` int(11) NOT NULL AUTO_INCREMENT,
  `ls_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'LOGIN_SERVER',
  `ls_port` int(11) DEFAULT NULL,
  `ls_network_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ls_network_port` int(11) DEFAULT NULL,
  `gs_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'GAME_SERVER',
  `gs_port` int(11) DEFAULT NULL,
  `gs_network_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gs_network_port` int(11) DEFAULT NULL,
  `dbc_player_host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'PLAYER_DB',
  `dbc_player_port` int(11) DEFAULT NULL,
  `dbc_player_dbname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dbc_player_user` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dbc_player_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gl_host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'GAME_LOG',
  `gl_port` int(11) DEFAULT NULL,
  `gl_dbname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gl_user` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gl_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `debug_port` int(11) DEFAULT NULL,
  `dbc_global_host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'GLOBAL_SERVER',
  `dbc_global_port` int(11) DEFAULT NULL,
  `dbc_global_dbname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dbc_global_user` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dbc_global_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `server_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `newtag` int(11) DEFAULT '0',
  `status` int(11) DEFAULT '0',
  `groupid` int(11) DEFAULT '0',
  `groupname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `new_acc_default` int(11) DEFAULT '0',
  `http_host` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `gmt` int(11) DEFAULT '0',
  `question` int(11) DEFAULT '0',
  PRIMARY KEY (`serverid`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Table structure for game_config
-- ----------------------------
DROP TABLE IF EXISTS `game_config`;
CREATE TABLE `game_config` (
  `serverid` int(11) NOT NULL AUTO_INCREMENT,
  `data` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`serverid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Table structure for world_config
-- ----------------------------
DROP TABLE IF EXISTS `world_config`;
CREATE TABLE `world_config` (
  `worldid` int(11) NOT NULL AUTO_INCREMENT,
  `data` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`worldid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- ----------------------------
-- Table structure for feedback
-- ----------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `account` char(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `id` int(10) unsigned NOT NULL DEFAULT '0',
  `serverid` int(10) unsigned NOT NULL DEFAULT '0',
  `qatype` int(10) unsigned NOT NULL DEFAULT '0',
  `content` text COLLATE utf8_unicode_ci,
  `reply` text COLLATE utf8_unicode_ci,
  `time` int(10) unsigned NOT NULL DEFAULT '0',
  `status` int(10) unsigned NOT NULL DEFAULT '0',
  `sourcetype` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`account`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- ----------------------------
-- Table structure for fcm_token
-- ----------------------------
DROP TABLE IF EXISTS `fcm_token`;
CREATE TABLE `fcm_token` (
  `device` char(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `token` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  `language` char(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `serverid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`device`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;