require 'spec_helper'
describe 'scollector' do
  context 'with default values for all parameters' do
    it { should contain_class('scollector') }
  end
end
