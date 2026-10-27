require_relative '../../../puppet_x/consul/http_client'
require 'json'
require 'net/http'
require 'uri'

Puppet::Type.type(:consul_intention).provide(
  :default,
) do
  mk_resource_methods

  def self.prefetch(resources)
    reset
    resources.each do |name, resource|
      found = list_resources(resource).find { |intention| intention[:name] == name }
      resource.provider = new(found || { ensure: :absent })
    end
  end

  def self.list_resources(resource)
    @intentions ||= {}
    cache_key = [resource[:hostname], resource[:port], resource[:protocol], resource[:acl_api_token], PuppetX::Consul::HTTPClient.tls_options(resource)]
    @intentions[cache_key] ||= begin
      response = api_request(resource, Net::HTTP::Get, '/v1/config/service-intentions', nil, resource[:api_tries])
      JSON.parse(response.body).map do |entry|
        {
          name: entry['Name'],
          ensure: :present,
          sources: (entry['Sources'] || []).map { |source| { 'name' => source['Name'], 'action' => source['Action'] } },
        }
      end
    end
  end

  def self.api_request(resource, method, path, body = nil, tries = 1)
    uri = URI("#{resource[:protocol]}://#{resource[:hostname]}:#{resource[:port]}#{path}")
    http = PuppetX::Consul::HTTPClient.build(uri, PuppetX::Consul::HTTPClient.tls_options(resource))
    request = method.new(uri.request_uri)
    request['X-Consul-Token'] = resource[:acl_api_token] unless resource[:acl_api_token].to_s.empty?
    if body
      request['Content-Type'] = 'application/json'
      request.body = body.to_json
    end
    response = nil

    # retry Consul API query, in case Consul has just started
    (1..tries).each do |i|
      unless i == 1
        Puppet.debug("retrying Consul API query in #{i} seconds")
        sleep i
      end

      begin
        response = http.request(request)
        return response if response.code == '200'
      rescue Errno::ECONNREFUSED => e
        Puppet.debug("#{e.class} #{e.message}")
      end
    end

    raise Puppet::Error, "Connection refused by Consul API after #{tries} tries" if response.nil?

    raise Puppet::Error, "Got negative Consul API response (Code: #{response.code}, Response: #{response.body})"
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

  def sources=(value)
    @property_flush[:sources] = value
  end

  def flush
    return if @property_flush.empty?

    name = @resource[:name]

    if @property_flush[:ensure] == :absent
      self.class.api_request(@resource, Net::HTTP::Delete, "/v1/config/service-intentions/#{URI.encode_www_form_component(name)}", nil, @resource[:api_tries])
      Puppet.notice("Deleted Consul intentions for #{name}")
      @property_hash = { name: name, ensure: :absent }
      return
    end

    sources = @resource[:sources] || []
    body = {
      'Kind' => 'service-intentions',
      'Name' => name,
      'Sources' => sources.map { |source| { 'Name' => source['name'], 'Action' => source['action'] } },
    }
    self.class.api_request(@resource, Net::HTTP::Put, '/v1/config', body, @resource[:api_tries])
    Puppet.notice("Updated Consul intentions for #{name}")
    @property_hash = { name: name, ensure: :present, sources: sources }
  end

  def self.reset
    @intentions = nil
  end
end
