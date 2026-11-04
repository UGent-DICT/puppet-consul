# @summary Manages a `file-system-certificate` Consul config entry
#
# Points an API gateway listener at a certificate and key on the gateway host, so that the private key
# never enters the Consul state. Reference the entry from a listener in
# `TLS => { Certificates => [{ Kind => file-system-certificate, Name => <name> }] }`.
# Both files must be readable by the API gateway proxy at runtime.
#
# @example
#   consul::config_entry::file_system_certificate { 'web':
#     certificate => '/etc/consul/connect/web.crt',
#     private_key => '/etc/consul/connect/web.key',
#   }
#
# @param certificate
#   Path to the public certificate (chain) on the gateway host.
# @param private_key
#   Path to the private key on the gateway host.
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
define consul::config_entry::file_system_certificate (
  Stdlib::Absolutepath $certificate,
  Stdlib::Absolutepath $private_key,
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
    'Certificate' => $certificate,
    'PrivateKey'  => $private_key,
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

  consul_config_entry { "file-system-certificate/${name}":
    ensure => $ensure,
    config => $_config,
    *      => $_connection,
  }
}
