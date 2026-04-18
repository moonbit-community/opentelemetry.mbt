///|
fn sum_double(
  metrics : Array[@sdkmetrics.MetricData],
  name : StringView,
) -> Double? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        @sdkmetrics.Aggregation::Sum(@sdkmetrics.Number::Double(value)) =>
          return Some(value)
        _ => return None
      }
    }
  }
  None
}

///|
fn sum_u64(
  metrics : Array[@sdkmetrics.MetricData],
  name : StringView,
) -> UInt64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        @sdkmetrics.Aggregation::Sum(@sdkmetrics.Number::UInt64(value)) =>
          return Some(value)
        _ => return None
      }
    }
  }
  None
}

///|
fn gauge_u64(
  metrics : Array[@sdkmetrics.MetricData],
  name : StringView,
) -> UInt64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        @sdkmetrics.Aggregation::Gauge(@sdkmetrics.Number::UInt64(value)) =>
          return Some(value)
        _ => return None
      }
    }
  }
  None
}

///|
fn histogram_sum_u64(
  metrics : Array[@sdkmetrics.MetricData],
  name : StringView,
) -> UInt64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        @sdkmetrics.Aggregation::Histogram(summary) =>
          match summary.sum {
            @sdkmetrics.Number::UInt64(value) => return Some(value)
            _ => return None
          }
        _ => return None
      }
    }
  }
  None
}

///|
test "wrapper floating-point counters use sdk-backed double sums" {
  let reader = @sdkmetrics.ManualReader::builder().build()
  let provider = MeterProvider::from_sdk(
    @sdkmetrics.SdkMeterProvider::builder().with_reader(reader).build(),
  )
  let meter = provider.meter("wrapper-metrics")
  let counter = meter.f64_counter("bytes").build()
  let active = meter.f64_up_down_counter("active").build()
  let current_rate = Ref::new(1.25)
  ignore(
    meter
    .f64_observable_counter("rate")
    .with_callback(observer => observer.observe(current_rate.val))
    .build(),
  )

  counter.add(1.5)
  counter.add(-3.0)
  counter.add(2.0)
  active.add(5.0)
  active.add(-1.5)

  let first = reader.collect()
  assert_eq(sum_double(first, "bytes"), Some(3.5))
  assert_eq(sum_double(first, "active"), Some(3.5))
  assert_eq(sum_double(first, "rate"), Some(1.25))

  current_rate.val = 2.75
  let second = reader.collect()
  assert_eq(sum_double(second, "rate"), Some(2.75))
}

///|
test "wrapper u64 instruments preserve full range" {
  let reader = @sdkmetrics.ManualReader::builder().build()
  let provider = MeterProvider::from_sdk(
    @sdkmetrics.SdkMeterProvider::builder().with_reader(reader).build(),
  )
  let meter = provider.meter("wrapper-u64")
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
  assert_eq(sum_u64(metrics, "bytes"), Some(current.val))
  assert_eq(histogram_sum_u64(metrics, "payload"), Some(current.val))
  assert_eq(gauge_u64(metrics, "load"), Some(current.val))
  assert_eq(sum_u64(metrics, "rate"), Some(current.val))
  assert_eq(gauge_u64(metrics, "current"), Some(current.val))
}
