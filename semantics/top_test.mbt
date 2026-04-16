///|
test "semantics schema url matches upstream" {
  assert_eq(SCHEMA_URL, "https://opentelemetry.io/schemas/1.36.0")
}

///|
test "semantics expose representative upstream constants" {
  assert_eq(@attribute.HTTP_REQUEST_METHOD, "http.request.method")
  assert_eq(@attribute.APP_INSTALLATION_ID, "app.installation.id")
  assert_eq(
    @metric.HTTP_SERVER_REQUEST_DURATION,
    "http.server.request.duration",
  )
}

///|
test "resource and trace packages mirror attribute constants" {
  assert_eq(@resource.SERVICE_NAME, @attribute.SERVICE_NAME)
  assert_eq(@trace.CLIENT_ADDRESS, @attribute.CLIENT_ADDRESS)
}
