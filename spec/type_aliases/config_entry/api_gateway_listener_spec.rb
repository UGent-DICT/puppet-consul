require 'spec_helper'

describe 'Consul::Config_entry::Api_gateway_listener' do
  it { is_expected.to allow_value({ 'Name' => 'tcp-8200', 'Port' => 8200, 'Protocol' => 'tcp' }) }
  it { is_expected.to allow_value({ 'Name' => 'https', 'Port' => 443, 'Protocol' => 'http', 'Hostname' => '*.example.org', 'TLS' => { 'MinVersion' => 'TLSv1_2', 'Certificates' => [{ 'Kind' => 'file-system-certificate', 'Name' => 'cert' }] } }) }
  it { is_expected.not_to allow_value({ 'Name' => 'x', 'Port' => 8200, 'Protocol' => 'udp' }) }
  it { is_expected.not_to allow_value({ 'Name' => 'x', 'Port' => 0, 'Protocol' => 'tcp' }) }
  it { is_expected.not_to allow_value({ 'Name' => 'x', 'Port' => 70_000, 'Protocol' => 'tcp' }) }
  it { is_expected.not_to allow_value({ 'Name' => 'not valid', 'Port' => 8200, 'Protocol' => 'tcp' }) }
  it { is_expected.not_to allow_value({ 'Name' => 'x', 'Port' => 8200 }) }
  it { is_expected.not_to allow_value({ 'Name' => 'x', 'Port' => 8200, 'Protocol' => 'tcp', 'TLS' => { 'MinVersion' => 'SSLv3' } }) }
  it { is_expected.not_to allow_value({ 'Name' => 'x', 'Port' => 8200, 'Protocol' => 'tcp', 'TLS' => { 'Certificates' => [{ 'Name' => 'cert' }] } }) }
end
