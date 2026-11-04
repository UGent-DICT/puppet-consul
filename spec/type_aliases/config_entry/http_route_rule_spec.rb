require 'spec_helper'

describe 'Consul::Config_entry::Http_route_rule' do
  it { is_expected.to allow_value({ 'Services' => [{ 'Name' => 'web' }] }) }

  it do
    is_expected.to allow_value(
      {
        'Matches' => [{ 'Path' => { 'Match' => 'prefix', 'Value' => '/api' }, 'Method' => 'GET', 'Headers' => [{ 'Name' => 'X-Env', 'Match' => 'exact', 'Value' => 'dev' }] }],
        'Filters' => { 'URLRewrite' => { 'Path' => '/' }, 'Headers' => [{ 'Set' => { 'X-A' => 'b' }, 'Remove' => ['X-C'] }], 'TimeoutFilter' => { 'RequestTimeout' => '30s' } },
        'Services' => [{ 'Name' => 'web', 'Weight' => 10 }],
      },
    )
  end

  it { is_expected.not_to allow_value({}) }
  it { is_expected.not_to allow_value({ 'Services' => [] }) }
  it { is_expected.not_to allow_value({ 'Services' => [{ 'Name' => 'web' }], 'Matches' => [{ 'Path' => { 'Match' => 'glob', 'Value' => '/' } }] }) }
  it { is_expected.not_to allow_value({ 'Services' => [{ 'Name' => 'web' }], 'Filters' => { 'TimeoutFilter' => { 'RequestTimeout' => 'soon' } } }) }
end
