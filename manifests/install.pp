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

  # We use PHPMailer provided by the system
  # TODO: make it more flexible from alternate sources
  # I do believe phpList is shipping its own version,
  # but it was somehow more safe to rely on the OS
  package { 'php-PHPMailer':
    ensure  => latest,
  } ->

  # Install phpList provided by the system
  # TODO: make it more flexible from alternate sources
  package { 'phplist':
    ensure  => $ensure,
  } ->

  # Provide extra plugins and restrict permission
  # With only read access given by default
  # because they are shared between instances
  # TODO: treat plugin as data per instances
  file { 'phplist-plugin-dir':
    path    => "${base_dir}/www/admin/plugins",
    source  => 'puppet:///modules/phplist/plugins',
    owner   => 'root',
    group   => "${plugins_group}",
    mode    => 'ug=rw,o=r,a+X',
    recurse => 'remote',
  } ->

  # Overwrite the initial configuration to switch
  # between instances based on the SERVER_NAME
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
