class elasticsearch::munin (

    $all_nodes_graph,

    ) { 

    #Sanitize boolean for perl
    $all_graphs = $all_nodes_graph ? {
      true  => 1,
      default => 0,
    }

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
