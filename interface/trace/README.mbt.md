# OpenTelemetry Trace API

This package is the public trace API surface. It wraps the SDK tracer provider
and span types while keeping the user-facing trace operations in one place.

## Main types

- `TracerProvider`, `Tracer`, `Span`
- `SpanBuilder`
- `Event`, `Link`
- aliases for `SpanKind`, `Status`, and `StatusCode`

## Builder objects

- `Event::new(name, timestamp?, attributes?, dropped_attributes_count?)`:
  creates one event; the timestamp defaults to `now`
- `Link::new(span_context, attributes?, dropped_attributes_count?)`:
  creates one link; invalid linked span contexts are ignored later when the
  span is built
- `SpanBuilder::from_name(name)`:
  starts building a span
- `SpanBuilder::with_kind(kind)`:
  sets the span kind
- `SpanBuilder::with_start_time(ts)`:
  sets the start timestamp
- `SpanBuilder::with_attributes(attributes)`:
  replaces the builder attribute list
- `SpanBuilder::with_events(events)`:
  replaces the builder event list
- `SpanBuilder::with_links(links)`:
  replaces the builder link list

## `TracerProvider` behavior

- `TracerProvider::from_sdk(provider)`:
  wraps an SDK provider
- `TracerProvider::noop()`:
  returns a provider that creates non-recording spans
- `tracer(name)`:
  returns a tracer for one instrumentation name
- `tracer_with_scope(scope)`:
  returns a tracer for a full instrumentation scope
- `force_flush()`:
  forwards to the SDK provider; no-op providers return success
- `shutdown()`:
  forwards to the SDK provider; no-op providers return success
- `spawn_batch_processor_tasks(group, allow_failure?)`:
  starts batch span processor loops owned by the provider

## `Tracer` behavior

- `start(name)`:
  starts a root span
- `start_with_context(name, parent_context)`:
  starts a span with an explicit parent context
- `span_builder(name)`:
  returns a fresh builder
- `build(builder)`:
  builds a span using an empty parent context
- `build_with_context(builder, parent_context)`:
  builds a span with an explicit parent context
- `in_span(name, f)`:
  runs `f` inside a root span and ends the span after `f` returns successfully
- `in_span_with_context(name, parent_context, f)`:
  same as above, but with an explicit parent context
- `in_span_with_builder(builder, parent_context, f)`:
  same as above, but with an explicit builder

## `Span` behavior

- `span_context()`:
  returns the span context that should be propagated
- `context()`:
  returns a context that carries this span as the active span
- `is_recording()`:
  reports whether the span records telemetry
- `has_ended()`:
  reports whether the span has ended
- `add_event(name, attributes?)`:
  adds an event with the current timestamp
- `add_event_with_timestamp(name, ts, attributes?)`:
  adds an event with an explicit timestamp
- `record_error(message)`:
  adds an `exception` event with `exception.message`; it does not set span
  status automatically
- `set_attribute(attribute)`:
  sets or replaces one attribute
- `set_attributes(attributes)`:
  sets or replaces multiple attributes
- `set_status(status)`:
  updates the span status
- `update_name(new_name)`:
  replaces the span name
- `add_link(span_context, attributes?)`:
  adds one link
- `end()`:
  ends the span with the current timestamp
- `end_with_timestamp(ts)`:
  ends the span with an explicit timestamp

## No-op behavior

No-op tracers still return spans so that parent/child context propagation keeps
working. Those spans do not record telemetry, and most mutating methods become
no-ops.
