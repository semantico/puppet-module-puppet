
class puppet::puppetmaster::passenger26 {

    # Puppetmaster Passenger config for Puppet 2.6.x and 2.7.x

    $puppetmaster_servertype = 'passenger'

    include puppet::puppetmaster
    include apache::module::ssl

    include puppet::puppetmaster::reports_prune

    apache::vhost { "puppetmaster":
        template_name => "puppet/passenger26-apache2.conf",
    }

    exec { "/bin/rm -f ${vhost_enabled_dir}/puppetmasterd":
        onlyif => "/usr/bin/test -L ${vhost_enabled_dir}/puppetmasterd",
        notify => Exec["reload-apache2"],
    }

    File { owner => puppet, group => puppet, mode  => 0640, }
    Dir  { owner => root, group => puppet, mode  => 0755, }

    package { "puppetmaster-passenger":
        ensure => $puppet_client_upgrade ? {
            "2.7" => '2.7.16-1puppetlabs1',
            default => present
        },
    }
    package { "libapache2-mod-passenger": }
    package { "rails": }
    package { "librack-ruby": }

    file { "/etc/puppet/rack":
        ensure => absent,
        recurse => true,
        force => true,
    }

    file { "/etc/puppet/rack/config.ru":
        ensure => absent,
    }

    dir { "/usr/share/puppet/rack": }
    dir { "/usr/share/puppet/rack/puppetmasterd": }

    file { "/usr/share/puppet/rack/puppetmasterd/config.ru":
        content => template("puppet/puppetmaster/passenger/config.ru"),
        owner => puppet,
        group => puppet,
        mode => 0644,
        notify => Exec["reload-apache2"],
    }

    file { "/etc/apache2/conf.d/puppetmaster":
        content => "User puppet\nGroup puppet\n",
        owner => root,
        group => root,
        mode => 0444,
    }

    file { "/etc/default/puppetmaster":
        content => template("puppet/puppetmaster.default"),
        require => Class["puppet::puppetmaster"],
    }

}
