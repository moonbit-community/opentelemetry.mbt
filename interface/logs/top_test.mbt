///|
// Test target: Verify interface-level log records preserve severity, event metadata, and structured payloads when forwarded to the SDK.
// Test method: Emit a structured record through the wrapper logger and assert the in-memory exporter retains the expected fields and map values.
async test "logger record preserves full severity and structured fields" {
  let exporter = @sdklogs.InMemoryLogExporter::new()
  let provider = @sdklogs.SdkLoggerProvider::builder()
    .with_simple_exporter(exporter.into_log_exporter())
    .build()
    .into_logger_provider()
  let logger = provider.logger("root-logs")
  let record = logger.create_log_record()
  let body_map : Map[String, AnyValue] = {}
  body_map["message"] = AnyValue::String("boom")
  body_map["retryable"] = AnyValue::Boolean(false)
  record.set_severity_number(Severity::Error3)
  record.set_event_name("checkout.failed")
  record.set_target("cart")
  record.set_body(AnyValue::Map(body_map))
  record.add_attribute("payload", AnyValue::Map(body_map))
  logger.emit(record)

  let exported = exporter.finished_logs()
  assert_eq(exported.length(), 1)
  assert_eq(exported[0].event_name, Some("checkout.failed"))
  assert_eq(exported[0].target, Some("cart"))
  assert_eq(exported[0].severity_text, Some("ERROR3"))
  assert_true(
    exported[0].severity_number is Some(@sdklogs.SeverityNumber::Error3),
  )
  guard exported[0].body is @sdklogs.AnyValue::Map(body) else {
    fail("expected structured map body")
  }
  assert_eq(body.length(), 2)
  guard exported[0].attributes[0].value is @sdklogs.AnyValue::Map(payload) else {
    fail("expected structured map attribute")
  }
  assert_eq(payload.length(), 2)
}
