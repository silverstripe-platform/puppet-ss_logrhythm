# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::vector (
  Boolean $enabled = true, # Enable client config by default
  Integer $agent_port = 6514, # Port used to pass Syslog data to Vector agent
) inherits ss_logrhythm {

  # Add Vector.dev apt source for installing Vector package
  apt::source { 'vector':
    comment  => 'Mirror for Vector.dev package',
    location    => 'https://repositories.timber.io/public/vector/deb/ubuntu',
    release     => $::lsbdistcodename,
    repos       => 'main',
    require     => [
      Package['apt-transport-https', 'ca-certificates']
    ],
    key         => {
      'id' => 'C80FB028A4612B1A0EAE214AC96886944BD55D79',
      'source' => 'https://repositories.timber.io/public/vector/gpg.3543DB2D0A2BC4B8.key',
    },
  }

  # Install Vector package
  package { 'vector': 
    ensure => 'present',
  }

  Class['apt::update'] -> Package['vector']

  # Send Syslog data to Vector agent
  class {'ss_logrhythm::client':
    agent_ip   => '127.0.0.1',
    agent_port => $agent_port
  }

  # Configure Vector with default settings
  # Expects Role/Stream to be provided via environment variables
  #  - STREAM_NAME
  #  - ROLE_ARN
  file { '/etc/vector/vector.toml':
    ensure  => 'present',
    content => template('ss_logrhythm/vector.toml.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['vector'],
  }
}
