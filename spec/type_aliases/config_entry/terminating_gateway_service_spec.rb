require 'spec_helper'

describe 'Consul::Config_entry::Terminating_gateway_service' do
  it { is_expected.to allow_value({ 'Name' => 'db' }) }
  it { is_expected.to allow_value({ 'Name' => '*' }) }
  it { is_expected.to allow_value({ 'Name' => 'db', 'CAFile' => '/etc/ssl/ca.pem', 'CertFile' => '/etc/ssl/c.pem', 'KeyFile' => '/etc/ssl/k.pem', 'SNI' => 'db.example.org' }) }
  it { is_expected.not_to allow_value({ 'Name' => 'db', 'CAFile' => 'relative/ca.pem' }) }
  it { is_expected.not_to allow_value({ 'CAFile' => '/etc/ssl/ca.pem' }) }
end
