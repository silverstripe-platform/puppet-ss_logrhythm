# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::kinesis (
  Boolean $enabled = true, # Enable client config by default
  Variant[Stdlib::HTTPSUrl,Stdlib::HttpUrl] $package_url = '', # eg. https://s3-ap-southeast-2.amazonaws.com/ss-packages/logrhythm/aws-kinesis-agent_0.9-Ubuntu_amd64.deb
) inherits ss_logrhythm {

  require java

  # Set up rsyslog configuration
  if $enabled == true {
    $logrhythm_agent_ensure = present
    $rsyslog_delivery = "    *.* /var/log/kinesis/logrhythm.log\n    \$FileCreateMode 0644"
  } else {
    $logrhythm_agent_ensure = absent
  }

  # Add logryhthm rsyslog configuration
  file {'logrhythm_syslog.conf':
    ensure  => $logrhythm_agent_ensure,
    path    => '/etc/rsyslog.d/logrhythm.conf',
    content => template('ss_logrhythm/rsyslogd_client.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service['rsyslog'],
  }

  # install Kinesis from .deb - package name is the last part dof agent URL
  # Ensure package only installed if not already present. Servicetools did not work
  # and reinstalls. This method will install once and allow for upgrades.

  $kinesis_package = String($package_url).split('/')[-1]

  exec { 'download':
    command => "curl -s -f ${package_url} -o /usr/src/${kinesis_package}",
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => "test ! -f /usr/src/${kinesis_package}",
  }-> package { 'aws-kinesis-agent':
    ensure   => installed,
    provider => dpkg,
    source   => "/usr/src/${kinesis_package}"
  }-> file { 'agent.json':
    path    => '/etc/aws-kinesis-agent/agent.json',
    content => template('ss_logrhythm/kinesis-agent.json.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['aws-kinesis-agent'],
  }-> service {'aws-kinesis-agent':
    ensure    => running,
    enable    => true,
    subscribe => File['agent.json'],
  }
}
