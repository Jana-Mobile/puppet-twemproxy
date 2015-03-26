# = Class definition for nutcracker config file
# TODO: Document the class.
define twemproxy::resource::nutcracker (
  $auto_eject_hosts     = true,
  $distribution         = 'ketama',
  $ensure               = 'present',
  $exec_dir             = '/usr/local/bin',
  $log_dir              = '/var/log/nutcracker',
  $members              = '',
  $nutcracker_hash      = 'fnv1a_64',
  $nutcracker_hash_tag  = '',
  $pid_dir              = '/var/run/nutcracker',
  $port                 = '22111',
  $redis                = true,
  $server_retry_timeout = '2000',
  $server_failure_limit = '3',
  $statsport            = '21111',
  $twemproxy_timeout    = '300'
) {


   $service_template_os_specific = $osfamily ? {
        'RedHat'   => 'twemproxy/nutcracker-redhat.erb',
        'Debian'   => 'twemproxy/nutcracker.erb',
        default    => 'twemproxy/nutcracker.erb',
    }

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  # Ensure nutcracker config directory exists
  if ! defined(File['/etc/nutcracker']) {
    file { '/etc/nutcracker':
      ensure  => 'directory',
      mode    => '0755',
    }
  }

  # Ensure nutcracker log directory exists
  if ! defined(File["${log_dir}"]) {
    file { "${log_dir}":
      ensure  => 'directory',
      mode    => '0755',
    }
  }

  # Ensure nutcracker pid directory exists
  if ! defined(File["${pid_dir}"]) {
    file { "${pid_dir}":
      ensure  => 'directory',
      mode    => '0755',
    }
  }

  file { "/etc/nutcracker/${name}.yml":
    ensure  => present,
    content => template('twemproxy/pool.erb',
                        'twemproxy/members.erb'),
  }
  ->
  file { "/etc/init.d/${name}":
    ensure  => present,
    mode    => '0755',
    content => template("${service_template_os_specific}"),
    require => [ File["$log_dir"], File["$pid_dir"] ]
  }
  ->
  exec { "/etc/init.d/${name} restart":
    command     => "/etc/init.d/${name} restart",
    alias       => "reload-nutcracker-${name}",
    require     => [ File["/etc/init.d/${name}"], File["/etc/nutcracker/${name}.yml"] ]
  }

}
