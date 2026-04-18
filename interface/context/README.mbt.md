# OpenTelemetry Context API

This package stores the cross-cutting values that instrumentation carries
between calls: the active span context, baggage, and the telemetry suppression
flag.

## Design

`Context` is immutable. Every `with_*` helper returns a new value, which makes
it safe to derive child contexts without mutating the original.

## Method behavior

- `Context::new()`:
  alias for `Context::empty()`
- `Context::empty()`:
  returns a context with no span, empty baggage, and suppression disabled
- `Context::span_context()`:
  returns the stored span context, if present
- `Context::has_active_span()`:
  returns `true` only when a valid span context is present
- `Context::with_span_context(span_context)`:
  returns a copy with a local span context attached
- `Context::with_remote_span_context(span_context)`:
  returns a copy with a remote span context attached
- `Context::baggage()`:
  returns the stored baggage value
- `Context::with_baggage(baggage)`:
  returns a copy with the given baggage
- `Context::with_baggage_item(key, value, metadata?)`:
  returns a copy with one baggage item inserted or replaced; baggage validation
  rules still apply
- `Context::is_telemetry_suppressed()`:
  returns the suppression flag
- `Context::with_telemetry_suppressed(suppressed?)`:
  returns a copy with the suppression flag updated; omitting the argument turns
  suppression on

## Local vs remote span contexts

Use `with_remote_span_context()` for span contexts extracted from inbound
headers. Use `with_span_context()` for locally created spans. Propagators rely
on that distinction.
