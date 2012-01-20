# Class: java::params
#
# This class manage the java parameters for different OS
class java::params {
    case $::operatingsystem {
        /(Ubuntu|Debian)/ : {
            $download_dir = "/var/cache/puppet-java"
            $install_dir = "/usr/lib/jvm"
        }
        default : {
            fail("The ${module_name} module is not supported on $::operatingsystem")
        }
    }
    case $java::vendor {
        /(sun)/ : {
           # Extract the major version removing the beta 
            $major = inline_template("<%= scope.lookupvar('java::version').split('-')[0].gsub('.', '_') %>")
            $file = "jdk-${major}-linux-${java::arch}.bin"
            $url = "http://download.oracle.com/otn-pub/java/jdk/${java::version}/${file}"
            $jdk_dir = "jdk-${major}-sun-${java::arch}"
        }
        default : {
            fail("The ${java::vendor} vendor is not supported")
        }
    }
    case $java::arch {
        /(i586)/ : {
            $arch_dir = "32b"
        }
        /(amd64|x64)/ : {
            $arch_dir = "64b"
        }
        default : {
            fail('unknow architecture ${java::arch} . Please use "x64" or "i586" for java 6 and "amd64" or "i586" for java 5')
        }
    }
    if ($java::defaultJava) {
        $priority = 10000
    }
    else {
        $priority = 5000
    }
}