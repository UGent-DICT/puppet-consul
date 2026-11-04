require 'spec_helper'

describe 'consul::config_entry::service_intentions' do
  let(:title) { 'web' }
  let(:sources) { [{ 'Name' => 'api', 'Action' => 'allow' }, { 'Name' => '*', 'Action' => 'deny' }] }
  let(:params) { { sources: sources } }

  it { is_expected.to compile.with_all_deps }

  it 'declares the config entry and ignores the order of the sources' do
    is_expected.to contain_consul_config_entry('service-intentions/web').with(
      ensure: 'present',
      config: { 'Sources' => sources },
      unordered_keys: ['Sources'],
    )
  end

  context 'with L7 permissions' do
    let(:sources) { [{ 'Name' => 'api', 'Permissions' => [{ 'Action' => 'allow', 'HTTP' => { 'PathPrefix' => '/v1', 'Methods' => ['GET'] } }] }] }

    it { is_expected.to contain_consul_config_entry('service-intentions/web').with_config('Sources' => sources) }
  end

  context 'with meta and connection parameters' do
    let(:params) { { sources: sources, meta: { 'a' => 'b' }, port: 8501, protocol: 'https' } }

    it { is_expected.to contain_consul_config_entry('service-intentions/web').with(config: { 'Sources' => sources, 'Meta' => { 'a' => 'b' } }, port: 8501, protocol: 'https') }
  end

  context 'with ensure absent' do
    let(:params) { { sources: sources, ensure: 'absent' } }

    it { is_expected.to contain_consul_config_entry('service-intentions/web').with_ensure('absent') }
  end

  context 'with an invalid action' do
    let(:params) { { sources: [{ 'Name' => 'api', 'Action' => 'permit' }] } }

    it { is_expected.to compile.and_raise_error(%r{'Action' expects a match for Enum\['allow', 'deny'\], got 'permit'}) }
  end

  context 'with both Action and Permissions' do
    let(:params) { { sources: [{ 'Name' => 'api', 'Action' => 'allow', 'Permissions' => [{ 'Action' => 'allow', 'HTTP' => {} }] }] } }

    it { is_expected.to compile.and_raise_error(%r{unrecognized key 'Permissions'}) }
  end

  context 'without sources' do
    let(:params) { { sources: [] } }

    it { is_expected.to compile.and_raise_error(%r{expects size to be at least 1}) }
  end
end
