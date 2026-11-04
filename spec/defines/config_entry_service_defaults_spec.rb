require 'spec_helper'

describe 'consul::config_entry::service_defaults' do
  let(:title) { 'db.example.org' }
  let(:params) { {} }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_consul_config_entry('service-defaults/db.example.org').with(ensure: 'present', config: {}) }

  context 'with a destination' do
    let(:destination) { { 'Addresses' => ['db.example.org'], 'Port' => 5432 } }
    let(:params) { { service_protocol: 'tcp', mode: 'transparent', destination: destination } }

    it do
      is_expected.to contain_consul_config_entry('service-defaults/db.example.org').with_config(
        'Protocol' => 'tcp', 'Mode' => 'transparent', 'Destination' => destination,
      )
    end
  end

  context 'with meta' do
    let(:params) { { meta: { 'a' => 'b' } } }

    it { is_expected.to contain_consul_config_entry('service-defaults/db.example.org').with_config('Meta' => { 'a' => 'b' }) }
  end

  context 'with a wildcard destination' do
    let(:params) { { destination: { 'Addresses' => ['*.example.org'], 'Port' => 443 } } }

    it { is_expected.to compile.and_raise_error(%r{Addresses}) }
  end

  context 'with an unknown mode' do
    let(:params) { { mode: 'sideways' } }

    it { is_expected.to compile.and_raise_error(%r{mode}) }
  end
end
