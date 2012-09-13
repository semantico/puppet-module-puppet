class puppet::common {

    File { owner => puppet, group => puppet }

    file { "/var/lib/puppet":
        ensure => directory,
        mode => 2755,
    }

}
