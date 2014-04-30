class elasticsearch (
  
  $esVersion,
  $esUser,
  $esUlimitNofile,
  $esUlimitMemlock,
  $esDataPath,
  $esLogPath,
  $esConfPath,
  $escluster,
  $esTCPPortRange,
  $esHTTPPortRange,
  $esClusterHosts,
  $esPlugins,
  $esLockAll,
  $esLogVerbose,
  $esDisableDynamic,
  $esAutoReload,
  $esInterval,
  $esUpgrade

  ) {

  $boolesUpgrade = any2bool($esUpgrade)

  package { 'elasticsearch':
    ensure  => $esVersion,
  }
     
  file { "/etc/security/limits.d/${esUser}.conf":
    ensure  => present,
    owner   => root,
    group   => root,
    content => template("elasticsearch/elasticsearch.limits.conf.erb"),
    notify  => Service['elasticsearch'],
    require => Package['elasticsearch']
  }
     
  # Apply config template for search
  file { "/etc/elasticsearch/elasticsearch.yml":
    content => template("elasticsearch/elasticsearch.yml.erb"),
    notify  => Service['elasticsearch'],
    require => Package['elasticsearch'],
  }
      
  file { "/etc/elasticsearch/logging.yml":
    content => template("elasticsearch/logging.yml.erb"),
    notify  => Service['elasticsearch'],
    require => Package['elasticsearch'],
  }

  # Ensure the service is running
  service { 'elasticsearch':
    enable => true,
    ensure => running,
    hasrestart => true,
  }

  define install_plugin {
    $plugin     = $name
    $plugindir  = regsubst ( regsubst( regsubst($plugin, '.*?/', '') , '.*?-', '') , '/.*', '')
    if $boolesUpgrade {
      exec { "remove plugin ${plugindir}" :
        command   => "/usr/share/elasticsearch/bin/plugin -r $plugindir --verbose",
        onlyif    => "test -d /usr/share/elasticsearch/plugins/$plugindir",
        notify   => Service['elasticsearch'],
        before   => Exec["install plugin ${plugindir}"],
        require  => Package['elasticsearch'],
     }
    }
    exec { "install plugin ${plugindir}": 
      command   => "/usr/share/elasticsearch/bin/plugin -i $plugin --verbose",
      creates   => "/usr/share/elasticsearch/plugins/$plugindir",
      notify    => Service['elasticsearch'],
      require   => Package['elasticsearch'],
    }
  }

  install_plugin { $esPlugins:}
}
