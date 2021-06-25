<?php
header('Content-Type: text/plain');

// Set the status OK by default
$status = "OK";

// Function to compute timestamp in milliseconds
function milliseconds() {
  $mt = explode(' ', microtime());
  return $mt[1] * 1000 + round($mt[0] * 1000);
}

// Start output buffer
ob_start();

if(!@include('../config/config.php')){
  $status = "CRITICAL (Could not load phpList config)";
} else {
  mysql_connect($database_host, $database_user, $database_password) or $status = "CRITICAL (Could not connect to phpList DB)";
  mysql_select_db($database_name) or $status = "CRITICAL (Could not select phpList database)";

  if ($status == "OK") {
    if ($table_prefix == '') {
      $table_prefix = 'phplist';
    }
    $result = mysql_query('SELECT value FROM '. $table_prefix .'_config WHERE item = "version"');
    $row = mysql_fetch_assoc($result);
    $database_version = $row['value'];

    // Test version number to determine the status
    if ($database_version == "") {
      $status = "CRITICAL (Could not determine phpList version)";
    }
  }
}

// Clean the buffer so we don't see dirt from config.php
ob_end_clean();

// Print formated output
echo "Status: " . $status . "\n";
echo "Timestamp: " . milliseconds() . "\n";
echo "Version: " . $database_version;
?>
