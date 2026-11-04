require 'spec_helper'

describe 'Consul::Config_entry::Tcp_route_service' do
  it { is_expected.to allow_value({ 'Name' => 'vault' }) }
  it { is_expected.not_to allow_value({ 'Name' => '' }) }
  it { is_expected.not_to allow_value({}) }
end
