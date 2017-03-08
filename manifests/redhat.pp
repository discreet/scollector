# Class: scollector::redhat
# ===========================
#
# Installs and configures for RedHat specific Scollector
#
class scollector::redhat inherits scollector {

  $init_file = $::operatingsystemmajrelease ? {
    /^6/ => 'scollector',
    /^7/ => 'scollector.service',
  }

  $init_path = $::operatingsystemmajrelease ? {
    /^6/ => '/etc/init.d',
    /^7/ => '/etc/systemd/system',
  }

  $type = "file"

  $dir_defaults = {
    ensure => directory,
    owner => root,
    group => root,
    mode  => '0755',
    purge => true
  }

  $file_defaults = {
    ensure => file,
    owner  => root,
    group  => root
  }

  $directories = {
    'install-dir' => {
      path => $::scollector::install_path
    },
    'config-dir' => {
      path => $::scollector::config_path
    },
    'collector-dir' => {
      path    => $::scollector::collector_dir,
    }
  }
  $files = {
    'scollector-binary' => {
      path    => "${::scollector::install_path}/scollector",
      mode    => '0755',
    },
    'scollector-config' => {
      path    => "${::scollector::config_path}/scollector.toml",
      mode    => '0644',
      content => template('scollector/redhat.toml.erb'),
    },
    'scollector-init' => {
      path   => "${init_path}/${init_file}",
      mode   => '0755',
      source => "puppet:///modules/scollector/init_scripts/${init_file}"
    }
  }


  wget::fetch { 'download-scollector':
    source      => $::scollector::download_url,
    destination => "${::scollector::install_path}/scollector",
    require     => File['install-dir'],
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
      owner   => root,
      group   => root,
      mode    => '0755',
      purge   => true,
    }
  }

  service { 'scollector':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [ File['scollector-init'],
                    File['scollector-binary'],
                    File['scollector-config']
                  ],
  }
}
