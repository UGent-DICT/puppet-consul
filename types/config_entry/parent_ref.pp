# Reference from a route to the API gateway (listener) it attaches to.
# Consul only supports `api-gateway` parents.
type Consul::Config_entry::Parent_ref = Struct[
  {
    'Kind'        => Enum['api-gateway'],
    'Name'        => String[1],
    # Bind to a single listener; all listeners of the gateway when omitted
    'SectionName' => Optional[String[1]],
  }
]
