#!/bin/bash

# install EPEL
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -O /root/epel-release-6-8.noarch.rpm
rpm -vhi /root/epel-release-6-8.noarch.rpm

# install some software
yum -y install colordiff ruby-devel redhat-lsb

# install some gems
gem install -V --no-ri --no-rdoc rspec -v 2.14.1
gem install -V --no-ri --no-rdoc rake -v 10.3.1
gem install -V --no-ri --no-rdoc puppet-lint -v 0.3.2
gem install -V --no-ri --no-rdoc rspec-core -v 2.14.8
gem install -V --no-ri --no-rdoc rspec-expectations -v 2.14.5
gem install -V --no-ri --no-rdoc rspec-mocks -v 2.14.6
gem install -V --no-ri --no-rdoc thor -v 0.19.1
gem install -V --no-ri --no-rdoc librarian-puppet-simple -v 0.0.3
gem install -V --no-ri --no-rdoc puppetlabs_spec_helper -v 0.4.1
gem install -V --no-ri --no-rdoc rspec-puppet -v 1.0.1
gem uninstall -V rspec-expectations -v 3.0.2
gem uninstall -V rspec-mocks -v 3.0.2
gem uninstall -V rspec-core -v 3.0.2

# update system
yum -y update puppet hiera facter tzdata

# install puppet skeleton
cd ~
git clone https://github.com/ghoneycutt/puppet-module-skeleton
mkdir -p `puppet config print vardir`/puppet-module/skeleton/
rsync -avp --exclude .git puppet-module-skeleton/ `puppet config print vardir`/puppet-module/skeleton/

# install puppet modules
rm -fr /usr/share/puppet/modules
ln -s /usr/share/puppet/puppet-modules/modules /usr/share/puppet/modules
cd /usr/share/puppet && git clone git://github.com/ghoneycutt/puppet-modules.git && cd puppet-modules && librarian-puppet install --verbose
