# Install and configure LogRhythm
# Packages will be downloaded from s3://ss-packages/logrhythm (publicly accessible)
class ss_logrhythm (
  $enabled = false,
  $https_proxy = undef,
  $agent_ip = '',            # Platform agent server to forward syslog messages to
  $agent_url = '',           # Agent public accessible .deb pachake URL (eg. https://s3-ap-southeast-2.amazonaws.com/ss-packages/logrhythm/scsm-x.x.x.xxxx-xx_amd64.deb)
  $agent_mediator = '',      # Mediator hostname our platform agent server(s) send requests (eg. Advantage)
  $agent_mediator_host = '', # Mediator IP address [currently unused]
){
  include ss_auditd

  # Server will only be agent or client, not both
  if $enabled {
    if $agent_url != '' and $agent_mediator != '' {
      # Agent install
      class {'ss_logrhythm::agent':}
    } elsif $agent_ip != '' {
        # Client setup
        class {'ss_logrhythm::client':}
    }
  }
}
