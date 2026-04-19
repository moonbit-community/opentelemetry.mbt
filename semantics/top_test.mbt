///|
// Test target: Verify the packaged schema URL stays aligned with the upstream semantic conventions release.
// Test method: Compare the exported schema URL constant against the expected upstream URL string.
test "semantics schema url matches upstream" {
  assert_eq(SCHEMA_URL, "https://opentelemetry.io/schemas/1.36.0")
}

///|
// Test target: Verify representative semantic convention constants are re-exported with the expected upstream names.
// Test method: Assert a small cross-section of attribute and metric constants against their canonical string values.
test "semantics expose representative upstream constants" {
  assert_eq(@attribute.HTTP_REQUEST_METHOD, "http.request.method")
  assert_eq(@attribute.APP_INSTALLATION_ID, "app.installation.id")
  assert_eq(
    @metric.HTTP_SERVER_REQUEST_DURATION,
    "http.server.request.duration",
  )
}

///|
// Test target: Verify package-specific semantic aliases stay consistent with the shared attribute definitions.
// Test method: Compare resource and trace constants against the attribute package constants they should mirror.
test "resource and trace packages mirror attribute constants" {
  assert_eq(@resource.SERVICE_NAME, @attribute.SERVICE_NAME)
  assert_eq(@trace.CLIENT_ADDRESS, @attribute.CLIENT_ADDRESS)
}
