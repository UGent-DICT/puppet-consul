require 'spec_helper'

describe Puppet::Type.type(:consul_config_entry) do
  let(:config) { { 'Listeners' => [{ 'Port' => 8200, 'Protocol' => 'tcp' }] } }

  it 'splits the title into kind and name' do
    entry = described_class.new(title: 'api-gateway/agw', config: config)
    expect(entry[:kind]).to eq('api-gateway')
    expect(entry[:name]).to eq('agw')
  end

  it 'keeps slashes in the name' do
    entry = described_class.new(title: 'service-defaults/a/b')
    expect(entry[:kind]).to eq('service-defaults')
    expect(entry[:name]).to eq('a/b')
  end

  it 'has a unique name across kinds, as Puppet keys prefetching by it' do
    route = described_class.new(title: 'http-route/web')
    intentions = described_class.new(title: 'service-intentions/web')
    expect(route.name).to eq('http-route/web')
    expect(intentions.name).not_to eq(route.name)
    expect(intentions[:name]).to eq('web')
  end

  it 'defaults ensure to present and unordered_keys to empty' do
    entry = described_class.new(title: 'mesh/mesh')
    expect(entry[:ensure]).to eq(:present)
    expect(entry[:unordered_keys]).to eq([])
  end

  it 'fails without a kind in the title' do
    expect { described_class.new(title: 'agw') }.to raise_error(Puppet::Error, %r{title patterns})
  end

  it 'fails if config is not a hash' do
    expect { described_class.new(title: 'mesh/mesh', config: 'x') }.to raise_error(Puppet::Error, %r{config must be a hash})
  end

  it 'fails if config contains Kind or Name' do
    expect { described_class.new(title: 'mesh/mesh', config: { 'Kind' => 'mesh' }) }.to raise_error(Puppet::Error, %r{must not contain Kind})
  end

  describe 'config insync?' do
    let(:entry) { described_class.new(title: 'service-intentions/web', config: { 'Sources' => [{ 'Name' => 'a', 'Action' => 'allow' }, { 'Name' => 'b', 'Action' => 'deny' }] }, unordered_keys: ['Sources']) }
    let(:property) { entry.property(:config) }

    it 'ignores fields set by Consul and the order of unordered keys' do
      is = { 'Sources' => [{ 'Name' => 'b', 'Action' => 'deny', 'Precedence' => 9 }, { 'Name' => 'a', 'Action' => 'allow', 'Precedence' => 9 }], 'CreateIndex' => 1 }
      expect(property.insync?(is)).to be(true)
    end

    it 'detects a difference' do
      expect(property.insync?({ 'Sources' => [{ 'Name' => 'a', 'Action' => 'deny' }, { 'Name' => 'b', 'Action' => 'deny' }] })).to be(false)
    end

    it 'detects a missing entry' do
      expect(property.insync?(:absent)).to be(false)
    end
  end

  it 'only shows the managed keys of the current state' do
    entry = described_class.new(title: 'api-gateway/agw', config: config)
    is = config.merge('Status' => { 'Conditions' => [] }, 'Hash' => 1, 'CreateIndex' => 2)
    expect(entry.property(:config).is_to_s(is)).to eq(config.to_json)
    expect(entry.property(:config).is_to_s(:absent)).to eq('"absent"')
  end

  it 'takes the TLS parameters' do
    expect { described_class.new(title: 'mesh/mesh', client_cert: '/c.pem') }.to raise_error(Puppet::Error, %r{client_cert and client_key})
  end
end
