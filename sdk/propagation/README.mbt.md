# OpenTelemetry Propagation

This package contains the text-map propagators used to move trace context and
baggage across process boundaries.

## Carriers

The SDK models text carriers through two traits:

- `Injector`: write key/value pairs into an outbound carrier
- `Extractor`: read key/value pairs from an inbound carrier

`Map[String, String]` implements both traits out of the box. Keys written
through `Injector` are normalized to lowercase, and `Extractor` lookups are
case-insensitive, which makes it a convenient stand-in for HTTP headers in
tests.

## Provided propagators

- `BaggagePropagator`: reads and writes the `baggage` header
- `TraceContextPropagator`: reads and writes `traceparent` and `tracestate`
- `TextMapCompositePropagator`: chains multiple propagators in order

Extraction is intentionally forgiving: malformed headers are ignored and the
input context is returned unchanged.
