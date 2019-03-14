-- ----------------------------
-- Procedure structure for OA_SP_UPDATEPLAYERID
-- ----------------------------
DROP PROCEDURE IF EXISTS `OA_SP_COPYPLAYER`;
DELIMITER ;;
CREATE PROCEDURE `OA_SP_COPYPLAYER`()
begin

  DECLARE done INT DEFAULT 0;
  DECLARE maxid INT DEFAULT 0;
  DECLARE tablename CHAR(255);
  DECLARE CursorSegment CURSOR FOR select table_name from information_schema.columns where table_schema in (select database()) and column_name='playerid' and (column_key='pri' or table_name='account');
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  select max(playerid) from account into maxid;
  set @tempid = maxid;
  OPEN CursorSegment;
  REPEAT
    FETCH CursorSegment INTO tablename;
    IF NOT done THEN
		set @sql1 = 'drop table if exists temp;';
		prepare stmt_p from @sql1;
		execute stmt_p;
		set @sql1 = concat('create table temp as (select * from ', tablename, ');');
		prepare stmt_p from @sql1;
		execute stmt_p;
		set @sql1 = concat('update temp set playerid = playerid + ', @tempid, ';');
		prepare stmt_p from @sql1;
		execute stmt_p;
		IF tablename = 'account' or tablename = 'player' THEN
			set @sql1 = concat('update temp set account = concat(account, playerid);');
			prepare stmt_p from @sql1;
			execute stmt_p;
			IF tablename = 'player' THEN
				set @sql1 = concat('update temp set name = concat(name, playerid);');
				prepare stmt_p from @sql1;
				execute stmt_p;
			END IF;
		END IF;
		set @sql1 = concat('insert into `', tablename, '` select * from temp;');
		prepare stmt_p from @sql1;
		execute stmt_p;
		set @sql1 = 'drop table temp;';
		prepare stmt_p from @sql1;
		execute stmt_p;
    END IF;
  UNTIL done END REPEAT;
  CLOSE CursorSegment;

end;;
DELIMITER ;

call OA_SP_COPYPLAYER();
