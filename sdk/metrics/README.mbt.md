# OpenTelemetry Metrics SDK

This package implements synchronous and observable metric instruments,
exporters, views, and reader coordination.

## Main types

- `SdkMeterProvider`: owns resource, exporters, and readers
- `SdkMeter`: creates instruments scoped to a name/version/schema URL
- `Counter`, `UpDownCounter`, `Histogram`, `Gauge`: supported synchronous
  instruments
- `ObservableCounter`, `ObservableUpDownCounter`, `ObservableGauge`: callback
  driven instruments sampled during collection
- `ManualReader`: pulls a snapshot on demand
- `PeriodicMetricReader`: pushes snapshots on an interval
- `Temporality`: selects cumulative vs delta style reporting for readers
- `Stream`, `StreamBuilder`: view output configuration for renaming, attribute
  filtering, and cardinality limits
- `MetricExporter`, `InMemoryMetricExporter`: exporter abstraction and test
  helper

## Aggregation model

The current implementation stores one point per unique attribute set and emits
one of these aggregations:

- `Aggregation::Sum`
- `Aggregation::Gauge`
- `Aggregation::Histogram`

Histograms keep count, sum, min, and max. They do not currently compute bucket
boundaries.

## Reader behavior

`ManualReader::builder()` creates a detached reader that can be registered with
`SdkMeterProviderBuilder::with_reader()`. `SdkMeterProvider::manual_reader()`
remains as a convenience for creating a reader directly from an existing
provider.

`ManualReader::collect_result()` is the lifecycle-aware pull API. It returns an
error after shutdown and also reports detached readers that were never
registered with a provider.

`ManualReader::collect()` remains the convenience wrapper. It returns `[]` when
collection is unavailable, including after shutdown.

`ManualReader::force_flush()` is a no-op and always succeeds because the reader
does not own exporters or background work.

`PeriodicMetricReader::builder(exporter)` creates a detached push reader that
can be registered with `SdkMeterProviderBuilder::with_periodic_reader()`.
`with_periodic_exporter()` remains as the convenience shortcut.

Both reader builders support `with_temporality()`:

- `Temporality::Cumulative`
- `Temporality::Delta`
- `Temporality::LowMemory`

`SdkMeterProvider::force_flush()` collects a fresh snapshot, exports it through
every registered exporter, and then asks each exporter to flush.

`PeriodicMetricReader::run()` performs the same collection/export cycle on a
timer. Like the trace and log batch processors, it must be spawned explicitly.

When `with_periodic_exporter()` is used without an explicit interval, the
reader defaults from `OTEL_METRIC_EXPORT_INTERVAL`.

Delta temporality currently applies to sum-like streams and the simplified
histogram summary model used in this package. Histogram deltas reuse the
current cycle's min/max because the implementation does not yet store full
bucket state.

`Counter::add()` now ignores negative deltas so the instrument remains
monotonic.

Observable callbacks run during each `collect()` / periodic export cycle. Their
last values are cleared before each run so gauges and counters report the
current callback result instead of accumulating stale points forever.

`with_view()` currently supports per-instrument stream renaming, aggregation
override, attribute allow-lists, and cardinality limits.

`StreamBuilder::with_aggregation()` supports these modes:

- `StreamAggregation::Default`
- `StreamAggregation::Drop`
- `StreamAggregation::Sum`
- `StreamAggregation::LastValue`
- `StreamAggregation::Histogram`

`Drop` suppresses the matching stream entirely. `Sum`, `LastValue`, and
`Histogram` remap the recorded measurements into the selected aggregation
without changing the instrument name or scope unless the view also overrides
those fields.
