# Puppet Example Repo
This is an example repo to demonstrate how to set up your environment to get it to work with the scripts in the [Puppet-Provisioning](https://github.com/shoddyguard/Puppet-Provisioning) repo.  

This branch is a fully functioning example of how to bootstrap a Puppet6 environment using the [puppetmaster.sh](https://github.com/shoddyguard/Puppet-Provisioning/blob/master/puppetmaster.sh) script.

## Getting started
To start with you'll need to create your own repository by clicking the ["Use this template"](https://github.com/shoddyguard/puppet_hiera_example/generate) button.
I'd suggest making any production repositories private, but if you're just testing then by all means go ahead and leave it as public.

If you're setting up a brand new environment or haven't used hiera-eyaml before then you'll want to generate a set of keys and save these for later.

Once you've got your new repo edit the `modules\example_puppetserver\templates\r10k.yaml.erb` file to point to the ssh address of your shiny new git repo.

If you want to test in a virtual machine then I'd suggest following the testing instructions in the [Puppet-Provisioning](https://github.com/shoddyguard/Puppet-Provisioning) repo to use Vagrant to make this simple as peas.

If you're doing this on a physical machine then you'll need to `wget https://raw.githubusercontent.com/shoddyguard/Puppet-Provisioning/master/puppetmaster.sh` and run that.