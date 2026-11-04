# @summary Manages a `service-defaults` Consul config entry
#
# Sets the defaults of a service. The `destination` block registers an external service that is
# reached through a terminating gateway; it needs the proxy of the calling service to run in
# transparent mode (`mode => transparent`).
#
# @example
#   consul::config_entry::service_defaults { 'db.example.org':
#     protocol    => 'tcp',
#     mode        => 'transparent',
#     destination => { 'Addresses' => ['db.example.org'], 'Port' => 5432 },
#   }
#
# @param service_protocol
#   Protocol of the service. Not to be confused with `protocol`, which is the protocol of the Consul API.
# @param mode
#   Proxy mode of the service.
# @param destination
#   External destination reached through a terminating gateway.
# @param ensure
#   Whether the config entry should exist.
# @param meta
#   Metadata stored with the config entry.
# @param acl_api_token
#   Token for accessing the Consul API.
# @param protocol
#   Protocol of the Consul API, `http` or `https`.
# @param hostname
#   Hostname of the Consul API.
# @param port
#   Port of the Consul API.
# @param ca_file
#   PEM CA bundle used to verify the Consul HTTPS server.
# @param ca_path
#   OpenSSL hashed CA directory used to verify the Consul HTTPS server.
# @param client_cert
#   PEM client certificate for mutual TLS.
# @param client_key
#   Unencrypted PEM private key for `client_cert`.
# @param api_tries
#   Number of tries when contacting the Consul API.
define consul::config_entry::service_defaults (
  Optional[Enum['tcp', 'http', 'http2', 'grpc']] $service_protocol = undef,
  Optional[Enum['direct', 'transparent']] $mode = undef,
  Optional[Consul::Config_entry::Destination] $destination = undef,
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Hash[String[1], String]] $meta = undef,
  Optional[String] $acl_api_token = undef,
  Optional[Enum['http', 'https']] $protocol = undef,
  Optional[String[1]] $hostname = undef,
  Optional[Stdlib::Port] $port = undef,
  Optional[Stdlib::Absolutepath] $ca_file = undef,
  Optional[Stdlib::Absolutepath] $ca_path = undef,
  Optional[Stdlib::Absolutepath] $client_cert = undef,
  Optional[Stdlib::Absolutepath] $client_key = undef,
  Optional[Integer[1]] $api_tries = undef,
) {
  $_config = {
    'Protocol'    => $service_protocol,
    'Mode'        => $mode,
    'Destination' => $destination,
    'Meta'        => $meta,
  }.filter |$_key, $value| { $value =~ NotUndef }

  $_connection = {
    'acl_api_token' => $acl_api_token,
    'protocol'      => $protocol,
    'hostname'      => $hostname,
    'port'          => $port,
    'ca_file'       => $ca_file,
    'ca_path'       => $ca_path,
    'client_cert'   => $client_cert,
    'client_key'    => $client_key,
    'api_tries'     => $api_tries,
  }.filter |$_key, $value| { $value =~ NotUndef }

  consul_config_entry { "service-defaults/${name}":
    ensure => $ensure,
    config => $_config,
    *      => $_connection,
  }
}
