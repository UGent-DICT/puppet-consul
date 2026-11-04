require 'spec_helper'
require_relative '../../../../lib/puppet_x/consul/config_entry_client'

describe PuppetX::Consul::ConfigEntryClient do
  let(:connection) { { protocol: 'http', hostname: 'consul.example', port: 8500, acl_api_token: 'secret' } }
  let(:url) { 'http://consul.example:8500/v1/config' }

  describe '.request' do
    it 'sends the token and returns the response' do
      stub = stub_request(:get, url).with(headers: { 'X-Consul-Token' => 'secret' }).to_return(status: 200, body: '[]')
      response = described_class.request(connection, Net::HTTP::Get, '/v1/config')
      expect(response.body).to eq('[]')
      expect(stub).to have_been_requested
    end

    it 'omits the token header when no token is set' do
      stub_request(:get, url).to_return(status: 200, body: '[]')
      described_class.request(connection.merge(acl_api_token: ''), Net::HTTP::Get, '/v1/config')
      expect(a_request(:get, url).with { |request| !request.headers.key?('X-Consul-Token') }).to have_been_made
    end

    it 'sends the body as JSON' do
      stub = stub_request(:put, url).with(body: { 'Kind' => 'mesh' }, headers: { 'Content-Type' => 'application/json' }).to_return(status: 200, body: 'true')
      described_class.request(connection, Net::HTTP::Put, '/v1/config', { 'Kind' => 'mesh' })
      expect(stub).to have_been_requested
    end

    it 'raises on a negative response' do
      stub_request(:get, url).to_return(status: 403, body: 'Permission denied')
      expect { described_class.request(connection, Net::HTTP::Get, '/v1/config') }.to raise_error(Puppet::Error, %r{Code: 403, Response: Permission denied})
    end

    it 'retries until the API answers' do
      allow(described_class).to receive(:sleep)
      stub_request(:get, url).to_raise(Errno::ECONNREFUSED).then.to_return(status: 200, body: '[]')
      expect(described_class.request(connection, Net::HTTP::Get, '/v1/config', nil, 2).code).to eq('200')
    end

    it 'raises when the connection is refused on every try' do
      allow(described_class).to receive(:sleep)
      stub_request(:get, url).to_raise(Errno::ECONNREFUSED)
      expect { described_class.request(connection, Net::HTTP::Get, '/v1/config', nil, 2) }.to raise_error(Puppet::Error, %r{refused by Consul API after 2 tries})
    end
  end
end
