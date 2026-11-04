require_relative '../../puppet_x/consul/tls_parameters'
require_relative '../../puppet_x/consul/config_entry_match'

Puppet::Type.newtype(:consul_config_entry) do
  desc <<-EOD
  Manages a Consul config entry through the `/v1/config` API.

  The title is `<kind>/<name>`, e.g. `api-gateway/agw`. The `config` property is the raw Consul
  JSON of the entry (PascalCase keys, without `Kind` and `Name`) and is not validated here;
  use the `consul::config_entry::*` defined types for validated input.

  The entry is in sync when everything in `config` is present in Consul: fields set by Consul
  itself are ignored.
  EOD
  PuppetX::Consul::TLSParameters.apply(self)

  ensurable do
    defaultvalues
    defaultto :present
  end

  # Puppet keys prefetching by #name, so it has to be unique across kinds (e.g. http-route/web and service-intentions/web)
  def name
    "#{self[:kind]}/#{self[:name]}"
  end

  def self.title_patterns
    [[%r{\A([^/]+)/(.+)\z}m, [[:kind], [:name]]]]
  end

  newparam(:kind, namevar: true) do
    desc 'Kind of the config entry, e.g. `api-gateway` or `service-defaults`'
    validate do |value|
      raise ArgumentError, 'Kind must be a non-empty string' unless value.is_a?(String) && !value.empty?
    end
  end

  newparam(:name, namevar: true) do
    desc 'Name of the config entry'
    validate do |value|
      raise ArgumentError, 'Name must be a non-empty string' unless value.is_a?(String) && !value.empty?
    end
  end

  newproperty(:config) do
    desc 'Raw Consul JSON of the entry, without `Kind` and `Name`'
    validate do |value|
      raise ArgumentError, 'config must be a hash' unless value.is_a?(Hash)

      reserved = value.keys & %w[Kind Name]
      raise ArgumentError, "config must not contain #{reserved.join(' or ')}, they come from the title" unless reserved.empty?
    end

    def insync?(is)
      PuppetX::Consul::ConfigEntryMatch.subset?(should, is, @resource[:unordered_keys])
    end

    def should_to_s(value)
      value.to_json
    end

    # Only show what is managed: Consul adds fields like Status, Hash and the indexes
    def is_to_s(value)
      value = value.slice(*should.keys) if value.is_a?(Hash) && should.is_a?(Hash)
      value.to_json
    end
  end

  newparam(:unordered_keys) do
    desc 'Keys holding arrays that are compared regardless of order, e.g. `Sources` as Consul sorts intentions by precedence'
    validate do |value|
      raise ArgumentError, 'unordered_keys must be an array of strings' unless value.is_a?(Array) && value.all?(String)
    end
    defaultto []
  end

  newparam(:acl_api_token) do
    desc 'Token for accessing the Consul API'
    validate do |value|
      raise ArgumentError, 'ACL API token must be a string' unless value.is_a?(String)
    end
    defaultto ''
  end

  newparam(:protocol) do
    desc 'consul protocol'
    newvalues(:http, :https)
    defaultto :http
  end

  newparam(:ca_file, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to a PEM CA bundle used to verify the Consul HTTPS server.'
  end

  newparam(:ca_path, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to an OpenSSL hashed CA directory used to verify the Consul HTTPS server.'
  end

  newparam(:client_cert, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to a PEM client certificate, optionally followed by intermediate certificates, for mutual TLS.'
  end

  newparam(:client_key, parent: PuppetX::Consul::TLSParameters::Path) do
    desc 'Absolute path to the unencrypted PEM private key for client_cert.'
  end

  newparam(:port) do
    desc 'consul port'
    defaultto 8500
    validate do |value|
      raise ArgumentError, 'The port number must be a number' unless value.is_a?(Integer)
    end
  end

  newparam(:hostname) do
    desc 'consul hostname'
    validate do |value|
      raise ArgumentError, 'The hostname must be a string' unless value.is_a?(String)
    end
    defaultto 'localhost'
  end

  newparam(:api_tries) do
    desc 'number of tries when contacting the Consul REST API'
    defaultto 3
    validate do |value|
      raise ArgumentError, 'Number of API tries must be a number' unless value.is_a?(Integer)
    end
  end

  autorequire(:service) do
    ['consul']
  end
end
