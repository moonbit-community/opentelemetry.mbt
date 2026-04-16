///|
test "logger record maps severity and body into sdk log pipeline" {
  let exporter = @sdklogs.InMemoryLogExporter::new()
  let provider = LoggerProvider::from_sdk(
    @sdklogs.SdkLoggerProvider::builder()
    .with_simple_exporter(exporter.into_log_exporter())
    .build(),
  )
  let logger = provider.logger("root-logs")
  let record = logger.create_log_record()
  record.set_severity_number(Severity::Error3)
  record.set_body(AnyValue::String("boom"))
  record.add_attribute("retryable", AnyValue::Boolean(false))
  logger.emit(record)

  let exported = exporter.finished_logs()
  assert_eq(exported.length(), 1)
  assert_eq(exported[0].severity_text, Some("ERROR3"))
  assert_true(
    exported[0].severity_number is Some(@sdklogs.SeverityNumber::Error),
  )
}
