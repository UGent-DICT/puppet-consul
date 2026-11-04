# Source of a `service-intentions` config entry: either an L4 `Action` or a list of L7 `Permissions`, never both.
# L7 permissions need the destination to use an http-based protocol and do not work with wildcard names.
type Consul::Config_entry::Intention_source = Variant[
  Struct[{
    'Name'        => String[1],
    'Action'      => Enum['allow', 'deny'],
    'Description' => Optional[String],
  }],
  Struct[{
    'Name'        => String[1],
    'Permissions' => Array[Struct[{
      'Action' => Enum['allow', 'deny'],
      'HTTP'   => Struct[{
        # Set at most one of the path matchers
        'PathExact'  => Optional[String[1]],
        'PathPrefix' => Optional[String[1]],
        'PathRegex'  => Optional[String[1]],
        'Methods'    => Optional[Array[String[1]]],
        'Header'     => Optional[Array[Struct[{
          'Name'       => String[1],
          'Present'    => Optional[Boolean],
          'Exact'      => Optional[String],
          'Prefix'     => Optional[String],
          'Suffix'     => Optional[String],
          'Contains'   => Optional[String],
          'Regex'      => Optional[String],
          'IgnoreCase' => Optional[Boolean],
          'Invert'     => Optional[Boolean],
        }]]],
      }],
    }], 1],
    'Description' => Optional[String],
  }],
]
