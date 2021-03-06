class elasticsearch (
  
  $esVersion,
  $esUser,
  $esDataPath,
  $esLogPath,
  $esConfPath,
  $esCluster,
  $esTCPPortRange,
  $esHTTPPortRange,
  $esClusterHosts,
  $esPlugins,
  $esLockAll,
  $esLogVerbose,
  $esDisableDynamic,
  $esAutoReload,
  $esInterval,
  $esUpgrade,
  $esClauseCount,
  $esHeapSize,
  $esMaxOpenFiles,
  $esEligible_Master

  ) {

  $boolesUpgrade = any2bool($esUpgrade)

  package { 'elasticsearch':
    ensure  => $esVersion,
  }

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

  file { "/etc/init.d/elasticsearch":
    content => template('elasticsearch/elasticsearch.erb'),
    notify  => Service['elasticsearch'],
    require => Package['elasticsearch'],
    mode    => 744,
  }

  define install_plugin {
    $plugin     = $name
    $plugindir  = regsubst ( regsubst( regsubst($plugin, '.*?/', '') , '.*?-', '') , '/.*', '')
    if $boolesUpgrade {
      exec { "remove plugin ${plugindir}" :
        command   => "/usr/share/elasticsearch/bin/plugin -r $plugindir --verbose",
        onlyif    => "test -d /usr/share/elasticsearch/plugins/$plugindir",
        notify    => Service['elasticsearch'],
        before    => Exec["install plugin ${plugindir}"],
        require   => Package['elasticsearch'],
     }
    }
    exec { "install plugin ${plugindir}": 
      command => "/usr/share/elasticsearch/bin/plugin -i $plugin --verbose",
      creates => "/usr/share/elasticsearch/plugins/$plugindir",
      notify  => Service['elasticsearch'],
      require => Package['elasticsearch'],
    }
  }

  install_plugin { $esPlugins:}
}
