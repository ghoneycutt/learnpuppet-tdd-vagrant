node default {
  include dnsclient
  include ntp
  include redhat
  include vim

  class { 'utils':
    packages => [
      'colordiff',
      'curl',
      'screen',
      'strace',
      'sysstat',
      'tree',
    ],
  }
}
