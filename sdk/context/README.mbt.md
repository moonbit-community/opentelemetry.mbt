# SDK Context

This package models the OpenTelemetry context values needed by the MoonBit SDK.

## Stored state

- Active `SpanContext`
- `Baggage`
- Telemetry suppression flag

## Semantics

`Context` is immutable. The `with_*` helpers always return a new value, so the
same context can be safely reused when deriving child contexts.

`with_span_context()` marks the stored span context as local, while
`with_remote_span_context()` preserves the same identifiers but marks the
context as remote. Propagators use the remote form after extracting headers
from an inbound carrier.

The suppression flag is respected by signal implementations that need to avoid
re-entering telemetry pipelines during export or internal work.
