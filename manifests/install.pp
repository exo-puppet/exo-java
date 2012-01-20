# Class: java::install
#
# This class manages the installation of the java package
class java::install {
    Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }
    file {
        ["${java::params::install_dir}",
        "${java::params::install_dir}/${java::vendor}",
        "${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}"] :
            ensure => directory,
    }
    file {
        "${java::params::download_dir}" :
            ensure => directory,
    } ->
    # Download the archive
    wget::fetch {
        "download-java-installer" :
            source_url => "${java::params::url}",
            target_directory => "${java::params::download_dir}",
            target_file => "${java::params::file}",
    } ->
    # Fix archive rights
    file {
        "${java::params::download_dir}/${java::params::file}" :
            ensure => present,
            mode => 755,
    } ->
    # Copy file
    exec {"copy-jdk-${java::vendor}-${java::version}-${java::arch}":
        command => "cp -f ${java::params::download_dir}/${java::params::file} ${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::file}",
        creates => "${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::file}",
        unless => "/usr/bin/test -d ${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::jdk_dir}",
    } ->
    # Packaged required by the installer
    package{
        "g++-multilib":
        ensure => installed,
    } ->
    # Extract it
    exec{"extract-jdk-${java::vendor}-${java::version}-${java::arch}":
        command => "${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::file}", 
        cwd => "${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}",
        unless => "test -d ${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::jdk_dir}",
    } ->      
    # Remove the archive
    exec {"remove-tmp-${java::vendor}-${java::version}-${java::arch}":
        command => "rm -f ${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::file}", 
        onlyif => "test -f ${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::file}",     
    } ->    
    #If marked as default register it using update-alternatives
    exec{"update-alternatives-java-default-${java::vendor}-${java::version}-${java::arch}":
        command => "update-alternatives --install /usr/bin/java java ${java::params::install_dir}/${java::vendor}/${java::params::arch_dir}/${java::params::file}/${java::params::jdk_dir}/jre/bin/java ${java::params::priority}", 
        refreshonly => true,
    }
}
