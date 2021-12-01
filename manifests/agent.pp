# Setup LogRhythm agent
# Install and configure packages and assume firewall allows connections
class ss_logrhythm::agent inherits ss_logrhythm {
  # Disable Rsyslog as Logrhythm includes own syslog server
  service { 'rsyslog':
    ensure => stopped,
    enable => false,
  }

  # Download LogRhythm package
  if $ss_logrhythm::https_proxy {
    $proxy_environment = ["https_proxy=${ss_logrhythm::https_proxy}"]
  } else {
    $proxy_environment = []
  }

  # Package name is the last part of agent URL
  $agent_package = $ss_logrhythm::agent_url.split('/')[-1]
  notice("LogRhythm Agent Setup: ${agent_package}")

  file { ['/opt/logrhythm', '/opt/logrhythm/scsm', '/opt/logrhythm/scsm/config']:
    ensure => directory,
    owner  => root,
    group  => root,
  }-> exec { 'download':
    command     => "curl -s -f ${ss_logrhythm::agent_url} -o /usr/src/${agent_package}",
    path        => '/usr/bin:/usr/sbin:/bin',
    environment => $proxy_environment,
    onlyif      => "test ! -f /usr/src/${agent_package}",
  }-> package { 'scsm':
    ensure   => installed,
    provider => dpkg,
    source   => "/usr/src/${agent_package}"
  }-> file { 'scsm.ini':
    ensure  => 'present',
    replace => 'no',
    path    => '/opt/logrhythm/scsm/config/scsm.ini',
    content => template('ss_logrhythm/scsm.ini.erb'),
    owner   => root,
    group   => root,
    mode    => '0666',
    require => Package['scsm'],
  }-> service {'scsm':
    ensure    => running,
    enable    => true,
    subscribe => File['scsm.ini'],
  }

}
