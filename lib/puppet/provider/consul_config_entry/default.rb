require_relative '../../../puppet_x/consul/http_client'
require_relative '../../../puppet_x/consul/config_entry_client'
require 'json'
require 'net/http'
require 'uri'

Puppet::Type.type(:consul_config_entry).provide(
  :default,
) do
  mk_resource_methods

  # Singleton kinds without a Name: Consul rejects the field on write and leaves it out on read
  def self.nameless_kind?(kind)
    %w[mesh].include?(kind)
  end

  def self.prefetch(resources)
    reset
    resources.each_value do |resource|
      found = list_entries(resource).find { |entry| (entry['Name'] || entry['Kind']) == resource[:name] }
      resource.provider = new(found ? { name: resource[:name], ensure: :present, config: found.reject { |key, _| %w[Kind Name].include?(key) } } : { ensure: :absent })
    end
  end

  # One request per kind and connection, shared by all resources of that kind
  def self.list_entries(resource)
    @entries ||= {}
    cache_key = [resource[:kind], resource[:hostname], resource[:port], resource[:protocol], resource[:acl_api_token], PuppetX::Consul::HTTPClient.tls_options(resource)]
    @entries[cache_key] ||= begin
      response = PuppetX::Consul::ConfigEntryClient.request(resource, Net::HTTP::Get, "/v1/config/#{URI.encode_www_form_component(resource[:kind])}", nil, resource[:api_tries])
      JSON.parse(response.body)
    end
  end

  def self.reset
    @entries = nil
  end

  def initialize(value = {})
    super
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def config=(value)
    @property_flush[:config] = value
  end

  def flush
    return if @property_flush.empty?

    kind = @resource[:kind]
    name = @resource[:name]

    if @property_flush[:ensure] == :absent
      PuppetX::Consul::ConfigEntryClient.request(@resource, Net::HTTP::Delete, "/v1/config/#{URI.encode_www_form_component(kind)}/#{URI.encode_www_form_component(name)}", nil, @resource[:api_tries])
      Puppet.notice("Deleted Consul #{kind} config entry #{name}")
      @property_hash = { name: name, ensure: :absent }
      return
    end

    config = @resource[:config] || {}
    identity = self.class.nameless_kind?(kind) ? { 'Kind' => kind } : { 'Kind' => kind, 'Name' => name }
    PuppetX::Consul::ConfigEntryClient.request(@resource, Net::HTTP::Put, '/v1/config', identity.merge(config), @resource[:api_tries])
    Puppet.notice("Updated Consul #{kind} config entry #{name}")
    @property_hash = { name: name, ensure: :present, config: config }
  end
end
