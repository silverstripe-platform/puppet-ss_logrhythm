# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::kinesis (
  Boolean                                   $enabled = true, # Enable client config by default
  Variant[Stdlib::HTTPSUrl,Stdlib::HttpUrl] $package_url,    # eg. https://s3-ap-southeast-2.amazonaws.com/ss-packages/logrhythm/aws-kinesis-agent_0.9-Ubuntu_amd64.deb
) inherits ss_logrhythm {
  require java

  # Set up rsyslog configuration
  class {'ss_logrhythm::client':
    agent_ip         => '127.0.0.1', # Dummy Agent IP
    rsyslog_delivery => "    *.* /var/log/kinesis/logrhythm.log\n    \$FileCreateMode 0644"
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
  }
  
  service {'aws-kinesis-agent':
    ensure    => running,
    enable    => true
  }
}
