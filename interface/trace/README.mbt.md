# OpenTelemetry Trace API

This package is the public trace API. It gives instrumentation code the types
needed to describe work as spans without forcing a concrete SDK or exporter on
the final application.

A trace is a tree of spans. A span represents one operation: a request handler,
database query, cache lookup, queue publish, background job, or any other unit
of work worth timing and correlating. Spans carry attributes, events, links,
status, and a span context that can be propagated to downstream services.

## Main Types

- `TracerProvider`: entry point that creates tracers
- `Tracer`: creates spans for one instrumentation scope
- `Span`: mutable handle for one in-flight operation
- `SpanBuilder`: immutable descriptor for creating a span with kind, start
  time, attributes, events, and links
- `Event`: named timestamped occurrence during a span
- `Link`: relationship to another span context, often from queues or fan-in
  workflows
- `SpanKind`, `Status`, `StatusCode`: aliases for SDK-compatible trace
  metadata

## Getting A Tracer

Library code usually gets a tracer from the root package or `interface/global`.
Use a stable instrumentation name, typically the library or component name.

```mbt check
///|
fn _trace_readme_get_tracer() -> Tracer {
  TracerProvider::noop().tracer("moonbit-community/example-library")
}
```

Applications can wrap an SDK provider with `TracerProvider::from_sdk(provider)`
and register it through `interface/global`.

## Creating Spans

Use `start(name)` for a simple root span, `start_with_context(name, context)`
when you already have an inbound parent context, or `build_with_context()` when
you need to set span kind, explicit start time, initial attributes, events, or
links before the span starts.

```mbt check
///|
async fn _trace_readme_span_lifecycle() -> Unit {
  let tracer = TracerProvider::noop().tracer("example")
  let builder = tracer
    .span_builder("http.request")
    .with_kind(SpanKind::Server)
    .with_attributes([
      @common.KeyValue::new("http.request.method", @common.Value::String("GET")),
    ])
  let span = tracer.build(builder)

  span.add_event("handler.start")
  span.set_status(Status::ok())
  span.end()
}
```

Always end spans you start. `end()` is async because real SDK processors may
export, queue, or flush data.

## Parent Context And Propagation

`Span::context()` returns a `Context` carrying the span context as the active
local span. Pass this context to child operations and to propagators for
outgoing requests.

No-op spans still preserve an incoming valid parent span context. This allows
libraries to propagate trace identity even when the final application has not
enabled recording.

## Events, Attributes, Links, And Status

- Attributes describe span dimensions such as route, peer, queue, or database
  system. Prefer low-cardinality values.
- Events describe point-in-time facts inside a span, such as retries or
  exceptions.
- Links connect a span to another span context without making it the parent.
  They are useful for batch processing, queues, or fan-in/fan-out workflows.
- Status communicates final outcome. `record_error(message)` adds an
  `exception` event but intentionally does not set error status for you.

## Builder Reference

- `Event::new(name, timestamp?, attributes?, dropped_attributes_count?)` creates
  one event. The timestamp defaults to current Unix time in nanoseconds.
- `Link::new(span_context, attributes?, dropped_attributes_count?)` creates one
  link. Invalid linked span contexts are ignored when a span is built.
- `SpanBuilder::from_name(name)` starts a builder.
- `with_kind(kind)` sets client/server/producer/consumer/internal kind.
- `with_start_time(ts)` sets an explicit start timestamp.
- `with_attributes(attributes)` replaces initial attributes.
- `with_events(events)` replaces initial events.
- `with_links(links)` replaces initial links.

## Provider Reference

- `TracerProvider::from_sdk(provider)` wraps an SDK trace provider.
- `TracerProvider::noop()` creates non-recording spans.
- `tracer(name)` creates a tracer for one instrumentation name.
- `tracer_with_scope(scope)` creates a tracer from a full instrumentation scope.
- `force_flush()` and `shutdown()` forward to the SDK provider; no-op providers
  report success.
- `spawn_batch_processor_tasks(group, allow_failure?)` starts batch span
  processor loops owned by the provider.

## Span Reference

- `span_context()` returns the context that should be propagated downstream.
- `context()` returns a `Context` carrying this span context.
- `is_recording()` reports whether mutations are being recorded.
- `has_ended()` reports whether the span has ended.
- `add_event(name, attributes?)` and `add_event_with_timestamp(name, ts,
  attributes?)` add events.
- `set_attribute(attribute)` and `set_attributes(attributes)` update
  attributes.
- `set_status(status)`, `update_name(new_name)`, and `add_link(span_context,
  attributes?)` mutate span metadata.
- `end()` and `end_with_timestamp(ts)` finish the span.

## No-Op Behavior

When backed by `TracerProvider::noop()`, spans are non-recording:

- `is_recording()` is false
- mutating methods do not export or store telemetry
- a valid incoming parent span context is still propagated
- ending the span only marks the local no-op handle as ended

This makes unconditional library instrumentation safe, while keeping the final
application in control of whether telemetry is collected.
