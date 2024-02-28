# @summary Sets up a Consul service definition
# @see http://www.consul.io/docs/agent/services.html
#
# @param ensure Define availability of check. Use 'absent' to remove existing checks
# @param id Specifies a unique ID for this service. This must be
#    unique per _agent_. This defaults to the `Name` parameter if not provided.
# @param service_name Specifies the logical name of the service.
#    Many service instances may share the same logical service name. We recommend using
#    valid DNS labels for service definition names.
# @param tags Specifies a list of tags to assign to the
#    service. Tags enable you to filter when querying for the services and are exposed in Consul APIs. We recommend using
#    valid DNS labels for tags.
# @param address Specifies the address of the service. If not
#    provided, the agent's address is used as the address for the service during
#    DNS queries.
# @param tagged_addresses Specifies a map of explicit LAN
#    and WAN addresses for the service instance. Both the address and port can be
#    specified within the map values.
# @param meta Specifies arbitrary KV metadata linked to the service instance.
# @param port Specifies the port of the service.
# @param kind The kind of service. Defaults to undef, which is a
#    typical Consul service. You can specify the following values:
#    - `"connect-proxy"` for [service mesh](/consul/docs/connect) proxies representing another service
#    - `"mesh-gateway"` for instances of a [mesh gateway](/consul/docs/connect/gateways/mesh-gateway#service-mesh-proxy-configuration)
#    - `"terminating-gateway"` for instances of a [terminating gateway](/consul/docs/connect/gateways/terminating-gateway)
#    - `"ingress-gateway"` for instances of an [ingress gateway](/consul/docs/connect/gateways/ingress-gateway)
# @param proxy From 1.2.3 on, specifies the configuration for a
#    service mesh proxy instance. This is only valid if `Kind` defines a proxy or gateway.
# @param connect  Specifies the [configuration for service mesh](/consul/docs/connect/configuration).
#    The connect subsystem provides Consul's service mesh capabilities.
#    The connect hash can contain the following parameters:
#    - `Native` `(bool: false)` - Specifies whether this service supports
#      the [Consul service mesh](/consul/docs/connect) protocol [natively](/consul/docs/connect/native).
#      If this is true, then service mesh proxies, DNS queries, etc. will be able to
#      service discover this service.
#    - `Proxy` `(Proxy: nil)` -
#      **Deprecated** Specifies that a managed service mesh proxy should be started
#      for this service instance, and optionally provides configuration for the proxy.
#      Managed proxies (which have been deprecated since Consul v1.3.0) have been
#      [removed](/consul/docs/connect/proxies) since v1.6.0.
#    - `SidecarService` `(ServiceDefinition: nil)` - Specifies an optional nested
#      service definition to register. Refer to
#      [Deploy sidecar services](/consul/docs/connect/proxies/deploy-sidecar-services) for additional information.
#
# @param checks Specifies a list of checks. Please see the
#    [check documentation](/consul/api-docs/agent/check) for more information about the
#    accepted fields. If you don't provide a name or id for the check then they
#    will be generated. To provide a custom id and/or name set the `CheckID`
#    and/or `Name` field. The automatically generated `Name` and `CheckID` depend
#    on the position of the check within the array, so even though the behavior is
#    deterministic, it is recommended for all checks to either let consul set the
#    `CheckID` by leaving the field empty/omitting it or to provide a unique value.
# @param enable_tag_override Specifies to disable the anti-entropy
#    feature for this service's tags. If `EnableTagOverride` is set to `true` then
#    external agents can update this service in the [catalog](/consul/api-docs/catalog)
#    and modify the tags. Subsequent local sync operations by this agent will
#    ignore the updated tags. For instance, if an external agent modified both the
#    tags and the port for this service and `EnableTagOverride` was set to `true`
#    then after the next sync cycle the service's port would revert to the original
#    value but the tags would maintain the updated value. As a counter example, if
#    an external agent modified both the tags and port for this service and
#    `EnableTagOverride` was set to `false` then after the next sync cycle the
#    service's port _and_ the tags would revert to the original value and all
#    modifications would be lost.
# @param weights Specifies weights for the service.
#
# @param token ACL token for interacting with the catalog (must be 'management' type)
# @param service_config_hash Hash containing any other parameters to pass on to consul.
#
# @example simple MySQL service
#  consul::service { 'my_db':
#    port                => 3306,
#    tags                => ['db','mysql'],
#    address             => '1.2.3.4',
#    token               => 'xxxxxxxxxx',
#    connect             => {
#      'sidecar_service' => {},
#    },
#    checks              => [
#      {
#        name     => 'MySQL Port',
#        tcp      => 'localhost:3306',
#        interval => '10s',
#      },
#    ],
#  }
#
# @example simple HTTPS service
#  consul::service { 'my_https_app':
#    port                => 443,
#    tags                => ['web','rails'],
#    address             => '1.2.3.5',
#    token               => 'xxxxxxxxxx',
#    connect             => {
#      'sidecar_service' => {},
#    },
#    checks              => [
#      {
#        name            => 'HTTPS Request',
#        http            => 'https://localhost:443',
#        tls_skip_verify => true,
#        method          => "GET",
#        headers         => { "Host" => ["test.example.com"] },
#      },
#    ],
#  }
#
define consul::service (
  Enum['present', 'absent'] $ensure = 'present',
  String[1] $id = $title,
  String[1] $service_name = $title,
  Array[String[1]] $tags = [],

  Optional[String[1]] $address = undef,
  Optional[Hash] $tagged_addresses = undef,
  Optional[Hash[String[1],ScalarData]] $meta = undef,
  Optional[Stdlib::Port] $port = undef,
  Optional[Enum['connect-proxy', 'mesh-gateway', 'terminating-gateway', 'ingress-gateway']] $kind = undef,

  Optional[Hash] $proxy = undef,
  Optional[Hash] $connect = undef,

  Array[Hash] $checks = [],
  Boolean $enable_tag_override = false,
  Optional[Hash] $weights = undef,

  Optional[String[1]] $token = undef,
  Hash $service_config_hash = {},
) {
  include consul

  $checks.each |$check| {
    consul::validate_check($check)
  }

  $_config_hash = {
    'id'                  => $id,
    'name'                => $service_name,
    'tags'                => $tags,
    'address'             => $address,
    'tagged_addresses'    => $tagged_addresses,
    'meta'                => $meta,
    'port'                => $port,
    'kind'                => $kind,
    'proxy'               => $proxy,
    'connect'             => $connect,
    'checks'              => $checks,
    'enable_tag_override' => $enable_tag_override,
    'weights'             => $weights,
    'token'               => $token,
  } + $service_config_hash

  consul::config_file { "service_${id}":
    ensure  => $ensure,
    content => { 'service' => $_config_hash.delete_undef_values },
    reload  => true,
  }
}
