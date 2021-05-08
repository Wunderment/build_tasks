<?php
// Pull the current stats from OnePlus.com and decode the json response.
$string = file_get_contents( 'unifiednlp-releases.json' );
$json = json_decode( $string, true );

// Get the last release version we have.
$version = file_get_contents( 'last-unifiednlp-release.txt' );

$latest_release = $json[0]['tag_name'];

if( $latest_release != $version ) {
	echo "new UnifiedNlp release found... $latest_release." . PHP_EOL;

	foreach( $json[0]['assets'] as $asset ) {
		if( $asset['name'] == 'NetworkLocation.apk' ) {
			$url = $asset['browser_download_url'];
		}
	}

	// Go get the release.
	echo "Downloading new release... ";
	$cmd = 'wget -q -O ~/tasks/unifiednlp/current-networklocation.apk ' . escapeshellarg( $url );
	exec( $cmd );

	// Store the new release tag for later.
	file_put_contents( 'last-unifiednlp-release.txt', $latest_release );

	echo "done." . PHP_EOL;
} else {
	echo "no new UnfiedNlp release found!" . PHP_EOL;
}
