require 'puppet_x'
require_relative 'http_client'
require 'json'
require 'net/http'
require 'uri'

module PuppetX::Consul
  # Minimal Consul HTTP API client shared by the providers that manage config entries.
  module ConfigEntryClient
    # Performs a request against the Consul API, taking the connection settings
    # (protocol, hostname, port, acl_api_token and the TLS parameters) from the resource.
    #
    # @param resource [Puppet::Type] resource carrying the connection parameters
    # @param method [Class] a Net::HTTP request class, e.g. Net::HTTP::Get
    # @param path [String] API path including the leading slash, e.g. '/v1/config'
    # @param body [Hash, nil] body, sent as JSON
    # @param tries [Integer] number of tries, to ride out Consul having just started
    # @return [Net::HTTPResponse] the first response with status 200
    def self.request(resource, method, path, body = nil, tries = 1)
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
  end
end
