################################################################################
#
#   This module manages the SUN/sun Java JDK installation.
#
#   Tested platforms:
#    - Ubuntu 11.04 Natty
#
# == Parameters
#
# [+editor+]
#   (OPTIONAL) (default: sun) 
#   
#   this variable allows to select the vendor of the jvm (values: sun. TODO : ibm, jrockit, openjdk)
#
# [+version+]
#   
#   this variable allows to choose the version of the JDK to install
#
# [+arch+]
#   
#   this variable allows to choose the architecture of the package to install (values : "x64" or "i586" for java 6 and "amd64" or "i586" for java 5)
#
# [+defaultJava+]
#   (OPTIONAL) (default: false) 
#   
#   this variable allows to activate this java version by default on your system. 
#
# == Modules Dependencies
#
# [+wget+]
#   the +wget+ puppet module is used to download java packages (java::install)
#
# == Examples
#
#    java {
#        "sun-java6-i586" :
#            version => "6u30-b12",
#            arch => "i586",
#            defaultJava => true,
#    }
#
################################################################################
class java ($vendor = "sun", $version, $arch, $defaultJava = false) {
    include repo

    if !($vendor in ["sun"]) {
        fail('unknow java vendor $vendor . Please use "sun".')
    }
    if !($arch in ["x64", "amd64", "i586"]) {
        fail('unknow architecture $arch . Please use "x64" or "i586" for java 6 and "amd64" or "i586" for java 5')
    }

    include java::params, java::install
}