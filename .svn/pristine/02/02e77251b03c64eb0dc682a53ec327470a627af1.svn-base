<?php 
	include_once "config.php";
	
	$redis = new Redis();
	$redis->connect($REDIS_CONFIG["host"], $REDIS_CONFIG["port"]);

	$redis->ping();

	function set_key_expire($key, $expire) {
		global $redis;
		if ($expire > 0) {
			$redis->setTimeout($key, $expire);
		}
	}

	class PRedis {
		#清空整个redis
		static function flushAll() {
			global $redis;
			$redis->flushAll();
		}

		#删除
		static function deletekey($field) {
			global $redis;
			$redis->delete($field);
		}
		
		#存储array(hash)
		static function setarray($field, $arr, $expire = 0) {
			global $redis;
			foreach ($arr as $key => $value) {
				$redis->hSet($field, $key, $value);
			}

			set_key_expire($field, $expire);
		}
		#获取一个array(hash)
		static function getarray($field) {
			global $redis;

			$ret = $redis->hGetAll($field);

			return $ret;
		}
		
		#获取一个array(hash)
		static function getarrayvalue($field, $key) {
			global $redis;

			$ret = $redis->hGet($field, $key);

			return $ret;
		}


		#存储一个数组array(list)
		static function setlist($field, $arr, $expire = 0) {
			global $redis;

			$len = count($arr);
			for ($i=0; $i<$len; $i++) {
				$redis->lPush($field, $arr[$i]);
			}

			set_key_expire($field, $expire);
		}
		#获取一个数组array(list)
		static function getlist($field) {
			global $redis;

			return $redis->lRange($field, 0, -1);
		}

		#存字符串
		static function setstring($field, $str, $expire = 0) {
			global $redis;

			$redis->set($field, $str);

			set_key_expire($field, $expire);
		}
		#取字符串
		static function getstring($field) {
			global $redis;

			return $redis->get($field);
		}


		#redis set操作
		static function addkey($field, $key) {
			global $redis;
			
			return $redis->sAdd($field, $key);
		}
		static function iskey($field, $key) {
			global $redis;

			return $redis->sIsMember($field, $key);
		}
		static function removekey($field, $key) {
			global $redis;

			return $redis->sRem($field, $key);
		}
		static function getallkey($field) {
			global $redis;

			return $redis->sMembers($field);
		}

		
		#错误日志
		static function ERROR($str) {
			date_default_timezone_set('UTC');
			$timestr = date('[Y-m-d H:i:s] ', time());
			$str = $timestr . $str;
			PRedis::setlist(LOG, array($str));
		}
		#显示日志
		static function showlog() {
			$arr = PRedis::getlist(LOG);
			for ($i=0; $i<count($arr); $i++) {
				echo $arr[$i] . '<br>';
			}
		}
		static function clearlog() {
			global $redis;
			
			$redis->delete(LOG);
		}
	};
?>