class phplist::remove (
) {
  include phplist
  require mysqld
  require httpd

  # Collect parameters from parent class
  $db_name     = $::phplist::db_name
  $db_user     = $::phplist::db_user
  $db_password = $::phplist::db_password
  $vname       = $::phplist::vname

  Package["phplist"] ->
  File["httpd-phplist-rules"] ->
  File["httpd-phplist-conf"] ->
  Host["phplist-blocked"] ->
  Mysqld::Drop["phplist"] ->
  File["phplist-var-dir"] ->
  File["phplist-share-dir"] ->
  File["phplist-conf-dir"]

  package { "phplist":
    ensure  => absent,
  }

  # Migration of the prefix: ISQ-902
  exec { "httpd-phplist-rules-migration":
    command => "/bin/mv -f /etc/httpd/conf.d/phplist_${vname}.rules /etc/httpd/conf.d/${vname}_phplist.rules",
    onlyif  => "/usr/bin/test -f /etc/httpd/conf.d/phplist_${vname}.rules",
    before  => File["httpd-phplist-rules"],
  }

  file { "httpd-phplist-rules":
    path    => "/etc/httpd/conf.d/${vname}_phplist.rules",
    ensure  => absent,
    notify  => Class['httpd::service'],
  }

  file { "httpd-phplist-conf":
    path    => "/etc/httpd/conf.d/phplist.conf",
    ensure  => absent,
    backup  => false,
    notify  => Class['httpd::service'],
  }

  # Remove the hosts entries that were preventing this phplist instance to access public phplist webservers
  host { "phplist-blocked":
    ensure       => absent,
    name         => "www.phplist.org",
    ip           => "127.0.0.2",
    host_aliases => [ "www.phplist.com", ],
  }

  mysqld::drop { "phplist":
    db_name => $db_name,
    db_user => $db_user,
    db_pass => $db_password,
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
