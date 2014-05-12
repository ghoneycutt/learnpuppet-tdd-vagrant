node default {
  include dnsclient
  include ntp
  include redhat
  include vim

  class { 'utils':
    packages => [ 'curl',
                  'nc',
                  'screen',
                  'strace',
                  'sysstat',
                  'tree',
                ],
  }
}
