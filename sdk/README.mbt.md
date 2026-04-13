# OpenTelemetry SDK

This package is the MoonBit entry point for the SDK layer. It re-exports the
core types from the `sdk/common`, `sdk/context`, `sdk/resource`,
`sdk/propagation`, `sdk/trace`, `sdk/logs`, and `sdk/metrics` packages so
application code can depend on a single import path.

## What lives here

- Trace setup: `tracer_provider_builder()`, `tracer()`
- Log setup: `logger_provider_builder()`, `logger()`
- Metric setup: `meter_provider_builder()`, `meter()`
- Background worker wiring: `spawn_background_tasks()`

## Provider lifecycle

The root package follows the same lifecycle shape as the Rust SDK:

1. Build a provider for each signal.
2. Optionally register it into `sdk/global`.
3. Spawn background tasks when using batch span/log processors or periodic
   metric readers.
4. Call `force_flush()` and `shutdown()` during application teardown.

Batch span processors, batch log processors, and periodic metric readers do not
start their loops automatically. They are activated by
`spawn_background_tasks(group)`, which fans out to the currently registered
global providers.

## Default global state

`sdk/global` keeps one tracer provider, logger provider, meter provider, and
text map propagator. The default propagator is a composite of W3C trace context
and baggage propagation, matching the common OpenTelemetry startup behavior.

## Environment variables

The current MoonBit implementation reads the resource-related environment
variables below through `sdk/resource`:

- `OTEL_SERVICE_NAME`
- `OTEL_RESOURCE_ATTRIBUTES`

Signal-specific sampler and processor environment variables from the Rust SDK
are not implemented yet in this package.
