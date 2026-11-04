require 'spec_helper'

describe 'consul::config_entry::tcp_route' do
  let(:title) { 'vault' }
  let(:parents) { [{ 'Kind' => 'api-gateway', 'Name' => 'agw', 'SectionName' => 'vault' }] }
  let(:services) { [{ 'Name' => 'vault' }] }
  let(:params) { { parents: parents, services: services } }

  it { is_expected.to compile.with_all_deps }

  it 'declares the config entry' do
    is_expected.to contain_consul_config_entry('tcp-route/vault').with(ensure: 'present', config: { 'Parents' => parents, 'Services' => services })
  end

  context 'with meta and connection parameters' do
    let(:params) { { parents: parents, services: services, meta: { 'a' => 'b' }, hostname: 'consul2', port: 8500 } }

    it 'adds Meta and passes the connection parameters through' do
      is_expected.to contain_consul_config_entry('tcp-route/vault').with(
        config: { 'Parents' => parents, 'Services' => services, 'Meta' => { 'a' => 'b' } },
        hostname: 'consul2',
        port: 8500,
      )
    end
  end

  context 'with more than one service' do
    let(:params) { { parents: parents, services: [{ 'Name' => 'a' }, { 'Name' => 'b' }] } }

    it { is_expected.to compile.and_raise_error(%r{expects size to be 1, got 2}) }
  end

  context 'with a parent that is not an api-gateway' do
    let(:params) { { parents: [{ 'Kind' => 'ingress-gateway', 'Name' => 'x' }], services: services } }

    it { is_expected.to compile.and_raise_error(%r{expects a match for Enum\['api-gateway'\]}) }
  end
end
