# @summary Enter a brief description of the module here
# 
# @param Parameter1
#   description of parameter1
#
class example_puppetserver
(
  $puppet_majorversion,
  $puppet_environment,
  $puppet_user = 'puppet',
  $puppet_group = 'puppet',
  # Used by both ::hiera and ::puppet class because they both try
  # to manage the hiera_config setting in puppet.conf
  # https://puppet.com/docs/puppet/latest/lang_facts_builtin_variables.html
  $hiera_yaml_path = "${::settings::codedir}/hiera.yaml",
  $puppet_dbserver = $::fqdn,
)
{

  group { $puppet_group:
    ensure => present,
  }
  -> user { $puppet_user:
      ensure => present,
      groups => $puppet_group,
      shell  => '/usr/sbin/nologin',
    }
  # We lock the versions in to the below as we know they work at the time of writing. 
  # We can look to overwrite, make these more flexible in the future.
  if $puppet_majorversion == 6
  {
    $postgres_version = '9.6'
    $puppetserver_version = '6.10.0'
    $puppetserver_package_version = "6.10.0-1${::lsbdistcodename}"
    $puppetdb_package_version = "6.9.1-1${::lsbdistcodename}"
    # Do not let puppet upgrade to the latest version of puppet-agent.
    # That's because for major upgrades, we are supposed to upgrade puppetserver
    # before puppet-agent.
    $puppet_agent_package_version = "6.13.0-1${::lsbdistcodename}" # skipping version 14 as it causes issues, waiting for 6.15
    $hiera_version = '5'
    # with hiera v5, hierarchies should be defined in the environment and module layers
    # hiera.yaml files which are committed with our puppet source code.
    $hiera_hierarchies = []
    $eyaml_version = '3.2.0'
  }
  elsif $puppet_majorversion == 5
  {
    $postgres_version = '9.0'
    $puppetserver_version = '5.5.0'
    $puppetserver_package_version = "5.5.0-1${::lsbdistcodename}"
    $puppetdb_package_version = "5.5.1-1${::lsbdistcodename}"
    # Do not let puppet upgrade to the latest version of puppet-agent.
    # That's because for major upgrades, we are supposed to upgrade puppetserver
    # before puppet-agent.
    $puppet_agent_package_version = "5.5.0-1${::lsbdistcodename}"
    $hiera_version = '5'
    # with hiera v5, hierarchies should be defined in the environment and module layers
    # hiera.yaml files which are committed with our puppet source code.
    $hiera_hierarchies = []
    $eyaml_version = '3.2.0'
  }
  else
  {
    fail("Unsupported Puppet version: ${puppet_majorversion}. If you are upgrading, follow the instructions in the repo.")
  }

  # Install and configure PuppetDB
  class { 'puppetdb::globals':
    version => $puppetdb_package_version,
  }

  class { 'puppetdb':
    node_ttl         => '14d',
    node_purge_ttl   => '30d',
    report_ttl       => '5d',
    # we CANNOT disable ssl as it is needed in puppetdb.conf (server_urls)
    disable_ssl      => false,
    # less ram plz
    java_args        => {
      '-Xmx' => '1g',
      '-Xms' => '1g',
    },
    postgres_version => $postgres_version,
  }

  if $::trusted['extensions']['pp_environment'] == 'live' {
    $puppet_tuning_parameters = {
      # Puppet server tuning. See https://puppet.com/docs/puppetserver/latest/tuning_guide.html
      # Set max active JRuby instances. (how many Puppet runs can happen at once)
      # Generally this should equal CPU count, howerver as my env is small 1 is enough, 2 for safety
      server_max_active_instances    => 2,
      # Set heap size. Recommendation is (512MB * max_active_instances) + 'a bit'.
      # Therefor I have set mimimun to 1G and given a max of 2G.
      # This is equivelent to setting JAVA_ARGS="-xms1g -xmx2g" in /etc/default/puppetserver
      server_jvm_min_heap_size       => '1G',
      server_jvm_max_heap_size       => '2G',
      # Set ReservedCodeCache to 1G (recommended when working with 6-12 JRuby instances)
      # Not needed in my case, but could potentially be LOWERED in the future! 
      # server_jvm_extra_args          => '-XX:ReservedCodeCacheSize=1G',
    }
  }
  else
  {
    $puppet_tuning_parameters = {
      # Vagrant/testing - helpful to keep things from going cray-cray
      server_max_active_instances => 1,
      server_jvm_min_heap_size => '512m',
      server_jvm_max_heap_size => '1G',
    }
  }

  # Install and configure puppet-agent, puppet-server and foreman
  # will manage Java Memory settings in /etc/default/puppetserver
  class { '::puppet':
    # install puppet server
    server                      => true,
    # The version of the puppet-agent package.
    version                     => $puppet_agent_package_version,
    # the version of the puppetserver package.
    server_version              => $puppetserver_package_version,
    # used by foreman to setup the correct config options.
    server_puppetserver_version => $puppetserver_version,
    # Which Puppet environment to use
    environment                 => $puppet_environment,
    # disable integration with foreman (revisit this when we've looked into foreman more)
    server_foreman              => false,
    # disable getting external nodes from foreman
    server_external_nodes       => '',
    # Will manage puppetdb.conf for us
    server_puppetdb_host        => $puppet_dbserver,
    # only store the reports in the puppetdb
    server_reports              => 'puppetdb',
    server_storeconfigs_backend => 'puppetdb',
    server_user                 => $puppet_user,
    server_group                => $puppet_group,
    # We do not use a list of common modules to be shared between environments
    server_common_modules_path  => [],
    # The ::puppet class default hiera_config to the wrong value for puppet > 4.5
    # At the time of writing, puppet version is 4.5.3. Hardcode hiera_config here.
    hiera_config                => $hiera_yaml_path,

    # Manage additional puppet.conf settings:
    # [main] section
    additional_settings         => {
      # So that we will see failure to retrieve/compile the catalog
      # As run failure on our puppet board for all agents.
      # https://puppet.com/docs/puppet/latest/configuration.html#usecacheonfailure
      usecacheonfailure => false,
      },
    # [agent] section
    agent_additional_settings   => {},
    # [master] section
    server_additional_settings  => {},

    # because ::puppet does set usecacheonfailure in the [agent] section as well.
    usecacheonfailure           => false,

    # We manage $puppet_user ourselves thank you very much.
    server_manage_user          => false,

    *                           => $puppet_tuning_parameters,

    require                     => [Class['puppetdb']],
  }

  class {'hiera':
    hiera_yaml     => $hiera_yaml_path,
    hiera_version  => $hiera_version,
    hierarchy      => $hiera_hierarchies,
    eyaml          => true,
    eyaml_version  => $eyaml_version,
    datadir        => '/etc/puppetlabs/code/environments',
    eyaml_datadir  => '/etc/puppetlabs/code/environments',
    datadir_manage => false,
    provider       => 'puppetserver_gem',
    # don't want a symlink at /etc/hiera.yaml as this breaks our tests
    create_symlink => false,
    #restart puppetserver so that puppet picks up the hiera config changes.
    master_service => 'puppetserver',
    require        => User[$puppet_user],
  }

  # Add a symlink to the eyaml binary to /opt/puppetlabs/bin/ which is already
  # included in the system PATH
  file {'/opt/puppetlabs/bin/eyaml':
    ensure  => link,
    target  => '/opt/puppetlabs/puppet/bin/eyaml',
    require => Class['hiera'],
  }
}
