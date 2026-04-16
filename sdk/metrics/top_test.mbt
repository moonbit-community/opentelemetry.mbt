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
fn restore_env_var(key : String, value : String?) -> Unit {
  match value {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
}

///|
fn counter_sum(metrics : Array[MetricData], name : StringView) -> Int64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        Aggregation::Sum(Number::Int64(value)) => return Some(value)
        _ => return None
      }
    }
  }
  None
}

///|
fn gauge_value(metrics : Array[MetricData], name : StringView) -> Double? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        Aggregation::Gauge(Number::Double(value)) => return Some(value)
        _ => return None
      }
    }
  }
  None
}

///|
fn sum_double(metrics : Array[MetricData], name : StringView) -> Double? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        Aggregation::Sum(Number::Double(value)) => return Some(value)
        _ => return None
      }
    }
  }
  None
}

///|
fn metric_count(metrics : Array[MetricData], name : StringView) -> Int {
  let mut count = 0
  for metric in metrics {
    if metric.name == name.to_string() {
      count += 1
    }
  }
  count
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
  let retries = meter.counter("retries").build()
  let histogram = meter.histogram("latency").build()
  let gauge = meter.gauge("load").build()

  counter.add(2)
  counter.add(3, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/health")),
  ])
  retries.add(3)
  retries.add(-1)
  histogram.record(10.0)
  histogram.record(20.0)
  gauge.record(0.75)

  let reader = provider.manual_reader()
  let metrics = reader.collect()
  assert_true(has_metric(metrics, "requests"))
  assert_eq(counter_sum(metrics, "retries"), Some(3))
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
test "builder-registered manual reader collects metrics" {
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let meter = provider.meter("metrics-reader")
  let counter = meter.counter("requests").build()
  counter.add(7)

  let metrics = reader.collect()
  assert_eq(counter_sum(metrics, "requests"), Some(7))
}

///|
test "manual reader delta temporality reports counter deltas" {
  let reader = ManualReader::builder()
    .with_temporality(Temporality::Delta)
    .build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let counter = provider.meter("metrics-delta").counter("requests").build()

  counter.add(2)
  assert_eq(counter_sum(reader.collect(), "requests"), Some(2))
  counter.add(3)
  assert_eq(counter_sum(reader.collect(), "requests"), Some(3))
  assert_eq(counter_sum(reader.collect(), "requests"), Some(0))
}

///|
test "low memory temporality keeps up-down counters cumulative" {
  let reader = ManualReader::builder()
    .with_temporality(Temporality::LowMemory)
    .build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let meter = provider.meter("metrics-low-memory")
  let counter = meter.counter("requests").build()
  let active = meter.up_down_counter("active").build()

  counter.add(2)
  active.add(5)
  let first = reader.collect()
  assert_eq(counter_sum(first, "requests"), Some(2))
  assert_eq(counter_sum(first, "active"), Some(5))

  counter.add(3)
  active.add(-2)
  let second = reader.collect()
  assert_eq(counter_sum(second, "requests"), Some(3))
  assert_eq(counter_sum(second, "active"), Some(3))
}

///|
test "views rename metrics filter attributes and cap cardinality" {
  let provider = SdkMeterProvider::builder()
    .with_view(instrument => {
      if instrument.name == "requests" {
        Some(
          Stream::builder()
          .with_name("http.requests")
          .with_allowed_attribute_keys(["route"])
          .with_cardinality_limit(1)
          .build(),
        )
      } else {
        None
      }
    })
    .build()
  let counter = provider.meter("metrics-view").counter("requests").build()
  counter.add(1, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/a")),
    @common.KeyValue::new("status", @common.Value::Int64(200)),
  ])
  counter.add(2, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/b")),
    @common.KeyValue::new("status", @common.Value::Int64(500)),
  ])

  let metrics = provider.manual_reader().collect()
  assert_eq(metric_count(metrics, "http.requests"), 1)
  assert_eq(counter_sum(metrics, "http.requests"), Some(1))
  guard metrics[0].attributes.length() == 1 else {
    fail("expected attributes to be filtered by view")
  }
  assert_eq(metrics[0].attributes[0].key.as_string(), "route")
}

///|
test "observable gauges refresh on each collection" {
  let current = Ref::new(1.5)
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  ignore(
    provider
    .meter("metrics-observable")
    .observable_gauge("load")
    .with_callback(observer => observer.observe(current.val))
    .build(),
  )

  let first = reader.collect()
  assert_eq(gauge_value(first, "load"), Some(1.5))
  current.val = 2.5
  let second = reader.collect()
  assert_eq(metric_count(second, "load"), 1)
  assert_eq(gauge_value(second, "load"), Some(2.5))
}

///|
test "views can override histogram aggregation to sum" {
  let provider = SdkMeterProvider::builder()
    .with_view(instrument => {
      if instrument.name == "latency" {
        Some(Stream::builder().with_aggregation(StreamAggregation::Sum).build())
      } else {
        None
      }
    })
    .build()
  let histogram = provider
    .meter("metrics-view-aggregation")
    .histogram("latency")
    .build()
  histogram.record(1.5)
  histogram.record(2.0)

  let metrics = provider.manual_reader().collect()
  assert_eq(sum_double(metrics, "latency"), Some(3.5))
}

///|
test "views can drop matching streams" {
  let provider = SdkMeterProvider::builder()
    .with_view(instrument => {
      if instrument.name == "drop.me" {
        Some(
          Stream::builder().with_aggregation(StreamAggregation::Drop).build(),
        )
      } else {
        None
      }
    })
    .build()
  let counter = provider.meter("metrics-drop").counter("drop.me").build()
  counter.add(1)

  let metrics = provider.manual_reader().collect()
  assert_true(!has_metric(metrics, "drop.me"))
}

///|
test "builder-registered periodic reader force flush honors delta temporality" {
  let exporter = InMemoryMetricExporter::new()
  let reader = PeriodicMetricReader::builder(exporter.into_metric_exporter())
    .with_interval(10)
    .with_temporality(Temporality::Delta)
    .build()
  let provider = SdkMeterProvider::builder()
    .with_periodic_reader(reader)
    .build()
  let counter = provider
    .meter("metrics-periodic-reader")
    .counter("jobs")
    .build()

  counter.add(4)
  guard reader.force_flush() is Ok(_) else {
    fail("expected periodic reader force_flush to succeed")
  }
  assert_eq(counter_sum(exporter.finished_metrics(), "jobs"), Some(4))

  exporter.reset()
  counter.add(2)
  guard reader.force_flush() is Ok(_) else {
    fail("expected periodic reader force_flush to succeed")
  }
  assert_eq(counter_sum(exporter.finished_metrics(), "jobs"), Some(2))
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

///|
async test "periodic exporter default interval reads environment" {
  let original_interval = @env.get_env_var("OTEL_METRIC_EXPORT_INTERVAL")
  defer restore_env_var("OTEL_METRIC_EXPORT_INTERVAL", original_interval)
  @env.set_env_var("OTEL_METRIC_EXPORT_INTERVAL", "10")

  let exporter = InMemoryMetricExporter::new()
  let provider = SdkMeterProvider::builder()
    .with_periodic_exporter(exporter.into_metric_exporter())
    .build()
  @async.with_task_group(group => {
    provider.spawn_periodic_readers(group)
    let meter = provider.meter("metrics-env")
    let counter = meter.counter("env-jobs").build()
    counter.add(1)
    @async.sleep(40)
    assert_true(has_metric(exporter.finished_metrics(), "env-jobs"))
    ignore(provider.shutdown_with_timeout(1))
  })
}

///|
test "floating-point counters and observables export double sums" {
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let meter = provider.meter("metrics-double")
  let counter = meter.f64_counter("bytes").build()
  let up_down_counter = meter.f64_up_down_counter("balance").build()
  let current_rate = Ref::new(1.25)
  let current_offset = Ref::new(-0.5)
  ignore(
    meter
    .f64_observable_counter("rate")
    .with_callback(observer => observer.observe(current_rate.val))
    .build(),
  )
  ignore(
    meter
    .f64_observable_up_down_counter("offset")
    .with_callback(observer => observer.observe(current_offset.val))
    .build(),
  )

  counter.add(1.5)
  counter.add(-2.0)
  counter.add(2.0)
  up_down_counter.add(5.5)
  up_down_counter.add(-1.0)

  let first = reader.collect()
  assert_eq(sum_double(first, "bytes"), Some(3.5))
  assert_eq(sum_double(first, "balance"), Some(4.5))
  assert_eq(sum_double(first, "rate"), Some(1.25))
  assert_eq(sum_double(first, "offset"), Some(-0.5))

  current_rate.val = 2.75
  current_offset.val = 3.0
  let second = reader.collect()
  assert_eq(sum_double(second, "rate"), Some(2.75))
  assert_eq(sum_double(second, "offset"), Some(3.0))
}
