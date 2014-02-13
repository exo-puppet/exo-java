define java::alternative (
  $defaultJava,
  # oracle / sun / ...
  $vendor,
  $version,
  $arch,
  # java / javac / ...
  $binary_name,
  # /usr/lib/jvm/jdk-oracle-7u45-x64/bin or /usr/lib/jvm/jdk-oracle-7u45-x64/jre/bin/ or ...
  $binary_dir,
  # /usr/bin
  $binary_link_dir,
) {

  if $defaultJava == true {
    $priority = 10000
  } else {
    $priority = 5000
  }

  # Registers an alternative
  exec { "java-alternatives-install-${binary_name}-${vendor}-${version}-${arch}":
    command   => "update-alternatives --install ${binary_link_dir}/${binary_name} ${binary_name} ${binary_dir}/${binary_name} ${priority}",
    logoutput => "on_failure",
    unless    => "update-alternatives --list ${binary_name} | grep \"^${binary_dir}/${binary_name}$\"",
    subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}"],
  }

  if $defaultJava == true {
    # Set as default alternative
    exec { "puppet-alternatives-update-${binary_name}-default-${vendor}-${version}-${arch}":
      command   => "update-alternatives --set ${binary_name} ${binary_dir}/${binary_name}",
      logoutput => "on_failure",
      unless    => "test $(readlink -e ${binary_link_dir}/${binary_name}) = ${binary_dir}/${binary_name}",
      subscribe => Exec["puppet-java-install-${vendor}-${version}-${arch}", "java-alternatives-install-${binary_name}-${vendor}-${version}-${arch}"],
    }
  }
}
