#!/bin/bash

# install EPEL
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -O /root/epel-release-6-8.noarch.rpm
rpm -vhi /root/epel-release-6-8.noarch.rpm
sed -i /etc/yum.repos.d/epel.repo -e 's/https:/http:/'

yum repolist

# install some software
yum -y install ruby-devel redhat-lsb puppet-server

# seed site.pp
cat << EOF > /etc/puppet/manifests/site.pp
# Define filebucket 'main':
filebucket { 'main':
  server => 'puppet.learnpuppet.net',
  path   => false,
}

# Ignoring version control artifacts
File {
  backup => 'main',
  ignore => [ '.svn',
              '.git',
              'CVS',
              '.bzr' ],
}

if versioncmp($::puppetversion,'3.6.1') >= 0 {

  \$allow_virtual_packages = hiera('allow_virtual_packages',false)

  Package {
    allow_virtual => \$allow_virtual_packages,
  }
}
EOF

# handle environments
mkdir /etc/puppet/environments/production
ln -s /etc/puppet/manifests /etc/puppet/environments/production/manifests
ln -s /etc/puppet/modules /etc/puppet/environments/production/modules

# Handle an error with Puppet
# https://tickets.puppetlabs.com/browse/PUP-3324
mkdir -p /etc/puppet/modules/PUP3324/facts.d

# install some gems
gem install -V rake -v 10.5.0 --no-ri --no-rdoc
gem install -V --no-ri --no-rdoc \
  puppet-lint \
  puppetlabs_spec_helper \
  rspec-puppet \
  librarian-puppet-simple \
  bundler

# install puppet skeleton
cd ~
git clone https://github.com/ghoneycutt/puppet-module-skeleton
mkdir -p `puppet config print vardir`/puppet-module/skeleton/
rsync -avp --exclude .git puppet-module-skeleton/ `puppet config print vardir`/puppet-module/skeleton/
cp /vagrant/Rakefile `puppet config print vardir`/puppet-module/skeleton/

# setup puppet.conf
cat << EOF > /etc/puppet/puppet.conf
[main]
    # The Puppet log directory.
    # The default value is '\$vardir/log'.
    logdir = /var/log/puppet

    # Where Puppet PID files are kept.
    # The default value is '\$vardir/run'.
    rundir = /var/run/puppet

    # Where SSL certificates are kept.
    # The default value is '\$confdir/ssl'.
    ssldir = \$vardir/ssl

    # there can be only one
    ca = true

    # autosign certs
    autosign = true

    # alternative names on the cert (SAN's)
    dns_alt_names = puppet.learnpuppet.net,puppet

    # module lookup order
    #   1st - modules per environment with r10k (environmentpath)
    #   2nd - modules from Garrett Honeycutt (basemodulepath)
    environmentpath = /etc/puppet/environments
    basemodulepath = /var/local/ghoneycutt-modules/modules

    # allow for structured facts
    stringify_facts = false

[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '\$confdir/classes.txt'.
    classfile = \$vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '\$confdir/localconfig'.
    localconfig = \$vardir/localconfig

    server = puppet.learnpuppet.net
    ca_server = puppet.learnpuppet.net
    report = true
    graph = true
    pluginsync = true

[master]
#  storeconfigs_backend = puppetdb
#  storeconfigs = true
  reports = store
  ignorecache = true
EOF

# install puppet modules
git clone https://github.com/ghoneycutt/puppet-modules.git /var/local/ghoneycutt-modules

# update modules
cd /var/local/ghoneycutt-modules
git pull
rake install
chown -R vagrant /var/local/ghoneycutt-modules
