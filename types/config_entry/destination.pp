# `Destination` block of a `service-defaults` config entry: an external service reached through a terminating gateway.
# Requires the service to be in transparent proxy mode. Wildcards are not supported.
type Consul::Config_entry::Destination = Struct[
  {
    'Addresses' => Array[Pattern[/\A[^*]+\z/], 1],
    'Port'      => Integer[1, 65535],
  }
]
