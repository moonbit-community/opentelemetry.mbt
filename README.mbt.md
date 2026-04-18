# OpenTelemetry for MoonBit

This repository is the MoonBit implementation of OpenTelemetry. It follows the
same broad split as `opentelemetry-rust`:

- public API packages for instrumentation
- SDK packages for providers, processors, readers, and resources
- exporters for stdout and OTLP
- semantic-convention constants
- generated OTLP protocol models

## Which package should I import?

| Package | Use it for |
| --- | --- |
| `moonbit-community/opentelemetry` | The smallest public entry point. Good for libraries that only need `tracer()`, `meter()`, `logger()`, baggage, and context types. |
| `moonbit-community/opentelemetry/interface/*` | Signal-specific public APIs when you want direct access to traces, logs, metrics, propagation, or baggage behavior. |
| `moonbit-community/opentelemetry/sdk` | Application-side setup. Build providers, readers, processors, resources, and exporters here. |
| `moonbit-community/opentelemetry/sdk/global` | Process-wide registration of tracer/logger/meter providers and the text-map propagator. |
| `moonbit-community/opentelemetry/print` | Human-readable stdout exporters for local development and debugging. |
| `moonbit-community/opentelemetry/otlp` | OTLP HTTP exporters for traces, logs, and metrics. |
| `moonbit-community/opentelemetry/semantics/*` | Semantic-convention constants for attributes and metric names. |
| `moonbit-community/opentelemetry/protocol/*` | Low-level generated OTLP protobuf/JSON model types. Import these only when you need raw protocol payloads. |

## Typical startup flow

Applications normally follow this order:

1. Build one provider per signal in `sdk/trace`, `sdk/logs`, or `sdk/metrics`.
2. Optionally register those providers into `sdk/global`.
3. Spawn background tasks when you use batch span/log processors or periodic
   metric readers.
4. Obtain tracers, loggers, and meters from the root package or the
   `interface/*` packages.
5. Flush and shut down providers during application teardown.

Two important defaults:

- Global providers start as no-op providers.
- The default global text-map propagator is a composite of W3C trace-context
  and baggage propagation.

## Minimal tracing example

```moonbit nocheck
import {
  "moonbit-community/opentelemetry" @otel,
  "moonbit-community/opentelemetry/print" @print,
  "moonbit-community/opentelemetry/sdk" @sdk,
  "moonbit-community/opentelemetry/sdk/global" @sdkglobal,
}

async fn main {
  let exporter = @print.SpanExporter::new()
  let provider = @sdk.tracer_provider_builder()
    .with_simple_exporter(exporter.into_span_exporter())
    .build()

  @sdkglobal.set_tracer_provider(provider)

  let tracer = @otel.tracer("example-service", version=Some("1.0.0"))
  let span = tracer.start("startup")
  span.set_attribute(@sdk.KeyValue::new("component", @sdk.Value::String("cli")))
  span.end()

  ignore(provider.shutdown())
}
```

## Background work matters

Simple processors export immediately. Batch processors and periodic readers do
not start themselves.

Use `spawn_background_tasks()` when you configure:

- `sdk/trace.BatchSpanProcessor`
- `sdk/logs.BatchLogProcessor`
- `sdk/metrics.PeriodicMetricReader`

Example shape:

```moonbit nocheck
@async.with_task_group(group => {
  @sdkglobal.spawn_background_tasks(group)
  // application work
  ignore(@sdkglobal.shutdown())
})
```

## Signal-specific notes

### Traces

- `Tracer::start()` creates a span immediately.
- `Tracer::build()` lets you preconfigure span kind, start time, events, links,
  and attributes.
- `Span::record_error()` only adds an exception event. It does not set span
  status automatically.

### Logs

- `Logger::create_log_record()` returns a mutable record builder.
- `Logger::emit()` fills in missing timestamps with `now`.
- `event_name` and `target` are exported as synthetic attributes:
  `log.event_name` and `log.target`.

### Metrics

- Counters are monotonic. Negative counter deltas are ignored by the SDK.
- Observable callbacks run during collection, not at instrument creation time.
- Integer gauges and some integer observable instruments are bridged through the
  SDK's floating-point representation where noted in the package docs.

## Exporter choices

### `print`

Use `print` when you want readable local output. It is best for tests,
examples, and debugging.

### `otlp`

Use `otlp` when you want to send telemetry to an OpenTelemetry Collector or
another OTLP HTTP endpoint. The current implementation supports:

- `http/protobuf`
- `http/json`

`grpc` is exposed in the API for parity with upstream shapes, but exporter
construction rejects it today.

Compression flags are also exposed for parity, but they are not implemented
yet. Setting compression currently produces a build error.

## Semantic conventions

The semantic-convention packages are generated from upstream OpenTelemetry
semantic-convention data. Use them to avoid hard-coding attribute keys and
metric names:

```moonbit nocheck
import {
  "moonbit-community/opentelemetry/sdk" @sdk,
  "moonbit-community/opentelemetry/semantics/trace" @semtrace,
}

let attrs = [
  @sdk.KeyValue::new(
    @semtrace.HTTP_REQUEST_METHOD,
    @sdk.Value::String("GET"),
  ),
]
```

## Where to read next

- [`sdk/README.mbt.md`](sdk/README.mbt.md): application-side SDK entry point
- [`interface/trace/README.mbt.md`](interface/trace/README.mbt.md): trace API
- [`interface/logs/README.mbt.md`](interface/logs/README.mbt.md): log API
- [`interface/metrics/README.mbt.md`](interface/metrics/README.mbt.md): metric API
- [`interface/propagation/README.mbt.md`](interface/propagation/README.mbt.md): propagation API
- [`otlp/README.mbt.md`](otlp/README.mbt.md): OTLP exporter behavior
- [`print/README.mbt.md`](print/README.mbt.md): stdout exporter behavior
