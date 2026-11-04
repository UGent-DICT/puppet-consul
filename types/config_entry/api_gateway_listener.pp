# Listener of an `api-gateway` config entry.
# `tcp` listeners are used by `tcp-route`, the other protocols by `http-route`.
type Consul::Config_entry::Api_gateway_listener = Struct[
  {
    'Name'                => Pattern[/\A[a-zA-Z0-9-]+\z/],
    'Port'                => Integer[1, 65535],
    'Protocol'            => Enum['tcp', 'http', 'http2', 'grpc'],
    'Hostname'            => Optional[String[1]],
    'MaxRequestHeadersKB' => Optional[Integer[1]],
    'TLS'                 => Optional[Struct[{
      'MinVersion'   => Optional[Enum['TLS_AUTO', 'TLSv1_0', 'TLSv1_1', 'TLSv1_2', 'TLSv1_3']],
      'MaxVersion'   => Optional[Enum['TLS_AUTO', 'TLSv1_0', 'TLSv1_1', 'TLSv1_2', 'TLSv1_3']],
      'CipherSuites' => Optional[Array[String[1]]],
      # References to `file-system-certificate` (or `inline-certificate`) entries
      'Certificates' => Optional[Array[Struct[{
        'Kind' => Enum['file-system-certificate', 'inline-certificate'],
        'Name' => String[1],
      }]]],
      # Mutually exclusive with Certificates
      'SDS'          => Optional[Struct[{
        'ClusterName'  => Optional[String[1]],
        'CertResource' => String[1],
      }]],
    }]],
  }
]
