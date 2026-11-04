require 'spec_helper'
require 'json'

describe Puppet::Type.type(:consul_config_entry).provider(:default) do
  let(:config) { { 'Listeners' => [{ 'Port' => 8200, 'Protocol' => 'tcp' }] } }
  let(:resource) do
    Puppet::Type.type(:consul_config_entry).new(
      title: 'api-gateway/agw',
      config: config,
      acl_api_token: token,
      api_tries: 1,
    )
  end
  let(:existing) { { 'Kind' => 'api-gateway', 'Name' => 'agw', 'Listeners' => [{ 'Port' => 8200, 'Protocol' => 'tcp', 'Name' => '' }], 'CreateIndex' => 5, 'ModifyIndex' => 7 } }

  after { described_class.reset }

  def token
    'e33653a6-0320-4a71-b3af-75f14578e3aa'
  end

  def list_url
    'http://localhost:8500/v1/config/api-gateway'
  end

  def resources
    { 'api-gateway/agw' => resource }
  end

  def stub_list(entries, url = list_url)
    stub_request(:get, url).with(headers: { 'X-Consul-Token' => token }).to_return(status: 200, body: JSON.dump(entries))
  end

  describe '.prefetch' do
    it 'marks a missing entry as absent' do
      stub_list([])
      described_class.prefetch(resources)
      expect(resource.provider.exists?).to be(false)
    end

    it 'ignores entries of the same kind with another name' do
      stub_list([existing.merge('Name' => 'other')])
      described_class.prefetch(resources)
      expect(resource.provider.exists?).to be(false)
    end

    it 'reads the config of an existing entry without Kind and Name' do
      stub_list([existing])
      described_class.prefetch(resources)
      expect(resource.provider.exists?).to be(true)
      expect(resource.provider.config).to eq(existing.reject { |key, _| %w[Kind Name].include?(key) })
    end

    it 'raises on a negative API response' do
      stub_request(:get, list_url).to_return(status: 403, body: 'Permission denied')
      expect { described_class.prefetch(resources) }.to raise_error(Puppet::Error, %r{Code: 403})
    end

    it 'lists each kind once' do
      tcp_route = Puppet::Type.type(:consul_config_entry).new(title: 'api-gateway/other', config: {}, acl_api_token: token, api_tries: 1)
      mesh = Puppet::Type.type(:consul_config_entry).new(title: 'mesh/mesh', config: {}, acl_api_token: token, api_tries: 1)
      gateways = stub_list([existing])
      meshes = stub_list([], 'http://localhost:8500/v1/config/mesh')

      described_class.prefetch('a' => resource, 'b' => tcp_route, 'c' => mesh)
      expect(gateways).to have_been_requested.once
      expect(meshes).to have_been_requested.once
    end

    it 'lists again for a different connection' do
      other = Puppet::Type.type(:consul_config_entry).new(title: 'api-gateway/agw', hostname: 'consul2', acl_api_token: token, api_tries: 1)
      first = stub_list([existing])
      second = stub_list([], 'http://consul2:8500/v1/config/api-gateway')

      described_class.prefetch('a' => resource, 'b' => other)
      expect(first).to have_been_requested.once
      expect(second).to have_been_requested.once
    end
  end

  context 'with a kind without a name' do
    let(:resource) { Puppet::Type.type(:consul_config_entry).new(title: 'mesh/mesh', config: { 'TransparentProxy' => { 'MeshDestinationsOnly' => true } }, acl_api_token: token, api_tries: 1) }
    let(:mesh_url) { 'http://localhost:8500/v1/config/mesh' }

    it 'finds the entry by its kind' do
      stub_list([{ 'Kind' => 'mesh', 'TransparentProxy' => { 'MeshDestinationsOnly' => true }, 'Hash' => 1 }], mesh_url)
      described_class.prefetch('mesh/mesh' => resource)
      expect(resource.provider.exists?).to be(true)
      expect(resource.property(:config).insync?(resource.provider.config)).to be(true)
    end

    it 'writes the entry without a Name' do
      stub_list([], mesh_url)
      put = stub_request(:put, 'http://localhost:8500/v1/config').with { |request| JSON.parse(request.body) == { 'Kind' => 'mesh', 'TransparentProxy' => { 'MeshDestinationsOnly' => true } } }.to_return(status: 200, body: 'true')

      described_class.prefetch('mesh/mesh' => resource)
      resource.provider.create
      resource.provider.flush
      expect(put).to have_been_requested
    end
  end

  describe 'insync?' do
    it 'is in sync when Consul only adds its own fields' do
      stub_list([existing])
      described_class.prefetch(resources)
      expect(resource.property(:config).insync?(resource.provider.config)).to be(true)
    end

    it 'is out of sync when a value differs' do
      stub_list([existing.merge('Listeners' => [{ 'Port' => 9999, 'Protocol' => 'tcp' }])])
      described_class.prefetch(resources)
      expect(resource.property(:config).insync?(resource.provider.config)).to be(false)
    end
  end

  describe '#flush' do
    let(:body) { { 'Kind' => 'api-gateway', 'Name' => 'agw' }.merge(config) }

    it 'writes the config entry on create' do
      stub_list([])
      put = stub_request(:put, 'http://localhost:8500/v1/config').with(body: body, headers: { 'X-Consul-Token' => token }).to_return(status: 200, body: 'true')

      described_class.prefetch(resources)
      resource.provider.create
      resource.provider.flush
      expect(put).to have_been_requested
    end

    it 'writes the config entry on update' do
      stub_list([existing.merge('Listeners' => [])])
      put = stub_request(:put, 'http://localhost:8500/v1/config').with(body: body).to_return(status: 200, body: 'true')

      described_class.prefetch(resources)
      resource.provider.config = config
      resource.provider.flush
      expect(put).to have_been_requested
    end

    it 'deletes the config entry on destroy' do
      stub_list([existing])
      delete = stub_request(:delete, 'http://localhost:8500/v1/config/api-gateway/agw').to_return(status: 200, body: 'true')

      described_class.prefetch(resources)
      resource.provider.destroy
      resource.provider.flush
      expect(delete).to have_been_requested
    end

    it 'does nothing without changes' do
      stub_list([existing])
      described_class.prefetch(resources)
      resource.provider.flush
      expect(a_request(:any, %r{/v1/config})).to have_been_made.once # only the list
    end

    it 'raises when Consul rejects the entry' do
      stub_list([])
      stub_request(:put, 'http://localhost:8500/v1/config').to_return(status: 400, body: 'invalid')

      described_class.prefetch(resources)
      resource.provider.create
      expect { resource.provider.flush }.to raise_error(Puppet::Error, %r{Code: 400})
    end
  end
end
