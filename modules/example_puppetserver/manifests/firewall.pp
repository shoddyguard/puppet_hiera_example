# Class: example_puppetserver::firewall
#
# Configures the firewall on the puppet server to allow expected services.
class example_puppetserver::firewall {
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
    require => Package['iptables-persistent'],
  }
  -> firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }
  -> firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }
  -> firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }
  -> firewall { '004 accept SSH':
      proto  => 'tcp',
      dport  => 22,
      action => accept,
  }
  -> firewall { '005 allow 8081 (PuppetDB)':
      proto  => 'tcp',
      dport  => 8081,
      action => accept,
  }
  -> firewall { '006 allow 8140 (Puppet Agent Incoming)':
      proto  => 'tcp',
      dport  => 8140,
      action => accept,
  }
  -> firewall { '007 accept HTTP (PuppetBoard)':
      proto  => 'tcp',
      dport  => 80,
      action => accept,
  }
  -> firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}
