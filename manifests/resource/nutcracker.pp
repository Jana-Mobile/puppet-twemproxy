# = Class definition for nutcracker config file
# TODO: Document the class.
define twemproxy::resource::nutcracker (
  $auto_eject_hosts     = true,
  $distribution         = 'ketama',
  $ensure               = 'present',
  $members              = '',
  $nutcracker_hash      = 'fnv1a_64',
  $nutcracker_hash_tag  = '',
  $port                 = '22111',
  $redis                = true,
  $server_retry_timeout = '2000',
  $server_failure_limit = '3',
  $statsport            = '21111',
  $twemproxy_timeout    = '300',
  $verbosity            = '11',
  $mbuf_size            = '2048'
) {

  require twemproxy

  $instance_name   = "nutcracker-${name}"
  $daemon_path     = $::twemproxy::daemon_path
  $log_dir         = $::twemproxy::log_dir
  $pid_dir         = $::twemproxy::pid_dir
  $twemproxy_user  = $::twemproxy::twemproxy_user
  $twemproxy_group = $::twemproxy::twemproxy_group


  $service_template_os_specific = $::osfamily ? {
    'RedHat'   => 'twemproxy/nutcracker.init.erb',
    'Debian'   => 'twemproxy/nutcracker.init.debian.erb',
    default    => 'twemproxy/nutcracker.init.debian.erb',
  }

  $sysconfig_file = $::osfamily ? {
    'RedHat' => "/etc/sysconfig/${instance_name}",
    'Debian' => "/etc/default/${instance_name}",
    default  => "/etc/default/${instance_name}",
  }

  file { $sysconfig_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('twemproxy/sysconfig.erb')
  }

  file { "/etc/nutcracker/${instance_name}.yml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('twemproxy/pool.erb',
                        'twemproxy/members.erb'),
  }

  file { "/etc/init.d/${instance_name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${service_template_os_specific}"),
  }

  service { $instance_name:
    ensure    => true,
    enable    => true,
    subscribe => Package['twemproxy'],
  }

  File[$sysconfig_file] ~> Service[$instance_name]
  File["/etc/nutcracker/${instance_name}.yml"] ~> Service[$instance_name]
  File["/etc/init.d/${instance_name}"] ~> Service[$instance_name]

}
