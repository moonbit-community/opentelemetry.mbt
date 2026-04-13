///|
// Test target: Verify package-specific semantic aliases stay consistent with the shared attribute definitions.
// Test method: Compare resource and trace constants against the attribute package constants they should mirror.
test "resource and trace packages mirror attribute constants" {
  @debug.assert_eq(@resource.SERVICE_NAME, @attribute.SERVICE_NAME)
  @debug.assert_eq(@trace.CLIENT_ADDRESS, @attribute.CLIENT_ADDRESS)
}
