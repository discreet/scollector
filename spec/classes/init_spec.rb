require 'spec_helper'

describe 'scollector' do

  context 'CentOS/RHEL 7 without Hiera' do
    let(:facts) { { :osfamily => 'RedHat',
		    :architecture => 'x86_64',
                    :kernel => 'linux',
                    :operatingsystemmajrelease => '7',
                    :operatingsystem => 'CentOS' } }
    let(:params) { { :use_hiera => false } }

    it { is_expected.to contain_class('scollector::redhat') }
  end

  context 'CentOS/RHEL 6 without Hiera' do
    let(:facts) { { :osfamily => 'RedHat',
		    :architecture => 'x86_64',
		    :kernel => 'linux',
		    :operatingsystemmajrelease => '6',
		    :operatingsystem => 'CentOS' } }
    let(:params) { { :use_hiera => false } }

    it { is_expected.to contain_class('scollector::redhat') }
  end

  context 'CentOS/RHEL 7 with Hiera' do
    let(:facts) { { :osfamily => 'RedHat',
		    :architecture => 'x86_64',
		    :kernel => 'linux',
		    :operatingsystemmajrelease => '7',
		    :operatingsystem => 'CentOS' } }
    let(:params) { { :use_hiera => true } }

    it { is_expected.to contain_class('scollector::redhat') }
    it { is_expected.to contain_class('scollector::collectors') }
  end

  context 'CentOS/RHEL 6 with Hiera' do
    let(:facts) { { :osfamily => 'RedHat',
                    :architecture => 'x86_64',
                    :kernel => 'linux',
                    :operatingsystemmajrelease => '6',
                    :operatingsystem => 'CentOS' } }
    let(:params) { { :use_hiera => true } }

    it { is_expected.to contain_class('scollector::redhat') }
    it { is_expected.to contain_class('scollector::collectors') }
  end

  context 'Windows 2012R2 without Hiera' do
    let(:facts) { { :osfamily => 'windows',
		    :architecture => 'x64',
		    :kernel => 'windows',
		    :operatingsystemmajrelease => '2012 R2',
                    :operatingsystem => 'windows' } }
    let(:params) { { :use_hiera => false } }

    it { is_expected.to contain_class('scollector::windows') }
  end

  context 'Windows 2008R2 without Hiera' do
    let(:facts) { { :osfamily => 'windows',
                    :architecture => 'x64',
                    :kernel => 'windows',
                    :operatingsystemmajrelease => '2008 R2',
                    :operatingsystem => 'windows' } }
    let(:params) { { :use_hiera => false } }

    it { is_expected.to contain_class('scollector::windows') }
  end

  context 'Windows 2012R2 with Hiera' do
    let(:facts) { { :osfamily => 'windows',
                    :architecture => 'x64',
                    :kernel => 'windows',
                    :operatingsystemmajrelease => '2012 R2',
                    :operatingsystem => 'windows' } }
    let(:params) { { :use_hiera => true } }

    it { is_expected.to contain_class('scollector::windows') }
    it { is_expected.to contain_class('scollector::collectors') }
  end

  context 'Windows 2008R2 with Hiera' do
    let(:facts) { { :osfamily => 'windows',
                    :architecture => 'x64',
                    :kernel => 'windows',
                    :operatingsystemmajrelease => '2008 R2',
                    :operatingsystem => 'windows' } }
    let(:params) { { :use_hiera => true } }

    it { is_expected.to contain_class('scollector::windows') }
    it { is_expected.to contain_class('scollector::collectors') }
  end
end
