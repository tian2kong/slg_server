<?php
	include_once "redis.php";
	function opstring($value) {
		if (gettype($value) == "string") {
			return "'" . $value . "'";
		} else {
			return $value;
		}
	}

	class PMysql {
		var $conn;

		function __construct($conf) {
			$this->conn = mysqli_connect($conf["host"], $conf["user"], $conf["password"]);
			if (!$this->conn) {
				die("connect mysql error : " . mysqli_connect_error());
			}
			mysqli_set_charset($this->conn,"utf8");
			mysqli_select_db($this->conn, $conf["dbname"]);
			if (mysqli_errno($this->conn)) { 
			    die("mysql error: " . mysqli_error($this->conn)); 
			}
		}

		function __destruct() {
			mysqli_close($this->conn);
		}

		function query($sql, ...$args) {
			if ( !empty($args) ) {
				foreach ($args as &$value) {//防注入
					$value = mysqli_real_escape_string($this->conn, $value);
				}
				$sql = sprintf($sql, ...$args);
			}
			//var_dump($sql);
			$result = mysqli_query($this->conn, $sql);
			if (mysqli_errno($this->conn)) { 
			    PRedis::ERROR("mysql query [" . $sql . "] error:" . mysqli_error($this->conn));
			    return false;
			}
			if (!$result or is_bool($result)) {
				return $result;
			}
			// 获取数据 
			$ret = mysqli_fetch_all($result,MYSQLI_ASSOC); 

			mysqli_free_result($result);

			return $ret;
		}

		function insert($arr, $tb) {
			$sql = "insert into `" . $tb . "`(";
			foreach ($arr as $key => $value) {
				$sql = $sql . $key . ",";
			}
			$sql[strlen($sql) - 1] = ")";
			$sql = $sql . "values(";
			foreach ($arr as $key => $value) {
				$sql = $sql . opstring($value) . ",";
			}
			$sql[strlen($sql) - 1] = ");";
			return $this->query($sql);
		}

		
		function update($tb, $dbkey, $dbfield) {
			$sql = "update " . $tb . " set ";
			$first = true;
			foreach ($dbfield as $key => $value) {
				if (!$first) {
					$sql = $sql . ", ";
				}
				$sql = $sql . $key . " = " . opstring($value);
				$first = false;
			}
			if ($dbkey) {
				$sql = $sql . " where ";
				$first = true;
				foreach ($dbkey as $key => $value) {
					if (!$first) {
						$sql = $sql . " and ";
					}
					$sql = $sql . $key . " = " . opstring($value);
					$first = false;
				}
			}
			return $this->query($sql);
		}
 	};
?>