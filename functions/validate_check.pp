# @summary check the validity of a consul health check
#
# @param check the check hash to validate
# @return Hash The validated hash is returned, if the check is invalid a fail() is raised
#
function consul::validate_check(
  Hash $check,
) {
  $check_types = [
    'args',
    'alias_service',
    'alias_node',
    'docker_container_id',
    'grpc',
    'h2ping',
    'http',
    'tcp',
    'udp',
    'os_service',
    'ttl',
  ]
  $no_interval_types = [
    'alias_service',
    'alias_node',
    'ttl',
  ]
  $types = $check.keys.filter | $key | { $key in $check_types }

  assert_type(Variant[Array[String,1,1], Array[Enum['alias_node', 'alias_service'],1,2]], $types) |$expeted, $actual| {
    fail("Check expects exactly 1 off: '${check_types.join("', '")}', or 'alias_node' and 'alias_service', got: ${actual}")
  }
  $type = $types[0]

  if $type in $no_interval_types {
    if $check['interval'] {
      fail("Checks of ${type} do not use interval")
    }
  } else {
    unless $check['interval'] {
      fail("Checks of ${type} require an interval")
    }
  }
  return $check
}
