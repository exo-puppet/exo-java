# Class: java::config
#
# This class manages the java puppet configuration
class java::config {

    file {
        "${java::params::downloadDir}" :
            ensure => directory,
            owner => root,
            group => root,
            mode => 0744,
    }    
    
    # Packaged required by the installer
    package{
        "g++-multilib":
        ensure => installed,
    } 
    
}