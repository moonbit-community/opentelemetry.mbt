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
