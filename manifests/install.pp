class phplist::install (
) {
  include phplist

  # Collect parameters from parent class
  $ensure           = $::phplist::ensure
  $db_name          = $::phplist::db_name
  $db_user          = $::phplist::db_user
  $db_password      = $::phplist::db_password
  $admin_password   = $::phplist::admin_password
  $bounce_email     = $::phplist::bounce_email
  $bounce_host      = $::phplist::bounce_host
  $bounce_user      = $::phplist::bounce_user
  $bounce_password  = $::phplist::bounce_password
  $plugin_dir_group = $::phplist::plugin_dir_group
  $hash_algo        = $::phplist::hash_algo
  $test             = $::phplist::test

  Package["php-PHPMailer"] ->
  Package["phplist"] ->
  File['phplist-plugin-dir'] ->
  File["phplist-conf"] ->
  File['phplist-data-dir'] ->
  File['phplist-tmp-dir'] ->
  Exec["phplist-update-admin-pwd"] ->
  File["phplist-uploadimages-lnk"] ->
  File["phplist-uploadimages-dir"] ->
  File["phplist-upload-dir"] ->
  File["phplist-upload-lnk"] ->
  Host["phplist-blocked"]

  $mysql = "mysql --batch --skip-column-names -u${db_user} -p${db_password} ${db_name}"

  package { "php-PHPMailer":
    ensure  => latest,
  }

  package { "phplist":
    ensure  => $ensure,
  }

  file { 'phplist-plugin-dir':
    path    => '/usr/share/phplist/www/admin/plugins',
    source  => 'puppet:///modules/phplist/plugins',
    owner   => 'root',
    group   => "${plugin_dir_group}",
    mode    => 'ug=rw,o=r,a+X',
    recurse => 'remote',
  }

  file { "phplist-conf":
    path    => "/etc/phplist/config.php",
    content => template("phplist/config.php.erb"),
  }

  file { 'phplist-data-dir':
    path    => "/var/lib/phplist",
    ensure  => 'directory',
    owner   => 'root',
    group   => 'apache',
    mode    => '0770',
  }

  file { 'phplist-tmp-dir':
    path    => "/var/lib/phplist/tmp",
    ensure  => 'directory',
    owner   => 'root',
    group   => 'apache',
    mode    => '0770',
  }

  exec { "phplist-update-admin-pwd":
    path      => [ "/bin", "/usr/bin", ],
    command   => "${mysql} -e \"UPDATE phplist_admin SET password = \'$(echo -n '${admin_password}' | ${hash_algo}sum | grep -Po '^([0-9a-f]+)(?=\s)')\' WHERE loginname = 'admin'\"",
    onlyif    => "${mysql} -e \"SELECT loginname FROM phplist_admin WHERE loginname = 'admin'\" 2> /dev/null | grep \"^admin\"",
    unless    => "[ \"${admin_password}\" == \"false\" ] || [ \"\$(${mysql} -e \"SELECT password FROM phplist_admin WHERE loginname = 'admin'\" | tail -1)\" == \"$(echo -n '${admin_password}' | ${hash_algo}sum | grep -Po '^([0-9a-f]+)(?=\s)')\" ]",
    logoutput => true,
  }

  file { "phplist-uploadimages-lnk":
    path    => "/usr/share/phplist/www/uploadimages",
    ensure  => absent,
  }

  file { "phplist-uploadimages-dir":
    path    => "/var/lib/phplist/images",
    ensure  => absent,
    recurse => true,
    force   => true,
    backup  => false,
  }

  file { 'phplist-upload-dir':
    path    => '/var/lib/phplist/upload',
    ensure  => 'directory',
    owner   => 'root',
    group   => 'apache',
    mode    => '0775',
  }

  file { "phplist-upload-lnk":
    path    => "/usr/share/phplist/www/upload",
    ensure  => "/var/lib/phplist/upload",
  }

  # Add hosts entries that prevent this phplist instance to access public phplist webservers
  host { "phplist-blocked":
    ensure       => present,
    name         => "www.phplist.org",
    ip           => "127.0.0.2",
    host_aliases => [ "www.phplist.com", ],
  }
}
