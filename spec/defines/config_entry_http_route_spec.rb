require 'spec_helper'

describe 'consul::config_entry::http_route' do
  let(:title) { 'web' }
  let(:parents) { [{ 'Kind' => 'api-gateway', 'Name' => 'agw', 'SectionName' => 'https' }] }
  let(:rules) { [{ 'Matches' => [{ 'Path' => { 'Match' => 'prefix', 'Value' => '/' } }], 'Services' => [{ 'Name' => 'web' }] }] }
  let(:params) { { parents: parents, rules: rules } }

  it { is_expected.to compile.with_all_deps }

  it 'declares the config entry without unset fields' do
    is_expected.to contain_consul_config_entry('http-route/web').with(ensure: 'present', config: { 'Parents' => parents, 'Rules' => rules })
  end

  context 'with hostnames, meta and connection parameters' do
    let(:params) { { parents: parents, rules: rules, hostnames: ['web.example.org'], meta: { 'team' => 'core' }, hostname: 'consul2', acl_api_token: 'secret' } }

    it do
      is_expected.to contain_consul_config_entry('http-route/web').with(
        config: { 'Parents' => parents, 'Rules' => rules, 'Hostnames' => ['web.example.org'], 'Meta' => { 'team' => 'core' } },
        hostname: 'consul2',
        acl_api_token: 'secret',
      )
    end
  end

  context 'with ensure absent' do
    let(:params) { { parents: parents, rules: rules, ensure: 'absent' } }

    it { is_expected.to contain_consul_config_entry('http-route/web').with_ensure('absent') }
  end

  context 'without rules' do
    let(:params) { { parents: parents, rules: [] } }

    it { is_expected.to compile.and_raise_error(%r{expects size to be at least 1}) }
  end

  context 'with an unknown match type' do
    let(:params) { { parents: parents, rules: [{ 'Matches' => [{ 'Path' => { 'Match' => 'glob', 'Value' => '/' } }], 'Services' => [{ 'Name' => 'web' }] }] } }

    it { is_expected.to compile.and_raise_error(%r{Match}) }
  end
end
