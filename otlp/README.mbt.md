# OpenTelemetry OTLP Exporters

This package exports traces, logs, and metrics to OTLP over HTTP. It keeps the
same general builder shape as upstream OpenTelemetry SDKs while matching the
current MoonBit implementation.

Use `print` exporters when learning or writing local tests. Use OTLP exporters
when telemetry should leave the process and go to the OpenTelemetry Collector or
an OTLP-compatible backend.

## Quickstart With The OpenTelemetry Collector

Run a local Collector listening for OTLP/HTTP on port `4318`:

```bash
docker run --rm -p 4318:4318 otel/opentelemetry-collector:latest
```

Create a trace exporter and attach it to an SDK provider:

```mbt nocheck
let exporter = @otlp.SpanExporter::builder()
  .with_http()
  .with_endpoint("http://localhost:4318/v1/traces")
  .build()

match exporter {
  Ok(exporter) => {
    let provider = @sdk.tracer_provider_builder()
      .with_batch_exporter(exporter.into_span_exporter())
      .build()
    @sdk.set_tracer_provider(provider)
  }
  Err(err) => fail(err.to_string())
}
```

The same shape applies to logs and metrics: use `LogExporter::builder()` with
`logger_provider_builder()`, or `MetricExporter::builder()` with
`meter_provider_builder()` / `with_periodic_exporter()`.

Batch processors and periodic readers need background tasks; see
[`../sdk/README.mbt.md`](../sdk/README.mbt.md) for lifecycle details.

## Supported transports

- `Protocol::HttpBinary`
- `Protocol::HttpJson`

`Protocol::Grpc` exists for API parity, but `build()` rejects it today with
`ExporterBuildError::UnsupportedProtocol`.

Default OTLP/HTTP endpoints use these signal paths:

- traces: `/v1/traces`
- metrics: `/v1/metrics`
- logs: `/v1/logs`

## Compression

The API exposes `Compression::Gzip` and `Compression::Zstd` for parity, but the
current implementation does not apply compression. Setting compression through a
builder or environment variable causes `build()` to fail with
`ExporterBuildError::UnsupportedCompressionAlgorithm`.

## Main types

- `SpanExporterBuilder`, `SpanExporter`
- `LogExporterBuilder`, `LogExporter`
- `MetricExporterBuilder`, `MetricExporter`
- `ExporterBuildError`

## Builder flow

Every exporter follows the same pattern:

1. call `SpanExporter::builder()`, `LogExporter::builder()`, or
   `MetricExporter::builder()`
2. optionally override endpoint, protocol, timeout, headers, and other options
3. call `build()`

The convenience constructors `SpanExporter::new()`, `LogExporter::new()`, and
`MetricExporter::new()` are shorthand for `builder().build()`.

Explicit builder options take precedence over signal-specific environment
variables, which take precedence over generic OTLP environment variables.

## Builder method behavior

### Shared builder methods

- `with_http()`:
  forces `Protocol::HttpBinary`
- `with_endpoint(endpoint)`:
  sets an explicit HTTP or HTTPS endpoint and overrides environment-derived
  endpoints
- `with_protocol(protocol)`:
  sets the transport; `Grpc` is still rejected during `build()`
- `with_timeout(timeout_millis)`:
  sets the request timeout in milliseconds; the value must be greater than zero
- `with_headers(headers)`:
  adds explicit headers; names are normalized to lowercase and override
  environment-derived headers with the same name
- `with_compression(compression)`:
  requests compression, which currently causes `build()` to fail
- `build()`:
  validates the configuration, resolves environment fallbacks, and returns the
  exporter or an `ExporterBuildError`

### Metric-only builder methods

- `MetricExporterBuilder::with_temporality(temporality)`:
  selects the temporality used when metrics are exported

## Runtime method behavior

### Common behavior

- `name()`:
  always returns `"otlp"`
- `force_flush()`:
  no-op unless the exporter has already been shut down
- `shutdown_with_timeout(timeout_millis)`:
  marks the exporter as shut down; the timeout argument is accepted for API
  parity but is not used by the current implementation
- `shutdown()`:
  shorthand for `shutdown_with_timeout(5000)`

### Export

- `SpanExporter::export_batch(batch)`:
  exports a trace batch; empty batches succeed immediately
- `LogExporter::export_batch(batch)`:
  exports a log batch; empty batches succeed immediately
- `MetricExporter::export_batch(batch)`:
  exports a metric batch using the exporter's temporality; empty batches succeed
  immediately

After shutdown, all three export methods return `AlreadyShutdown`.

The exporter validates OTLP partial-success responses and converts them into
`ExportFailure` values when the backend rejects part of a batch.

### SDK interop

- `into_span_exporter()`:
  erases the concrete span exporter into `sdk/trace.SpanExporter`
- `into_log_exporter()`:
  erases the concrete log exporter into `sdk/logs.LogExporter`
- `into_metric_exporter()`:
  erases the concrete metric exporter into `sdk/metrics.MetricExporter`
- `into_periodic_reader(interval_millis?)`:
  creates a periodic metric reader using the exporter's temporality; a negative
  interval keeps the SDK default

## Environment variables

The builder resolves configuration in this order:

1. explicit builder option
2. signal-specific environment variable
3. generic OTLP environment variable
4. hard-coded default

Currently used variables:

- generic:
  `OTEL_EXPORTER_OTLP_ENDPOINT`,
  `OTEL_EXPORTER_OTLP_HEADERS`,
  `OTEL_EXPORTER_OTLP_PROTOCOL`,
  `OTEL_EXPORTER_OTLP_TIMEOUT`,
  `OTEL_EXPORTER_OTLP_COMPRESSION`
- traces:
  `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`,
  `OTEL_EXPORTER_OTLP_TRACES_HEADERS`,
  `OTEL_EXPORTER_OTLP_TRACES_TIMEOUT`,
  `OTEL_EXPORTER_OTLP_TRACES_COMPRESSION`
- logs:
  `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`,
  `OTEL_EXPORTER_OTLP_LOGS_HEADERS`,
  `OTEL_EXPORTER_OTLP_LOGS_TIMEOUT`,
  `OTEL_EXPORTER_OTLP_LOGS_COMPRESSION`
- metrics:
  `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`,
  `OTEL_EXPORTER_OTLP_METRICS_HEADERS`,
  `OTEL_EXPORTER_OTLP_METRICS_TIMEOUT`,
  `OTEL_EXPORTER_OTLP_METRICS_COMPRESSION`,
  `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE`

The default endpoint root is `http://localhost:4318`, and the signal path is
appended automatically when only the generic endpoint is set.
