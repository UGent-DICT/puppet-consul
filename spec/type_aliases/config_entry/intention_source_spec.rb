require 'spec_helper'

describe 'Consul::Config_entry::Intention_source' do
  it { is_expected.to allow_value({ 'Name' => 'api', 'Action' => 'allow' }) }
  it { is_expected.to allow_value({ 'Name' => '*', 'Action' => 'deny', 'Description' => 'default deny' }) }
  it { is_expected.to allow_value({ 'Name' => 'api', 'Permissions' => [{ 'Action' => 'allow', 'HTTP' => { 'PathPrefix' => '/v1', 'Methods' => ['GET'], 'Header' => [{ 'Name' => 'X-A', 'Present' => true }] } }] }) }
  it { is_expected.not_to allow_value({ 'Name' => 'api', 'Action' => 'maybe' }) }
  it { is_expected.not_to allow_value({ 'Name' => 'api' }) }
  it { is_expected.not_to allow_value({ 'Action' => 'allow' }) }
  it { is_expected.not_to allow_value({ 'Name' => 'api', 'Action' => 'allow', 'Permissions' => [{ 'Action' => 'allow', 'HTTP' => {} }] }) }
  it { is_expected.not_to allow_value({ 'Name' => 'api', 'Permissions' => [] }) }
  it { is_expected.not_to allow_value({ 'Name' => 'api', 'Permissions' => [{ 'Action' => 'allow' }] }) }
end
