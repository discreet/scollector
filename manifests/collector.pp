# Define: scollector::collector
# ===========================
#
# Installs external collectors for RedHat and Windows
#
# Parameters
# ----------
#
# [*ensure*]
#  Enforce whether or not the external collector should be present
#  Type: string
#
# [*freq*]
#  The frequency in which the external collector should send data.
#  Type: string
#
define scollector::collector (
  Pattern[/^present$|^absent$/] $ensure = present,
  String $freq = '',
) {

  include '::scollector'

  unless $freq in $::scollector::freq_dir {
    fail('frequency is not valid')
  }

  $collector_path = "${::scollector::collector_dir}/${freq}"

  case $ensure {
    'present': {
      $collector_os = downcase($::osfamily)
      $collector_source = "collectors/${collector_os}"

      if $::osfamily != 'windows' {
        file { "collector-${name}":
          ensure  => file,
          path    => "${collector_path}/${name}",
          owner   => root,
          group   => root,
          mode    => '0755',
          require => File[$scollector::collector_freq_dir],
          source  => "puppet:///modules/scollector/${collector_source}/${name}",
          notify  => Service['scollector'],
        }
      }else {
        file { "collector-${name}":
          ensure  => file,
          path    => "${collector_path}/${name}",
          require => File[$scollector::collector_freq_dir],
          source  => "puppet:///modules/scollector/${collector_source}/${name}",
          notify  => Service['scollector'],
        }
      }
    }
    'absent': {
      file { "collector-${name}":
        ensure => absent,
        path   => "${collector_path}/${name}",
      }
    }
    default: {
      fail("something went seriously wrong")
    }
  }
}
