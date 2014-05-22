class elasticsearch::java_sun (
  $version,
  $file,
  $source

) {

  exec { 'get_tar':
    cwd     => "/tmp",
    command => "/usr/bin/wget ${source}/${file}",
    creates => "/tmp/${package}",
  }

  exec { "untar jdk${version}":
    cwd     => "/opt",
    command => "/bin/tar xzvf /tmp/${file}",
    require => Exec['get_tar'],
    creates => "/opt/jdk${version}",
  }

  exec { 'update_alternatives':
    command => "/usr/sbin/update-alternatives --install /usr/bin/java java /opt/jdk${version}/bin/java 1;
                /usr/sbin/update-alternatives --install /usr/bin/javac javac /opt/jdk${version}/bin/javac 1;
                /usr/sbin/update-alternatives --set java /opt/jdk${version}/bin/java;
                /usr/sbin/update-alternatives --set javac /opt/jdk${version}/bin/javac",
    require => Exec["untar jdk${version}"],
    unless  => "/usr/sbin/update-alternatives --display java | /bin/grep /opt/jdk${version}/bin/java"
  }
}
