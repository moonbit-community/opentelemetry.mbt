///|
fn restore_env_var(key : String, value : String?) -> Unit {
  match value {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
}

///|
// Test target: Verify emitted SDK log records preserve trace context, severity, and attributes in exported output.
// Test method: Emit one log record with an explicit span context into an in-memory exporter and assert the exported fields match.
async test "logger exports trace-aware log records" {
  guard @common.TraceId::from_hex("4bf92f3577b34da6a3ce929d0e0e4736")
    is Some(trace_id) else {
    fail("expected trace id")
  }
  guard @common.SpanId::from_hex("00f067aa0ba902b7") is Some(span_id) else {
    fail("expected span id")
  }
  let trace_flags : @common.TraceFlags = Default::default()
  let span_context = @common.SpanContext::new(
    trace_id,
    span_id,
    trace_flags=trace_flags.with_sampled(true),
  )
  let context = @context.Context::empty().with_span_context(span_context)

  let exporter = InMemoryLogExporter::new()
  let provider = SdkLoggerProvider::builder()
    .with_simple_exporter(exporter.into_log_exporter())
    .build()
  let logger = provider.logger("logs-test")
  logger.emit(
    AnyValue::String("request failed"),
    context~,
    severity_number=Some(SeverityNumber::Error3),
    severity_text=Some("ERROR3"),
    event_name=Some("checkout.failed"),
    target=Some("api"),
    attributes=[KeyValue::new("http.status_code", AnyValue::Int64(500))],
  )

  let records = exporter.finished_logs()
  assert_eq(records.length(), 1)
  assert_eq(records[0].event_name, Some("checkout.failed"))
  assert_eq(records[0].target, Some("api"))
  guard records[0].trace_context is Some(trace_context) else {
    fail("expected trace context on log record")
  }
  assert_eq(trace_context.trace_id().to_hex(), span_context.trace_id().to_hex())
  assert_eq(trace_context.span_id().to_hex(), span_context.span_id().to_hex())
  assert_eq(records[0].attributes.length(), 1)
  assert_true(records[0].severity_number is Some(SeverityNumber::Error3))
}

///|
// Test target: Verify the batch log processor flushes queued records once the scheduled delay elapses.
// Test method: Spawn the processor background tasks, emit one record, wait past the delay, and assert the exporter received it.
async test "batch log processor flushes on scheduled delay in background" {
  let exporter = InMemoryLogExporter::new()
  let provider = SdkLoggerProvider::builder()
    .with_batch_exporter(
      exporter.into_log_exporter(),
      config=BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=10,
      ),
    )
    .build()
  @async.with_task_group(group => {
    provider.spawn_batch_processor_tasks(group)
    let logger = provider.logger("logs-background")
    logger.emit(AnyValue::String("background flush"))
    @async.sleep(40)
    assert_eq(exporter.finished_logs().length(), 1)
    ignore(provider.shutdown())
  })
}

///|
// Test target: Verify the default batch log processor configuration is sourced from the documented environment variables.
// Test method: Override the environment variables before constructing the default config and assert the parsed values are applied.
test "default batch log config reads environment variables" {
  let original_schedule_delay = @env.get_env_var("OTEL_BLRP_SCHEDULE_DELAY")
  let original_export_timeout = @env.get_env_var("OTEL_BLRP_EXPORT_TIMEOUT")
  let original_queue_size = @env.get_env_var("OTEL_BLRP_MAX_QUEUE_SIZE")
  let original_batch_size = @env.get_env_var("OTEL_BLRP_MAX_EXPORT_BATCH_SIZE")
  defer restore_env_var("OTEL_BLRP_SCHEDULE_DELAY", original_schedule_delay)
  defer restore_env_var("OTEL_BLRP_EXPORT_TIMEOUT", original_export_timeout)
  defer restore_env_var("OTEL_BLRP_MAX_QUEUE_SIZE", original_queue_size)
  defer restore_env_var("OTEL_BLRP_MAX_EXPORT_BATCH_SIZE", original_batch_size)

  @env.set_env_var("OTEL_BLRP_SCHEDULE_DELAY", "13")
  @env.set_env_var("OTEL_BLRP_EXPORT_TIMEOUT", "17")
  @env.set_env_var("OTEL_BLRP_MAX_QUEUE_SIZE", "19")
  @env.set_env_var("OTEL_BLRP_MAX_EXPORT_BATCH_SIZE", "23")

  let config : BatchConfig = Default::default()
  assert_eq(config.scheduled_delay_millis, 13)
  assert_eq(config.export_timeout_millis, 17)
  assert_eq(config.max_queue_size, 19)
  assert_eq(config.max_export_batch_size, 19)
}

///|
// Test target: Verify shutdown_with_timeout closes the logger provider and keeps it unavailable for later shutdown calls.
// Test method: Shut the provider down with a timeout, then call shutdown again and assert the already-shutdown error is returned.
async test "logger provider shutdown with timeout marks provider unavailable" {
  let exporter = InMemoryLogExporter::new()
  let provider = SdkLoggerProvider::builder()
    .with_batch_exporter(exporter.into_log_exporter())
    .build()
  guard provider.shutdown_with_timeout(1) is Ok(_) else {
    fail("expected shutdown_with_timeout to succeed")
  }
  guard provider.shutdown() is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected provider to stay shut down")
  }
}
