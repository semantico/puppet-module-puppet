
class puppet::service {

    $f_dir = "/var/lib/puppet/modules/puppet/files"

    include puppet::common

    package { puppet:
        ensure => $puppet_client_upgrade ? {
            "2.7" => $operatingsystem ? {
                /(Debian|Ubuntu)/ => $lsbdistcodename ? {
                    'sarge' => '2.7.9-1puppetlabs3~1etch',
                    'etch' => '2.7.9-1puppetlabs3~1etch',
                    'lenny' => '2.7.9-1puppetlabs3~1etch',
                    default => '2.7.16-1puppetlabs1'
                },
                "RedHat" => $lsbmajdistrelease ? {
                    '4' => present,
                    default => '2.7.9-1.el5'
                },
                "CentOS" => $lsbmajdistrelease ? {
                    '4' => latest,
                    default => '2.7.9-1.el5'
                },
                default => present,
            },
            default => present
        }
    }

    package { facter:
        ensure => $puppet_client_upgrade ? {
            "2.7" => $operatingsystem ? {
                "CentOS" => $lsbmajdistrelease ? {
                    '4' => '1.6.4-1',
                    '5' => '1.6.4-1el5',
                    default => '1.6.4-1puppetlabs1'
                },
                "RedHat" => $lsbmajdistrelease ? {
                    '4' => present,
                    '5' => '1.6.4-1el5',
                    default => '1.6.4-1puppetlabs1'
                },
                default => present
            },
            default => present
        }
    }

    File {
        owner => "root",
        group => "puppet",
        mode  => 0440,
    }

    # MP - this should not be in puppet module - need to refactor out to
    # another class. Is it even required any more though?
    file { "$rubysitedir/cidr.rb":
        content => file("$f_dir/cidr.rb"),
        mode    => 0444,
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
            package { "dmidecode": ensure => present }
        }
        Debian,Ubuntu: {
            file { "/etc/default/puppet":
                content => template("puppet/puppet.default"),
                require => Package['puppet'],
            }
            realize Package[dmidecode]
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

