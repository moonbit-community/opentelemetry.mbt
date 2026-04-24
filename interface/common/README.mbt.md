# OpenTelemetry Common API Types

This package contains data structures shared by traces, logs, metrics, resource
detection, and propagation.

## Main groups

- Attributes: `Key`, `Value`, `KeyValue`
- Trace identity: `TraceId`, `SpanId`, `TraceFlags`, `TraceState`,
  `SpanContext`
- Instrumentation metadata: `InstrumentationScope`
Host runtime helpers live in `internal/utils`; they are intentionally not part
of this public common package.

## Design notes

- `TraceId` and `SpanId` validate byte width on construction.
- `TraceFlags` keeps only the low 8 bits, matching the W3C `traceparent`
  representation.
- `TraceState` stores entries in a map and can serialize to and from the HTTP
  `tracestate` header shape.
- `InstrumentationScope` records the library name, version, schema URL, and
  scope attributes attached to emitted telemetry.
