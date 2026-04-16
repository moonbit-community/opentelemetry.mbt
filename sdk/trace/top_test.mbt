///|
fn restore_env_var(key : String, value : String?) -> Unit {
  match value {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
}

///|
test "simple processor exports parent child spans" {
  let exporter = InMemorySpanExporter::new()
  let provider = SdkTracerProvider::builder()
    .with_simple_exporter(exporter.into_span_exporter())
    .build()
  let tracer = provider.tracer("trace-test")
  let root = tracer.start("root")
  root.set_attribute("http.method", @common.Value::String("GET"))
  root.add_event("connected")
  let child = tracer.start("child", parent_context=root.context())
  child.end()
  root.end()

  let spans = exporter.finished_spans()
  assert_eq(spans.length(), 2)
  assert_eq(spans[0].name, "child")
  assert_eq(spans[1].name, "root")
  guard spans[0].parent_span_context is Some(parent_span_context) else {
    fail("expected child span parent context")
  }
  assert_eq(
    parent_span_context.span_id().to_hex(),
    root.span_context().span_id().to_hex(),
  )
  assert_eq(spans[1].attributes.length(), 1)
  assert_eq(spans[1].events.length(), 1)
}

///|
test "batch processor flushes queued spans" {
  let exporter = InMemorySpanExporter::new()
  let provider = SdkTracerProvider::builder()
    .with_batch_exporter(
      exporter.into_span_exporter(),
      config=BatchConfig::new(max_queue_size=8, max_export_batch_size=8),
    )
    .build()
  let tracer = provider.tracer("trace-batch")
  let span = tracer.start("queued")
  span.end()

  assert_eq(exporter.finished_spans().length(), 0)
  guard provider.force_flush() is Ok(_) else {
    fail("expected force_flush to succeed")
  }
  assert_eq(exporter.finished_spans().length(), 1)
}

///|
test "default trace config reads environment variables" {
  let original_sampler = @env.get_env_var("OTEL_TRACES_SAMPLER")
  let original_sampler_arg = @env.get_env_var("OTEL_TRACES_SAMPLER_ARG")
  let original_attr_limit = @env.get_env_var("OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT")
  let original_event_limit = @env.get_env_var("OTEL_SPAN_EVENT_COUNT_LIMIT")
  let original_link_limit = @env.get_env_var("OTEL_SPAN_LINK_COUNT_LIMIT")
  let original_schedule_delay = @env.get_env_var("OTEL_BSP_SCHEDULE_DELAY")
  let original_export_timeout = @env.get_env_var("OTEL_BSP_EXPORT_TIMEOUT")
  let original_queue_size = @env.get_env_var("OTEL_BSP_MAX_QUEUE_SIZE")
  let original_batch_size = @env.get_env_var("OTEL_BSP_MAX_EXPORT_BATCH_SIZE")
  defer restore_env_var("OTEL_TRACES_SAMPLER", original_sampler)
  defer restore_env_var("OTEL_TRACES_SAMPLER_ARG", original_sampler_arg)
  defer restore_env_var("OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT", original_attr_limit)
  defer restore_env_var("OTEL_SPAN_EVENT_COUNT_LIMIT", original_event_limit)
  defer restore_env_var("OTEL_SPAN_LINK_COUNT_LIMIT", original_link_limit)
  defer restore_env_var("OTEL_BSP_SCHEDULE_DELAY", original_schedule_delay)
  defer restore_env_var("OTEL_BSP_EXPORT_TIMEOUT", original_export_timeout)
  defer restore_env_var("OTEL_BSP_MAX_QUEUE_SIZE", original_queue_size)
  defer restore_env_var("OTEL_BSP_MAX_EXPORT_BATCH_SIZE", original_batch_size)

  @env.set_env_var("OTEL_TRACES_SAMPLER", "parentbased_traceidratio")
  @env.set_env_var("OTEL_TRACES_SAMPLER_ARG", "0.25")
  @env.set_env_var("OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT", "7")
  @env.set_env_var("OTEL_SPAN_EVENT_COUNT_LIMIT", "9")
  @env.set_env_var("OTEL_SPAN_LINK_COUNT_LIMIT", "11")
  @env.set_env_var("OTEL_BSP_SCHEDULE_DELAY", "17")
  @env.set_env_var("OTEL_BSP_EXPORT_TIMEOUT", "19")
  @env.set_env_var("OTEL_BSP_MAX_QUEUE_SIZE", "23")
  @env.set_env_var("OTEL_BSP_MAX_EXPORT_BATCH_SIZE", "29")

  let config : Config = Default::default()
  assert_eq(config.sampler.description(), "parent_based(trace_id_ratio(0.25))")
  assert_eq(config.span_limits.max_attributes_per_span, 7)
  assert_eq(config.span_limits.max_events_per_span, 9)
  assert_eq(config.span_limits.max_links_per_span, 11)

  let batch : BatchConfig = Default::default()
  assert_eq(batch.scheduled_delay_millis, 17)
  assert_eq(batch.export_timeout_millis, 19)
  assert_eq(batch.max_queue_size, 23)
  assert_eq(batch.max_export_batch_size, 23)
}

///|
async test "batch processor flushes on scheduled delay in background" {
  let exporter = InMemorySpanExporter::new()
  let provider = SdkTracerProvider::builder()
    .with_batch_exporter(
      exporter.into_span_exporter(),
      config=BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=10,
      ),
    )
    .build()
  @async.with_task_group(group => {
    provider.spawn_batch_processor_tasks(group)
    let tracer = provider.tracer("trace-background")
    let span = tracer.start("scheduled")
    span.end()
    @async.sleep(40)
    assert_eq(exporter.finished_spans().length(), 1)
    ignore(provider.shutdown())
  })
}

///|
test "provider shutdown with timeout marks provider unavailable" {
  let exporter = InMemorySpanExporter::new()
  let provider = SdkTracerProvider::builder()
    .with_batch_exporter(exporter.into_span_exporter())
    .build()
  guard provider.shutdown_with_timeout(1) is Ok(_) else {
    fail("expected shutdown_with_timeout to succeed")
  }
  guard provider.shutdown() is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected provider to stay shut down")
  }
}
