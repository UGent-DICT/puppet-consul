require 'spec_helper'

describe 'Consul::Config_entry::Parent_ref' do
  it { is_expected.to allow_value({ 'Kind' => 'api-gateway', 'Name' => 'agw' }) }
  it { is_expected.to allow_value({ 'Kind' => 'api-gateway', 'Name' => 'agw', 'SectionName' => 'tcp-8200' }) }
  it { is_expected.not_to allow_value({ 'Kind' => 'ingress-gateway', 'Name' => 'agw' }) }
  it { is_expected.not_to allow_value({ 'Kind' => 'api-gateway' }) }
  it { is_expected.not_to allow_value({ 'Kind' => 'api-gateway', 'Name' => 'agw', 'Namespace' => 'x' }) }
end
