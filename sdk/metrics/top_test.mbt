///|
fn has_metric(metrics : Array[MetricData], name : StringView) -> Bool {
  for metric in metrics {
    if metric.name == name.to_string() {
      return true
    }
  }
  false
}

///|
test "manual reader collects metric snapshots" {
  let exporter = InMemoryMetricExporter::new()
  let provider = SdkMeterProvider::builder()
    .with_exporter(exporter.into_metric_exporter())
    .build()
  let meter = provider.meter("metrics-test")
  let counter = meter
    .counter("requests")
    .with_description("request count")
    .build()
  let histogram = meter.histogram("latency").build()
  let gauge = meter.gauge("load").build()

  counter.add(2)
  counter.add(3, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/health")),
  ])
  histogram.record(10.0)
  histogram.record(20.0)
  gauge.record(0.75)

  let reader = provider.manual_reader()
  let metrics = reader.collect()
  assert_true(has_metric(metrics, "requests"))
  assert_true(has_metric(metrics, "latency"))
  assert_true(has_metric(metrics, "load"))

  guard provider.force_flush() is Ok(_) else {
    fail("expected metric force_flush to succeed")
  }
  let exported = exporter.finished_metrics()
  assert_true(has_metric(exported, "requests"))
  assert_true(has_metric(exported, "latency"))
  assert_true(has_metric(exported, "load"))
}

///|
async test "periodic reader exports in background" {
  let exporter = InMemoryMetricExporter::new()
  let provider = SdkMeterProvider::builder()
    .with_periodic_exporter(exporter.into_metric_exporter(), interval_millis=10)
    .build()
  @async.with_task_group(group => {
    provider.spawn_periodic_readers(group)
    let meter = provider.meter("metrics-background")
    let counter = meter.counter("jobs").build()
    counter.add(1)
    @async.sleep(40)
    let exported = exporter.finished_metrics()
    assert_true(has_metric(exported, "jobs"))
    ignore(provider.shutdown())
  })
}
