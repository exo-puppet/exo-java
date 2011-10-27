class java::default {
	$download_dir = "/home/download/jvm/sun"
	$install_dir = "/usr/lib/jvm"
	
	Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }
	
	# Create a Download directory (and all parents if necessary - puppet don't allow mkdir -p :( )
	file {["/home/download","/home/download/jvm",$download_dir]:
	    ensure => directory,
	    owner   => root,
	    group   => root,
	}
	
	# Create a directory to extract jvms (and all parents if necessary - puppet dont allow mkdir -p :( )
	file {["/usr/lib",$install_dir]:
	    ensure => directory,
	    owner   => root,
	    group   => root,
	}	
	
	package{
		"g++-multilib":
		ensure => installed,
	}
	
}

define download_file(
        $site="",
        $cwd="",
        $require="",
        $user="") {                                                                                         

    Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }

    exec { $name:                                                                                                                     
        command => "wget ${site}/${name}",                                                         
        cwd => $cwd,
        creates => "${cwd}/${name}",                                                              
        require => $require,
        user => $user,                      
        onlyif => "test ! -f ${cwd}/${name}",                                                                                    
    }

}

define java::install ($version,$arch,$defaultJava=false) {

    include java::default

    Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }

	$download_dir = "/home/download/jvm/sun"
	$install_dir = "/usr/lib/jvm"
		
	if ! ( "$arch" in ["x64","amd64","i586"]){
		fail('unknow architecture $arch . Please use "x64" or "i586" for java 6 and "amd64" or "i586" for java 5')
	}
    # Extract the major version removing the beta 
    $major = inline_template("<%= version.split('-')[0].gsub('.', '_') %>") 
    $url_base = "http://download.oracle.com/otn-pub/java/jdk/${version}"
    $file = "jdk-${major}-linux-${arch}.bin"
    notice ("Java will be downloaded from $url_base/$file")     

    # Download the file    
	download_file { "${file}":                                                                                                                                
	    site => "${url_base}",                                                                           
	    cwd => $download_dir,                                                                                                                                              
	    require => File[$download_dir],                                                                  
	    user => "root",
	    timeout => 300,                                                                                                              
	}    
	
	# Update rigths
	file {"$download_dir/${file}":
        ensure => file,
        owner   => root,
        group   => root,
        mode    => 755,
        require => Exec["${file}"], 
    }	
    
    # Extract and move it in
    exec{"extract-jdk-$name":
		command => "$download_dir/${file}", 
		cwd => $download_dir,
		require => [File["$install_dir","$download_dir/${file}"],Package["g++-multilib"]],
		onlyif => "test ! -d $install_dir/jdk-${major}-linux-${arch}",
	}     	
	
	# Move it
	exec{"move-jdk-$name":
		command => "mv -f $download_dir/jdk1* $install_dir/jdk-${major}-linux-${arch}", 
		require => [Exec["extract-jdk-$name"]],
		onlyif => "test ! -d $install_dir/jdk-${major}-linux-${arch}",
	}	

	if($defaultJava){
		#If marked as default register it using update-alternatives
		exec{"update-alternatives-java-default-$name":
			command => "update-alternatives --install /usr/bin/java java $install_dir/jdk-${major}-linux-${arch}/jre/bin/java 10000", 
			require => [Exec["move-jdk-$name"]],
		}			
	}else{
		exec{"update-alternatives-java-not-default-$name":
			command => "update-alternatives --install /usr/bin/java java $install_dir/jdk-${major}-linux-${arch}/jre/bin/java 5000", 
			require => [Exec["move-jdk-$name"]],
		}			
		
	}
}