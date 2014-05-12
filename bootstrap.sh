#!/bin/bash

# install EPEL
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -O /root/epel-release-6-8.noarch.rpm
rpm -vhi /root/epel-release-6-8.noarch.rpm

# install some software
yum -y install colordiff ruby-devel redhat-lsb puppet-server

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
EOF

# install some gems
gem install -V puppet-lint puppetlabs_spec_helper rake rspec-puppet librarian-puppet-simple --no-ri --no-rdoc

# update system
yum -y update

# install puppet skeleton
cd ~
git clone https://github.com/ghoneycutt/puppet-module-skeleton
mkdir -p `puppet config print vardir`/puppet-module/skeleton/
rsync -avp --exclude .git puppet-module-skeleton/ `puppet config print vardir`/puppet-module/skeleton/

# install puppet modules
cd /usr/share/puppet && cp /vagrant/Puppetfile . && librarian-puppet install --verbose

# install RVM
#curl -sSL https://get.rvm.io | bash -s stable
#source /etc/profile.d/rvm.sh

# Not actually doing this as it takes forever to compile and bootstrap the VM
#
#for version in 1.9.3 2.0.0
#do
#  rvm install $version
#done
