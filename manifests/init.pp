class phplist (
  $ensure           = $phplist::params::ensure,
  $db_name          = $phplist::params::db_name,
  $db_user          = $phplist::params::db_user,
  $db_password      = $phplist::params::db_password,
  $admin_password   = $phplist::params::admin_password,
  $vname            = $phplist::params::vname,
  $bounce_email     = $phplist::params::bounce_email,
  $bounce_host      = $phplist::params::bounce_host,
  $bounce_user      = $phplist::params::bounce_user,
  $bounce_password  = $phplist::params::bounce_password,
  $plugin_dir_group = $phplist::params::plugin_dir_group,
  $hash_algo        = $phplist::params::hash_algo,
  $test             = $phplist::params::test,
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
