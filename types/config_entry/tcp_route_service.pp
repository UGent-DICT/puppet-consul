# Service a `tcp-route` forwards to. Consul accepts at most one.
type Consul::Config_entry::Tcp_route_service = Struct[
  {
    'Name' => String[1],
  }
]
