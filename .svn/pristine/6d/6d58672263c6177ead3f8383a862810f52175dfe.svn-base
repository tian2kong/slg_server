<?php
/***************************************************************************

 * Copyright (c) 2015 Baidu.com, Inc. All Rights Reserved
 * 
**************************************************************************/



/**
 * @file baidu_transapi.php 
 * @author mouyantao(mouyantao@baidu.com)
 * @date 2015/06/23 14:32:18
 * @brief 
 *  
 **/
 
// zh	中文
// en	英语
// yue	粤语
// wyw	文言文
// jp	日语
// kor	韩语
// fra	法语
// spa	西班牙语
// th	泰语
// ara	阿拉伯语
// ru	俄语
// pt	葡萄牙语
// de	德语
// it	意大利语
// el	希腊语
// nl	荷兰语
// pl	波兰语
// bul	保加利亚语
// est	爱沙尼亚语
// dan	丹麦语
// fin	芬兰语
// cs	捷克语
// rom	罗马尼亚语
// slo	斯洛文尼亚语
// swe	瑞典语
// hu	匈牙利语
// cht	繁体中文
// vie	越南语

define("CURL_TIMEOUT",   10); 
define("URL",            "http://api.fanyi.baidu.com/api/trans/vip/translate"); 
define("APP_ID",         "20161214000034044"); //替换为您的APPID
define("SEC_KEY",        "n5nkbNxY5asmLilQ1oEy");//替换为您的密钥

//翻译入口
function translate($query, $from, $to)
{
    $args = array(
        'q' => $query,
        'appid' => APP_ID,
        'salt' => rand(10000,99999),
        'from' => $from,
        'to' => $to,

    );
    $args['sign'] = buildSign($query, APP_ID, $args['salt'], SEC_KEY);
    $ret = call(URL, $args);
    $ret = json_decode($ret, true);
    return $ret; 
}

//加密
function buildSign($query, $appID, $salt, $secKey)
{/*{{{*/
    $str = $appID . $query . $salt . $secKey;
    $ret = md5($str);
    return $ret;
}/*}}}*/

//发起网络请求
function call($url, $args=null, $method="post", $testflag = 0, $timeout = CURL_TIMEOUT, $headers=array())
{/*{{{*/
    $ret = false;
    $i = 0; 
    while($ret === false) 
    {
        if($i > 1)
            break;
        if($i > 0) 
        {
            sleep(1);
        }
        $ret = callOnce($url, $args, $method, false, $timeout, $headers);
        $i++;
    }
    return $ret;
}/*}}}*/

function callOnce($url, $args=null, $method="post", $withCookie = false, $timeout = CURL_TIMEOUT, $headers=array())
{/*{{{*/
    $ch = curl_init();
    if($method == "post") 
    {
        $data = convert($args);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch, CURLOPT_POST, 1);
    }
    else 
    {
        $data = convert($args);
        if($data) 
        {
            if(stripos($url, "?") > 0) 
            {
                $url .= "&$data";
            }
            else 
            {
                $url .= "?$data";
            }
        }
    }
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_TIMEOUT, $timeout);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    if(!empty($headers)) 
    {
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    }
    if($withCookie)
    {
        curl_setopt($ch, CURLOPT_COOKIEJAR, $_COOKIE);
    }
    $r = curl_exec($ch);
    curl_close($ch);
    return $r;
}/*}}}*/

function convert(&$args)
{/*{{{*/
    $data = '';
    if (is_array($args))
    {
        foreach ($args as $key=>$val)
        {
            if (is_array($val))
            {
                foreach ($val as $k=>$v)
                {
                    $data .= $key.'['.$k.']='.rawurlencode($v).'&';
                }
            }
            else
            {
                $data .="$key=".rawurlencode($val)."&";
            }
        }
        return trim($data, "&");
    }
    return $args;
}/*}}}*/

	// $src = "apple";
	// $tar = translate($src, "auto", "zh");
	// $res = $tar['trans_result'];
	// print_r('<pre>');
	// print_r($res);
	
	// $src = "hello";
	// $tar = translate($src, "auto", "zh");
	// $res = $tar['trans_result'];
	// print_r($res);
	
	// $src = "good";
	// $tar = translate($src, "auto", "zh");
	// $res = $tar['trans_result'];
	// print_r($res);
	
	// $src = "fine";
	// $tar = translate($src, "auto", "zh");
	// $res = $tar['trans_result'];
	// print_r($res);
	
	// $src = "think";
	// $tar = translate($src, "auto", "zh");
	// $res = $tar['trans_result'];
	// print_r($res);
	
	// $src = "我们来玩游戏吧";
	// $tar = translate($src, "auto", "en");
	// $res = $tar['trans_result'];
	// print_r($res);
?>
