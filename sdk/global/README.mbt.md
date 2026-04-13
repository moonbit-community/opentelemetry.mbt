# SDK Global State

This package stores the process-wide tracer, logger, meter, and propagator
instances.

## Defaults

- Tracer provider: empty `SdkTracerProvider`
- Logger provider: empty `SdkLoggerProvider`
- Meter provider: empty `SdkMeterProvider`
- Text map propagator: composite of trace context and baggage propagation

## When to use it

Use this package when instrumentation code should be decoupled from provider
construction. Applications can configure providers once during startup, register
them globally, and let the rest of the process call `tracer()`, `logger()`, or
`meter()`.

## Background work

`spawn_background_tasks()` forwards to every currently registered global
provider. This is the easiest way to activate batch span/log processors and
periodic metric readers in one place.
