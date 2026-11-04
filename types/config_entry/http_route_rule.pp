# Rule of an `http-route` config entry: what to match, how to filter and where to send it.
type Consul::Config_entry::Http_route_rule = Struct[
  {
    'Matches'         => Optional[Array[Struct[{
      'Headers' => Optional[Array[Struct[{
        'Name'   => String[1],
        'Match'  => Enum['exact', 'prefix', 'suffix', 'regex', 'present'],
        'Value'  => Optional[String],
        'Invert' => Optional[Boolean],
      }]]],
      'Method'  => Optional[String[1]],
      'Path'    => Optional[Struct[{
        'Match' => Enum['exact', 'prefix', 'regex'],
        'Value' => String[1],
      }]],
      'Query'   => Optional[Array[Struct[{
        'Name'  => String[1],
        'Match' => Enum['exact', 'present', 'regex'],
        'Value' => Optional[String],
      }]]],
    }]]],
    'Filters'         => Optional[Struct[{
      'Headers'       => Optional[Array[Struct[{
        'Add'    => Optional[Hash[String[1], String]],
        'Set'    => Optional[Hash[String[1], String]],
        'Remove' => Optional[Array[String[1]]],
      }]]],
      'URLRewrite'    => Optional[Struct[{ 'Path' => String }]],
      'RetryFilter'   => Optional[Struct[{
        'NumRetries'               => Optional[Integer[0]],
        'RetryOnConnectionFailure' => Optional[Boolean],
        'RetryOn'                  => Optional[Array[String[1]]],
        'RetryOnStatusCodes'       => Optional[Array[Integer[100, 599]]],
      }]],
      'TimeoutFilter' => Optional[Struct[{
        'IdleTimeout'    => Optional[Pattern[/\A\d+(\.\d+)?(ns|us|µs|ms|s|m|h)\z/]],
        'RequestTimeout' => Optional[Pattern[/\A\d+(\.\d+)?(ns|us|µs|ms|s|m|h)\z/]],
      }]],
    }]],
    'ResponseFilters' => Optional[Struct[{
      'Headers' => Optional[Array[Struct[{
        'Add'    => Optional[Hash[String[1], String]],
        'Set'    => Optional[Hash[String[1], String]],
        'Remove' => Optional[Array[String[1]]],
      }]]],
    }]],
    'Services'        => Array[Struct[{
      'Name'   => String[1],
      'Weight' => Optional[Integer[0]],
    }], 1],
  }
]
