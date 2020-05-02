# Puppet Example Repo
This is an example repo to demonstrate how to set up your environment to get it to work with the scripts in the [Puppet-Provisioning](https://github.com/shoddyguard/Puppet-Provisioning) repo.  
There's also some example Puppet modules here that you may find useful in demonstrating how things work.
The modules don't actully work so don't try to use them! 

The most interesting stuff happens in the [hiera.yaml](hiera.yaml) file where we define what our hiera configuration looks like.
This particular configuration uses trusted facts that get set during a machines certificate request (see https://puppet.com/docs/puppet/latest/ssl_attributes_extensions.html)
This allows you to move all of your node classifications out of site.pp and into hiera.
This is useful when have you have the same setup for a lot of nodes just differing parameters.

The basic premise is that when you setup Puppet on a node, you create a csr with three extra parameters:  
`pp_service`, `pp_role`, `pp_environment`  
This allows you to begin working up the chain in hiera to build your node classification:
* `data/common.yaml` & `data/common.eyaml` - apply to ALL nodes
* `data/services/<pp_service>/common.eyaml` - applies to all nodes in that are part of that particular `<pp_service>`
* `data/services/<pp_service>/<pp_role>.eyaml` - applies to all nodes that are part of `<pp_service>` and `<pp_role>`
* `data/services/<pp_service>/<pp_environment>/common.eyaml` - applies to all nodes in a given `pp_environment` for a particular `pp_service`
* `data/services/<pp_service>/<pp_environment>/<pp_role>.eyaml` 
* `data/services/<pp_service>/<pp_environment>/<certificate_name>.eyaml`

## Example
**Mycorp** has 2 webservers:
* Web01.mycorp.com - their main public facing webserver
* stagingserver.mycorp.com - their staging/testing server

Both servers are connected to Puppet and when they had their certificates created they had the following defined:
* `pp_service`: webserver
* `pp_role`: apache_webserver

Web01 had it's `pp_environment` defined as `live` while staginingserver had it's defined as `staging`.
The following conigurations would apply to both nodes:
* `data/common.yaml` & `data/common.eyaml` - these apply to ALL nodes for Mycorp but as the files don't contain anything in this instance there's nothing to do here.
* `data/services/webserver/common.eyaml` - this applies to any nodes which have webserver set as their pp_service
* `data/services/webserver/apache_webserver.eyaml` - this applies to any node with webserver as it's pp_service and apache_webserver as it's pp_role