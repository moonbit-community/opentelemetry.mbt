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
fn counter_sum_u64(metrics : Array[MetricData], name : StringView) -> UInt64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        Aggregation::Sum(Number::UInt64(value)) => return Some(value)
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
fn gauge_value_u64(metrics : Array[MetricData], name : StringView) -> UInt64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        Aggregation::Gauge(Number::UInt64(value)) => return Some(value)
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
fn histogram_sum_u64(metrics : Array[MetricData], name : StringView) -> UInt64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        Aggregation::Histogram(summary) =>
          match summary.sum {
            Number::UInt64(value) => return Some(value)
            _ => return None
          }
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
// Test target: Verify the manual reader captures metric snapshots from synchronous instruments and force_flush exports the same data.
// Test method: Record counters, histograms, and gauges, collect through the manual reader, then force flush and assert the exported metric names and values.
async test "manual reader collects metric snapshots" {
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
// Test target: Verify a manual reader registered through the builder can collect metrics from the provider.
// Test method: Attach a manual reader, record one counter value, and assert collect returns the expected sum.
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
// Test target: Verify collect_result reports an internal failure when a manual reader has not been registered with any provider.
// Test method: Call collect_result on a detached reader and assert the returned error message matches the registration failure.
test "manual reader collect_result reports detached readers" {
  let reader = ManualReader::builder().build()

  guard reader.collect_result()
    is Err(@error.OTelSdkError::InternalFailure(message)) else {
    fail("expected detached manual reader collect_result to fail")
  }
  assert_eq(message, "reader is not registered")
}

///|
// Test target: Verify collect_result succeeds while a registered manual reader is still active.
// Test method: Register a reader, record one counter update, then call collect_result and assert the returned metrics contain that value.
test "manual reader collect_result succeeds before shutdown" {
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let counter = provider
    .meter("metrics-reader-result")
    .counter("requests")
    .build()
  counter.add(9)

  guard reader.collect_result() is Ok(metrics) else {
    fail("expected registered manual reader collect_result to succeed")
  }
  assert_eq(counter_sum(metrics, "requests"), Some(9))
}

///|
// Test target: Verify collect_result reports an already-shutdown error after the manual reader is shut down.
// Test method: Register and shut down a reader, then call collect_result and assert it fails with the shutdown error.
async test "manual reader collect_result reports shutdown" {
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let counter = provider
    .meter("metrics-reader-shutdown")
    .counter("requests")
    .build()
  counter.add(3)

  guard reader.shutdown() is Ok(_) else {
    fail("expected manual reader shutdown to succeed")
  }
  guard reader.collect_result() is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected manual reader collect_result to report shutdown")
  }
}

///|
// Test target: Verify the convenience collect API degrades to an empty snapshot instead of failing after shutdown.
// Test method: Register and shut down a reader, then call collect and assert it returns no metrics.
async test "manual reader collect stays convenience-oriented after shutdown" {
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let counter = provider
    .meter("metrics-reader-convenience")
    .counter("requests")
    .build()
  counter.add(5)

  guard reader.shutdown() is Ok(_) else {
    fail("expected manual reader shutdown to succeed")
  }
  assert_eq(reader.collect().length(), 0)
}

///|
// Test target: Verify delta temporality readers report only the increment since the previous collection.
// Test method: Add to a counter across multiple collections and assert each snapshot returns the delta for that interval.
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
// Test target: Verify low-memory temporality keeps monotonic counters delta-based while up-down counters remain cumulative.
// Test method: Record both counter types across two collections and assert the counter resets to deltas while the active total stays cumulative.
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
// Test target: Verify views can rename metrics, filter attributes, and enforce cardinality limits.
// Test method: Register a view for one counter, record two attribute sets, and assert the collected stream uses the renamed metric with filtered attributes and one series.
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
// Test target: Verify observable gauges re-run their callback and publish a fresh point on every collection.
// Test method: Change the observed value between two manual collections and assert each snapshot reports the latest reading only once.
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
// Test target: Verify a view can replace histogram aggregation with a sum aggregation.
// Test method: Register a sum view for a histogram instrument, record two measurements, and assert the exported metric is the summed value.
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
// Test target: Verify views can drop matching metric streams entirely.
// Test method: Register a drop view for one counter, record a value, and assert the collected snapshot omits that metric.
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
// Test target: Verify force_flush remains a successful no-op after a manual reader has been shut down.
// Test method: Shut down the reader first, then call force_flush and assert it still returns success.
async test "manual reader force flush is ok after shutdown" {
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()

  guard reader.shutdown() is Ok(_) else {
    fail("expected manual reader shutdown to succeed")
  }
  guard reader.force_flush() is Ok(_) else {
    fail("expected manual reader force_flush to remain a no-op")
  }
  ignore(provider)
}

///|
// Test target: Verify a periodic reader registered through the builder respects delta temporality when force-flushed.
// Test method: Force flush after two counter updates and assert each export contains only the delta added since the previous flush.
async test "builder-registered periodic reader force flush honors delta temporality" {
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
// Test target: Verify periodic readers export metrics automatically while their background task is running.
// Test method: Spawn the periodic reader task, record a counter value, wait past the interval, and assert the exporter receives it.
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
// Test target: Verify the default periodic export interval is read from the environment.
// Test method: Override OTEL_METRIC_EXPORT_INTERVAL, run the periodic reader in the background, and assert an export happens on that schedule.
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
// Test target: Verify floating-point synchronous and observable instruments export double-valued sums across collections.
// Test method: Record and observe double values, collect twice, and assert each metric reports the expected current totals.
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

///|
// Test target: Verify u64 synchronous and observable instruments preserve full-range unsigned values in the exported data.
// Test method: Record one large u64 value through multiple instrument kinds and assert every collected aggregate matches it exactly.
test "u64 instruments preserve full-range values" {
  let reader = ManualReader::builder().build()
  let provider = SdkMeterProvider::builder().with_reader(reader).build()
  let meter = provider.meter("metrics-u64")
  let counter = meter.u64_counter("bytes").build()
  let histogram = meter.u64_histogram("payload").build()
  let gauge = meter.u64_gauge("load").build()
  let current = Ref::new(9223372036854775809UL)
  ignore(
    meter
    .u64_observable_counter("rate")
    .with_callback(observer => observer.observe(current.val))
    .build(),
  )
  ignore(
    meter
    .u64_observable_gauge("current")
    .with_callback(observer => observer.observe(current.val))
    .build(),
  )

  counter.add(current.val)
  histogram.record(current.val)
  gauge.record(current.val)

  let metrics = reader.collect()
  assert_eq(counter_sum_u64(metrics, "bytes"), Some(current.val))
  assert_eq(histogram_sum_u64(metrics, "payload"), Some(current.val))
  assert_eq(gauge_value_u64(metrics, "load"), Some(current.val))
  assert_eq(counter_sum_u64(metrics, "rate"), Some(current.val))
  assert_eq(gauge_value_u64(metrics, "current"), Some(current.val))
}
