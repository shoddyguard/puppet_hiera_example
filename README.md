# Puppet Example Repo
This is an example repo to demonstrate how to set up your environment to get it to work with the scripts in the [Puppet-Provisioning](https://github.com/shoddyguard/Puppet-Provisioning) repo.  

This branch is a fully functioning example of how to bootstrap a **Puppet6** environment using the [puppetmaster.sh](https://github.com/shoddyguard/Puppet-Provisioning/blob/master/puppetmaster.sh) script.

## Getting started
To start with you'll need to create your own repository by clicking the ["Use this template"](https://github.com/shoddyguard/puppet_hiera_example/generate) button.
I'd suggest making any production repositories private, but if you're just testing then by all means go ahead and leave it as public.

If you're setting up a brand new environment or haven't used hiera-eyaml before then you'll want to generate a set of keys and save these for later.
To do this you'll need to install the Ruby gem:  
`gem install hiera-eyaml` and then create your keypair with `eyaml createkeys` you'll want to copy `private_key.pkcs7.pem` and `public_key.pkcs7.pem` for use later on.
I highly recommend keeping a copy of `private_key.pkcs7.pem` somewhere safe so if you ever loose it then you can still decrypt all your secrets.

Once you've got your new repo edit the `modules\example_puppetserver\templates\r10k.yaml.erb` file to point to the ssh address of your shiny new git repo.  
You'll probably also want to grab a copy of the r10k yaml for use in the provisioning script later on.

Now you're ready to get going, head on over to the [Puppet-Provisioning](https://github.com/shoddyguard/Puppet-Provisioning) repo to get the instructions on to use Vagrant to make this as easy as peas.

If you're doing this on a physical machine then you'll need to `wget https://raw.githubusercontent.com/shoddyguard/Puppet-Provisioning/master/puppetmaster.sh` and run the script following the instructions from the Puppet-Provisioning repo.