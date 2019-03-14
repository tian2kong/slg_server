local gamesql = {} -- version -> sql
gamesql[1] = [[
  --
  -- Table structure for table `player_charge`
  --
  DROP TABLE IF EXISTS `player_charge`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_charge` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `history` bigint(10) unsigned NOT NULL DEFAULT '0',
    `firstcharge` char(255) COLLATE utf8_unicode_ci DEFAULT '',
    `chargereward` char(255) COLLATE utf8_unicode_ci DEFAULT '',
    `activetimes` int(10) unsigned NOT NULL DEFAULT '0',
    `activegroup` int(10) unsigned NOT NULL DEFAULT '0',
    `activeindex` int(10) unsigned NOT NULL DEFAULT '0',
    `chargefund` char(255) COLLATE utf8_unicode_ci DEFAULT '',
    `promotionstatus` int(10) unsigned NOT NULL DEFAULT '0',
    `promotiontime` int(10) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player`
  --
  DROP TABLE IF EXISTS `player`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `account` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
    `exp` bigint(10) NOT NULL DEFAULT '0',
    `level` int(10) unsigned NOT NULL DEFAULT '0',
    `shape` int(10) unsigned NOT NULL DEFAULT '0',
    `name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
    `lastname` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
    `roleid` int(10) unsigned NOT NULL DEFAULT '0',
    `offlinetime` bigint(10) unsigned NOT NULL DEFAULT '0',
    `updatetime` bigint(10) unsigned NOT NULL DEFAULT '0',
    `createtime` bigint(10) unsigned NOT NULL DEFAULT '0',
    `online` int(10) unsigned NOT NULL DEFAULT '0',
    `logintime` bigint(10) unsigned NOT NULL DEFAULT '0',
    `loginIP` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
    `language` int(10) unsigned NOT NULL DEFAULT '0',
    `silence` int(10) unsigned NOT NULL DEFAULT '0',
    `viplevel` int(10) unsigned NOT NULL DEFAULT '0',
    `vipexp` int(10) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;

  
  --
  -- Table structure for table `player_storage`
  --
  DROP TABLE IF EXISTS `player_storage`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_storage` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `page` int(10) unsigned NOT NULL DEFAULT '0',
    `size` int(10) unsigned NOT NULL DEFAULT '0',
    `things` text COLLATE utf8_unicode_ci,
    PRIMARY KEY (`playerid`,`page`),
    KEY `player` (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player_thing_other`
  --
  DROP TABLE IF EXISTS `player_thing_other`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_thing_other` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `dailyitem` text COLLATE utf8_unicode_ci,
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player_tempbag`
  --
  DROP TABLE IF EXISTS `player_tempbag`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_tempbag` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `size` int(10) unsigned NOT NULL DEFAULT '0',
    `things` text COLLATE utf8_unicode_ci,
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player_taskbag`
  --
  DROP TABLE IF EXISTS `player_taskbag`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_taskbag` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `size` int(10) unsigned NOT NULL DEFAULT '0',
    `things` text COLLATE utf8_unicode_ci,
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player_clothes`
  --
  DROP TABLE IF EXISTS `player_clothes`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_clothes` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `size` int(10) unsigned NOT NULL DEFAULT '0',
    `things` text COLLATE utf8_unicode_ci,
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player_bag`
  --
  DROP TABLE IF EXISTS `player_bag`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_bag` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `size` int(10) unsigned NOT NULL DEFAULT '0',
    `things` text COLLATE utf8_unicode_ci,
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player_token`
  --
  DROP TABLE IF EXISTS `player_token`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_token` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `Food` bigint(10) unsigned NOT NULL DEFAULT '0',
    `Water` bigint(10) unsigned NOT NULL DEFAULT '0',
    `Iron` bigint(10) unsigned NOT NULL DEFAULT '0',
    `Gas` bigint(10) unsigned NOT NULL DEFAULT '0',
    `Money` bigint(10) unsigned NOT NULL DEFAULT '0',
    `BangGong` bigint(10) unsigned NOT NULL DEFAULT '0',
    `ArenaScore` bigint(10) unsigned NOT NULL DEFAULT '0',
    `SysMoney` bigint(10) unsigned NOT NULL DEFAULT '0',
    `SysFood` bigint(10) unsigned NOT NULL DEFAULT '0',
    `SysWater` bigint(10) unsigned NOT NULL DEFAULT '0',
    `SysIron` bigint(10) unsigned NOT NULL DEFAULT '0',
    `SysGas` bigint(10) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;

  --
  -- Table structure for table `player_thing`
  --
  DROP TABLE IF EXISTS `player_thing`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `player_thing` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `cfgid` int(10) unsigned NOT NULL DEFAULT '0',
    `amount` int(10) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`playerid`,`cfgid`),
    KEY `player` (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `gameversion`
  --
  DROP TABLE IF EXISTS `gameversion`;
  /*!40101 SET @saved_cs_client     = @@character_set_client */;
  /*!40101 SET character_set_client = utf8 */;
  CREATE TABLE `gameversion` (
    `version_number` int(11) NOT NULL DEFAULT '0',
    PRIMARY KEY (`version_number`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
  /*!40101 SET character_set_client = @saved_cs_client */;


  --
  -- Table structure for table `player_shop`
  --
  DROP TABLE IF EXISTS `player_shop`;
  CREATE TABLE `player_shop` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `buytimes` text COLLATE utf8_unicode_ci DEFAULT "",
    `treasurekey` char(255) COLLATE utf8_unicode_ci DEFAULT "",
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


  --
  -- Table structure for table `player_title`
  --
  DROP TABLE IF EXISTS `player_title`;
  CREATE TABLE `player_title` (
    `playerid` int(10) unsigned NOT NULL DEFAULT '0',
    `curtitleid` char(255) COLLATE utf8_unicode_ci DEFAULT "",
    `prevtitle` char(255) COLLATE utf8_unicode_ci DEFAULT "",
    `activetitle` char(255) COLLATE utf8_unicode_ci DEFAULT "",
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

  --
  -- Table structure for table `player_city`
  --
  DROP TABLE IF EXISTS `player_city`;
  CREATE TABLE `player_city` (
    `playerid` int(10) unsigned NOT NULL DEFAULT '0',
    `land` char(255) COLLATE utf8_unicode_ci DEFAULT "",
    `buildqueue` char(255) COLLATE utf8_unicode_ci DEFAULT "",
    PRIMARY KEY (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

  --
  -- Table structure for table `player_facility`
  --
  DROP TABLE IF EXISTS `player_facility`;
  CREATE TABLE `player_facility` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `facilityid` int(10) unsigned NOT NULL DEFAULT '0',
    `type` int(10) unsigned NOT NULL DEFAULT '0',
    `level` int(10) unsigned NOT NULL DEFAULT '0',
    `origin_x` int(10) unsigned NOT NULL DEFAULT '0',
    `origin_y` int(10) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`playerid`,`facilityid`), KEY `playerid` (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

  --
  -- Table structure for table `title`
  --
  DROP TABLE IF EXISTS `title`;
  CREATE TABLE `title` (
    `playerid` bigint(10) unsigned NOT NULL DEFAULT '0',
    `id` int(10) unsigned NOT NULL DEFAULT '0',
    `time` int(10) unsigned NOT NULL DEFAULT '0',
    `param` char(255) COLLATE utf8_unicode_ci DEFAULT '',
    PRIMARY KEY (`playerid`,`id`), KEY `playerid` (`playerid`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
]]

return gamesql