define phplist::instance (
  $svname           = '*',
  $ensure           = 'present',
  $db_host          = $::phplist::db_host,
  $db_name          = "phplist_${name}",
  $db_user          = "phplist_${name}",
  $db_password      = $::phplist::db_password,
  $admin_password   = $::phplist::admin_password,
  $bounce_email     = $::phplist::bounce_email,
  $bounce_host      = $::phplist::bounce_host,
  $bounce_user      = $::phplist::bounce_user,
  $bounce_password  = $::phplist::bounce_password,
  $bounce_mailbox_port        = $::phplist::bounce_mailbox_port,
  $hash_algo        = $::phplist::hash_algo,
  $test             = $::phplist::test,
  $ldap             = $::phplist::ldap,
  $ldap_proto       = $::phplist::ldap_proto,
  $ldap_server      = $::phplist::ldap_server,
  $ldap_port        = $::phplist::ldap_port,
  $ldap_base        = $::phplist::ldap_base,
  $ldap_users_dn    = $::phplist::ldap_users_dn,
  $ldap_groups_dn   = $::phplist::ldap_groups_dn,
  $ldap_bind_dn     = $::phplist::ldap_bind_dn,
  $ldap_bind_pw     = $::phplist::ldap_bind_pw,
  $ldap_all_user_is_super     = $::phplist::ldap_all_user_is_super,
  $ldap_all_user_pattern      = $::phplist::ldap_all_user_pattern,
  $ldap_matching_user_pattern = $::phplist::ldap_matching_user_pattern,
) {
  $data_group       = $::phplist::data_group
  $base_dir         = $::phplist::base_dir
  $conf_dir         = "$::phplist::conf_dir/${name}"
  $data_dir         = "$::phplist::data_dir/${name}"
  $manage_db        = $::phplist::manage_db
  $mysql_bin        = $::phplist::mysql_bin

  # Manage some configuration part directly in the DB
  # TODO: initialize and upgrade the DB if possible
  if ($manage_db) {
    $mysql_cmd = "${mysql_bin} --batch --skip-column-names -h${db_host} -u${db_user} -p${db_password} ${db_name}"

    exec { "phplist-${name}-update-admin-pwd":
      path      => [ '/bin', '/usr/bin', ],
      command   => "${mysql_cmd} -e \"UPDATE phplist_admin SET password = \'$(echo -n '${admin_password}' | ${hash_algo}sum | grep -Po '^([0-9a-f]+)(?=\s)')\' WHERE loginname = 'admin'\"",
      onlyif    => [
        "${mysql_cmd} -e \"DESCRIBE phplist_admin\"",
        "test \"\$(${mysql_cmd} -e \"SELECT loginname FROM phplist_admin WHERE loginname = 'admin'\")\" = \"admin\"",
        "test \"\$(${mysql_cmd} -e \"SELECT password FROM phplist_admin WHERE loginname = 'admin'\")\" != \"$(echo -n '${admin_password}' | ${hash_algo}sum | grep -Po '^([0-9a-f]+)(?=\s)')\"",
      ],
      logoutput => true,
    } ->

    exec { "phplist-${name}-insert-upload-dir":
      path      => [ '/bin', '/usr/bin', ],
      command   => "${mysql_cmd} -e \"INSERT INTO phplist_config (item,value) VALUES ('kcfinder_uploaddir','${data_dir}/upload')\"",
      onlyif    => [
        "${mysql_cmd} -e \"DESCRIBE phplist_config\"",
        "test \"\$(${mysql_cmd} -e \"SELECT item FROM phplist_config WHERE item = 'kcfinder_uploaddir'\")\" = \"\"",
      ],
      logoutput => true,
    } ->

    exec { "phplist-${name}-update-upload-dir":
      path      => [ '/bin', '/usr/bin', ],
      command   => "${mysql_cmd} -e \"UPDATE phplist_config SET value = '${data_dir}/upload' WHERE item = 'kcfinder_uploaddir'\"",
      onlyif    => [
        "${mysql_cmd} -e \"DESCRIBE phplist_config\"",
        "test \"\$(${mysql_cmd} -e \"SELECT item FROM phplist_config WHERE item = 'kcfinder_uploaddir'\")\" = \"kcfinder_uploaddir\"",
        "test \"\$(${mysql_cmd} -e \"SELECT value FROM phplist_config WHERE item = 'kcfinder_uploaddir'\")\" != \"${data_dir}/upload\"",
      ],
      logoutput => true,
    }
  }

  Anchor['phplist-begin'] ->
  Package['phplist'] ->

  file { "phplist-${name}-conf-dir":
    path    => "${conf_dir}",
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0775',
  } ->

  file { "phplist-${name}-conf":
    path    => "${conf_dir}/config.php",
    content => template('phplist/config.php.erb'),
    owner   => 'root',
    group   => 'root',
  } ->

  file { "phplist-${name}-data-dir":
    path    => "${data_dir}",
    ensure  => 'directory',
    owner   => 'root',
    group   => "${data_group}",
    mode    => '0770',
  } ->

  file { "phplist-${name}-tmp-dir":
    path    => "${data_dir}/tmp",
    ensure  => 'directory',
    owner   => 'root',
    group   => "${data_group}",
    mode    => '0770',
  } ->

  file { "phplist-${name}-upload-dir":
    path    => "${data_dir}/upload",
    ensure  => 'directory',
    owner   => 'root',
    group   => "${data_group}",
    mode    => '0770',
  }
}