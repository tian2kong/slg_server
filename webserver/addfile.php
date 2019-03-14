<?php
	require __DIR__ . '/vendor/autoload.php';
	use \Firebase\JWT\JWT;
	/** 
	 * Get hearder Authorization
	 * */
	function getAuthorizationHeader(){
	        $headers = null;
	        if (isset($_SERVER['Authorization'])) {
	            $headers = trim($_SERVER["Authorization"]);
	        }
	        else if (isset($_SERVER['HTTP_AUTHORIZATION'])) { //Nginx or fast CGI
	            $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
	        } elseif (function_exists('apache_request_headers')) {
	            $requestHeaders = apache_request_headers();
	            // Server-side fix for bug in old Android versions (a nice side-effect of this fix means we don't care about capitalization for Authorization)
	            $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
	            //print_r($requestHeaders);
	            if (isset($requestHeaders['Authorization'])) {
	                $headers = trim($requestHeaders['Authorization']);
	            }
	        }
	        return $headers;
	    }
	/**
	 * get access token from header
	 * */
	function getBearerToken() {
	    $headers = getAuthorizationHeader();
	    // HEADER: Get the access token from the header
	    if (!empty($headers)) {
	        if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
	            return $matches[1];
	        }
	    }
	    return null;
	}


	$jwt = getAuthorizationHeader();
	$secretKey = "example_key";
    if ($jwt) {
        try {                
            $token = JWT::decode($jwt, $secretKey, array('HS256'));
    		$filedata = file_get_contents('php://input');
            if (strlen($filedata) > 128 * 1024) 
			{
				echo "Invalid file";
				return;
			}

			$key = $token->jti;
			$serverid = $token->iss;
			$filetype = $_GET['filetype'];
			$filedir=sprintf('./%d', $serverid);
			is_dir($filedir) || @mkdir($filedir) || die("Can't Create folder");
			if($filetype == "image") {
				$filepath=sprintf('./%d/%d.png', $serverid, $key);
			} else {
				$filepath=sprintf('./%d/%d.amr', $serverid, $key);
			}

			echo file_put_contents($filepath, $filedata);
        } catch (Exception $e) {
            /*
             * the token was not able to be decoded.
             * this is likely because the signature was not able to be verified (tampered token)
             */
            echo 'HTTP/1.0 401 Unauthorized';
        }
    } else {
        /*
         * No token was able to be extracted from the authorization header
         */
        echo 'HTTP/1.0 400 Bad Request';
    }
?>


