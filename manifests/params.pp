# The puppetdb default configuration settings.
class puppetdb::params {
  $listen_address            = 'localhost'
  $listen_port               = '8080'
  $open_listen_port          = false
  $ssl_listen_address        = $::fqdn
  $ssl_listen_port           = '8081'
  $disable_ssl               = false
  # This technically defaults to 'true', but in order to preserve backwards
  # compatibility with the deprecated 'manage_redhat_firewall' parameter, we
  # need to specify 'undef' as the default so that we can tell whether or
  # not the user explicitly specified a value.  See implementation in
  # `firewall.pp`.  We should change this back to `true` when we get rid
  # of `manage_redhat_firewall`.
  $open_ssl_listen_port      = undef
  $postgres_listen_addresses = 'localhost'
  # This technically defaults to 'true', but in order to preserve backwards
  # compatibility with the deprecated 'manage_redhat_firewall' parameter, we
  # need to specify 'undef' as the default so that we can tell whether or
  # not the user explicitly specified a value.  See implementation in
  # `postgresql.pp`.  We should change this back to `true` when we get rid
  # of `manage_redhat_firewall`.
  $open_postgres_port        = undef

  $database                  = 'postgres'

  # The remaining database settings are not used for an embedded database
  $database_host          = 'localhost'
  $database_port          = '5432'
  $database_name          = 'puppetdb'
  $database_username      = 'puppetdb'
  $database_password      = 'puppetdb'

  # These settings manage the various auto-deactivation and auto-purge settings
  $node_ttl               = '0s'
  $node_purge_ttl         = '0s'
  $report_ttl             = '14d'

  $puppetdb_version       = 'present'

  # TODO: figure out a way to make this not platform-specific
  $manage_redhat_firewall = undef

  $gc_interval            = '60'

  $log_slow_statements    = '10'
  $conn_max_age           = '60'
  $conn_keep_alive        = '45'
  $conn_lifetime          = '0'

  case $::osfamily {
    'RedHat': {
      $firewall_supported       = true
      $persist_firewall_command = '/sbin/iptables-save > /etc/sysconfig/iptables'
    }

    'Debian': {
      $firewall_supported       = false
      # TODO: not exactly sure yet what the right thing to do for Debian/Ubuntu is.
      #$persist_firewall_command = '/sbin/iptables-save > /etc/iptables/rules.v4'
    }
    default: {
      $firewall_supported       = false
    }
  }

  if $::puppetversion =~ /Puppet Enterprise/ {
    $puppetdb_package     = 'pe-puppetdb'
    $puppetdb_service     = 'pe-puppetdb'
    $confdir              = '/etc/puppetlabs/puppetdb/conf.d'
    $puppet_service_name  = 'pe-httpd'
    $puppet_confdir       = '/etc/puppetlabs/puppet'
    $terminus_package     = 'pe-puppetdb-terminus'
    $embedded_subname     = 'file:/opt/puppet/share/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'

    case $::osfamily {
      'RedHat', 'Suse': {
        $puppetdb_initconf = '/etc/sysconfig/pe-puppetdb'
      }
      'Debian': {
        $puppetdb_initconf = '/etc/default/pe-puppetdb'
      }
      default: {
        fail("${module_name} supports osfamily's RedHat and Debian. Your osfamily is recognized as ${::osfamily}")
      }
    }
  } else {
    $puppetdb_package     = 'puppetdb'
    $puppetdb_service     = 'puppetdb'
    $confdir              = '/etc/puppetdb/conf.d'
    $puppet_service_name  = 'puppetmaster'
    $puppet_confdir       = '/etc/puppet'
    $terminus_package     = 'puppetdb-terminus'
    $embedded_subname     = 'file:/usr/share/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'

    case $::osfamily {
      'RedHat', 'Suse', 'Archlinux': {
        $puppetdb_initconf = '/etc/sysconfig/puppetdb'
      }
      'Debian': {
        $puppetdb_initconf = '/etc/default/puppetdb'
      }
      default: {
        fail("${module_name} supports osfamily's RedHat and Debian. Your osfamily is recognized as ${::osfamily}")
      }
    }
  }

  $puppet_conf              = "${puppet_confdir}/puppet.conf"
  $puppetdb_startup_timeout = 120
}
