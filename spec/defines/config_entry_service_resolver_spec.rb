require 'spec_helper'

describe 'consul::config_entry::service_resolver' do
  let(:title) { 'web' }
  let(:cookie_policy) do
    {
      'Policy'       => 'maglev',
      'HashPolicies' => [{
        'Field'        => 'cookie',
        'FieldValue'   => 'ROUTEID',
        'CookieConfig' => { 'TTL' => '1h', 'Path' => '/' },
      }],
    }
  end
  let(:params) { { load_balancer: cookie_policy } }

  it { is_expected.to compile.with_all_deps }

  it 'names the entry after the service and sends the load balancer as is' do
    is_expected.to contain_consul_config_entry('service-resolver/web').with(ensure: 'present', config: { 'LoadBalancer' => cookie_policy })
  end

  context 'with subsets, failover and timeouts' do
    let(:params) do
      {
        default_subset:  'v1',
        subsets:         { 'v1' => { 'Filter' => 'Service.Meta.version == 1', 'OnlyPassing' => true } },
        failover:        { '*' => { 'Datacenters' => ['S10'] } },
        connect_timeout: '5s',
        request_timeout: '1m30s',
        meta:            { 'owner' => 'platform' },
      }
    end

    it do
      is_expected.to contain_consul_config_entry('service-resolver/web').with_config(
        'DefaultSubset'  => 'v1',
        'Subsets'        => { 'v1' => { 'Filter' => 'Service.Meta.version == 1', 'OnlyPassing' => true } },
        'Failover'       => { '*' => { 'Datacenters' => ['S10'] } },
        'ConnectTimeout' => '5s',
        'RequestTimeout' => '1m30s',
        'Meta'           => { 'owner' => 'platform' },
      )
    end
  end

  context 'with connection parameters' do
    let(:params) { { hostname: 'consul.example.org', port: 8501, protocol: 'https', api_tries: 3 } }

    it { is_expected.to contain_consul_config_entry('service-resolver/web').with(hostname: 'consul.example.org', port: 8501, protocol: 'https', api_tries: 3) }
  end

  context 'with ensure absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_consul_config_entry('service-resolver/web').with_ensure('absent') }
  end

  context 'with a least_request policy and its config' do
    let(:params) { { load_balancer: { 'Policy' => 'least_request', 'LeastRequestConfig' => { 'ChoiceCount' => 3 } } } }

    it { is_expected.to compile.with_all_deps }
  end

  context 'with hash policies and the round_robin policy' do
    let(:params) { { load_balancer: cookie_policy.merge('Policy' => 'round_robin') } }

    it { is_expected.to compile.and_raise_error(%r{HashPolicies need the ring_hash or maglev policy}) }
  end

  context 'with hash policies and no policy' do
    let(:params) { { load_balancer: { 'HashPolicies' => [{ 'SourceIP' => true }] } } }

    it { is_expected.to compile.and_raise_error(%r{HashPolicies need the ring_hash or maglev policy}) }
  end

  context 'with a ring hash config and another policy' do
    let(:params) { { load_balancer: { 'Policy' => 'maglev', 'RingHashConfig' => { 'MinimumRingSize' => 64 } } } }

    it { is_expected.to compile.and_raise_error(%r{RingHashConfig needs the ring_hash policy}) }
  end

  context 'with a least request config and another policy' do
    let(:params) { { load_balancer: { 'Policy' => 'random', 'LeastRequestConfig' => { 'ChoiceCount' => 2 } } } }

    it { is_expected.to compile.and_raise_error(%r{LeastRequestConfig needs the least_request policy}) }
  end

  context 'with a hash policy field and no FieldValue' do
    let(:params) { { load_balancer: { 'Policy' => 'maglev', 'HashPolicies' => [{ 'Field' => 'cookie' }] } } }

    it { is_expected.to compile.and_raise_error(%r{Field cookie needs a FieldValue}) }
  end

  context 'with a cookie config on a header hash policy' do
    let(:params) { { load_balancer: { 'Policy' => 'maglev', 'HashPolicies' => [{ 'Field' => 'header', 'FieldValue' => 'X-Id', 'CookieConfig' => { 'Session' => true } }] } } }

    it { is_expected.to compile.and_raise_error(%r{CookieConfig is only valid with Field => cookie}) }
  end

  context 'with both TTL and Session in the cookie config' do
    let(:params) { { load_balancer: { 'Policy' => 'maglev', 'HashPolicies' => [{ 'Field' => 'cookie', 'FieldValue' => 'A', 'CookieConfig' => { 'Session' => true, 'TTL' => '1h' } }] } } }

    it { is_expected.to compile.and_raise_error(%r{either TTL or Session}) }
  end

  context 'with a default subset that does not exist' do
    let(:params) { { default_subset: 'v2', subsets: { 'v1' => {} } } }

    it { is_expected.to compile.and_raise_error(%r{default_subset v2 is not one of the subsets}) }
  end

  context 'with a default subset and no subsets' do
    let(:params) { { default_subset: 'v1' } }

    it { is_expected.to compile.and_raise_error(%r{default_subset v1 is not one of the subsets}) }
  end

  context 'with an invalid timeout' do
    let(:params) { { connect_timeout: 'soon' } }

    it { is_expected.to compile.and_raise_error(%r{connect_timeout}) }
  end

  context 'with an unknown policy' do
    let(:params) { { load_balancer: { 'Policy' => 'fastest' } } }

    it { is_expected.to compile.and_raise_error(%r{Policy}) }
  end
end
