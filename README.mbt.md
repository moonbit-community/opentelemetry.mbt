# OpenTelemetry for MoonBit

MoonBit implementation of [OpenTelemetry](https://opentelemetry.io/): APIs for
instrumenting libraries and applications, SDK providers for processing telemetry,
and exporters for getting telemetry out of the process.

OpenTelemetry is not a tracing UI, metrics database, or log backend. It is the
standard instrumentation and transport layer that lets your code produce
portable telemetry data, then send it to tools such as the OpenTelemetry
Collector, Jaeger, Prometheus, or a vendor backend.

This repository contains:

- public API packages for traces, metrics, logs, context, baggage, and
  propagation
- SDK packages for providers, processors, readers, samplers, resources, and
  in-memory test exporters
- `print` exporters for local learning and debugging
- OTLP HTTP exporters for production-oriented export through the OpenTelemetry
  Protocol
- semantic-convention constants and generated OTLP protocol model types

## Mental Model

OpenTelemetry has two layers:

- **API layer**: what libraries should depend on. It provides stable
  instrumentation types such as `Tracer`, `Meter`, `Logger`, `Context`, and
  `KeyValue`. If an application does not install an SDK provider, the API layer
  is no-op by default.
- **SDK layer**: what applications configure. It owns resources, samplers,
  processors, readers, exporters, batching, flushing, and shutdown.

Library authors should usually import `moonbit-community/opentelemetry` or
`moonbit-community/opentelemetry/interface/*`. Application authors add
`moonbit-community/opentelemetry/sdk`, `print`, or `otlp` to make the
instrumentation do real work.

## Package Guide

| Package | Use it for |
| --- | --- |
| `moonbit-community/opentelemetry` | Small public entry point for library instrumentation: `tracer()`, `meter()`, `logger()`, attributes, baggage, and context aliases. |
| `moonbit-community/opentelemetry/interface/trace` | Trace API: spans, span builders, events, links, status, and no-op trace behavior. |
| `moonbit-community/opentelemetry/interface/metrics` | Metrics API: meters, counters, up-down counters, histograms, gauges, and observable instruments. |
| `moonbit-community/opentelemetry/interface/logs` | Log bridge API: structured log records that can be correlated with traces. |
| `moonbit-community/opentelemetry/interface/context` | Immutable context container used to carry span context, baggage, and telemetry suppression. |
| `moonbit-community/opentelemetry/interface/propagation` | W3C trace-context and baggage propagation through text carriers such as HTTP headers. |
| `moonbit-community/opentelemetry/interface/global` | Process-wide API providers. Libraries normally read from here indirectly through the root package. |
| `moonbit-community/opentelemetry/sdk` | Application-side SDK facade for providers, processors, readers, resources, samplers, and global SDK helpers. |
| `moonbit-community/opentelemetry/sdk/global` | Process-wide SDK providers used by the SDK facade. Prefer `interface/global` when wiring the public root package. |
| `moonbit-community/opentelemetry/print` | Human-readable stdout exporters for examples, local debugging, and tests. |
| `moonbit-community/opentelemetry/otlp` | OTLP HTTP exporters for traces, logs, and metrics. |
| `moonbit-community/opentelemetry/semantics/*` | Generated semantic-convention constants for standard attribute and metric names. |
| `moonbit-community/opentelemetry/protocol/*` | Low-level generated OTLP protobuf/JSON models. Most users do not need these directly. |

## Quick Start: Trace To Stdout

The shortest useful setup is: build an SDK provider, register it as the global
API provider, get a tracer, create spans, and shut the provider down.

```mbt check
///|
async fn _readme_trace_to_stdout() -> Unit {
  let exporter = @print.SpanExporter::new()
  let provider = @sdk.tracer_provider_builder()
    .with_simple_exporter(exporter.into_span_exporter())
    .build()

  @global.set_tracer_provider(@trace.TracerProvider::from_sdk(provider))

  let tracer = tracer("checkout-service", version=Some("1.0.0"))
  let span = tracer.start("charge-card")
  span.set_attribute(KeyValue::new("payment.system", Value::String("test")))
  span.set_status(@trace.Status::ok())
  span.end()

  ignore(provider.shutdown())
}
```

`Span::end()` is async because processors and exporters may do I/O. In examples
using a simple stdout exporter it returns quickly, but production exporters
should still be flushed or shut down before process exit.

## Instrumenting Libraries

Libraries should depend on the API layer and avoid choosing exporters or SDK
configuration for their users. The final application decides whether telemetry
is enabled.

```mbt check
///|
pub async fn _library_operation() -> Unit {
  let tracer = tracer(
    "moonbit-community/example-library",
    version=Some("0.1.0"),
  )
  let span = tracer.start("example.operation")
  span.set_attribute(KeyValue::new("example.kind", Value::String("demo")))
  // Library work goes here.
  span.end()
}
```

If no application registers a provider, the global API providers are no-op.
Spans, instruments, and loggers still exist so code can remain unconditional,
but they do not record or export telemetry. This is intentionally a low-overhead
runtime no-op, not a compile-time removal of all instrumentation code.

## Application Setup

Applications configure one provider per signal:

1. Build a trace, log, or metric provider in `sdk/*`.
2. Register it into `interface/global` if code uses the root
   `moonbit-community/opentelemetry` package.
3. Spawn background tasks when using batch span/log processors or periodic
   metric readers.
4. Flush and shut down providers during application teardown.

Simple processors export immediately when spans/logs end. Batch processors and
periodic metric readers require background tasks:

```mbt check
///|
async fn _spawn_background_tasks_shape() -> Unit {
  @async.with_task_group(group => @sdk.spawn_background_tasks(group))
}
```

## Metrics

Metrics record measurements and aggregate them in memory until a reader collects
them. Reuse instruments instead of creating them on every request.

Choose instruments by meaning:

- `Counter`: monotonic value that only increases, such as requests served or
  bytes sent
- `UpDownCounter`: value that can increase or decrease, such as active sessions
  or queue depth
- `Histogram`: distribution of measurements, such as latency or payload size
- `Gauge`: latest value for state that can move up or down, such as temperature
  or memory usage
- observable instruments: callbacks for values already owned by another system

```mbt check
///|
fn _record_request_metrics() -> Unit {
  let meter = meter("checkout-service")
  let request_count = meter.u64_counter("http.server.request.count").build()
  let request_latency = meter
    .f64_histogram("http.server.duration")
    .with_unit("ms")
    .build()

  request_count.add(1UL, attributes=[
    KeyValue::new("http.request.method", Value::String("POST")),
  ])
  request_latency.record(32.5, attributes=[
    KeyValue::new("http.route", Value::String("/checkout")),
  ])
}
```

## Logs

The logging API is a bridge into the OpenTelemetry log data model. Existing
application logging can keep its own frontend; bridge code can translate log
events into `LogRecord` values.

```mbt check
///|
async fn _emit_structured_log() -> Unit {
  let logger = logger("checkout-service")
  if logger.event_enabled(@logs.Severity::Info, "checkout") {
    let record = logger.create_log_record()
    record.set_event_name("checkout.completed")
    record.set_target("checkout")
    record.set_severity_number(@logs.Severity::Info)
    record.set_body(@logs.AnyValue::String("checkout completed"))
    record.add_attribute("cart.items", @logs.AnyValue::Int(3L))
    logger.emit(record)
  }
}
```

`event_enabled()` is the cheap guard to check before building expensive log
records. It currently reports whether a real SDK logger exists; future versions
may add severity or target filtering.

## Propagation

Propagation carries trace context and baggage across process boundaries. For
HTTP-like transports, inject the current context into outgoing headers and
extract it from incoming headers.

```mbt check
///|
fn _inject_headers(context : Context) -> Map[String, String] {
  let headers = {}
  get_text_map_propagator(propagator => {
    propagator.inject_context(context, headers)
  })
  headers
}
```

The default global propagator is a composite of W3C trace context and W3C
baggage.

## OTLP Export

Use `print` while learning. Use `otlp` when sending telemetry to the
OpenTelemetry Collector or an OTLP-compatible backend.

Typical local Collector command:

```bash
docker run --rm -p 4318:4318 otel/opentelemetry-collector:latest
```

The MoonBit OTLP exporter currently supports HTTP/protobuf and HTTP/JSON. gRPC
and compression options are exposed for shape compatibility but rejected during
exporter construction when unsupported. See [`otlp/README.mbt.md`](otlp/README.mbt.md)
for endpoint, protocol, header, timeout, and signal-specific environment
variables.

## Environment Variables

Programmatic builder configuration takes precedence over environment defaults
where both are available.

| Area | Variables |
| --- | --- |
| Resource | `OTEL_SERVICE_NAME`, `OTEL_RESOURCE_ATTRIBUTES` |
| Trace sampling | `OTEL_TRACES_SAMPLER`, `OTEL_TRACES_SAMPLER_ARG` |
| Trace limits | `OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT`, `OTEL_SPAN_EVENT_COUNT_LIMIT`, `OTEL_SPAN_LINK_COUNT_LIMIT` |
| Batch spans | `OTEL_BSP_SCHEDULE_DELAY`, `OTEL_BSP_MAX_QUEUE_SIZE`, `OTEL_BSP_MAX_EXPORT_BATCH_SIZE`, `OTEL_BSP_EXPORT_TIMEOUT` |
| Batch logs | `OTEL_BLRP_SCHEDULE_DELAY`, `OTEL_BLRP_MAX_QUEUE_SIZE`, `OTEL_BLRP_MAX_EXPORT_BATCH_SIZE`, `OTEL_BLRP_EXPORT_TIMEOUT` |
| Periodic metrics | `OTEL_METRIC_EXPORT_INTERVAL` |
| OTLP exporter | `OTEL_EXPORTER_OTLP_*` plus signal-specific `TRACES`, `METRICS`, and `LOGS` variants |

## Practical Guidance

- Use instrumentation names that identify the library or component, for example
  `moonbit-community/http-client`.
- Prefer semantic-convention constants from `semantics/*` instead of hard-coded
  keys when a standard key exists.
- Add low-cardinality attributes by default. Avoid user IDs, raw URLs, or
  unbounded strings as metric attributes.
- Create metric instruments once and reuse them.
- Always call `shutdown()` on providers you own so buffered telemetry is flushed.
- Library code should not import `sdk` or exporters unless it is explicitly an
  integration package.

```mbt check
///|
fn _semantic_convention_attribute() -> Array[KeyValue] {
  [KeyValue::new(@semtrace.HTTP_REQUEST_METHOD, Value::String("GET"))]
}
```

## Read Next

- [`interface/trace/README.mbt.md`](interface/trace/README.mbt.md): spans,
  parent context, events, links, status, and no-op trace behavior
- [`interface/metrics/README.mbt.md`](interface/metrics/README.mbt.md): choosing
  instruments and recording measurements
- [`interface/logs/README.mbt.md`](interface/logs/README.mbt.md): structured log
  records and log bridge behavior
- [`interface/propagation/README.mbt.md`](interface/propagation/README.mbt.md):
  W3C trace context and baggage propagation
- [`sdk/README.mbt.md`](sdk/README.mbt.md): provider configuration, processors,
  readers, environment variables, and lifecycle
- [`otlp/README.mbt.md`](otlp/README.mbt.md): OTLP exporter behavior
- [`print/README.mbt.md`](print/README.mbt.md): stdout exporter behavior

## Integration Tests

Collector-backed OTLP integration tests live in [`integration/otlp/README.md`](integration/otlp/README.md)
and run through the helper scripts
`integration/otlp/scripts/test_with_docker.mjs` or
`integration/otlp/scripts/test_with_binary.mjs`.
