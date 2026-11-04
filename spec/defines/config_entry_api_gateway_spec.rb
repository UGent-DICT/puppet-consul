require 'spec_helper'

describe 'consul::config_entry::api_gateway' do
  let(:title) { 'agw' }
  let(:listeners) { [{ 'Name' => 'vault', 'Port' => 8200, 'Protocol' => 'tcp' }] }
  let(:params) { { listeners: listeners } }

  it { is_expected.to compile.with_all_deps }

  it 'declares the config entry' do
    is_expected.to contain_consul_config_entry('api-gateway/agw').with(ensure: 'present', config: { 'Listeners' => listeners })
  end

  it 'does not pass connection parameters that are not set' do
    is_expected.to contain_consul_config_entry('api-gateway/agw').without_hostname.without_acl_api_token.without_protocol
  end

  context 'with meta and connection parameters' do
    let(:params) do
      {
        listeners: listeners,
        meta: { 'team' => 'core' },
        acl_api_token: 'secret',
        protocol: 'https',
        hostname: 'consul.example.org',
        port: 8501,
        ca_file: '/etc/ssl/ca.pem',
        client_cert: '/etc/ssl/client.pem',
        client_key: '/etc/ssl/client.key',
        api_tries: 5,
      }
    end

    it 'adds Meta and passes the connection parameters through' do
      is_expected.to contain_consul_config_entry('api-gateway/agw').with(
        config: { 'Listeners' => listeners, 'Meta' => { 'team' => 'core' } },
        acl_api_token: 'secret',
        protocol: 'https',
        hostname: 'consul.example.org',
        port: 8501,
        ca_file: '/etc/ssl/ca.pem',
        client_cert: '/etc/ssl/client.pem',
        client_key: '/etc/ssl/client.key',
        api_tries: 5,
      )
    end
  end

  context 'with ensure absent' do
    let(:params) { { listeners: listeners, ensure: 'absent' } }

    it { is_expected.to contain_consul_config_entry('api-gateway/agw').with_ensure('absent') }
  end

  context 'without listeners' do
    let(:params) { { listeners: [] } }

    it { is_expected.to compile.and_raise_error(%r{expects size to be at least 1}) }
  end

  context 'with an invalid protocol' do
    let(:params) { { listeners: [{ 'Name' => 'x', 'Port' => 1, 'Protocol' => 'udp' }] } }

    it { is_expected.to compile.and_raise_error(%r{Protocol}) }
  end
end
