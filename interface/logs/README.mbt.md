# OpenTelemetry Logs API

This package is the public logs bridge API. It represents log events in the
OpenTelemetry log data model and forwards them to an SDK logger when one is
installed.

You can use it directly, but its main role is to let logging libraries or
application logging adapters translate existing log events into OpenTelemetry
records. Traces, metrics, and logs can then share resource attributes,
instrumentation scope, and trace correlation fields.

## Main Types

- `AnyValue`: structured log body and attribute value
- `Severity`: OpenTelemetry severity ladder
- `LogRecord`: mutable builder for one log event
- `LoggerProvider`: entry point that creates loggers
- `Logger`: emits records for one instrumentation scope

## Creating A Record

```mbt check
///|
async fn _logs_readme_emit() -> Unit {
  let logger = LoggerProvider::noop().logger("example")
  if logger.event_enabled(Severity::Info, "example") {
    let record = logger.create_log_record()
    record.set_event_name("user.created")
    record.set_target("example")
    record.set_severity_number(Severity::Info)
    record.set_body(AnyValue::String("created user"))
    record.add_attribute("user.plan", AnyValue::String("free"))
    logger.emit(record)
  }
}
```

Use `event_enabled()` as a guard before building expensive records. The current
implementation only checks whether the logger has a real SDK backend; it does
not yet apply severity, target, or event-name filtering.

## Value Mapping

`AnyValue` supports scalar and structured values:

- `Int`, `Double`, `String`, `Boolean`, and `Bytes`
- `ListAny` for arrays
- `Map` for structured objects

Structured values remain structured when converted into the SDK and OTLP data
model. Use simple scalar attributes for common search fields and structured
bodies for payloads that should remain grouped.

## Severity

`Severity` follows the OpenTelemetry 24-slot severity ladder:

- `Trace` through `Trace4`
- `Debug` through `Debug4`
- `Info` through `Info4`
- `Warn` through `Warn4`
- `Error` through `Error4`
- `Fatal` through `Fatal4`

`Severity::name()` returns the canonical uppercase text, such as `INFO`,
`WARN3`, or `ERROR`.

## Trace Correlation

Logs can be correlated with traces by adding trace context to the record:

```mbt check
///|
fn _logs_readme_trace_context(
  record : LogRecord,
  trace_id : @common.TraceId,
  span_id : @common.SpanId,
) -> Unit {
  record.set_trace_context(trace_id, span_id)
}
```

When using trace APIs directly, prefer passing the current span context from the
active `Context` or `Span` so logs and spans share the same trace identifiers.

## Record Reference

- `LogRecord::new()` creates an empty mutable record.
- `set_event_name(name)` stores the OTLP `event_name` field.
- `set_target(target)` stores the target used for export-time scope grouping.
- `set_timestamp(ts)` sets event time in Unix nanoseconds.
- `set_observed_timestamp(ts)` sets observed time in Unix nanoseconds.
- `set_severity_text(text)` sets exact exported severity text.
- `set_severity_number(severity)` sets structured severity.
- `set_body(body)` sets the log body.
- `add_attribute(key, value)` appends one ad-hoc structured attribute.
- `add_attributes(attributes)` appends shared `KeyValue` attributes.
- `set_trace_context(trace_id, span_id, trace_flags?)` attaches explicit trace
  correlation fields; omitted flags default to zero.

When a field is omitted, `emit()` fills defaults:

- body becomes an empty string
- event timestamp becomes current time
- observed timestamp becomes current time
- severity text is derived from severity number when possible

## Provider And Logger Reference

- `LoggerProvider::noop()` drops all emitted records.
- `logger(name)` creates a logger for one instrumentation name.
- `logger_with_scope(scope)` creates a logger from a full instrumentation scope.
- `Logger::create_log_record()` creates a fresh mutable record.
- `Logger::emit(record)` forwards the record to the installed logger.
- `Logger::event_enabled(severity, target, name?)` is the pre-construction guard
  for potentially expensive log records.

Applications register SDK providers through `sdk.set_logger_provider(provider)`;
the SDK facade updates `interface/global` for API callers.

## No-Op Behavior

No-op loggers silently drop emitted records. Creating and populating a
`LogRecord` still has normal application cost, so use `event_enabled()` around
expensive message formatting or payload construction.
