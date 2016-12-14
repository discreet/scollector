require 'spec_helper'

describe 'scollector::redhat' do

  context 'CentOS/RHEL without external collectors' do
    let :pre_condition do
      'class { "scollector": external_collectors => false, }'
    end

    let(:facts) { { :osfamily => 'RedHat',
                    :architecture => 'x86_64',
                    :kernel => 'linux',
                    :operatingsystemmajrelease => '7',
                    :operatingsystem => 'CentOS' } }

    it do
      is_expected.to contain_wget__fetch('download-scollector').that_requires('File[install-dir]').with(
        'source'      => 'https://github.com/bosun-monitor/bosun/releases/download/0.5.0/scollector-linux-amd64',
	'destination' => '/usr/local/scollector/scollector',
      )

      is_expected.to contain_file('install-dir').with(
        'ensure' => 'directory',
	'path'   => '/usr/local/scollector',
	'owner'  => 'root',
        'group'  => 'root',
	'mode'   => '0755',
	'purge'  => true,
      )

      is_expected.to contain_file('scollector-binary').with(
        'ensure' => 'file',
	'path'   => '/usr/local/scollector/scollector',
	'owner'  => 'root',
	'group'  => 'root',
	'mode'   => '0755',
      )

      is_expected.to contain_file('config-dir').with(
        'ensure' => 'directory',
	'path'   => '/etc/scollector',
	'owner'  => 'root',
	'group'  => 'root',
	'mode'   => '0755',
	'purge'  => true,
      )

      is_expected.to contain_file('collector-dir').with(
        'ensure' => 'directory',
	'path'   => '/etc/scollector/collectors',
	'owner'  => 'root',
	'group'  => 'root',
	'mode'   => '0755',
	'purge'  => true,
      )

      is_expected.to contain_file('scollector-config').with(
        'ensure'  => 'file',
	'path'    => '/etc/scollector/scollector.toml',
	'owner'   => 'root',
	'group'   => 'root',
	'mode'    => '0644',
      )

      is_expected.to contain_file('scollector-init').with(
        'ensure' => 'file',
	'path'   => '/etc/systemd/system/scollector.service',
	'owner'  => 'root',
	'group'  => 'root',
	'mode'   => '0755',
	'source' => 'puppet:///modules/scollector/init_scripts/scollector.service',
      )
    end
  end

  context 'CentOS/RHEL 6 service' do
    let(:facts) { { :osfamily => 'RedHat',
                    :architecture => 'x86_64',
                    :kernel => 'linux',
                    :operatingsystemmajrelease => '6',
                    :operatingsystem => 'CentOS' } }
    it do
      is_expected.to contain_service('scollector').that_subscribes_to('File[scollector-init]').that_subscribes_to('File[scollector-binary]').that_subscribes_to('File[scollector-config]').with(
        'ensure'     => 'running',
	'enable'     => true,
	'hasrestart' => true,
	'hasstatus'  => true,
      )
    end
  end

  context 'CentOS/RHEL 7 service' do
    let(:facts) { { :osfamily => 'RedHat',
		    :architecture => 'x86_64',
		    :kernel => 'linux',
		    :operatingsystemmajrelease => '7',
		    :operatingsystem => 'CentOS' } }

    it do
      is_expected.to contain_service('scollector').that_subscribes_to('File[scollector-init]').that_subscribes_to('File[scollector-binary]').that_subscribes_to('File[scollector-config]').with(
        'ensure'     => 'running',
        'enable'     => true,
        'hasrestart' => true,
        'hasstatus'  => true,
      )
    end
  end

  context 'CentOS/RHEL with external collectors' do
    let :pre_condition do
      'class { "scollector":
         freq_dir => ["30","60"],
	 external_collectors => true,
         collector_freq_dir => ["/etc/scollector/collectors/30",
	                       "/etc/scollector/collectors/60"],
      }'
    end
    let(:facts) { { :osfamily => 'RedHat',
		   :architecture => 'x86_64',
		   :kernel => 'linux',
		   :operatingsystemmajrelease => '7',
		   :operatingsystem => 'CentOS' } }
    it do
      is_expected.to contain_file('/etc/scollector/collectors/30').with(
        'ensure' => 'directory',
	'owner'  => 'root',
	'group'  => 'root',
	'mode'   => '0755',
	'purge'  => true,
      )

      is_expected.to contain_file('/etc/scollector/collectors/60').with(
        'ensure' => 'directory',
	'owner'  => 'root',
	'group'  => 'root',
	'mode'   => '0755',
	'purge'  => true,
      )
    end
  end
end
