
class puppet::puppetmaster {

    $f_dir = "/var/lib/puppet/modules/puppet/files"

    File {
        owner => root,
        group => root,
        mode  => 0644,
    }

    case $operatingsystem {
        debian: { package { puppetmaster: ensure => present, } }
        ubuntu: { package { puppetmaster: ensure => present, } }
        centos: { package { puppet-server: ensure => present, } }
        redhat: { package { puppet-server: ensure => present, } }
    }

    # Puppetmasters need mkpasswd to be able to auto-create missing password hashes that are required
    case $lsbdistcodename {
        sarge,etch,lenny,hardy,karmic,jaunty: {
            # These seem to have mkpasswd within the whois package!
        }
        redhat,centos: {
            # mkpasswd doesn't have a package
        }
        default: {
            package { "mkpasswd": ensure => present }
        }
    }

    include puppet::common

    if $puppetmaster_servertype != 'passenger' {
        #requires the puppetservice which contains the puppet.conf template
        service { puppetmaster:
            name   => $operatingsystem ? {
                default => "puppetmaster"
            },
            enable => false,
            hasstatus => true,
            require => Class["puppet::service"],
        }
    }

    file { "/etc/puppet/autosign.conf":
        content => template("puppet/autosign.conf"),
        mode   => 0644,
        group => puppet,
    }

    file { "/etc/puppet/fileserver.conf":
        group => puppet,
        mode  => 0440,
        content => template('puppet/fileserver.conf'),
    }


}

