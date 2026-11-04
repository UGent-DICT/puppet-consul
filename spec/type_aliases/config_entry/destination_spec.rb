require 'spec_helper'

describe 'Consul::Config_entry::Destination' do
  it { is_expected.to allow_value({ 'Addresses' => ['s3.example.org'], 'Port' => 443 }) }
  it { is_expected.to allow_value({ 'Addresses' => ['10.0.0.1', 'db.example.org'], 'Port' => 5432 }) }
  it { is_expected.not_to allow_value({ 'Addresses' => ['*.example.org'], 'Port' => 443 }) }
  it { is_expected.not_to allow_value({ 'Addresses' => [], 'Port' => 443 }) }
  it { is_expected.not_to allow_value({ 'Addresses' => ['s3.example.org'] }) }
  it { is_expected.not_to allow_value({ 'Addresses' => ['s3.example.org'], 'Port' => 0 }) }
end
