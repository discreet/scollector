# Class: scollector::params
# ===========================
#
# this class is used for all default parameter logic
#
class scollector::params {
  $use_hiera           = false
  $version             = '0.5.0'
  $host                = undef
  $port                = '8090'
  $user                = undef
  $password            = undef
  $external_collectors = false
  $freq                = 60
  $freq_dir            = []
  $full_host           = false
  $proto               = 'https'
  $collector           = {}
  $tag_override        = {}

  case downcase($::kernel) {
    'linux': {
      $os            = 'linux'
      $ext           = undef
      $install_path  = '/usr/local/scollector'
      $config_path   = '/etc/scollector'
      $collector_dir = "${config_path}/collectors"
    }
    'windows': {
      $os            = 'windows'
      $ext           = '.exe'
      $install_path  = 'C:/Program Files/scollector'
      $config_path   = $install_path
      $collector_dir = "${install_path}/collectors"
    }
    default: {
      fail("${::kernel} is not a supported kernel")
    }
  }

  if $external_collectors == true {
    $collector_freq_dir = prefix($freq_dir, "${collector_dir}/")
  }else {
    $collector_freq_dir = undef
  }

  if ('64' in $::architecture) {
    $real_arch = 'amd64'
  }else {
    fail("${::architecture}  is not supported")
  }

  $binary             = "scollector-${os}-${real_arch}${ext}"
  $download_url       = "https://github.com/bosun-monitor/bosun/releases/download/${version}/${binary}"
  $klass              = downcase($::osfamily)
}
