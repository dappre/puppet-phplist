class phplist (
  $ensure           = $phplist::params::ensure,
  $db_name          = $phplist::params::db_name,
  $db_host          = $phplist::params::db_host,
  $db_user          = $phplist::params::db_user,
  $db_password      = $phplist::params::db_password,
  $admin_password   = $phplist::params::admin_password,
  $bounce_email     = $phplist::params::bounce_email,
  $bounce_host      = $phplist::params::bounce_host,
  $bounce_user      = $phplist::params::bounce_user,
  $bounce_password  = $phplist::params::bounce_password,
  $data_group       = $phplist::params::data_group,
  $plugins_group    = $phplist::params::plugins_group,
  $hash_algo        = $phplist::params::hash_algo,
  $test             = $phplist::params::test,
  $base_dir         = $phplist::params::base_dir,
  $conf_dir         = $phplist::params::conf_dir,
  $data_dir         = $phplist::params::data_dir,
  $manage_db        = $phplist::params::manage_db,
  $mysql_bin        = $phplist::params::mysql_bin,
  $ldap             = $phplist::params::ldap,
  $ldap_proto       = $phplist::params::ldap_proto,
  $ldap_server      = $phplist::params::ldap_server,
  $ldap_port        = $phplist::params::ldap_port,
  $ldap_base        = $phplist::params::ldap_base,
  $ldap_users_dn    = $phplist::params::ldap_users_dn,
  $ldap_groups_dn   = $phplist::params::ldap_groups_dn,
  $ldap_bind_dn     = $phplist::params::ldap_bind_dn,
  $ldap_bind_pw     = $phplist::params::ldap_bind_pw,
  $ldap_all_user_is_super     = $phplist::params::ldap_all_user_is_super,
  $ldap_all_user_pattern      = $phplist::params::ldap_all_user_pattern,
  $ldap_matching_user_pattern = $phplist::params::ldap_matching_user_pattern,
) inherits phplist::params {
  if ($ensure) {
    case $ensure {
      /absent|false/: {
        contain phplist::remove
      }
      default:  {
        contain phplist::install
      }
    }
  } else {
    contain phplist::remove
  }
}
