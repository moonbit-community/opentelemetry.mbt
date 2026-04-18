# OpenTelemetry Logs API

This package is the public logging bridge API. It wraps the logging parts of
the SDK but keeps a signal-specific surface for applications and bridges.

## Main types

- `AnyValue`: values accepted by log bodies and ad-hoc attributes
- `Severity`: the 24-slot OpenTelemetry severity ladder
- `LogRecord`: mutable record builder
- `LoggerProvider`: provider wrapper
- `Logger`: logger handle

## Value mapping

- `AnyValue::Map` is serialized to a JSON string before it is bridged into the
  SDK attribute model.
- `Severity::name()` returns the canonical uppercase severity text, such as
  `ERROR3` or `INFO`.

## `LogRecord` behavior

- `LogRecord::new()`:
  creates an empty mutable record
- `set_event_name(name)`:
  stores the event name; export turns it into `log.event_name`
- `set_target(target)`:
  stores the target; export turns it into `log.target`
- `set_timestamp(ts)`:
  sets the event timestamp in Unix nanoseconds
- `set_observed_timestamp(ts)`:
  sets the observed timestamp in Unix nanoseconds
- `set_severity_text(text)`:
  sets the exact text that should be exported
- `set_severity_number(severity)`:
  sets the structured severity
- `set_body(body)`:
  sets the log body
- `add_attribute(key, value)`:
  appends one ad-hoc attribute
- `add_attributes(attributes)`:
  appends multiple pre-built attributes
- `set_trace_context(trace_id, span_id, trace_flags?)`:
  attaches explicit trace-correlation fields; omitted flags default to zero

When a field is not set:

- body defaults to an empty string during `emit()`
- event timestamp defaults to `now`
- observed timestamp defaults to `now`
- severity text is derived from the severity number when possible

## `LoggerProvider` behavior

- `LoggerProvider::from_sdk(provider)`:
  wraps an SDK provider
- `LoggerProvider::noop()`:
  returns a provider that drops all log work
- `logger(name)`:
  returns a logger for one instrumentation name
- `logger_with_scope(scope)`:
  returns a logger for a full instrumentation scope
- `force_flush()`:
  forwards to the SDK provider; no-op providers return success
- `shutdown()`:
  forwards to the SDK provider; no-op providers return success
- `spawn_batch_processor_tasks(group, allow_failure?)`:
  starts batch processor loops when the provider owns them

## `Logger` behavior

- `create_log_record()`:
  returns a fresh mutable record
- `emit(record)`:
  converts the record into the SDK log pipeline and exports it through the
  provider's processors
- `event_enabled(severity, target, name?)`:
  currently only reports whether a real SDK logger exists; it does not apply
  severity-specific filtering yet

No-op loggers silently drop emitted records.
