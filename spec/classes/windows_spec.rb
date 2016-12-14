require 'spec_helper'

describe 'scollector::windows' do

  before :each do
    Puppet[:autosign] = false
    Puppet::Util::Platform.stubs(:windows?).returns true
  end

  context 'Windows 2012R2 without external collectors' do
    let :pre_condition do
      'class { "scollector": external_collectors => false, }'
    end

    let(:facts) { { :osfamily => 'windows',
		    :architecture => 'x64',
		    :kernel => 'windows',
		    :operatingsystemmajrelease => '2012 R2',
		    :operatingsystem => 'windows' } }

    it do
      is_expected.to contain_file('install-dir').with(
        'ensure' => 'directory',
      )

      is_expected.to contain_file('collector-dir').that_requires('File[install-dir]').with(
        'ensure' => 'directory',
      )

      is_expected.to contain_file('scollector-config').that_requires('File[install-dir]').that_notifies('Service[scollector]').with(
        'ensure' => 'file',
      )

      is_expected.to contain_pget('download-scollector').that_notifies('Exec[register-service]').with(
        'source'         => 'https://github.com/bosun-monitor/bosun/releases/download/0.5.0/scollector-windows-amd64.exe',
        'target'         => 'C:/Program Files/scollector',
        'targetfilename' => 'scollector.exe',
      )

      is_expected.to contain_exec('register-service').with(
        'path'        => 'C:/Program Files/scollector',
        'command'     => 'scollector.exe --winsvc=install',
        'refreshonly' => true,
      )

      is_expected.to contain_service('scollector').that_requires('Exec[register-service]').with(
        'ensure'     => 'running',
        'enable'     => true,
        'hasstatus'  => true,
        'hasrestart' => true,
      )
    end
  end

  context 'Windows 2008R2 without external collectors' do
    let :pre_condition do
      'class { "scollector": external_collectors => false, }'
    end

    let(:facts) { { :osfamily => 'windows',
		    :architecture => 'x64',
		    :kernel => 'windows',
		    :operatingsystemmajrelease => '2008 R2',
		    :operatingsystem => 'windows' } }

    it do
      is_expected.to contain_file('install-dir').with(
        'ensure' => 'directory',
      )

      is_expected.to contain_file('collector-dir').that_requires('File[install-dir]').with(
        'ensure' => 'directory',
      )

      is_expected.to contain_file('scollector-config').that_requires('File[install-dir]').that_notifies('Service[scollector]').with(
        'ensure' => 'file',
      )

      is_expected.to contain_pget('download-scollector').that_notifies('Exec[register-service]').with(
        'source'         => 'https://github.com/bosun-monitor/bosun/releases/download/0.5.0/scollector-windows-amd64.exe',
        'target'         => 'C:/Program Files/scollector',
        'targetfilename' => 'scollector.exe',
      )

      is_expected.to contain_exec('register-service').with(
        'path'        => 'C:/Program Files/scollector',
        'command'     => 'scollector.exe --winsvc=install',
        'refreshonly' => true,
      )

      is_expected.to contain_service('scollector').that_requires('Exec[register-service]').with(
        'ensure'     => 'running',
        'enable'     => true,
        'hasstatus'  => true,
        'hasrestart' => true,
      )
    end
  end

  context 'Windows with external collectors' do
    before :each do
      Puppet[:autosign] = false
      Puppet::Util::Platform.stubs(:windows?).returns true
    end

    let :pre_condition do
      'class { "scollector":
         freq_dir => ["30","60"],
	 external_collectors => true,
	 collector_freq_dir => ["C:/Program Files/scollector/collectors/30",
	                        "C:/Program Files/scollector/collectors/60"],
      }'
    end

    let(:facts) { { :osfamily => 'windows',
		    :architecture => 'x64',
		    :kernel => 'windows',
		    :operatingsystemmajrelease => '2012 R2',
		    :operatingsystem => 'windows' } }
    it do
      is_expected.to contain_file('C:/Program Files/scollector/collectors/30').that_requires('File[collector-dir]').with(
        'ensure' => 'directory',
	'mode'   => '0755',
	'purge'  => true,
      )

      is_expected.to contain_file('C:/Program Files/scollector/collectors/60').that_requires('File[collector-dir]').with(
        'ensure' => 'directory',
	'mode'   => '0755',
	'purge'  => true,
      )
    end
  end
end
