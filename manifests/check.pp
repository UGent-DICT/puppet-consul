# @summary Sets up a Consul healthcheck
# @see http://www.consul.io/docs/agent/checks.html
#
# @param ensure Define availability of check. Use 'absent' to remove existing checks
# @param id Specifies a unique ID for this check on the node.
#    This defaults to the `\"Name\"` parameter, but it may be necessary to provide an
#    ID for uniqueness. This value will return in the response as `\"CheckId\"`.
# @param notes Specifies arbitrary information for humans. This is
#    not used by Consul internally.
# @param service_id Specifies the ID of a service to associate the
#    registered check with an existing service provided by the agent.
# @param token ACL token for interacting with the catalog (must be 'management' type)
# @param status Specifies the initial status of the health check.
# @param args Specifies command arguments to run to update the
#    status of the check. Prior to Consul 1.0, checks used a single `Script` field
#    to define the command to run, and would always run in a shell. In Consul
#    1.0, the `Args` array was added so that checks can be run without a shell. The
#    `Script` field is deprecated, and you should include the shell in the `Args` to
#    run under a shell, eg. `\"args\": [\"sh\", \"-c\", \"...\"]`.
#    -> **Note:** Consul 1.0 shipped with an issue where `Args` was erroneously named
#    `ScriptArgs` in this API. Please use `ScriptArgs` with Consul 1.0 (that will
#    continue to be accepted in future versions of Consul), and `Args` in Consul
#    1.0.1 and later.
# @param http Specifies an `HTTP` check to perform a `GET` request
#    against the value of `HTTP` (expected to be a URL) every `Interval`. If the
#    response is any `2xx` code, the check is `passing`. If the response is `429 Too Many Requests`,
#    the check is `warning`. Otherwise, the check is `critical`. HTTP checks also support SSL.
#    By default, a valid SSL certificate is expected.
#    Certificate verification can be controlled using the `TLSSkipVerify`.
# @param header Specifies a set of headers that should
#    be set for `HTTP` checks. Each header can have multiple values.
# @param method Specifies a different HTTP method to be used
#    for an `HTTP` check. When no value is specified, `GET` is used.
# @param body Specifies a body that should be sent with `HTTP` checks.
# @param disable_redirects Specifies whether to disable following HTTP
#    redirects when performing an HTTP check.
# @param output_max_size Allow to put a maximum size of text
#    for the given check. This value must be greater than 0, by default, the value
#    is 4k.
#    The value can be further limited for all checks of a given agent using the
#    `check_output_max_size` flag in the agent.
# @param tcp Specifies a `TCP` to connect against the value of `TCP`
#    (expected to be an IP or hostname plus port combination) every `Interval`. If
#    the connection attempt is successful, the check is `passing`. If the
#    connection attempt is unsuccessful, the check is `critical`. In the case of a
#    hostname that resolves to both IPv4 and IPv6 addresses, an attempt will be
#    made to both addresses, and the first successful connection attempt will
#    result in a successful check.
# @param tcp_use_tls Specifies whether to use TLS for this `TCP` health check.
#    If TLS is enabled, then by default, a valid TLS certificate is expected. Certificate
#    verification can be turned off by setting `TLSSkipVerify` to `true`.
# @param udp Specifies a `UDP` IP address/hostname and port.
#   The check sends datagrams to the value specified at the interval specified in the `Interval` configuration.
#   If the datagram is sent successfully or a timeout is returned, the check is set to the `passing` state.
#   The check is logged as `critical` if the datagram is sent unsuccessfully.
# @param interval Specifies the frequency at which to run this
#    check. This is required for HTTP, TCP, and UDP checks.
# @param docker_container_id Specifies that the check is a Docker
#    check, and Consul will evaluate the script every `Interval` in the given
#    container using the specified `Shell`. Note that `Shell` is currently only
#    supported for Docker checks.
# @param grpc Specifies a `gRPC` check's endpoint that supports the standard
#    [gRPC health checking protocol](https://github.com/grpc/grpc/blob/master/doc/health-checking.md).
#    The state of the check will be updated at the given `Interval` by probing the configured
#    endpoint. Add the service identifier after the `gRPC` check's endpoint in the following format
#    to check for a specific service instead of the whole gRPC server `/:service_identifier`.
# @param grpc_use_tls Specifies whether to use TLS for this `gRPC` health check.
#    If TLS is enabled, then by default, a valid TLS certificate is expected. Certificate
#    verification can be turned off by setting `TLSSkipVerify` to `true`.
# @param tls_server_name Specifies an optional string used to set the
#    SNI host when connecting via TLS.
#    For an `HTTP` check, this value is set automatically if the URL uses a hostname
#    (not an IP address).
# @param tls_skip_verify Specifies if the certificate for an HTTPS
#    check should not be verified.
# @param alias_node Specifies the ID of the node for an alias check.
#    If no service is specified, the check will alias the health of the node.
#    If a service is specified, the check will alias the specified service on
#    this particular node.
# @param alias_service Specifies the ID of a service for an
#    alias check. If the service is not registered with the same agent,
#    `AliasNode` must also be specified. Note this is the service _ID_ and
#    not the service _name_ (though they are very often the same).
# @param timeout Specifies a timeout for outgoing connections in the
#    case of a Script, HTTP, TCP, UDP, or gRPC check. Can be specified in the form of \"10s\"
#    or \"5m\" (i.e., 10 seconds or 5 minutes, respectively).
# @param ttl Specifies this is a TTL check, and the TTL endpoint
#    must be used periodically to update the state of the check. If the check is not
#    set to passing within the specified duration, then the check will be set to the failed state.
# @param h2ping Specifies an address that uses http2 to run a ping check on.
#    At the specified `Interval`, a connection is made to the address, and a ping is sent.
#    If the ping is successful, the check will be classified as `passing`, otherwise it will be marked as `critical`.
#    TLS is used by default. To disable TLS and use h2c, set `H2PingUseTLS` to `false`.
#    If TLS is enabled, a valid SSL certificate is required by default, but verification can be removed with `TLSSkipVerify`.
# @param h2ping_use_tls Specifies if TLS should be used for H2PING check.
#    If TLS is enabled, a valid SSL certificate is required by default, but verification can be removed with `TLSSkipVerify`.
# @param os_service Specifies the identifier of an OS-level service to check.
#    You can specify either `Windows Services` on Windows or `SystemD` services on Unix.
# @param success_before_passing Specifies the number of consecutive successful
#    results required before check status transitions to passing. Available for HTTP,
#    TCP, gRPC, Docker & Monitor checks. Added in Consul 1.7.0.
# @param failures_before_warning Specifies the number of consecutive unsuccessful
#    results required before check status transitions to warning. Defaults to the same value
#    as `FailuresBeforeCritical`. Values higher than `FailuresBeforeCritical` are invalid.
#    Available for HTTP, TCP, gRPC, Docker & Monitor checks. Added in Consul 1.11.0.
# @param failures_before_critical Specifies the number of consecutive unsuccessful
#    results required before check status transitions to critical. Available for HTTP,
#    TCP, gRPC, Docker & Monitor checks. Added in Consul 1.7.0.
# @param deregister_critical_service_after Specifies that checks
#    associated with a service should deregister after this time. This is specified
#    as a time duration with suffix like \"10m\". If a check is in the critical state
#    for more than this configured value, then its associated service (and all of
#    its associated checks) will automatically be deregistered. The minimum timeout
#    is 1 minute, and the process that reaps critical services runs every 30
#    seconds, so it may take slightly longer than the configured timeout to trigger
#    the deregistration. This should generally be configured with a timeout that's
#    much, much longer than any expected recoverable outage for the given service.
define consul::check (
  Enum['present', 'absent'] $ensure = 'present',
  String $id = $title,
  Optional[String] $notes = undef,
  Optional[String] $service_id = undef,
  Optional[String] $token = undef,
  Optional[String] $status = undef,
  Optional[Array[String]] $args = undef,
  Optional[String] $http = undef,
  Optional[Hash[String,Array[String]]] $header = undef,
  Optional[String] $method = undef,
  Optional[String] $body = undef,
  Optional[Boolean] $disable_redirects = undef,
  Optional[Integer] $output_max_size = undef,
  Optional[String] $tcp = undef,
  Optional[Boolean] $tcp_use_tls = undef,
  Optional[String] $udp = undef,
  Optional[String] $interval = undef,
  Optional[String] $docker_container_id = undef,
  Optional[String] $grpc = undef,
  Optional[Boolean] $grpc_use_tls = undef,
  Optional[String] $tls_server_name = undef,
  Optional[Boolean] $tls_skip_verify = undef,
  Optional[String] $alias_node = undef,
  Optional[String] $alias_service = undef,
  Optional[String] $timeout = undef,
  Optional[String] $ttl = undef,
  Optional[String] $h2ping = undef,
  Optional[Boolean] $h2ping_use_tls = undef,
  Optional[String] $os_service = undef,
  Optional[Integer] $success_before_passing = undef,
  Optional[Integer] $failures_before_warning = undef,
  Optional[Integer] $failures_before_critical = undef,
  Optional[String] $deregister_critical_service_after = undef,
) {
  include consul
  $_config_hash = delete_undef_values({
      'id'                                => $id,
      'name'                              => $name,
      'notes'                             => $notes,
      'service_id'                        => $service_id,
      'token'                             => $token,
      'status'                            => $status,
      'args'                              => $args,
      'http'                              => $http,
      'header'                            => $header,
      'method'                            => $method,
      'body'                              => $body,
      'disable_redirects'                 => $disable_redirects,
      'output_max_size'                   => $output_max_size,
      'tcp'                               => $tcp,
      'tcp_use_tls'                       => $tcp_use_tls,
      'udp'                               => $udp,
      'interval'                          => $interval,
      'docker_container_id'               => $docker_container_id,
      'grpc'                              => $grpc,
      'grpc_use_tls'                      => $grpc_use_tls,
      'tls_server_name'                   => $tls_server_name,
      'tls_skip_verify'                   => $tls_skip_verify,
      'alias_node'                        => $alias_node,
      'alias_service'                     => $alias_service,
      'timeout'                           => $timeout,
      'ttl'                               => $ttl,
      'h2ping'                            => $h2ping,
      'h2ping_use_tls'                    => $h2ping_use_tls,
      'os_service'                        => $os_service,
      'success_before_passing'            => $success_before_passing,
      'failures_before_warning'           => $failures_before_warning,
      'failures_before_critical'          => $failures_before_critical,
      'deregister_critical_service_after' => $deregister_critical_service_after,
  })

  consul::validate_check($_config_hash)
  consul::config_file { "check_${id}":
    ensure  => $ensure,
    content => { 'check' => $_config_hash },
    reload  => true,
  }
}
