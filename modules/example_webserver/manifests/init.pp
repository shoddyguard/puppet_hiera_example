# Class: example_webserver
#
#
class example_webserver
(
  $provider,
  $php_version,
  $cdn,
  Array $hostnames,
  $bind_address
)
{
  $hostnames.each | String $hostname | {
    Webserver { $hostname :
        provider => $provider,
        php_version => $php_version,
        cdn => $cdn,
        bind_address => $bind_address
    }
  }
}
