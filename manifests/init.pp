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
  $log_dir      = '/var/log/nutcracker',
  $pid_dir      = '/var/run/nutcracker',
) {

  file { '/etc/nutcracker':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${log_dir}":
    ensure  => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { "${pid_dir}":
    ensure  => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

}
