# OpenTelemetry Logs SDK

This package implements the SDK objects needed to produce and export log
records.

## Main types

- `SdkLoggerProvider`: owns shared resource and processor configuration
- `SdkLogger`: creates scoped log records
- `LogRecord`: immutable exported log payload
- `BatchConfig`: queue and timing configuration for batch export
- `LogProcessor`: processing hook interface
- `SimpleLogProcessor`, `BatchLogProcessor`: processor implementations
- `LogExporter`: exporter callback wrapper
- `InMemoryLogExporter`: test helper

## Processing model

`SdkLogger::emit()` snapshots the current provider resource and
instrumentation scope into a `LogRecord`, then forwards that record through
every configured processor.

`BatchLogProcessor` buffers records in memory. When the queue reaches the batch
size it flushes immediately; otherwise it relies on `run()` to flush on the
configured interval. The queue is bounded, and the oldest record is dropped
when the queue is full.

`BatchConfig::default()` reads:

- `OTEL_BLRP_SCHEDULE_DELAY`
- `OTEL_BLRP_MAX_QUEUE_SIZE`
- `OTEL_BLRP_MAX_EXPORT_BATCH_SIZE`
- `OTEL_BLRP_EXPORT_TIMEOUT`

## Trace-aware logging

If `emit()` receives a context with a valid active span, the emitted log record
stores a local `SpanContext` so exporters can correlate logs with traces.
