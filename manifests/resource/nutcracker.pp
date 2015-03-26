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
  $twemproxy_timeout    = '300'
) {

  require twemproxy

  $instance_name = "nutcracker-${name}"

   $service_template_os_specific = $::osfamily ? {
        'RedHat'   => 'twemproxy/nutcracker.init.erb',
        'Debian'   => 'twemproxy/nutcracker.init.debian.erb',
        default    => 'twemproxy/nutcracker.init.debian.erb',
    }

  file { "/etc/nutcracker/${instance_name}.yml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('twemproxy/pool.erb',
                        'twemproxy/members.erb'),
  }
  ->
  file { "/etc/init.d/${instance_name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${service_template_os_specific}"),
  }
  ->
  exec { "/etc/init.d/${instance_name} restart":
    command     => "/etc/init.d/${instance_name} restart",
    alias       => "reload-nutcracker-${instance_name}",
    require     => [ File["/etc/init.d/${instance_name}"], File["/etc/nutcracker/${instance_name}.yml"] ]
  }

}
