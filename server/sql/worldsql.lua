local globalsql = {} -- version -> sql

globalsql[1] = [[
--
-- Table structure for table `worldversion`
--
DROP TABLE IF EXISTS `worldversion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `worldversion` (
  `version_number` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`version_number`)
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
  `serverid` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`playerid`),
  KEY `account` (`account`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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


]]

return globalsql