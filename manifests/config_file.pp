# @summary create a consul configuration file
#
# @param name the name of the file without extension
# @param content a hash to define the json content
# @param ensure ensure the presence or absence of this config file
# @param reload whether to reload the consul service when this config changes
# @param sensitive mark the contents of the config file as sensitive
define consul::config_file (
  Hash $content,
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $reload = true,
  Boolean $sensitive = false,
) {
  include consul
  $escaped_name = regsubst($name,'\/','_','G')
  if $consul::pretty_config {
    $_content = stdlib::to_json_pretty($content)
  } else {
  }
  $json = $consul::pretty_config ? {
    true    => to_json_pretty($content),
    default => to_json($content),
  }
  $_json = $sensitive ? {
    true    => Sensitive($json),
    default => $json,
  }
  file { "${consul::config_dir}/${escaped_name}.json":
    ensure  => $ensure,
    owner   => $consul::user_real,
    group   => $consul::group_real,
    mode    => $consul::config_mode,
    content => $_json,
  }
  if $reload {
    File["${consul::config_dir}/${escaped_name}.json"] ~> Class['consul::reload_service']
  }
}
