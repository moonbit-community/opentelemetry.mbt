///|
fn restore_env_var(key : String, value : String?) -> Unit {
  match value {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
}

///|
// Test target: Verify the environment resource detector reads standard OpenTelemetry resource variables.
// Test method: Set OTEL environment variables, detect a resource, and assert the expected attributes are present with the configured values.
test "env resource detector reads process environment" {
  let original_service_name = @env.get_env_var("OTEL_SERVICE_NAME")
  let original_resource_attributes = @env.get_env_var(
    "OTEL_RESOURCE_ATTRIBUTES",
  )
  defer restore_env_var("OTEL_SERVICE_NAME", original_service_name)
  defer restore_env_var(
    "OTEL_RESOURCE_ATTRIBUTES", original_resource_attributes,
  )

  @env.set_env_var("OTEL_SERVICE_NAME", "native-service")
  @env.set_env_var("OTEL_RESOURCE_ATTRIBUTES", "deployment.environment=staging")

  let resource = env_resource_detector().detect()
  guard resource.get("service.name")
    is Some(@common.Value::String(service_name)) else {
    fail("expected service.name from environment")
  }
  assert_eq(service_name, "native-service")
  guard resource.get("deployment.environment")
    is Some(@common.Value::String(environment)) else {
    fail("expected deployment.environment from environment")
  }
  assert_eq(environment, "staging")
}
