class phplist::install (
) {
  include phplist

  # Collect parameters from parent class
  $ensure           = $::phplist::ensure
  $db_host          = $::phplist::db_host
  $db_name          = $::phplist::db_name
  $db_user          = $::phplist::db_user
  $db_password      = $::phplist::db_password
  $admin_password   = $::phplist::admin_password
  $bounce_email     = $::phplist::bounce_email
  $bounce_host      = $::phplist::bounce_host
  $bounce_user      = $::phplist::bounce_user
  $bounce_password  = $::phplist::bounce_password
  $data_group       = $::phplist::data_group
  $plugins_group    = $::phplist::plugins_group
  $hash_algo        = $::phplist::hash_algo
  $test             = $::phplist::test
  $base_dir         = $::phplist::base_dir
  $conf_dir         = $::phplist::conf_dir
  $data_dir         = $::phplist::data_dir
  $manage_db        = $::phplist::manage_db
  $mysql_bin        = $::phplist::mysql_bin

  if ($manage_db) {
    $mysql_cmd = "${mysql_bin} --batch --skip-column-names -h${db_host} -u${db_user} -p${db_password} ${db_name}"

    exec { 'phplist-update-admin-pwd':
      path      => [ '/bin', '/usr/bin', ],
      command   => "${mysql_cmd} -e \"UPDATE phplist_admin SET password = \'$(echo -n '${admin_password}' | ${hash_algo}sum | grep -Po '^([0-9a-f]+)(?=\s)')\' WHERE loginname = 'admin'\"",
      onlyif    => "${mysql_cmd} -e \"SELECT loginname FROM phplist_admin WHERE loginname = 'admin'\" 2> /dev/null | grep \"^admin\"",
      unless    => "[ \"${admin_password}\" == \"false\" ] || [ \"\$(${mysql_cmd} -e \"SELECT password FROM phplist_admin WHERE loginname = 'admin'\" | tail -1)\" == \"$(echo -n '${admin_password}' | ${hash_algo}sum | grep -Po '^([0-9a-f]+)(?=\s)')\" ]",
      logoutput => true,
    }
  }

  package { 'php-PHPMailer':
    ensure  => latest,
  } ->

  package { 'phplist':
    ensure  => $ensure,
  } ->

  file { 'phplist-plugin-dir':
    path    => "${base_dir}/www/admin/plugins",
    source  => 'puppet:///modules/phplist/plugins',
    owner   => 'root',
    group   => "${plugins_group}",
    mode    => 'ug=rw,o=r,a+X',
    recurse => 'remote',
  } ->

  file { 'phplist-conf':
    path    => "${conf_dir}/config.php",
    content => template('phplist/config.php.erb'),
  } ->

  file { 'phplist-data-dir':
    path    => "${data_dir}",
    ensure  => 'directory',
    owner   => 'root',
    group   => "${data_group}",
    mode    => '0770',
  }

  file { 'phplist-tmp-dir':
    path    => "${data_dir}/tmp",
    ensure  => 'directory',
    owner   => 'root',
    group   => "${data_group}",
    mode    => '0770',
  } ->

  file { 'phplist-upload-dir':
    path    => "${data_dir}/upload",
    ensure  => 'directory',
    owner   => 'root',
    group   => "${data_group}",
    mode    => '0775',
  } ->

  file { 'phplist-upload-lnk':
    path    => "${base_dir}/www/upload",
    ensure  => "${data_dir}/upload",
  }
}
