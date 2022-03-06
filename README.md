# Puppet LogRhythm

Utilise puppet to

* Manage the install and configuration of the LogRhythm agent
* Configure `rsyslogd` on client machines to forward interested logs to LogRhythm agent

## Agent

This will download and install logrhythm from specified URL.

Configuration file is a template which configures `Mediator 1` in the scsm.ini file.

It is assumed that any firewall changes/ security group changes are managed elsewhere.

## Client

Set up rsyslogd to also forward syslog logs of interest to the agent server.

## Kinesis Package

Included in a script `make-debian` which can be used to create a debian package from the compiled application.

[Download the source](https://github.com/awslabs/amazon-kinesis-agent.git) and run `./setup --build` to compile. Further instructions are in the script.
