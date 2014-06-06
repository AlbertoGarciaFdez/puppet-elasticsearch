class elasticsearch::munin (

    $all_graphs,

    ) { 

    file { 'elasticsearch_munin':
        path    => '/usr/share/munin/plugins/elasticsearch',
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => 755,
        content => template("elasticsearch/elasticsearch_munin.erb")
    }

    file { 'elasticsearch_index_size':
        path    => '/etc/munin/plugins/elasticsearch_index_size',
        ensure  => 'link',
        target  => '/usr/share/munin/plugins/elasticsearch',
        require => File['elasticsearch_munin'],
        notify  => Service['munin-node'],
    }

    file { 'elasticsearch_docs':
        path    => '/etc/munin/plugins/elasticsearch_docs',
        ensure  => 'link',
        target  => '/usr/share/munin/plugins/elasticsearch',
        require => File['elasticsearch_munin'],
        notify  => Service['munin-node'],
    }

    service { 'munin-node':
        ensure  => running 
    }
}
