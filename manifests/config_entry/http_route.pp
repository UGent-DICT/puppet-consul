# @summary Manages an `http-route` Consul config entry
#
# Routes the traffic of an `http`, `http2` or `grpc` listener of an API gateway to services.
# Rules are validated with `Consul::Config_entry::Http_route_rule`.
#
# @example
#   consul::config_entry::http_route { 'web':
#     parents   => [{ 'Kind' => 'api-gateway', 'Name' => 'agw', 'SectionName' => 'https' }],
#     hostnames => ['web.example.org'],
#     rules     => [{ 'Services' => [{ 'Name' => 'web' }] }],
#   }
#
# @param parents
#   API gateways (and optionally listeners) the route attaches to.
# @param rules
#   Rules with matches, filters and the services to route to.
# @param hostnames
#   Hostnames the route applies to.
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
define consul::config_entry::http_route (
  Array[Consul::Config_entry::Parent_ref, 1] $parents,
  Array[Consul::Config_entry::Http_route_rule, 1] $rules,
  Optional[Array[String[1]]] $hostnames = undef,
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
    'Parents'   => $parents,
    'Hostnames' => $hostnames,
    'Rules'     => $rules,
    'Meta'      => $meta,
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

  consul_config_entry { "http-route/${name}":
    ensure => $ensure,
    config => $_config,
    *      => $_connection,
  }
}
