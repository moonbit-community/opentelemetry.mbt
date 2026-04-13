# OpenTelemetry Stdout Exporters

This package prints telemetry in a readable text format. It is primarily meant
for local development, examples, and debugging.

## Main types

- `SpanExporter`
- `LogExporter`
- `MetricExporter`
- `MetricExporterBuilder`

## Construction

- `SpanExporter::new()`:
  returns a stdout span exporter
- `LogExporter::new()`:
  returns a stdout log exporter
- `MetricExporter::builder()`:
  starts building a stdout metric exporter
- `MetricExporterBuilder::with_temporality(temporality)`:
  sets the temporality that will be used when the exporter is converted into a
  periodic reader
- `MetricExporterBuilder::build()`:
  builds the metric exporter
- `MetricExporter::temporality()`:
  returns the configured temporality

`MetricExporter::default()` is equivalent to `builder().build()` and uses
`Temporality::Cumulative`.

## Export behavior

- `SpanExporter::export_batch(batch)`:
  prints one human-readable span batch
- `LogExporter::export_batch(batch)`:
  prints one human-readable log batch
- `MetricExporter::export_batch(batch)`:
  prints one human-readable metric batch

Span and log exporters print the resource block only once, on the first non-empty
batch. The metric exporter prints every batch in full.

After shutdown, export methods return `AlreadyShutdown`.

## Flush and shutdown

- `force_flush()`:
  no-op unless the exporter has already been shut down
- `shutdown_with_timeout(timeout_millis)`:
  marks the exporter as shut down; the timeout argument is accepted for API
  parity but is not otherwise used
- `shutdown()`:
  shorthand for `shutdown_with_timeout(5000)`
- `name()`:
  always returns `"print"`

## SDK interop

- `into_span_exporter()`:
  erases the concrete span exporter into `sdk/trace.SpanExporter`
- `into_log_exporter()`:
  erases the concrete log exporter into `sdk/logs.LogExporter`
- `into_metric_exporter()`:
  erases the concrete metric exporter into `sdk/metrics.MetricExporter`
- `into_periodic_reader(interval_millis?)`:
  creates a periodic metric reader using the exporter's configured temporality;
  a negative interval keeps the SDK default
