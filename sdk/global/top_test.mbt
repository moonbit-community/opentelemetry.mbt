///|
// Test target: Verify the SDK-level global tracer provider can be replaced for subsequent root API calls.
// Test method: Install an in-memory provider globally, create a span through the global tracer helper, and assert one span is exported.
async test "global tracer provider can be replaced" {
  reset_for_test()

  let exporter = @trace.InMemorySpanExporter::new()
  let provider = @trace.SdkTracerProvider::builder()
    .with_simple_exporter(exporter.into_span_exporter())
    .build()
  set_tracer_provider(provider)

  let tracer = tracer("global-test")
  let span = tracer.start("global-span")
  span.end()

  assert_eq(exporter.finished_spans().length(), 1)
  reset_for_test()
}

///|
// Test target: Verify the global background-task runner drives both batch span export and periodic metric export.
// Test method: Register batch and periodic providers, spawn the shared background tasks, then assert spans and metrics are exported asynchronously.
async test "global background tasks drive batch and periodic exporters" {
  reset_for_test()

  let span_exporter = @trace.InMemorySpanExporter::new()
  let tracer_provider = @trace.SdkTracerProvider::builder()
    .with_batch_exporter(
      span_exporter.into_span_exporter(),
      config=@trace.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=10,
      ),
    )
    .build()
  set_tracer_provider(tracer_provider)

  let metric_exporter = @metrics.InMemoryMetricExporter::new()
  let meter_provider = @metrics.SdkMeterProvider::builder()
    .with_periodic_exporter(
      metric_exporter.into_metric_exporter(),
      interval_millis=10,
    )
    .build()
  set_meter_provider(meter_provider)

  @async.with_task_group(group => {
    spawn_background_tasks(group)
    let span = tracer("global-background").start("global-span")
    span.end()
    let counter = meter("global-background").counter("global-jobs").build()
    counter.add(1)
    @async.sleep(40)
    assert_eq(span_exporter.finished_spans().length(), 1)
    assert_true(metric_exporter.finished_metrics().length() > 0)
    ignore(tracer_provider.shutdown())
    ignore(meter_provider.shutdown())
  })

  reset_for_test()
}
