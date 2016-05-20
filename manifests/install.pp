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
#   this variable allows to select the vendor of the jvm (values: sun (java 6), oracle (java 7+). TODO : ibm, jrockit, openjdk)
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
#            defaultJava => false,
#    }
#
#    java::install {
#        "oracle-java7-i586" :
#            version => "7u25",
#            arch => "x64",
#            defaultJava => true,
#    }
#
################################################################################
define java::install (
  $vendor       = 'sun',
  $version,
  $arch,
  $defaultJava  = false,
  $downloadDir  = '/srv/download') {

  # modules dependencies
  include stdlib
  include wget

  # internal classes
  require java::params

  Exec {path => '/bin:/sbin:/usr/bin:/usr/sbin' }

  if !($arch in ['x64','amd64','i586']) {
    fail('unknow architecture $arch . Please use "x64" or "i586" for java 6 and "amd64" or "i586" for java 5')
  }

  $installDir = "${java::params::installRootDir}/jdk-${vendor}-${version}-${arch}"

  case $vendor {
    # Java <= 6 are using the vendor sun
    /(sun)/ : {
      # Extract the major version removing the beta
      $major   = inline_template('<%= scope.lookupvar(\'version\').split(\'-\')[0].gsub(\'.\', \'_\') %>')
      $file    = "jdk-${major}-linux-${arch}.bin"
      $jdk_dir = "jdk-${major}-${vendor}-${arch}"
    }
    # Java > 6 are using the vendor oracle
    /(oracle)/ : {
      $file    = "jdk-${version}-linux-${arch}.tar.gz"
      $jdk_dir = "jdk-${version}-${vendor}-${arch}"
    }
    default : {
      fail("The ${vendor} vendor is not supported")
    }
  }

  # eXo dedicated storage to avoid license controls from oracle that don't allow to automate the process
  # We manually download the binary and validate the license once from oracle and upload them here
  $url = "http://storage.exoplatform.org/public/java/jdk/${vendor}/${version}/${file}"

  # Packaged required by the installer
  ensure_packages ('g++-multilib', { 'require' => Class['apt::update'] })

  Class['java::params'] ->
  # Download the archive
  wget::fetch { "download-java-installer-${vendor}-${version}-${arch}":
    source_url       => $url,
    target_directory => $downloadDir,
    target_file      => $file,
    require          => File[$downloadDir],
  } ->
  # Generates installer script
  file { "${downloadDir}/puppet-install-java-${vendor}-${version}-${arch}.sh":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0744,
    content => template('java/puppet-install-java.sh.erb'),
  } ->
  # Process the installation
  exec { "puppet-java-install-${vendor}-${version}-${arch}":
    command => "${downloadDir}/puppet-install-java-${vendor}-${version}-${arch}.sh",
    unless  => "test -d ${installDir}/jre/bin",
    require => Package['g++-multilib'],
  }

  # Registers java using update-alternatives
  java::alternative { "java-alternatives-java-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'java',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers javac using update-alternatives
  java::alternative { "java-alternatives-javac-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'javac',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers jar using update-alternatives
  java::alternative { "java-alternatives-jar-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'jar',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers jhat using update-alternatives
  java::alternative { "java-alternatives-jhat-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'jhat',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers jstat using update-alternatives
  java::alternative { "java-alternatives-jstat-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'jstat',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers jps using update-alternatives
  java::alternative { "java-alternatives-jps-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'jps',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers jmap using update-alternatives
  java::alternative { "java-alternatives-jmap-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'jmap',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers jstack using update-alternatives
  java::alternative { "java-alternatives-jstack-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'jstack',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }



  # Registers jexec using update-alternatives
  java::alternative { "java-alternatives-jexec-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'jexec',
    binary_dir      => "${installDir}/lib",
    binary_link_dir => '/usr/bin',
  }

  # Registers keytool using update-alternatives
  java::alternative { "java-alternatives-keytool-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'keytool',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers orbd using update-alternatives
  java::alternative { "java-alternatives-orbd-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'orbd',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers pack200 using update-alternatives
  java::alternative { "java-alternatives-pack200-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'pack200',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }




  # Registers rmid using update-alternatives
  java::alternative { "java-alternatives-rmid-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'rmid',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers rmiregistry using update-alternatives
  java::alternative { "java-alternatives-rmiregistry-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'rmiregistry',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers servertool using update-alternatives
  java::alternative { "java-alternatives-servertool-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'servertool',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers tnameserv using update-alternatives
  java::alternative { "java-alternatives-tnameserv-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'tnameserv',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

  # Registers unpack200 using update-alternatives
  java::alternative { "java-alternatives-unpack200-${vendor}-${version}-${arch}":
    defaultJava     => $defaultJava,
    vendor          => $vendor,
    version         => $version,
    arch            => $arch,
    binary_name     => 'unpack200',
    binary_dir      => "${installDir}/bin",
    binary_link_dir => '/usr/bin',
  }

}
