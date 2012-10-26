
class puppet::service {

    $f_dir = "/var/lib/puppet/modules/puppet/files"

    include puppet::common

    case $operatingsystem {
        debian: { package { puppet: ensure => lookup_value("${environment}-puppet-version", "2.7.16" } }
        ubuntu: { package { puppet: ensure => lookup_value("${environment}-puppet-version", "2.7.16" } }
        centos: { package { puppet: ensure => lookup_value("${environment}-puppet-version", "2.6.17-2.el6" } }
        redhat: { package { puppet: ensure => lookup_value("${environment}-puppet-version", "2.6.17-2.el6" } }
    }

    case $operatingsystem {
        debian: { package { puppet: ensure => lookup_value("${environment}-facter-version", "1.6.4" } }
        ubuntu: { package { puppet: ensure => lookup_value("${environment}-facter-version", "1.6.4" } }
        centos: { package { puppet: ensure => lookup_value("${environment}-facter-version", "1.6.6-1.el6" } }
        redhat: { package { puppet: ensure => lookup_value("${environment}-facter-version", "1.6.6-1.el6" } }
    }

    File {
        owner => "root",
        group => "puppet",
        mode  => 0440,
    }

    #used in manufacturer custom fact
    realize Package[pciutils]

    service { puppet:
        name   => $operatingsystem ? {
             Solaris => "puppetd",
             default => "puppet"
            },
        ensure => stopped,
        pattern => "ruby /usr/sbin/puppetd -w 0"
    }

    #puppet will run without the shadow bindings, but won't be able to manipulate user accounts..
    case $operatingsystem {
        RedHat,CentOS: {
            package { "ruby-shadow": ensure => present }
            realize Package["dmidecode"]
        }
        Debian,Ubuntu: {
            file { "/etc/default/puppet":
                content => template("puppet/puppet.default"),
                require => Package['puppet'],
            }
            realize Package["dmidecode"]
        }
    }

    file { "puppet.conf":
        path   => "/etc/puppet/puppet.conf",
        content => template("puppet/puppet.conf"),
        mode   => 0640,
    }

    file { "puppetrun":
        path   => "/usr/local/bin/puppetrun",
        content => template("puppet/puppetrun"),
        mode   => 0555,
    }

    file { "kill_puppet":
        path   => "/usr/local/bin/kill_puppet",
        content => template("puppet/kill_puppet"),
        mode   => 0555,
    }

    file { "puppetd.conf":
        path   => "/etc/puppet/puppetd.conf",
        ensure => absent,
    }

    file { "/var/lib/puppet/state/modules":
        ensure => directory,
        mode => 1777,
    }

    file { "/var/lib/puppet/state/last_pm_connect":
        mode => 0444,
        content => "${date}\n",
    }

    # R.I's tool for looking at compiled local catalog
    file { "/usr/local/bin/parselocalconfig":
        content => file("$f_dir/parselocalconfig"),
        mode => 0555,
    }

    # Very simple tool for querying puppetmaster with correct settings
    # -- handy for testing connectivity
    file { "/usr/local/bin/pupcurl":
        tag => 'autoapply',
        content => file("$f_dir/pupcurl"),
        mode => 0550,
    }

}

