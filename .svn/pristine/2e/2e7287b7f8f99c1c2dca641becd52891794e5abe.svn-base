<?php

	require __DIR__ . '/vendor/autoload.php';
	use \Firebase\JWT\JWT;

	$secretKey = "example_key";
	$issuedAt   = time();
    $expire     = $issuedAt + 60;   
    $key 		= $_GET['key'];
    $serverid	= $_GET['serverid'];
	$token = array(
	    "iss" => $serverid,
	    "aud" => "http://example.com",
	    "iat" => $issuedAt,
	    "exp" => $expire,
	    "jti" => $key          // Json Token Id: an unique identifier for the token
	);

	/**
	 * IMPORTANT:
	 * You must specify supported algorithms for your application. See
	 * https://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms-40
	 * for a list of spec-compliant algorithms.
	 */
	$jwt = JWT::encode($token, $secretKey);
	echo $jwt;
	return;
?>

