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
  $ensure = present,
  $freq   = undef,
){

  validate_re($ensure, '^(present)|(absent)$')
  validate_string($freq)

  unless $freq in $::scollector::freq_dir {
    fail('frequency is not valid')
  }
  $collector_os    = downcase($::osfamily)
  $collector_path  = "${::scollector::collector_dir}/${freq}"
  $collector_source = "collectors/${collector_os}"

  case $ensure {
    'present': {
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
