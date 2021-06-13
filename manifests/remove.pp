class phplist::remove (
) {
  include phplist

  # Collect parameters from parent class
  $db_name     = $::phplist::db_name
  $db_user     = $::phplist::db_user
  $db_password = $::phplist::db_password
  $base_dir    = $::phplist::base_dir
  $conf_dir    = $::phplist::conf_dir
  $data_dir    = $::phplist::data_dir
  $www_dir     = $::phplist::www_dir

  Package["phplist"] ->
  Host["phplist-blocked"] ->
  File["phplist-data-dir"] ->
  File["phplist-base-dir"] ->
  File["phplist-conf-dir"]

  package { "phplist":
    ensure  => absent,
  }

  # Remove the hosts entries that were preventing this phplist instance to access public phplist webservers
  host { "phplist-blocked":
    ensure       => absent,
    name         => "www.phplist.org",
    ip           => "127.0.0.2",
    host_aliases => [ "www.phplist.com", ],
  }

  file { "phplist-data-dir":
    path    => "${data_dir}",
    ensure  => absent,
    recurse => true,
    force   => true,
    backup  => false,
  }

  file { "phplist-base-dir":
    path    => "${base_dir}",
    ensure  => absent,
    recurse => true,
    force   => true,
    backup  => false,
  }

  file { "phplist-conf-dir":
    path    => "${conf_dir}",
    ensure  => absent,
    recurse => true,
    force   => true,
    backup  => false,
  }
}
