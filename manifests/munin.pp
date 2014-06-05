class elasticsearch::munin (

    $all_graphs

    ) { 

    file { 'elasticsearch_munin':
        path    => '/usr/share/munin/plugins/elastisearch',
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => 755,
        content => template("elasticsaerch/elasticsearch_munin.erb")
    }

    file { 'elasticsearch_index_size':
        path    => '/etc/munin/plugin/elasticsearch_index_size',
        ensure  => 'link',
        target  => '/usr/share/munin/plugins/elastisearch',
    }

    file { 'elasticsearch_docs':
        path    => '/etc/munin/plugin/elasticsearch_docs',
        ensure  => 'link'
        target  => '/usr/share/munin/plugins/elastisearch',
    }
}
