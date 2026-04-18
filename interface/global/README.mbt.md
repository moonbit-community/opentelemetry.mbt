# OpenTelemetry Global API

This package holds the process-wide tracer provider, logger provider, meter
provider, and text-map propagator used by the public API layer.

## Defaults

- tracer provider: no-op
- logger provider: no-op
- meter provider: no-op
- text-map propagator: composite of W3C trace-context and baggage

## Getter and setter behavior

- `tracer_provider()` / `set_tracer_provider(provider)`:
  read or replace the global tracer provider
- `logger_provider()` / `set_logger_provider(provider)`:
  read or replace the global logger provider
- `meter_provider()` / `set_meter_provider(provider)`:
  read or replace the global meter provider
- `set_text_map_propagator(propagator)`:
  replaces the global propagator
- `get_text_map_propagator(f)`:
  passes the current propagator into `f`

## Instrument acquisition

- `tracer(name, version?, schema_url?, attributes?)`:
  builds an instrumentation scope from the arguments and returns a tracer from
  the current global tracer provider
- `tracer_with_scope(scope)`:
  same as above, but uses an already constructed scope
- `logger(name, version?, schema_url?, attributes?)`:
  builds a scope and returns a logger from the current global logger provider
- `logger_with_scope(scope)`:
  same as above, but uses an already constructed scope
- `meter(name, version?, schema_url?, attributes?)`:
  builds a scope and returns a meter from the current global meter provider
- `meter_with_scope(scope)`:
  same as above, but uses an already constructed scope

## Lifecycle helpers

- `spawn_background_tasks(group, allow_failure?)`:
  fans out to the currently registered providers and starts batch span/log
  processors plus periodic metric readers
- `force_flush()`:
  flushes all current providers and intentionally ignores individual provider
  errors
- `shutdown()`:
  shuts down all current providers and intentionally ignores individual provider
  errors
- `reset_for_test()`:
  resets every global slot back to the default no-op provider/propagator set

Use `sdk/global` when you need the same global pattern but with SDK-specific
types.
