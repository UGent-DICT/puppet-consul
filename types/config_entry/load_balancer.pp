# `LoadBalancer` block of a `service-resolver` config entry.
# `HashPolicies` need the `ring_hash` or `maglev` policy, `RingHashConfig` the `ring_hash` policy and
# `LeastRequestConfig` the `least_request` policy.
type Consul::Config_entry::Load_balancer = Struct[
  {
    'Policy'             => Optional[Enum['random', 'round_robin', 'least_request', 'ring_hash', 'maglev']],
    'RingHashConfig'     => Optional[Struct[{
      'MinimumRingSize' => Optional[Integer[1]],
      'MaximumRingSize' => Optional[Integer[1]],
    }]],
    'LeastRequestConfig' => Optional[Struct[{
      'ChoiceCount' => Optional[Integer[1]],
    }]],
    'HashPolicies'       => Optional[Array[Struct[{
      'Field'        => Optional[Enum['header', 'cookie', 'query_parameter']],
      # Name of the header, cookie or query parameter named in `Field`
      'FieldValue'   => Optional[String[1]],
      # With `Field => cookie`: the cookie is generated when the request has none. Set `TTL` or `Session`, not both.
      'CookieConfig' => Optional[Struct[{
        'Session' => Optional[Boolean],
        'TTL'     => Optional[Consul::Config_entry::Duration],
        'Path'    => Optional[String[1]],
      }]],
      'SourceIP'     => Optional[Boolean],
      'Terminal'     => Optional[Boolean],
    }], 1]],
  }
]
