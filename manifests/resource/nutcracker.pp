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

   $service_template_os_specific = $osfamily ? {
        'RedHat'   => 'twemproxy/nutcracker-redhat.erb',
        'Debian'   => 'twemproxy/nutcracker.erb',
        default    => 'twemproxy/nutcracker.erb',
    }

  file { "/etc/nutcracker/${name}.yml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('twemproxy/pool.erb',
                        'twemproxy/members.erb'),
  }
  ->
  file { "/etc/init.d/${name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${service_template_os_specific}"),
  }
  ->
  exec { "/etc/init.d/${name} restart":
    command     => "/etc/init.d/${name} restart",
    alias       => "reload-nutcracker-${name}",
    require     => [ File["/etc/init.d/${name}"], File["/etc/nutcracker/${name}.yml"] ]
  }

}
