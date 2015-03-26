# = Class: init twemproxy
#
# USAGE:
#  twemproxy::resource::nutcracker {
#    'pool1':
#      ensure    => present,
#      statsport => '22122',
#      members   => [
#        {
#          ip => '127.0.0.1',
#          name   => 'server1',
#          port   => '22121',
#          weight => '1',
#        },
#        {
#          ip     => '127.0.0.1',
#          name   => 'server2',
#          port   => '22122',
#          weight => '1',
#        }
#      ]
#  }

class twemproxy (
  $log_dir         = '/var/log/nutcracker',
  $pid_dir         = '/var/run/nutcracker',
  $twemproxy_user  = 'twemproxy',
  $twemproxy_group = 'twemproxy',
) {

  group { $twemproxy_group:
    ensure => present
  }

  user { $twemproxy_user:
    ensure => present,
    group  => $twemproxy_group,
    home   => $pid_dir,
    shell  => '/usr/bin/false',
  }

  file { '/etc/nutcracker':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${log_dir}":
    ensure => 'directory',
    owner  => $twemproxy_user,
    group  => $twemproxy_group,
    mode   => '0755'
  }

  file { "${pid_dir}":
    ensure => 'directory',
    owner  => $twemproxy_user,
    group  => $twemproxy_group,
    mode   => '0755'
  }

  Group[$twemproxy_group] ->
  User[$twemproxy_user] ->
  File['/etc/nutcracker'] ->
  File[$log_dir] ->
  File[$pid_dir]

}
