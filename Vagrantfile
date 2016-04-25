# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  #use 'vagrant plugin install vagrant-proxyconf' to install
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if ENV.has_key?('HTTP_PROXY')
      config.proxy.http=ENV['HTTP_PROXY']
    end
    if ENV.has_key?('HTTPS_PROXY')
      config.proxy.https=ENV['HTTPS_PROXY']
    end
    config.proxy.no_proxy="localhost,127.0.0.1"
  end

  config.vm.box = "centos65"
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box"
  config.vm.hostname = "puppet.learnpuppet.net"


  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision "shell", path: "bootstrap.sh"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
  end
end
