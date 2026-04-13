# OpenTelemetry Metrics SDK

This package implements synchronous metric instruments, exporters, and reader
coordination.

## Main types

- `SdkMeterProvider`: owns resource, exporters, and readers
- `SdkMeter`: creates instruments scoped to a name/version/schema URL
- `Counter`, `UpDownCounter`, `Histogram`, `Gauge`: supported synchronous
  instruments
- `ManualReader`: pulls a snapshot on demand
- `PeriodicMetricReader`: pushes snapshots on an interval
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

`force_flush()` collects a fresh snapshot, exports it through every registered
exporter, and then asks each exporter to flush.

`PeriodicMetricReader::run()` performs the same collection/export cycle on a
timer. Like the trace and log batch processors, it must be spawned explicitly.
