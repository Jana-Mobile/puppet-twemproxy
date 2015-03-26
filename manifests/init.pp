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
  $compile_twemproxy = true,
  $package_ensure    = present,
  $package_name      = 'twemproxy', # Have also seen "nutcracker" out there.
  $daemon_path       = '/usr/local/bin/nutcracker',
  $log_dir           = '/var/log/nutcracker',
  $pid_dir           = '/var/run/nutcracker',
  $manage_user       = true,
  $twemproxy_user    = 'twemproxy',
  $manage_group      = true,
  $twemproxy_group   = 'twemproxy',
) {

  if $compile_twemproxy == true {
    class { '::twemproxy::install': }
  } else {
    package { 'twemproxy':
      ensure => $package_ensure,
      alias  => 'twemproxy'
    }
  }

  if $manage_group == true {
    group { $twemproxy_group:
      ensure => present,
      system => true
    }
  }

  if !defined(Group[$twemproxy_group]) {
    fail("Must define Group[$twemproxy_group]")
  }

  if $manage_user == true {
    user { $twemproxy_user:
      ensure => present,
      gid    => $twemproxy_group,
      home   => $pid_dir,
      shell  => '/bin/false',
      system => true
    }
  }

  if !defined(User[$twemproxy_user]) {
    fail("Must define User[$twemproxy_user]")
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

  if $compile_twemproxy == true {
    Class['twemproxy::install'] -> Group[$twemproxy_group]
  } else {
    Package['twemproxy'] -> Group[$twemproxy_group]
  }

  Group[$twemproxy_group] ->
  User[$twemproxy_user] ->
  File['/etc/nutcracker'] ->
  File[$log_dir] ->
  File[$pid_dir]

}
