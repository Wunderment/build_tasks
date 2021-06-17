<?php
// Set what device we're downloading for.
$device = basename( dirname( realpath( getcwd() ) ) );;

/*
 * A device name may have a special case where we're building multiple versions, like for LOS 16
 * and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
 * so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
 * to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
 * but for the actual LOS build, we need to strip it off.  So do so now.
 */
$los_device=preg_replace( '/_.*/', '', $device );

// Pull the current stats from OnePlus.com and decode the json response.
$string = file_get_contents( 'oneplus.json' );
$json = json_decode( $string, true );

$current_release = -1;
$release_type = 1;

$get_beta = getenv( 'OPENBETA' );

if( $get_beta == 'true' ) {
	$release_type = 2;
}

if( ! array_key_exists( 'data', $json ) || $json['data'] == null ) {
	echo 'ERROR: Invalid json data!' . PHP_EOL;
	exit;
}

// Loop through the data.
foreach( $json['data'] as $field ) {
	// We're looking for versionType 1 for stable releases and 2 for open betas.
	if( intval( $field['versionType'] ) === $release_type ) {
		$current_release = $field;
	}
}

if( $current_release === -1 ) {
	echo "No release found!" . PHP_EOL;
	exit;
}

// Pull in the date value from the last time we checked.
$last_filename = '/home/WundermentOS/devices/' . $device . '/stock_os/last.stock.os.release.txt';
$last_release = intval( file_get_contents( $last_filename ) );

// Check if it's different from the value that OnePlus.com just returned to us.
if( $current_release[ 'versionReleaseTime' ] !== $last_release ) {
	// If so, download the new release.
	echo "New release found for $los_device!" . PHP_EOL;
	echo '    Downloading ' . $current_release['versionLink'] . '...';

	$output_file = '/home/WundermentOS/devices/' . $device . '/stock_os/current-stock-os.zip';

	$cmd = 'wget -q -O ' . $output_file . ' ' . escapeshellarg( $current_release[ 'versionLink' ] );

	exec( $cmd );
	touch( $output_file );

	echo 'done.' . PHP_EOL;

	// Update the last version file with the new date.
	echo '    Storing stock os version...';
	file_put_contents( $last_filename, $current_release[ 'versionReleaseTime' ] );
	echo 'done.' . PHP_EOL;

	// Extract the firmware.
	echo '    Extracting firmware...';
	exec( '../firmware/extract-stock-os-firmware.sh' );
	echo 'done.' . PHP_EOL;
} else {
	echo "No new release found for $los_device." . PHP_EOL;
}
