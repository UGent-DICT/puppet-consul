require_relative '../../puppet_x/consul/tls_parameters'

Puppet::Type.newtype(:consul_intention) do
  desc <<-EOD
  Manages the Consul service intentions of a destination service (L4 only).
  The resource maps 1:1 to a `service-intentions` config entry: the title is the
  destination service and `sources` lists the source services with their action.
  EOD
  PuppetX::Consul::TLSParameters.apply(self)

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, namevar: true) do
    desc 'Name of the destination service'
    validate do |value|
      raise ArgumentError, 'Destination service name must be a string' unless value.is_a?(String)
    end
  end

  newproperty(:sources, array_matching: :all) do
    desc "List of source services, each a hash with a 'name' and an 'action' ('allow' or 'deny')"
    validate do |value|
      raise ArgumentError, 'Intention source must be a hash' unless value.is_a?(Hash)

      unknown = value.keys - %w[name action]
      raise ArgumentError, "Unknown intention source keys: #{unknown.join(', ')}" unless unknown.empty?
      raise ArgumentError, 'Intention source name must be a string' unless value['name'].is_a?(String)
      raise ArgumentError, "Intention source action must be 'allow' or 'deny'" unless %w[allow deny].include?(value['action'])
    end

    # Consul returns sources ordered by precedence, so ignore ordering
    def insync?(is)
      return false unless is.is_a?(Array)

      is.sort_by { |source| source['name'] } == should.sort_by { |source| source['name'] }
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
