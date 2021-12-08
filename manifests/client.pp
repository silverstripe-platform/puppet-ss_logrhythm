# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::client inherits ss_logrhythm {
  file { 'logrhythm_syslog.conf':
    path    => '/etc/rsyslog.d/logrhythm.conf',
    content => template('ss_logrhythm/rsyslogd_client.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service['rsyslog'],
  }
}
