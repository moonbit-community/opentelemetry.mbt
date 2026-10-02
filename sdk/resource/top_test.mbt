///|
fn restore_env_var(key : String, value : String?) -> Unit {
  match value {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
}

///|
// Test target: Verify the environment resource detector reads valid OpenTelemetry resource variables and discards an invalid attribute list.
// Test method: Detect valid settings first, then add a malformed attribute and assert the entire generic attribute list is ignored.
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

  let resource = @resource.env_resource_detector().detect()
  guard resource.get("service.name") is Some(String(service_name)) else {
    fail("expected service.name from environment")
  }
  @debug.assert_eq(service_name, "native-service")
  guard resource.get("deployment.environment") is Some(String(environment)) else {
    fail("expected deployment.environment from environment")
  }
  @debug.assert_eq(environment, "staging")

  @env.set_env_var(
    "OTEL_RESOURCE_ATTRIBUTES", "valid.attribute=kept,malformed-attribute",
  )
  let malformed_resource = @resource.env_resource_detector().detect()
  @debug.assert_eq(malformed_resource.get("valid.attribute"), None)
  guard malformed_resource.get("service.name") is Some(String(service_name)) else {
    fail("expected OTEL_SERVICE_NAME to remain effective")
  }
  @debug.assert_eq(service_name, "native-service")
}
