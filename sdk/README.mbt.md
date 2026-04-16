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
4. Call async `force_flush()` and `shutdown()` during application teardown.

Batch span processors, batch log processors, and periodic metric readers do not
start their loops automatically. They are activated by
`spawn_background_tasks(group)`, which fans out to the currently registered
global providers.

## Default global state

`sdk/global` keeps one tracer provider, logger provider, meter provider, and
text map propagator. The default propagator is a composite of W3C trace context
and baggage propagation, matching the common OpenTelemetry startup behavior.

## Environment variables

The current MoonBit implementation reads these environment variables:

- Resource: `OTEL_SERVICE_NAME`, `OTEL_RESOURCE_ATTRIBUTES`
- Trace config: `OTEL_TRACES_SAMPLER`, `OTEL_TRACES_SAMPLER_ARG`
- Trace limits: `OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT`,
  `OTEL_SPAN_EVENT_COUNT_LIMIT`, `OTEL_SPAN_LINK_COUNT_LIMIT`
- Batch span processor: `OTEL_BSP_SCHEDULE_DELAY`,
  `OTEL_BSP_MAX_QUEUE_SIZE`, `OTEL_BSP_MAX_EXPORT_BATCH_SIZE`,
  `OTEL_BSP_EXPORT_TIMEOUT`
- Batch log processor: `OTEL_BLRP_SCHEDULE_DELAY`,
  `OTEL_BLRP_MAX_QUEUE_SIZE`, `OTEL_BLRP_MAX_EXPORT_BATCH_SIZE`,
  `OTEL_BLRP_EXPORT_TIMEOUT`
- Periodic metrics export: `OTEL_METRIC_EXPORT_INTERVAL`
