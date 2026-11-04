# Service linked to a `terminating-gateway` config entry.
# Set either none or both of CertFile and KeyFile; without CAFile, traffic to the destination is not encrypted.
type Consul::Config_entry::Terminating_gateway_service = Struct[
  {
    # `*` links all services
    'Name'     => String[1],
    'CAFile'   => Optional[Stdlib::Absolutepath],
    'CertFile' => Optional[Stdlib::Absolutepath],
    'KeyFile'  => Optional[Stdlib::Absolutepath],
    'SNI'      => Optional[String[1]],
  }
]
