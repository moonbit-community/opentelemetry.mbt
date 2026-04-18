# OpenTelemetry Metrics API

This package is the public metrics API surface. It wraps the SDK meter and
instruments while keeping a stable signal-specific API.

## Main types

- `MeterProvider`, `Meter`
- synchronous instruments:
  `Counter`, `UpDownCounter`, `Histogram`, `Gauge`
- observable instruments:
  `ObservableCounter`, `ObservableUpDownCounter`, `ObservableGauge`
- builders for every instrument kind

## Provider behavior

- `MeterProvider::from_sdk(provider)`:
  wraps an SDK provider
- `MeterProvider::noop()`:
  returns a provider that creates no-op instruments
- `meter(name)`:
  returns a meter for one instrumentation name
- `meter_with_scope(scope)`:
  returns a meter for a full instrumentation scope
- `force_flush()`:
  forwards to the SDK provider; no-op providers return success
- `shutdown()`:
  forwards to the SDK provider; no-op providers return success
- `spawn_periodic_readers(group, allow_failure?)`:
  starts any periodic readers owned by the provider

## Instrument method behavior

- `Counter::add(value, attributes?)`:
  records a monotonic delta; the underlying SDK ignores negative deltas
- `UpDownCounter::add(value, attributes?)`:
  records a signed delta
- `Histogram::record(value, attributes?)`:
  records one sample
- `Gauge::record(value, attributes?)`:
  records the latest value
- `ObservableCounter::observe(value, attributes?)`:
  reports one callback value for a monotonic observable counter
- `ObservableUpDownCounter::observe(value, attributes?)`:
  reports one callback value for an additive observable counter
- `ObservableGauge::observe(value, attributes?)`:
  reports one callback value for a gauge

## Builder method behavior

All builders follow the same pattern:

- `with_description(description)`:
  sets the instrument description
- `with_unit(unit)`:
  sets the instrument unit
- `build()`:
  creates the instrument with the current options

Observable builders additionally expose:

- `with_callback(callback)`:
  registers one callback to run during collection

Callbacks are frozen when `build()` is called.

## Meter factory methods

### Counters

- `u64_counter(name)`:
  builds a `UInt64` counter; values are bridged through the SDK's signed
  64-bit counter and values larger than `Int64::max` are dropped
- `f64_counter(name)`:
  builds a floating-point counter

### Up-down counters

- `i64_up_down_counter(name)`:
  builds an `Int64` up-down counter
- `f64_up_down_counter(name)`:
  builds a floating-point up-down counter

### Histograms

- `u64_histogram(name)`:
  builds a `UInt64` histogram; values are converted to `Double`
- `f64_histogram(name)`:
  builds a `Double` histogram

### Gauges

- `u64_gauge(name)`:
  builds a `UInt64` gauge; values are converted to `Double`
- `i64_gauge(name)`:
  builds an `Int64` gauge; values are converted to `Double`
- `f64_gauge(name)`:
  builds a `Double` gauge

### Observable counters

- `u64_observable_counter(name)`:
  builds a `UInt64` observable counter; callback values larger than
  `Int64::max` are dropped
- `f64_observable_counter(name)`:
  builds a `Double` observable counter

### Observable up-down counters

- `i64_observable_up_down_counter(name)`:
  builds an `Int64` observable up-down counter
- `f64_observable_up_down_counter(name)`:
  builds a `Double` observable up-down counter

### Observable gauges

- `u64_observable_gauge(name)`:
  builds a `UInt64` observable gauge; callback values are converted to `Double`
- `i64_observable_gauge(name)`:
  builds an `Int64` observable gauge; callback values are converted to `Double`
- `f64_observable_gauge(name)`:
  builds a `Double` observable gauge

No-op meters return builders whose built instruments silently discard all
measurements.
