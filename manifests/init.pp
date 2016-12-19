# Class: scollector
# ===========================
#
# This module will manage the installation and configuration of the Scollector
# agent for both the Windows and Linux operating systems. It has built in Hiera
# functionality and supports external collectors.
#
# Parameters
# ----------
#
# [*use_hiera*]
#  If Hiera data should be used to create external collectors
#  Type: boolean
#
# [*version*]
#  The version of Scollector for Puppet to install.
#  Type: string
#
# [*host*]
#  The host that Scollector will be sending metrics to.
#  Type: string
#
# [*port*]
#  The port that the remote host will accept the metrics on.
#  Type: string
#
# [*user*]
#  The user to connect to the remote host with.
#  Type: string
#
# [*password*]
#  The password for the user account used to connect.
#  Type: string
#
# [*external_collectors*]
#  Whether or not external collectors are going to be used.
#  Type: boolean
#
# [*freq*]
#  The frequency in which to send metrics in seconds.
#  ie. 0 (constantly), 10, 30, 60, 300
#  Type: integer
#
# [*freq_dir*]
#  The names of the directories to create for external collectors.
#  These names directly correspond to the frequency in which data
#  is sent in seconds.
#  Type: array
#
# [*full_host*]
#  Whether or not to truncate the FQDN to just the hostname.
#  Type: boolean
#
# [*proto*]
#  The protocol to connect to the remote host with.
#  Type: string
#
# [*collector*]
#  The native collector to use and it's inputs.
#  Type: hash
#
# [*tag_override*]
#  What tags to override in the scollector.toml file.
#  Type: hash
#
# Examples
# --------
#
#  class { 'scollector':
#    version   => '0.5.0',
#    host      => 'metrics.domain.com',
#    port      => '8099',
#    user      => 'foo',
#    password  => 'bar',
#    freq      => 60,
#    full_host => true,
#    proto     => 'https'
#    collector => { Java => { collector => 'Process',
#                             name      => 'java',
#                             command   => 'java_cmd',
#                             args      => 'java_args',
#                           }
#                 }
#  }
#
# Authors
# -------
#
# Christopher Pisano <pisanoc@advisory.com>
# Jon Hursey <hurseyj@advisory.com>
#
# Copyright
# ---------
#
# Copyright 2016
#
class scollector (
  $use_hiera           = $::scollector::params::use_hiera,
  $version             = $::scollector::params::version,
  $host                = $::scollector::params::host,
  $port                = $::scollector::params::port,
  $user                = $::scollector::params::user,
  $password            = $::scollector::params::password,
  $external_collectors = $::scollector::params::external_collectors,
  $freq                = $::scollector::params::freq,
  $freq_dir            = $::scollector::params::freq_dir,
  $full_host           = $::scollector::params::full_host,
  $proto               = $::scollector::params::proto,
  $collector           = $::scollector::params::collector,
  $tag_override        = $::scollector::params::tag_override,
  $real_arch           = $::scollector::params::real_arch,
  $os                  = $::scollector::params::os,
  $ext                 = $::scollector::params::ext,
  $install_path        = $::scollector::params::install_path,
  $config_path         = $::scollector::params::config_path,
  $collector_dir       = $::scollector::params::collector_dir,
  $collector_freq_dir  = $::scollector::params::collector_freq_dir,
  $binary              = $::scollector::params::binary,
  $download_url        = $::scollector::params::download_url,
  $klass               = $::scollector::params::klass
) inherits ::scollector::params {

  validate_re($version, '^\d+\.\d+\.\d+$')
  validate_re($port, '(^\d{4}$)')
  validate_re($proto, ['^http$', '^https$'], 'Valid protocols are http or https')
  validate_integer($freq)
  validate_array($freq_dir)
  validate_hash($collector,
                $tag_override)
  validate_bool($full_host,
                $external_collectors,
                $use_hiera)
  validate_string($host,
                  $user,
                  $password)

  if $user == undef and $password != undef {
    fail("every user needs a password")
  }

  if $user != undef and $password == undef {
    fail("every password needs a user")
  }

  if $external_collectors == true and $freq_dir == [] {
    fail("if you are using external collectors you need frequency directories")
  }

  if $external_collectors == false and $freq_dir != [] {
    fail("you must enable external collectors to create frequency directories")
  }

  if !defined("::scollector::${klass}") {
    fail("no class for ${::osfamily}")
  }

  case $use_hiera {
    true: {
      contain "::scollector::${klass}"
      contain "::scollector::collectors"
    }
    false: {
      contain "::scollector::${klass}"
    }
    default: {
      fail('something went terribly wrong')
    }
  }
}
