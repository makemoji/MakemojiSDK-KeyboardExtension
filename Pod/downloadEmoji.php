<?php

$emojiurl = "http://api.makemoji.com/sdk/emoji/emojiWall";
$categoryurl = "http://api.makemoji.com/sdk/emoji/categories";
$sdkKey = "YOUR_SDK_KEY";

$options = array(
  'http'=>array(
    'method'=>"GET",
    'header'=>"Accept-language: en\r\n" .
              "makemoji-sdkkey: ".$sdkKey."\r\n".
              "makemoji-deviceId: Download\r\n".  // check function.stream-context-create on php.net
              "User-Agent: MakemojiDownloadScript\r\n" // i.e. An iPad 
  )
);

$context = stream_context_create($options);
$emoji = file_get_contents($emojiurl, false, $context);

file_put_contents("emojiwall.json", str_replace("https://d1tvcfe0bfyi6u.cloudfront.net/video/", "", str_replace("https://d1tvcfe0bfyi6u.cloudfront.net/emoji/", "", $emoji)));

$categories = file_get_contents($categoryurl, false, $context);
file_put_contents("categories.json", str_replace("https://d1tvcfe0bfyi6u.cloudfront.net/emoji/", "", str_replace("https://d1tvcfe0bfyi6u.cloudfront.net/sdk-categories/", "", $categories)));
$imgdir = "./sdkimages";
if (!file_exists($imgdir)) {	
	mkdir($imgdir, 0700);
}

$emojiJson = json_decode($emoji, TRUE);
$categoryJson = json_decode($categories, TRUE);
echo "Download Images";

foreach($emojiJson as $k => $v) {
	foreach($v as $k1 => $v1) {
		if (!empty($v1['image_url'])) {
			$parts = explode('/', $v1['image_url']);
			$img = $imgdir.'/'.end($parts);
			echo $img."\r\n";
			if (!file_exists($img)) {	
				file_put_contents($img, file_get_contents(str_replace('https', 'http', $v1['image_url'])));
			}
			
			if (!empty($v1['video_url'])) {
				$parts = explode('/', $v1['video_url']);
				$img = $imgdir.'/'.end($parts);
				echo $img."\r\n";
				if (!file_exists($img)) {	
					file_put_contents($img, file_get_contents(str_replace('https', 'http', $v1['video_url'])));
				}
			}

			if (!empty($v1['40x40_url'])) {
				$parts = explode('/', $v1['40x40_url']);
				$img = $imgdir.'/'.end($parts);
				echo $img."\r\n";
				if (!file_exists($img)) {	
					file_put_contents($img, file_get_contents(str_replace('https', 'http', $v1['40x40_url'])));
				}
			}
						
			
		}
	}
}

foreach($categoryJson as $k1 => $v1) {
	$parts = explode('/', $v1['image_url']);
	$img = $imgdir.'/'.end($parts);
	echo $img."\r\n";	
	if (!file_exists($img)) {	
		file_put_contents($img, file_get_contents(str_replace('https', 'http', $v1['image_url'])));
	}
}

echo "Download Complete";
echo "\r\n";

?>