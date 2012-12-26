# Class: puppetdb::database::postgresql
#
# This class manages a postgresql server and database instance suitable for use
# with puppetdb.  It uses the `inkling/postgresql` puppet module for getting
# the postgres server up and running, and then also for creating the puppetdb
# database instance and user account.
#
# This class is intended as a high-level abstraction to help simplify the process
# of getting your puppetdb postgres server up and running; for maximum
# configurability, you may choose not to use this class.  You may prefer to
# use `inkling/postgresql` directly, use a different puppet postgres module,
# or manage your postgres setup on your own.  All of these approaches should
# be compatible with puppetdb.
#
# Parameters:
#   ['listen_addresses'] - A comma-separated list of hostnames or IP addresses
#                          on which the postgres server should listen for incoming
#                          connections.  (Defaults to 'localhost'.  This parameter
#                          maps directly to postgresql's 'listen_addresses' config
#                          option; use a '*' to allow connections on any accessible
#                          address.
# Actions:
# - Creates and manages a postgres server and database instance for use by
#   puppetdb
#
# Requires:
# - `camptocamp/postgresql`
#
# Sample Usage:
#   class { 'puppetdb::database::postgresql':
#       listen_addresses         => 'my.postgres.host.name',
#   }
#
class puppetdb::database::postgresql(
  # TODO: expose more of the parameters from `inkling/postgresql`!
  $listen_addresses       = $puppetdb::params::database_host,
  $manage_redhat_firewall = $puppetdb::params::manage_redhat_firewall,
  $database_name = $puppetdb::params::database_name,
  $database_username = $puppetdb::params::database_username,
  $database_password = $puppetdb::params::database_password,
) inherits puppetdb::params {


  ::postgresql::user {$database_username:
      ensure     => present,
      password   => $database_password,
      superuser  => false,
      createdb   => false,
      createrole => false,
  }

  ::postgresql::database {$database_name:
    ensure    => present,
    owner     => $database_username,
    encoding  => 'UTF8',
    template  => 'template1',
    overwrite => false,
    require   => Postgresql::User[$database_username],
  }

  ::postgresql::hba {'access to database puppetdb':
    ensure   => present,
    type     => 'local',
    database => $database_name,
    user     => 'all',
    method   => 'trust',
  }
}
