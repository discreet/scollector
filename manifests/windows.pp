# Class: scollector::windows
# ===========================
#
# Installs and configures for Windows specific Scollector
#
class scollector::windows inherits scollector {


  file {
    'install-dir':
      ensure => directory,
      path   => $::scollector::install_path;

    'collector-dir':
      ensure  => directory,
      path    => "${::scollector::collector_dir}",
      require => File['install-dir'];

     'scollector-config':
      ensure  => file,
      path    => "${::scollector::config_path}/scollector.toml",
      content => template('scollector/windows.toml.erb'),
      notify  => Service['scollector'],
      require => File['install-dir'];
  }

  if $::scollector::external_collectors == true {
    file { $::scollector::collector_freq_dir:
      ensure  => directory,
      mode    => '0755',
      purge   => true,
      require => File['collector-dir'],
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
    require    => Exec['register-service'],
  }
}
