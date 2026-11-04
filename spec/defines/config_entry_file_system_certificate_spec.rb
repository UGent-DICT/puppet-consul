require 'spec_helper'

describe 'consul::config_entry::file_system_certificate' do
  let(:title) { 'web' }
  let(:params) { { certificate: '/etc/consul/web.crt', private_key: '/etc/consul/web.key' } }

  it { is_expected.to compile.with_all_deps }

  it 'declares the config entry' do
    is_expected.to contain_consul_config_entry('file-system-certificate/web').with(
      ensure: 'present',
      config: { 'Certificate' => '/etc/consul/web.crt', 'PrivateKey' => '/etc/consul/web.key' },
    )
  end

  context 'with meta' do
    let(:params) { super().merge(meta: { 'a' => 'b' }) }

    it { is_expected.to contain_consul_config_entry('file-system-certificate/web').with_config('Certificate' => '/etc/consul/web.crt', 'PrivateKey' => '/etc/consul/web.key', 'Meta' => { 'a' => 'b' }) }
  end

  context 'with a relative path' do
    let(:params) { { certificate: 'web.crt', private_key: '/etc/consul/web.key' } }

    it { is_expected.to compile.and_raise_error(%r{certificate}) }
  end
end
