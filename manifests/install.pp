class phplist::install (
) {
  include phplist

  # Collect parameters from parent class
  $ensure           = $::phplist::ensure
  $data_group       = $::phplist::data_group
  $plugins_group    = $::phplist::plugins_group
  $base_dir         = $::phplist::base_dir
  $conf_dir         = $::phplist::conf_dir
  $data_dir         = $::phplist::data_dir
  $default_instance = $::phplist::default_instance
  $instances        = $::phplist::instances

  Anchor['phplist-begin'] ->

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
    owner   => 'root',
    group   => 'root',
    content => template('phplist/config_switch.php.erb'),
  } ->

  file { 'phplist-data-dir':
    path    => "${data_dir}",
    ensure  => 'directory',
    owner   => 'root',
    group   => "${data_group}",
    mode    => '0770',
  } ->

  # Make sure the default instances has been created before going any further
  Phplist::Instance["${default_instance}"] ->

  # Migrate existing tmp and upload folder to default instance data dir 
  exec { 'phplist-tmp-dir-mv':
    command => "mv ${data_dir}/tmp ${data_dir}/${default_instance}",
    onlyif  => [
      "test -d \"${data_dir}/tmp\"",
      "test \"$(ls -A ${data_dir}/tmp)\"",
      "test ! \"$(ls -A ${data_dir}/${default_instance}/tmp)\"",
    ],
  } ->

  exec { 'phplist-upload-dir-mv':
    command => "mv ${data_dir}/upload ${data_dir}/${default_instance}",
    onlyif  => [
      "test -d \"${data_dir}/upload\"",
      "test \"$(ls -A ${data_dir}/upload)\"",
      "test ! \"$(ls -A ${data_dir}/${default_instance}/upload)\"",
    ],
  } ->

  # Update base symlink to default instance data dir too 
  file { 'phplist-upload-lnk':
    path    => "${base_dir}/www/upload",
    ensure  => "${data_dir}/${default_instance}/upload",
  } ->

  Anchor['phplist-end']
}
