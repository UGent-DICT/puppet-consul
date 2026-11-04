require 'spec_helper'

describe 'consul::config_entry::terminating_gateway' do
  let(:title) { 'tgw-private' }
  let(:services) { [{ 'Name' => 'db.example.org', 'CAFile' => '/etc/ssl/ca.pem' }, { 'Name' => 'cache' }] }
  let(:params) { { services: services } }

  it { is_expected.to compile.with_all_deps }

  it 'declares the config entry' do
    is_expected.to contain_consul_config_entry('terminating-gateway/tgw-private').with(ensure: 'present', config: { 'Services' => services })
  end

  context 'with meta and connection parameters' do
    let(:params) { { services: services, meta: { 'a' => 'b' }, acl_api_token: 'secret' } }

    it { is_expected.to contain_consul_config_entry('terminating-gateway/tgw-private').with(config: { 'Services' => services, 'Meta' => { 'a' => 'b' } }, acl_api_token: 'secret') }
  end

  context 'with both CertFile and KeyFile' do
    let(:params) { { services: [{ 'Name' => 'db', 'CertFile' => '/etc/ssl/c.pem', 'KeyFile' => '/etc/ssl/k.pem' }] } }

    it { is_expected.to compile }
  end

  context 'with a CertFile without KeyFile' do
    let(:params) { { services: [{ 'Name' => 'db', 'CertFile' => '/etc/ssl/c.pem' }] } }

    it { is_expected.to compile.and_raise_error(%r{CertFile and KeyFile of service db must be set together}) }
  end

  context 'without services' do
    let(:params) { { services: [] } }

    it { is_expected.to compile.and_raise_error(%r{expects size to be at least 1}) }
  end
end
