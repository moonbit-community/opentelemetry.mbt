///|
test "logger exports trace-aware log records" {
  let span_exporter = @trace.InMemorySpanExporter::new()
  let trace_provider = @trace.SdkTracerProvider::builder()
    .with_simple_exporter(span_exporter.into_span_exporter())
    .build()
  let tracer = trace_provider.tracer("logs-trace")
  let span = tracer.start("request")

  let exporter = InMemoryLogExporter::new()
  let provider = SdkLoggerProvider::builder()
    .with_simple_exporter(exporter.into_log_exporter())
    .build()
  let logger = provider.logger("logs-test")
  logger.emit(
    @common.Value::String("request failed"),
    context=span.context(),
    severity_number=Some(SeverityNumber::Error),
    severity_text=Some("ERROR"),
    attributes=[
      @common.KeyValue::new("http.status_code", @common.Value::Int64(500)),
    ],
  )

  let records = exporter.finished_logs()
  assert_eq(records.length(), 1)
  guard records[0].trace_context is Some(trace_context) else {
    fail("expected trace context on log record")
  }
  assert_eq(
    trace_context.trace_id().to_hex(),
    span.span_context().trace_id().to_hex(),
  )
  assert_eq(records[0].attributes.length(), 1)
}

///|
async test "batch log processor flushes on scheduled delay in background" {
  let exporter = InMemoryLogExporter::new()
  let provider = SdkLoggerProvider::builder()
    .with_batch_exporter(
      exporter.into_log_exporter(),
      config=@trace.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=10,
      ),
    )
    .build()
  @async.with_task_group(group => {
    provider.spawn_batch_processor_tasks(group)
    let logger = provider.logger("logs-background")
    logger.emit(@common.Value::String("background flush"))
    @async.sleep(40)
    assert_eq(exporter.finished_logs().length(), 1)
    ignore(provider.shutdown())
  })
}
