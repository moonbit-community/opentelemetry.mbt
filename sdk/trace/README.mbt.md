# OpenTelemetry Trace SDK

This package implements the trace SDK pipeline: tracer providers, tracers,
spans, sampling, processors, exporters, and in-memory test helpers.

## Main objects

- `SdkTracerProvider`: owns configuration, processors, and resource
- `SdkTracer`: starts spans for one instrumentation scope
- `Span`: mutable handle used while the operation is in flight
- `SpanData`: immutable snapshot exported at end
- `Sampler`: decides whether a span is recorded and sampled
- `SpanProcessor`: start/end hooks around span lifecycle
- `SimpleSpanProcessor`, `BatchSpanProcessor`: processor implementations
- `SpanExporter`, `InMemorySpanExporter`: exporter abstraction and test helper

## Sampling

The default sampler is `Sampler::parent_based(Sampler::always_on())`, which
matches the common SDK default in OpenTelemetry implementations.

`Sampler::trace_id_ratio(ratio)` samples by comparing the high 32 bits of the
trace ID against a threshold derived from `ratio`.

## Limits

`SpanLimits` currently bound:

- attributes per span
- events per span
- links per span

When a limit is exceeded, new items are dropped and the corresponding dropped
count is incremented in `SpanData`.

## Batch processing

`BatchSpanProcessor` keeps a bounded in-memory queue. It flushes synchronously
when the queue reaches the export batch size, or periodically when `run()` is
spawned in the background.
