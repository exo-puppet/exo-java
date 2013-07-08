# Class: java::params
#
# This class manages the java parameters for different OS
class java::params {
  case $::operatingsystem {
    /(Ubuntu|Debian)/ : {
      $installRootDir = '/usr/lib/jvm'
      $downloadDir    = '/home/puppet-java'
    }
    default           : {
      fail("The ${module_name} module is not supported on ${::operatingsystem}")
    }
  }
}
