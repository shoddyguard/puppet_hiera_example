# Class: example_puppetserver::codemanagement
#
#
class example_puppetserver::codemanagement
(
  $r10k_version = 'present'
)
{
    # r10k commands need to be executed as root.
  # So we are going to setup root so that it can pull from our github repos
  $username ='root'
  $home_folder = '/root'

  File {
    mode    => '0600',
    owner   => $username,
    group   => $username,
  }

  package { 'ruby':
    ensure => 'present',
  }
  -> package { 'r10k':
      ensure   => $r10k_version,
      provider => 'gem',
    }
  -> file { '/etc/puppetlabs/r10k':
      ensure => 'directory',
    }
  -> file { '/etc/puppetlabs/r10k/r10k.yaml':
      content => template('bs_puppetserver/r10k.yaml.erb'),
    }

  cron { 'r10k deploy environment --puppetfile':
    ensure  => present,
    # We have seen instances of r10k hanging forever and using 100% CPU, so let's kill
    # any r10k process before each deployment.
    # Sadly, this will also kill r10k processes started by users...
    command => '/usr/bin/pkill --echo --signal 9 r10k; /usr/local/bin/r10k deploy environment --puppetfile 2>&1 | logger -t "r10k_deploy_environment"',
    user    => $username,
    minute  => '*/15',
    require => File['/etc/puppetlabs/r10k/r10k.yaml'],
  }
}
