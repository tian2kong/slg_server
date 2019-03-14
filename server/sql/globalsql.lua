 globalsql = {} -- version -> sql

globalsql[1] = [[
--
-- Table structure for table `systemtime`
--
DROP TABLE IF EXISTS `systemtime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `systemtime` (
  `id` int(10) unsigned NOT NULL DEFAULT '0',
  `time` bigint(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `globaldata`
--
DROP TABLE IF EXISTS `globaldata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `globaldata` (
  `id` int(10) unsigned NOT NULL DEFAULT '0',
  `opensertime` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account`
--
DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `account` char(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `playerid` int(10) unsigned NOT NULL DEFAULT '0',
  `gm` int(10) unsigned NOT NULL DEFAULT '0',
  `invatecode` char(255) COLLATE utf8_unicode_ci DEFAULT '',
  PRIMARY KEY (`playerid`),
  KEY `account` (`account`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `globalversion`
--
DROP TABLE IF EXISTS `globalversion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `globalversion` (
  `version_number` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`version_number`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `mail`
--
DROP TABLE IF EXISTS `mail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail` (
  `playerid` int(10) unsigned NOT NULL DEFAULT '0',
  `id` int(10) unsigned NOT NULL DEFAULT '0',
  `mailid` int(10) unsigned NOT NULL DEFAULT '0',
  `mailtype` int(10) unsigned NOT NULL DEFAULT '0',
  `params` text COLLATE utf8_unicode_ci,
  `tokens` char(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `things` char(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `open` int(10) unsigned NOT NULL DEFAULT '0',
  `sendtime` bigint(10) unsigned NOT NULL DEFAULT '0',
  `expire` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`playerid`,`id`),
  KEY `player` (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `mail_ids`
--
DROP TABLE IF EXISTS `mail_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_ids` (
  `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
  `mailid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chatrecord`
--
DROP TABLE IF EXISTS `chatrecord`;
CREATE TABLE `chatrecord` (
  `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
  `ckey` int(10) unsigned NOT NULL DEFAULT '0',
  `chatrecord` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`playerid`, `ckey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `mapplayerobject`
--
DROP TABLE IF EXISTS `mapplayerobject`;
CREATE TABLE `mapplayerobject` (
  `objectid` bigint(10) unsigned NOT NULL DEFAULT '0',
  `playerid` int(10) unsigned NOT NULL DEFAULT '0',
  `level` int(10) unsigned NOT NULL DEFAULT '0',
  `x` int(10) unsigned NOT NULL DEFAULT '0',
  `y` int(10) unsigned NOT NULL DEFAULT '0',
  `name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `mapresourceobject`
--
DROP TABLE IF EXISTS `mapresourceobject`;
CREATE TABLE `mapresourceobject` (
  `objectid` bigint(10) unsigned NOT NULL DEFAULT '0',
  `level` int(10) unsigned NOT NULL DEFAULT '0',
  `type` int(10) unsigned NOT NULL DEFAULT '0',
  `reserves` int(10) unsigned NOT NULL DEFAULT '0',
  `x` int(10) unsigned NOT NULL DEFAULT '0',
  `y` int(10) unsigned NOT NULL DEFAULT '0',
  `occupymarchid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `mapmonsterobject`
--
DROP TABLE IF EXISTS `mapmonsterobject`;
CREATE TABLE `mapmonsterobject` (
  `objectid` bigint(10) unsigned NOT NULL DEFAULT '0',
  `level` int(10) unsigned NOT NULL DEFAULT '0',
  `type` int(10) unsigned NOT NULL DEFAULT '0',
  `x` int(10) unsigned NOT NULL DEFAULT '0',
  `y` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`objectid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for table `mapmarch`
--
DROP TABLE IF EXISTS `mapmarch`;
CREATE TABLE `mapmarch` (
  `marchid` bigint(10) unsigned NOT NULL DEFAULT '0',
  `marchtype` int(10) unsigned NOT NULL DEFAULT '0',
  `status` int(10) unsigned NOT NULL DEFAULT '0',
  `startx` int(10) unsigned NOT NULL DEFAULT '0',
  `starty` int(10) unsigned NOT NULL DEFAULT '0',
  `endx` int(10) unsigned NOT NULL DEFAULT '0',
  `endy` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` int(10) unsigned NOT NULL DEFAULT '0',
  `endtime` int(10) unsigned NOT NULL DEFAULT '0',
  `name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `marchnode` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `collectnode` text COLLATE utf8_unicode_ci,
  `param` text COLLATE utf8_unicode_ci,
  `army` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`marchid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

]]

return globalsql