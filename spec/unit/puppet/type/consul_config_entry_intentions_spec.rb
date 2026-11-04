require 'spec_helper'

# service-intentions as written by consul::config_entry::service_intentions, compared with what Consul answers
describe Puppet::Type.type(:consul_config_entry) do
  let(:sources) { [{ 'Name' => 'api', 'Action' => 'allow' }, { 'Name' => 'db', 'Action' => 'deny', 'Description' => 'no direct access' }] }
  let(:entry) { described_class.new(title: 'service-intentions/web', config: { 'Sources' => sources }, unordered_keys: ['Sources']) }
  let(:consul_source) { { 'Type' => 'consul', 'Precedence' => 9, 'LegacyID' => '', 'Namespace' => 'default', 'Partition' => 'default' } }

  def insync?(is)
    entry.property(:config).insync?(is)
  end

  it 'ignores the sort order and fields added by Consul' do
    is = { 'Sources' => [{ 'Name' => 'db', 'Action' => 'deny', 'Description' => 'no direct access' }.merge(consul_source), { 'Name' => 'api', 'Action' => 'allow' }.merge(consul_source)], 'CreateIndex' => 1, 'ModifyIndex' => 2 }
    expect(insync?(is)).to be(true)
  end

  it 'detects a changed action' do
    expect(insync?({ 'Sources' => [{ 'Name' => 'api', 'Action' => 'deny' }.merge(consul_source), { 'Name' => 'db', 'Action' => 'deny', 'Description' => 'no direct access' }.merge(consul_source)] })).to be(false)
  end

  it 'detects an added source' do
    is = { 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow' }, { 'Name' => 'db', 'Action' => 'deny', 'Description' => 'no direct access' }, { 'Name' => 'other', 'Action' => 'allow' }] }
    expect(insync?(is)).to be(false)
  end

  it 'detects a removed source' do
    expect(insync?({ 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow' }] })).to be(false)
  end

  it 'detects a missing entry' do
    expect(insync?(:absent)).to be(false)
  end

  context 'with L7 permissions' do
    let(:sources) { [{ 'Name' => 'api', 'Permissions' => [{ 'Action' => 'allow', 'HTTP' => { 'PathPrefix' => '/v1', 'Methods' => %w[GET POST] } }] }] }

    it 'ignores fields added by Consul inside the permissions' do
      is = { 'Sources' => [{ 'Name' => 'api', 'Permissions' => [{ 'Action' => 'allow', 'HTTP' => { 'PathPrefix' => '/v1', 'Methods' => %w[GET POST], 'Header' => nil } }] }.merge(consul_source)] }
      expect(insync?(is)).to be(true)
    end

    it 'keeps the order of the methods significant' do
      is = { 'Sources' => [{ 'Name' => 'api', 'Permissions' => [{ 'Action' => 'allow', 'HTTP' => { 'PathPrefix' => '/v1', 'Methods' => %w[POST GET] } }] }] }
      expect(insync?(is)).to be(false)
    end
  end
end
