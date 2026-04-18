# OpenTelemetry Propagation API

This package moves trace context and baggage through text-based carriers such as
HTTP headers.

## Carrier traits

- `Injector`:
  write side of an outbound carrier
- `Extractor`:
  read side of an inbound carrier

`Map[String, String]` implements both traits. Keys are normalized to lowercase
by that implementation, which makes it convenient for HTTP-style headers.

## `TextMapPropagator`

- `TextMapPropagator::from_functions(inject, extract, fields)`:
  builds a custom propagator from three callbacks
- `inject_context(context, injector)`:
  writes propagation fields into the carrier
- `extract_with_context(context, extractor)`:
  reads from the carrier and returns an updated context
- `fields()`:
  reports the header names the propagator may touch

## `BaggagePropagator`

- `BaggagePropagator::new()`:
  reads and writes the `baggage` header
- `inject_context(context, injector)`:
  serializes baggage into the carrier
- `extract_with_context(context, extractor)`:
  parses baggage and merges it into the supplied context
- `into_text_map()`:
  erases the concrete type into `TextMapPropagator`

Malformed baggage items are ignored. Valid items still survive extraction.

## `TraceContextPropagator`

- `TraceContextPropagator::new()`:
  reads and writes `traceparent` and `tracestate`
- `inject_context(context, injector)`:
  writes the current valid span context
- `extract_with_context(context, extractor)`:
  validates the headers and, on success, returns a context with a remote span
  context attached
- `into_text_map()`:
  erases the concrete type into `TextMapPropagator`

Invalid headers are ignored and leave the input context unchanged.

## `TextMapCompositePropagator`

- `TextMapCompositePropagator::new(propagators)`:
  creates a propagator that runs multiple propagators in order
- `inject_context(context, injector)`:
  runs every child propagator
- `extract_with_context(context, extractor)`:
  threads the context through the propagators from left to right
- `into_text_map()`:
  erases the concrete type into `TextMapPropagator`

Field names are de-duplicated when `fields()` is queried on the composite.
