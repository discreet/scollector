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
# [*real_arch*]
#  Normalizing the actual architecture of the system to meet Scollector conventions
#  Type: string
#
# [*os*]
#  The operating system to match the SCollector binary name
#  Type: string
#
# [*ext*]
#  The extension of the Scollector binary
#  Type: string
#
# [*install_path*]
#  Where to place the binary package
#  Type: string
#
# [*config_path*]
#  Where to place the configuration file
#  Type: string
#
# [*collector_dir*]
#  Where to look for external collectors
#  Type: string
#
# [*collector_freq_dir*]
#  The directories used to run external collectors on schedule
#  Type: string
#
# [*binary*]
#  The full name of the Scollector binary
#  Type: string
#
# [*download_url*]
#  The location to download the Scollector binary from
#  Type: string
#
# [*klass*]
#  The subclass to contain for the os specific configurations
#  Type: string
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
  Boolean $use_hiera           = $::scollector::params::use_hiera,
  Boolean $external_collectors = $::scollector::params::external_collectors,
  Boolean $full_host           = $::scollector::params::full_host,

  Pattern[/^\d+\.\d+\.\d+$/] $version = $::scollector::params::version,
  Pattern[/^http$|^https$/] $proto    = $::scollector::params::proto,
  Pattern[/^\d{4}$/] $port            = $::scollector::params::port,
  Pattern[/^amd64$/] $real_arch       = $::scollector::params::real_arch,

  String $host     = $::scollector::params::host,
  String $user     = $::scollector::params::user,
  String $password = $::scollector::params::password,
  String $os       = $::scollector::params::os,

  Integer $freq = $::scollector::params::freq,

  Array $freq_dir           = $::scollector::params::freq_dir,
  Array $collector_freq_dir = $::scollector::params::collector_freq_dir,

  Hash $collector    = $::scollector::params::collector,
  Hash $tag_override = $::scollector::params::tag_override,

  Stdlib::Absolutepath $install_path  = $::scollector::params::install_path,
  Stdlib::Absolutepath $config_path   = $::scollector::params::config_path,
  Stdlib::Absolutepath $collector_dir = $::scollector::params::collector_dir,

  Stdlib::Httpsurl $download_url = $::scollector::params::download_url,

  $ext    = $::scollector::params::ext,
  $binary = $::scollector::params::binary,
  $klass  = $::scollector::params::klass
) inherits ::scollector::params {

   if $external_collectors and $freq_dir.count < 1 {
     fail("if you are using external collectors you need frequency directories")
   }

   if $external_collectors == false and $freq_dir.count > 0 {
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
