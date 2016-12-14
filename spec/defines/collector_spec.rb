require 'spec_helper'

describe 'scollector::collector' do

  context 'CentOS/RHEL create external collector' do
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

    let(:title) { 'spectest' }

    let(:params) { { :ensure => 'present',
		     :freq => '30' } }

    it do
      is_expected.to contain_file('collector-spectest').that_requires('File[/etc/scollector/collectors/30]').that_requires('File[/etc/scollector/collectors/60]').that_notifies('Service[scollector]').with(
        'ensure' => 'file',
	'path'   => '/etc/scollector/collectors/30/spectest',
	'owner'  => 'root',
	'group'  => 'root',
	'mode'   => '0755',
	'source' => 'puppet:///modules/scollector/collectors/redhat/spectest',
      )
    end
  end

  context 'Windows create external collector' do
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
		    :architecture => '64',
		    :kernel => 'windows',
		    :operatingsystemmajrelease => '2012 R2',
		    :operatingsystem => 'windows' } }

    let(:title) { 'spectest' }

    let(:params) { { :ensure => 'present',
		     :freq => '30' } }

    it do
      is_expected.to contain_file('collector-spectest').that_requires('File[C:/Program Files/scollector/collectors/30]').that_requires('File[C:/Program Files/scollector/collectors/60]').that_notifies('Service[scollector]').with(
        'ensure' => 'file',
        'path'   => 'C:/Program Files/scollector/collectors/30/spectest',
      )
    end
  end

  context 'CentOS/RHEL delete external collector' do
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

    let(:title) { 'spectest' }

    let(:params) { { :ensure => 'absent',
                     :freq => '30' } }

    it do
      is_expected.to contain_file('collector-spectest').with(
        'ensure' => 'absent',
	'path'   => '/etc/scollector/collectors/30/spectest',
      )
    end
  end

  context 'Windows delete external collector' do
    before :each do
      Puppet[:autosign] = false
      Puppet::Util::Platform.stubs(:windows?).returns true
    end

    let :pre_condition do
      'class { "scollector":
         freq_dir => ["30","60"],
	 external_collectors => true,
	 collector_freq_dir => ["/etc/scollector/collectors/30",
	                        "/etc/scollector/collectors/60"],
       }'
    end

    let(:facts) { { :osfamily => 'windows',
		    :architecture => 'x64',
		    :kernel => 'windows',
		    :operatingsystemmajrelease => '2012 R2',
		    :operatingsystem => 'windows' } }

    let(:title) { 'spectest' }

    let(:params) { { :ensure => 'absent',
		     :freq => '30' } }

    it do
      is_expected.to contain_file('collector-spectest').with(
        'ensure' => 'absent',
	'path' => 'C:/Program Files/scollector/collectors/30/spectest',
      )
    end
  end
end
