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
#   this variable allows to choose the architecture of the package to install (values : "x64" or "i586" for java 6 and "amd64" or
#   "i586" for java 5)
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
#    java::install {
#        "sun-java6-i586" :
#            version => "6u30-b12",
#            arch => "i586",
#            defaultJava => true,
#    }
#
################################################################################
define java::install (
  $vendor      = 'sun',
  $version,
  $arch,
  $defaultJava = false) {

  # modules dependencies
  include repo
  include wget

  # internal classes
  include java::params, java::config

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin' }



  if !($vendor in [
    'sun']) {
    fail('unknow java vendor $vendor . Please use "sun".')
  }

  if !($arch in [
    'x64',
    'amd64',
    'i586']) {
    fail('unknow architecture $arch . Please use "x64" or "i586" for java 6 and "amd64" or "i586" for java 5')
  }

  $installDir = "${java::params::installRootDir}/jdk-${vendor}-${version}-${arch}"

  case $vendor {
    /(sun)/ : {
      # Extract the major version removing the beta
      $major   = inline_template('<%= scope.lookupvar(\'version\').split(\'-\')[0].gsub(\'.\', \'_\') %>')
      $file    = "jdk-${major}-linux-${arch}.bin"
      $url     = "http://storage.exoplatform.org/public/java/jdk/sun/${version}/${file}"
      $jdk_dir = "jdk-${major}-sun-${arch}"
    }
    default : {
      fail("The ${vendor} vendor is not supported")
    }
  }

  if ($defaultJava) {
    $priority = 10000
  } else {
    $priority = 5000
  }

  Class['java::params'] -> Class['java::config'] -> # Download the archive
  wget::fetch { "download-java-installer-${vendor}-${version}-${arch}":
    source_url       => $url,
    target_directory => $java::params::downloadDir,
    target_file      => $file,
    require          => File[$java::params::downloadDir],
  } -> # Fix archive rights
  file { "${java::params::downloadDir}/${file}":
    ensure => present,
    mode   => 755,
  } -> # Generates installer script
  file { "${java::params::downloadDir}/puppet-install-java-${vendor}-${version}-${arch}.sh":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0744,
    content => template('java/puppet-install-java.sh.erb'),
  } -> # Process the installation
  exec { "puppet-java-install-${vendor}-${version}-${arch}":
    command => "${java::params::downloadDir}/puppet-install-java-${vendor}-${version}-${arch}.sh",
    unless  => "test -d ${installDir}/jre/bin",
  }

  # Registers java using update-alternatives
  exec { "puppet-java-install-alternatives-java-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/java java ${installDir}/bin/java ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  # Registers javac using update-alternatives
  exec { "puppet-java-install-alternatives-javac-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/javac javac ${installDir}/bin/javac ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  # Registers jar using update-alternatives
  exec { "puppet-java-install-alternatives-jar-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/jar jar ${installDir}/bin/jar ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  # Registers jhat using update-alternatives
  exec { "puppet-java-install-alternatives-jhat-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/jhat jhat ${installDir}/bin/jhat ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  # Registers jstat using update-alternatives
  exec { "puppet-java-install-alternatives-jstat-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/jstat jstat ${installDir}/bin/jstat ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  # Registers jps using update-alternatives
  exec { "puppet-java-install-alternatives-jps-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/jps jps ${installDir}/bin/jps ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  # Registers jmap using update-alternatives
  exec { "puppet-java-install-alternatives-jmap-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/jmap jmap ${installDir}/bin/jmap ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  # Registers jstack using update-alternatives
  exec { "puppet-java-install-alternatives-jstack-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install /usr/bin/jstack jstack ${installDir}/bin/jstack ${priority}",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  if ($defaultJava) {
    # Set as default java using update-alternatives
    exec { "puppet-java-update-alternatives-java-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set java ${installDir}/bin/java",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-java-${vendor}-${version}-${arch}"
        ],
    }

    # Set as default javac using update-alternatives
    exec { "puppet-java-update-alternatives-javac-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set javac ${installDir}/bin/javac",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-javac-${vendor}-${version}-${arch}"
        ],
    }

    # Set as default jar using update-alternatives
    exec { "puppet-java-update-alternatives-jar-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set jar ${installDir}/bin/jar",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-jar-${vendor}-${version}-${arch}"
        ],
    }

    # Set as default jhat using update-alternatives
    exec { "puppet-java-update-alternatives-jhat-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set jhat ${installDir}/bin/jhat",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-jhat-${vendor}-${version}-${arch}"
        ],
    }

    # Set as default jstat using update-alternatives
    exec { "puppet-java-update-alternatives-jstat-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set jstat ${installDir}/bin/jstat",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-jstat-${vendor}-${version}-${arch}"
        ],
    }

    # Set as default jps using update-alternatives
    exec { "puppet-java-update-alternatives-jps-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set jps ${installDir}/bin/jps",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-jps-${vendor}-${version}-${arch}"
        ],
    }

    # Set as default jmap using update-alternatives
    exec { "puppet-java-update-alternatives-jmap-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set jmap ${installDir}/bin/jmap",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-jmap-${vendor}-${version}-${arch}"
        ],
    }

    # Set as default jstack using update-alternatives
    exec { "puppet-java-update-alternatives-jstack-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set jstack ${installDir}/bin/jstack",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "puppet-java-install-alternatives-jstack-${vendor}-${version}-${arch}"
        ],
    }
  }
}
