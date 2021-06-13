class phplist::remove (
) {
  include phplist

  # Collect parameters from parent class
  $db_name     = $::phplist::db_name
  $db_user     = $::phplist::db_user
  $db_password = $::phplist::db_password

  Package["phplist"] ->
  Host["phplist-blocked"] ->
  File["phplist-var-dir"] ->
  File["phplist-share-dir"] ->
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

  file { "phplist-var-dir":
    path    => "/var/lib/phplist",
    ensure  => absent,
    recurse => true,
    force   => true,
    backup  => false,
  }

  file { "phplist-share-dir":
    path    => "/usr/share/phplist",
    ensure  => absent,
    recurse => true,
    force   => true,
    backup  => false,
  }

  file { "phplist-conf-dir":
    path    => "/etc/phplist",
    ensure  => absent,
    recurse => true,
    force   => true,
    backup  => false,
  }
}
