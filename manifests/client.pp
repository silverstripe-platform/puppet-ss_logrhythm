# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::client (
  Stdlib::Compat::Ip_address $agent_ip, # Platform agent server to forward syslog messages to
) inherits ss_logrhythm {
  # Add logryhthm rsyslog configuration
  file { 'logrhythm_syslog.conf':
    path    => '/etc/rsyslog.d/logrhythm.conf',
    content => template('ss_logrhythm/rsyslogd_client.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service['rsyslog'],
  }
}
