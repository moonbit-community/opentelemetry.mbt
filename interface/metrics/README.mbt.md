# OpenTelemetry Metrics API

This package is the public metrics API. It lets instrumentation code describe
measurements without depending on a concrete SDK, reader, or exporter.

Metrics are not exported one measurement at a time. Instruments record raw
measurements into in-memory aggregation state. SDK readers later collect the
aggregated metric points and exporters send those points to a backend.

## Main Types

- `MeterProvider`: entry point that creates meters
- `Meter`: creates instruments for one instrumentation scope
- `Counter`, `UpDownCounter`, `Histogram`, `Gauge`: synchronous instruments
- `ObservableCounter`, `ObservableUpDownCounter`, `ObservableGauge`: callback
  instruments observed during collection
- builder types for every instrument kind

## Choosing Instruments

Choose the instrument based on the meaning of the value, not only its type:

| Use case | Instrument |
| --- | --- |
| Count requests, errors, bytes sent, or other monotonic totals | `Counter` |
| Track active requests, queue depth, or connections that go up and down | `UpDownCounter` |
| Record latency, payload size, or other distributions | `Histogram` |
| Record latest temperature, memory use, or other current state | `Gauge` |
| Read a value owned elsewhere only when metrics are collected | Observable instrument |

Prefer low-cardinality attributes. Values such as user IDs, raw URLs, UUIDs, or
unbounded error strings can create too many time series.

## Recording Measurements

Create instruments once and reuse them. Instrument creation may register SDK
state; recording is the hot path.

```mbt check
///|
fn _metrics_readme_record() -> Unit {
  let meter = MeterProvider::noop().meter("example")
  let counter = meter
    .u64_counter("request.count")
    .with_description("Total handled requests")
    .build()
  let latency = meter.f64_histogram("request.duration").with_unit("ms").build()

  counter.add(1UL, attributes=[
    @common.KeyValue::new("http.request.method", @common.Value::String("GET")),
  ])
  latency.record(12.5, attributes=[
    @common.KeyValue::new("http.route", @common.Value::String("/health")),
  ])
}
```

The SDK ignores negative deltas for monotonic counters. Use an up-down counter
when the value can decrease.

## Observable Instruments

Observable instruments are callbacks. Use them when the measurement already
lives somewhere else and should be read during collection, for example process
memory, queue length, connection pool size, or OS counters.

```mbt check
///|
fn _metrics_readme_observable() -> Unit {
  let meter = MeterProvider::noop().meter("example")
  let observable = meter
    .i64_observable_up_down_counter("queue.depth")
    .with_callback(observer => observer.observe(42L))
    .build()
  ignore(observable)
}
```

Callbacks are frozen when `build()` is called. If a no-op meter is used,
callbacks are accepted but never collected by an SDK reader.

## Provider Reference

- `MeterProvider::from_sdk(provider)` wraps an SDK meter provider.
- `MeterProvider::noop()` creates no-op instruments.
- `meter(name)` creates a meter for one instrumentation name.
- `meter_with_scope(scope)` creates a meter from a full instrumentation scope.
- `force_flush()` and `shutdown()` forward to the SDK provider; no-op providers
  report success.
- `spawn_periodic_readers(group, allow_failure?)` starts periodic metric reader
  loops owned by the provider.

## Instrument Reference

- `Counter::add(value, attributes?)` records a monotonic delta.
- `UpDownCounter::add(value, attributes?)` records a signed delta.
- `Histogram::record(value, attributes?)` records one sample.
- `Gauge::record(value, attributes?)` records the latest value.
- `ObservableCounter::observe(value, attributes?)` reports a callback value for
  a monotonic observable counter.
- `ObservableUpDownCounter::observe(value, attributes?)` reports a callback
  value for an additive observable counter.
- `ObservableGauge::observe(value, attributes?)` reports a callback value for a
  gauge.

## Builder Reference

All builders expose:

- `with_description(description)`: human-readable explanation of the instrument
- `with_unit(unit)`: UCUM-style unit such as `ms`, `By`, or `1`
- `build()`: creates the instrument

Observable builders also expose `with_callback(callback)`.

## Meter Factory Reference

Counters:

- `u64_counter(name)`
- `f64_counter(name)`

Up-down counters:

- `i64_up_down_counter(name)`
- `f64_up_down_counter(name)`

Histograms:

- `u64_histogram(name)`
- `f64_histogram(name)`

Gauges:

- `u64_gauge(name)`
- `i64_gauge(name)`, converted to the SDK's floating-point representation
- `f64_gauge(name)`

Observable counters:

- `u64_observable_counter(name)`
- `f64_observable_counter(name)`

Observable up-down counters:

- `i64_observable_up_down_counter(name)`
- `f64_observable_up_down_counter(name)`

Observable gauges:

- `u64_observable_gauge(name)`
- `i64_observable_gauge(name)`, callback values converted to floating point
- `f64_observable_gauge(name)`

## No-Op Behavior

No-op meters return builders whose built instruments silently discard
measurements. This lets libraries record metrics unconditionally while the final
application decides whether a real SDK provider and reader are installed.
