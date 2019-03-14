local sql = {}

sql["object"] = [[
CREATE TABLE IF NOT EXISTS `%s` (
  `autoid` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `time` datetime DEFAULT NULL,
  `accounts` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `userid` bigint(10) unsigned NOT NULL DEFAULT '0', 
  `uuid` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `level` int(10) unsigned NOT NULL DEFAULT '0', 
  `town_level` int(10) unsigned NOT NULL DEFAULT '0', 
  `object_type` int(10) unsigned NOT NULL DEFAULT '0', 
  `object_id` int(10) unsigned NOT NULL DEFAULT '0', 
  `object_name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `change_type` int(10) unsigned NOT NULL DEFAULT '0', 
  `change_num` int(10) unsigned NOT NULL DEFAULT '0', 
  `left_num` int(10) unsigned NOT NULL DEFAULT '0', 
  `action_id` int(10) unsigned NOT NULL DEFAULT '0', 
  `action_name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_int1` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int2` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int3` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int4` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int5` int(10) unsigned NOT NULL DEFAULT '0',
  `para_str1` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str2` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str3` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str4` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str5` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bind_info` int(10) unsigned NOT NULL DEFAULT '0', 
  `job` int(10) unsigned NOT NULL DEFAULT '0', 
  `equip_value` int(10) unsigned NOT NULL DEFAULT '0', 
  `speed` int(10) unsigned NOT NULL DEFAULT '0', 
  `pet_type` int(10) unsigned NOT NULL DEFAULT '0', 
  `pet_value` int(10) unsigned NOT NULL DEFAULT '0', 
  PRIMARY KEY (`autoid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
]]

sql["event"] = [[
CREATE TABLE IF NOT EXISTS `%s` (
  `autoid` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `time` datetime DEFAULT NULL,
  `accounts` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` bigint(10) unsigned NOT NULL DEFAULT '0', 
  `server_id` bigint(10) unsigned NOT NULL DEFAULT '0', 
  `name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `level` int(10) unsigned NOT NULL DEFAULT '0', 
  `town_level` int(10) unsigned NOT NULL DEFAULT '0', 
  `event_type` int(10) unsigned NOT NULL DEFAULT '0', 
  `action_type_name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_id` int(10) unsigned NOT NULL DEFAULT '0', 
  `action_name` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_int1` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int2` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int3` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int4` int(10) unsigned NOT NULL DEFAULT '0', 
  `para_int5` int(10) unsigned NOT NULL DEFAULT '0',
  `para_str1` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str2` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str3` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str4` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `para_str5` char(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `job` int(10) unsigned NOT NULL DEFAULT '0', 
  `equip_value` int(10) unsigned NOT NULL DEFAULT '0', 
  `speed` int(10) unsigned NOT NULL DEFAULT '0', 
  `pet_type` int(10) unsigned NOT NULL DEFAULT '0', 
  `pet_value` int(10) unsigned NOT NULL DEFAULT '0', 
  PRIMARY KEY (`autoid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
]]

return sql