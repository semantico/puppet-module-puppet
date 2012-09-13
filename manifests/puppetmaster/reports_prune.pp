class puppet::puppetmaster::reports_prune {

    tag("autoapply")

    $reports_keep_days = 10

    #cron to purge old war files from
    cron { puppet-reports-prune-cron:
        user => root,
        hour => 3,
        minute => 0,
        environment => "PATH=/usr/sbin:/usr/bin:/sbin:/bin",
        command => "find /var/www -mtime +${reports_keep_days} -name '*.yaml' -delete > /dev/null 2>&1",
    }


}
