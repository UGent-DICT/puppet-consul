require 'spec_helper'
require 'json'

describe Puppet::Type.type(:consul_intention).provider(:default) do
  let(:token) { 'e33653a6-0320-4a71-b3af-75f14578e3aa' }
  let(:sources) { [{ 'name' => 'api', 'action' => 'allow' }] }
  let(:resource) do
    Puppet::Type.type(:consul_intention).new(
      name: 'web',
      sources: sources,
      acl_api_token: token,
      api_tries: 1,
    )
  end
  let(:resources) { { 'web' => resource } }

  after { described_class.reset }

  def stub_list(entries)
    stub_request(:get, 'http://localhost:8500/v1/config/service-intentions')
      .with(headers: { 'X-Consul-Token' => token })
      .to_return(status: 200, body: JSON.dump(entries))
  end

  describe '.prefetch' do
    it 'marks a missing destination as absent' do
      stub_list([])
      described_class.prefetch(resources)
      expect(resource.provider.exists?).to be(false)
    end

    it 'reads the sources of an existing destination' do
      stub_list([{ 'Kind' => 'service-intentions', 'Name' => 'web', 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow', 'Precedence' => 9, 'Type' => 'consul' }] }])
      described_class.prefetch(resources)
      expect(resource.provider.exists?).to be(true)
      expect(resource.provider.sources).to eq(sources)
    end

    it 'raises on a negative API response' do
      stub_request(:get, 'http://localhost:8500/v1/config/service-intentions').to_return(status: 403, body: 'Permission denied')
      expect { described_class.prefetch(resources) }.to raise_error(Puppet::Error, %r{Code: 403})
    end
  end

  describe '#flush' do
    it 'writes the config entry on create' do
      stub_list([])
      put = stub_request(:put, 'http://localhost:8500/v1/config')
            .with(body: { 'Kind' => 'service-intentions', 'Name' => 'web', 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow' }] })
            .to_return(status: 200, body: 'true')

      described_class.prefetch(resources)
      resource.provider.create
      resource.provider.flush
      expect(put).to have_been_requested
    end

    it 'deletes the config entry on destroy' do
      stub_list([{ 'Name' => 'web', 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow' }] }])
      delete = stub_request(:delete, 'http://localhost:8500/v1/config/service-intentions/web').to_return(status: 200, body: 'true')

      described_class.prefetch(resources)
      resource.provider.destroy
      resource.provider.flush
      expect(delete).to have_been_requested
    end

    it 'does nothing without changes' do
      stub_list([{ 'Name' => 'web', 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow' }] }])
      described_class.prefetch(resources)
      resource.provider.flush
      expect(a_request(:put, %r{/v1/config})).not_to have_been_made
    end
  end
end
