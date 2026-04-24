# OpenTelemetry SDK

This package is the MoonBit SDK facade. It re-exports the implementation layer
from `interface/common`, `interface/context`, `interface/propagation`,
`sdk/resource`, `sdk/trace`, `sdk/logs`, and `sdk/metrics` so application code
can configure telemetry through one import path.

The API layer answers "where should instrumentation write data?". The SDK layer
answers "what should happen to that data?". Applications own the SDK layer:
samplers, processors, metric readers, exporters, resources, batching, flushing,
and shutdown.

## When To Import This Package

Import `moonbit-community/opentelemetry/sdk` in applications, test harnesses,
and integration packages that configure telemetry. Library instrumentation
should normally import the root package or `interface/*` instead, so the final
application remains free to choose whether telemetry is enabled.

## Provider Lifecycle

The lifecycle is the same for all signals:

1. Build a provider with the signal-specific builder.
2. Attach exporters, processors, readers, resources, samplers, or views.
3. Register the provider with `sdk.set_*_provider()` if application code uses
   global lookup.
4. Spawn background tasks for batch processors and periodic metric readers.
5. Force flush and shut down providers during teardown.

The SDK does not automatically start background export loops. Call
`spawn_background_tasks(group)` after global provider registration when using:

- `BatchSpanProcessor`
- `BatchLogProcessor`
- `PeriodicMetricReader`

## Minimal Trace Setup

```mbt check
///|
async fn _sdk_readme_trace_setup() -> Unit {
  let exporter = InMemorySpanExporter::new()
  let provider = tracer_provider_builder()
    .with_simple_exporter(exporter.into_span_exporter())
    .build()

  let tracer = provider.tracer("sdk-readme")
  let span = tracer.start("startup")
  span.end()

  ignore(provider.shutdown())
}
```

To make root-package calls such as `@otel.tracer()` use this provider, register
it with `set_tracer_provider(provider)`. The SDK facade updates both SDK global
state and the public API global state.

## Traces

Trace providers own:

- `Config`: sampler, ID generator, span limits, and resource
- `SpanProcessor` pipeline: `on_start`, `on_end`, `force_flush`, and `shutdown`
- `SimpleSpanProcessor`: exports each ended span immediately
- `BatchSpanProcessor`: queues ended spans and exports batches from a background
  loop
- `SpanExporter`: destination-agnostic exporter callback wrapper

Sampling happens when a span starts. `Sampler::always_off()` still creates a
span context for propagation, but the span is not recording and processors do
not receive start/end callbacks.

Use simple processors for examples and tests. Use batch processors for
production-style network exporters because they reduce request-path export
costs.

## Metrics

Metric providers own:

- synchronous instruments that update in-memory aggregation state
- observable instruments whose callbacks run during collection
- `ManualReader` for pull-style collection in tests or integrations
- `PeriodicMetricReader` for scheduled background exports
- `MetricExporter` for exporting collected `MetricData`
- views that can rename streams, choose aggregation, filter attributes, and
  set cardinality limits

Metric instruments should be created once and reused. Creating instruments
inside hot paths registers extra collectors and increases memory use.

## Logs

Log providers own a processor pipeline similar to tracing:

- `SimpleLogProcessor`: exports each log record immediately
- `BatchLogProcessor`: queues log records and exports batches from a background
  loop
- `LogExporter`: destination-agnostic exporter callback wrapper

The public logs package provides mutable `LogRecord` builders. The SDK stores
immutable log snapshots that include resource and instrumentation scope before
processors receive them.

## Resources

`Resource` describes the entity producing telemetry. Typical attributes include
service name, service version, deployment environment, host, process, or cloud
metadata. Resource attributes are attached to exported spans, logs, and metrics.

The default resource builder reads:

- `OTEL_SERVICE_NAME`
- `OTEL_RESOURCE_ATTRIBUTES`

Prefer setting `service.name` explicitly for applications so downstream tools
can group telemetry correctly.

## Global SDK Helpers

`sdk/global` keeps process-wide SDK providers and a text-map propagator. The
facade helpers in this package delegate to `sdk/global`:

- `tracer_provider_builder()`, `logger_provider_builder()`,
  `meter_provider_builder()`
- `tracer(name, version?, schema_url?, attributes?)`
- `logger(name, version?, schema_url?, attributes?)`
- `meter(name, version?, schema_url?, attributes?)`
- `spawn_background_tasks(group, allow_failure?)`

Important distinction: root-package instrumentation uses `interface/global`,
while `sdk.tracer()`, `sdk.logger()`, and `sdk.meter()` use `sdk/global`.
Applications that want library instrumentation to light up should register SDK
providers through `interface/global`.

## Environment Variables

Programmatic builder methods take precedence over environment defaults whenever
both are present.

| Area | Variable | Meaning | Default |
| --- | --- | --- | --- |
| Resource | `OTEL_SERVICE_NAME` | Sets `service.name`; takes priority over `service.name` in `OTEL_RESOURCE_ATTRIBUTES`. | implementation default |
| Resource | `OTEL_RESOURCE_ATTRIBUTES` | Comma-separated `key=value` resource attributes. | none |
| Trace sampling | `OTEL_TRACES_SAMPLER` | `always_on`, `always_off`, `traceidratio`, `parentbased_always_on`, `parentbased_always_off`, or `parentbased_traceidratio`. | `parentbased_always_on` |
| Trace sampling | `OTEL_TRACES_SAMPLER_ARG` | Ratio for ratio-based samplers. | `1.0` |
| Trace limits | `OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT` | Max attributes per span. | `128` |
| Trace limits | `OTEL_SPAN_EVENT_COUNT_LIMIT` | Max events per span. | `128` |
| Trace limits | `OTEL_SPAN_LINK_COUNT_LIMIT` | Max links per span. | `128` |
| Batch spans | `OTEL_BSP_SCHEDULE_DELAY` | Delay between scheduled batch exports, in milliseconds. | `5000` |
| Batch spans | `OTEL_BSP_MAX_QUEUE_SIZE` | Max queued ended spans. | `2048` |
| Batch spans | `OTEL_BSP_MAX_EXPORT_BATCH_SIZE` | Max spans per export batch, capped by queue size. | `512` |
| Batch spans | `OTEL_BSP_EXPORT_TIMEOUT` | Export timeout budget in milliseconds. | `30000` |
| Batch logs | `OTEL_BLRP_SCHEDULE_DELAY` | Delay between scheduled log exports, in milliseconds. | `1000` |
| Batch logs | `OTEL_BLRP_MAX_QUEUE_SIZE` | Max queued log records. | `2048` |
| Batch logs | `OTEL_BLRP_MAX_EXPORT_BATCH_SIZE` | Max log records per export batch, capped by queue size. | `512` |
| Batch logs | `OTEL_BLRP_EXPORT_TIMEOUT` | Export timeout budget in milliseconds. | `30000` |
| Metrics | `OTEL_METRIC_EXPORT_INTERVAL` | Periodic metric export interval, in milliseconds. | `60000` |

OTLP exporter variables are documented in [`../otlp/README.mbt.md`](../otlp/README.mbt.md).

## Shutdown Rules

- Call `force_flush()` when you need a best-effort export before a known
  boundary.
- Call `shutdown()` exactly once for providers you own during application exit.
- After shutdown, providers reject or ignore later telemetry work depending on
  signal-specific behavior.
- Batch processors and periodic readers need background tasks to export before
  shutdown; without those tasks, data may only be exported by explicit flush or
  shutdown.
