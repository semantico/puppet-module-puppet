# a config.ru, for use with every rack-compatible webserver.
# SSL needs to be handled outside this, though.

# if puppet is not in your RUBYLIB:
# $:.unshift('/opt/puppet/lib')

$0 = "master"

# if you want debugging:
# ARGV << "--debug"

ARGV << "--rack"

# Log to a file in addition to syslog
ARGV << "--logdest" << "/var/log/puppet/puppetmaster.log"

require 'puppet/application/master'
# we're usually running inside a Rack::Builder.new {} block,
# therefore we need to call run *here*.
run Puppet::Application[:master].run

