# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::client (
  Stdlib::Compat::Ip_address  $agent_ip,          # Platform agent server ip to forward syslog messages to
  Integer                     $agent_port = 514,  # Platform agent server port to forward syslog messages to
  Boolean                     $enabled = true,     # Enable client config by default
) inherits ss_logrhythm {
  if $enabled == true {
    $logrhythm_agent_ensure = present
  } else {
    $logrhythm_agent_ensure = absent
  }

  # Add logryhthm rsyslog configuration
  file { 'logrhythm_syslog.conf':
    ensure  => $logrhythm_agent_ensure,
    path    => '/etc/rsyslog.d/logrhythm.conf',
    content => template('ss_logrhythm/rsyslogd_client.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service['rsyslog'],
  }
}
