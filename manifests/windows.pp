# Class: scollector::windows
# ===========================
#
# Installs and configures for Windows specific Scollector
#
class scollector::windows inherits scollector {

  $type = "file"

  $dir_defaults = {
    ensure => directory
  }

  $file_defaults = {
    ensure => file
  }

  $directories = {
    'install-dir' => {
      path   => $::scollector::install_path
    },
    'collector-dir' => {
      path    => "${::scollector::collector_dir}"
    }
  }

  $files = {
    'scollector-config' => {
      path    => "${::scollector::config_path}/scollector.toml",
      content => template('scollector/windows.toml.erb'),
    }
  }

  $directories.each |String $directory, Hash $attributes| {
    Resource[$type] {
      $directory: * => $attributes;
      default: * => $dir_defaults;
    }
  }

  $files.each |String $file, Hash $attributes| {
    Resource[$type] {
      $file: * => $attributes;
      default: * => $file_defaults;
    }
  }

  if $::scollector::external_collectors {
    file { $::scollector::collector_freq_dir:
      ensure  => directory,
      purge   => true,
    }
  }

  pget { 'download-scollector':
    source         => $::scollector::download_url,
    target         => $::scollector::install_path,
    targetfilename => "scollector${::scollector::ext}",
    notify         => Exec['register-service'],
  }

  exec { 'register-service':
    path        => $::scollector::install_path,
    command     => "scollector${::scollector::ext} --winsvc=install",
    refreshonly => true,
  }

  service { 'scollector':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['scollector-config'],
  }
}
