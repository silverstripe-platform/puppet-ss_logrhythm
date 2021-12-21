# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::client (
  Stdlib::Compat::Ip_address  $agent_ip,          # Platform agent server ip to forward syslog messages to
  Integer                     $agent_port = 514,  # Platform agent server port to forward syslog messages to
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
