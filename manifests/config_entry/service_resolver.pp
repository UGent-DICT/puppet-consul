# @summary Manages a `service-resolver` Consul config entry
#
# Decides which instances of a service a request goes to, and how the load is balanced over them.
# The title is the name of the service.
#
# A cookie hash policy gives sticky sessions for the clients of a service in the mesh, which a reverse proxy
# that sees one backend (such as Apache through a sidecar) cannot do itself. Hash policies need the `ring_hash`
# or `maglev` policy. The service has to use an L7 protocol in `service-defaults`
# (`consul::config_entry::service_defaults` with `service_protocol => 'http'`).
#
# @example Sticky sessions with a generated cookie
#   consul::config_entry::service_resolver { 'web':
#     load_balancer => {
#       'Policy'       => 'maglev',
#       'HashPolicies' => [{
#         'Field'        => 'cookie',
#         'FieldValue'   => 'ROUTEID',
#         'CookieConfig' => { 'TTL' => '1h', 'Path' => '/' },
#       }],
#     },
#   }
#
# @param default_subset
#   Subset to use when none is requested. Must be a key of `subsets`.
# @param subsets
#   Named subsets of the service, each with a `Filter` expression and `OnlyPassing`.
# @param redirect
#   Send all requests to another service or subset.
# @param failover
#   Where to send requests when no instance is healthy, per subset (`*` for all).
# @param connect_timeout
#   Timeout for new connections to an instance.
# @param request_timeout
#   Timeout of a request, from the moment it is sent. Only for L7 protocols.
# @param load_balancer
#   Load balancing policy and hash policies.
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
define consul::config_entry::service_resolver (
  Optional[String[1]] $default_subset = undef,
  Optional[Hash[String[1], Struct[{
    'Filter'      => Optional[String[1]],
    'OnlyPassing' => Optional[Boolean],
  }]]] $subsets = undef,
  Optional[Struct[{
    'Service'       => Optional[String[1]],
    'ServiceSubset' => Optional[String[1]],
    'Datacenter'    => Optional[String[1]],
  }]] $redirect = undef,
  Optional[Hash[String[1], Struct[{
    'Service'       => Optional[String[1]],
    'ServiceSubset' => Optional[String[1]],
    'Datacenters'   => Optional[Array[String[1]]],
  }]]] $failover = undef,
  Optional[Consul::Config_entry::Duration] $connect_timeout = undef,
  Optional[Consul::Config_entry::Duration] $request_timeout = undef,
  Optional[Consul::Config_entry::Load_balancer] $load_balancer = undef,
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
  $_policy = $load_balancer ? {
    undef   => undef,
    default => $load_balancer['Policy'],
  }

  if $load_balancer =~ NotUndef {
    if $load_balancer['HashPolicies'] =~ NotUndef and !($_policy in ['ring_hash', 'maglev']) {
      fail("consul::config_entry::service_resolver[${name}]: HashPolicies need the ring_hash or maglev policy")
    }
    if $load_balancer['RingHashConfig'] =~ NotUndef and $_policy != 'ring_hash' {
      fail("consul::config_entry::service_resolver[${name}]: RingHashConfig needs the ring_hash policy")
    }
    if $load_balancer['LeastRequestConfig'] =~ NotUndef and $_policy != 'least_request' {
      fail("consul::config_entry::service_resolver[${name}]: LeastRequestConfig needs the least_request policy")
    }

    pick($load_balancer['HashPolicies'], []).each |$_hash_policy| {
      if $_hash_policy['Field'] =~ NotUndef and $_hash_policy['FieldValue'] =~ Undef {
        fail("consul::config_entry::service_resolver[${name}]: Field ${_hash_policy['Field']} needs a FieldValue")
      }
      $_cookie = $_hash_policy['CookieConfig']
      if $_cookie =~ NotUndef {
        if $_hash_policy['Field'] != 'cookie' {
          fail("consul::config_entry::service_resolver[${name}]: CookieConfig is only valid with Field => cookie")
        }
        if $_cookie['TTL'] =~ NotUndef and $_cookie['Session'] == true {
          fail("consul::config_entry::service_resolver[${name}]: set either TTL or Session in CookieConfig, not both")
        }
      }
    }
  }

  if $default_subset =~ NotUndef and ($subsets =~ Undef or !($default_subset in $subsets.keys)) {
    fail("consul::config_entry::service_resolver[${name}]: default_subset ${default_subset} is not one of the subsets")
  }

  $_config = {
    'DefaultSubset'  => $default_subset,
    'Subsets'        => $subsets,
    'Redirect'       => $redirect,
    'Failover'       => $failover,
    'ConnectTimeout' => $connect_timeout,
    'RequestTimeout' => $request_timeout,
    'LoadBalancer'   => $load_balancer,
    'Meta'           => $meta,
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

  consul_config_entry { "service-resolver/${name}":
    ensure => $ensure,
    config => $_config,
    *      => $_connection,
  }
}
