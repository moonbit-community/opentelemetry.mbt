///|
/// Attribute key type shared by all SDK signals.
pub type Key = @common.Key

///|
/// Attribute value type shared by spans, metrics, logs, and resources.
pub type Value = @common.Value

///|
/// One OpenTelemetry attribute key/value pair.
pub type KeyValue = @common.KeyValue

///|
/// W3C trace state container used by trace propagation.
pub type TraceState = @common.TraceState

///|
/// W3C trace flags, including the sampled bit.
pub type TraceFlags = @common.TraceFlags

///|
/// 16-byte trace identifier.
pub type TraceId = @common.TraceId

///|
/// 8-byte span identifier.
pub type SpanId = @common.SpanId

///|
/// Trace/span identity plus flags, remote marker, and trace state.
pub type SpanContext = @common.SpanContext

///|
/// Metadata naming the instrumentation library or component producing telemetry.
pub type InstrumentationScope = @common.InstrumentationScope

///|
/// SDK context carrying span context, baggage, and telemetry suppression.
pub type Context = @context.Context

///|
/// SDK baggage map carried through context and propagation.
pub type Baggage = @context.Baggage

///|
/// Error type returned by SDK exporters, processors, readers, and providers.
pub type OTelSdkError = @error.OTelSdkError

///|
/// Standard SDK result alias.
pub type OTelSdkResult = @error.OTelSdkResult

///|
/// Resource attributes describing the entity that produced telemetry.
pub type Resource = @resource.Resource

///|
/// Builder for resources and resource detector output.
pub type ResourceBuilder = @resource.ResourceBuilder

///|
/// Callback wrapper for detecting resource attributes.
pub type ResourceDetector = @resource.ResourceDetector

///|
/// Erased text-map propagator used by SDK global state.
pub type TextMapPropagator = @propagation.TextMapPropagator

///|
/// W3C baggage propagator.
pub type BaggagePropagator = @propagation.BaggagePropagator

///|
/// W3C trace-context propagator for `traceparent` and `tracestate`.
pub type TraceContextPropagator = @propagation.TraceContextPropagator

///|
/// Composite propagator that runs multiple text-map propagators.
pub type TextMapCompositePropagator = @propagation.TextMapCompositePropagator

///|
/// SDK trace provider owning sampler, ID generator, span limits, resource, and processors.
pub type SdkTracerProvider = @trace.SdkTracerProvider

///|
/// Builder for SDK trace providers.
pub type SdkTracerProviderBuilder = @trace.SdkTracerProviderBuilder

///|
/// SDK tracer scoped to one instrumentation library.
pub type SdkTracer = @trace.SdkTracer

///|
/// SDK span handle for one in-flight operation.
pub type Span = @trace.Span

///|
/// Immutable snapshot of a completed or in-flight span.
pub type SpanData = @trace.SpanData

///|
/// Sampling policy evaluated when a span starts.
pub type Sampler = @trace.Sampler

///|
/// Sampling decision controlling recording and sampled trace flag.
pub type SamplingDecision = @trace.SamplingDecision

///|
/// Sampler output: decision plus attributes and trace state.
pub type SamplingResult = @trace.SamplingResult

///|
/// OpenTelemetry span kind: internal, client, server, producer, or consumer.
pub type SpanKind = @trace.SpanKind

///|
/// Span status with code and optional description.
pub type Status = @trace.Status

///|
/// Span status code.
pub type StatusCode = @trace.StatusCode

///|
/// Timestamped span event.
pub type SpanEvent = @trace.SpanEvent

///|
/// Relationship from one span to another span context.
pub type SpanLink = @trace.SpanLink

///|
/// Per-span limits for attributes, events, and links.
pub type SpanLimits = @trace.SpanLimits

///|
/// Batch span/log processor configuration.
pub type BatchConfig = @trace.BatchConfig

///|
/// Trace provider configuration.
pub type Config = @trace.Config

///|
/// Callback wrapper for exporting finished span batches.
pub type SpanExporter = @trace.SpanExporter

///|
/// Processing hook called when spans start and end.
pub type SpanProcessor = @trace.SpanProcessor

///|
/// Span processor that exports every ended span immediately.
pub type SimpleSpanProcessor = @trace.SimpleSpanProcessor

///|
/// Span processor that queues ended spans and exports batches from a background loop.
pub type BatchSpanProcessor = @trace.BatchSpanProcessor

///|
/// Test span exporter that stores finished spans in memory.
pub type InMemorySpanExporter = @trace.InMemorySpanExporter

///|
/// SDK logger provider owning resource and log processors.
pub type SdkLoggerProvider = @logs.SdkLoggerProvider

///|
/// Builder for SDK logger providers.
pub type SdkLoggerProviderBuilder = @logs.SdkLoggerProviderBuilder

///|
/// SDK logger scoped to one instrumentation library.
pub type SdkLogger = @logs.SdkLogger

///|
/// Immutable SDK log record snapshot.
pub type LogRecord = @logs.LogRecord

///|
/// OpenTelemetry log severity number.
pub type SeverityNumber = @logs.SeverityNumber

///|
/// Callback wrapper for exporting log batches.
pub type LogExporter = @logs.LogExporter

///|
/// Processing hook for emitted log records.
pub type LogProcessor = @logs.LogProcessor

///|
/// Log processor that exports every record immediately.
pub type SimpleLogProcessor = @logs.SimpleLogProcessor

///|
/// Log processor that queues records and exports batches from a background loop.
pub type BatchLogProcessor = @logs.BatchLogProcessor

///|
/// Test log exporter that stores emitted logs in memory.
pub type InMemoryLogExporter = @logs.InMemoryLogExporter

///|
/// SDK meter provider owning metric instruments, readers, exporters, views, and resource.
pub type SdkMeterProvider = @metrics.SdkMeterProvider

///|
/// Builder for SDK meter providers.
pub type SdkMeterProviderBuilder = @metrics.SdkMeterProviderBuilder

///|
/// SDK meter scoped to one instrumentation library.
pub type SdkMeter = @metrics.SdkMeter

///|
/// Pull-based metric reader.
pub type ManualReader = @metrics.ManualReader

///|
/// Background metric reader that exports on an interval.
pub type PeriodicMetricReader = @metrics.PeriodicMetricReader

///|
/// Callback wrapper for exporting metric batches.
pub type MetricExporter = @metrics.MetricExporter

///|
/// Test metric exporter that stores exported metrics in memory.
pub type InMemoryMetricExporter = @metrics.InMemoryMetricExporter

///|
/// Metric instrument kind.
pub type InstrumentKind = @metrics.InstrumentKind

///|
/// Numeric value stored inside metric aggregations.
pub type Number = @metrics.Number

///|
/// Compact histogram aggregation summary.
pub type HistogramSummary = @metrics.HistogramSummary

///|
/// Aggregated metric payload for one attribute set.
pub type Aggregation = @metrics.Aggregation

///|
/// Immutable metric data item exported by readers.
pub type MetricData = @metrics.MetricData

///|
/// Builder for monotonic counter instruments.
pub type CounterBuilder = @metrics.CounterBuilder

///|
/// Builder for up-down counter instruments.
pub type UpDownCounterBuilder = @metrics.UpDownCounterBuilder

///|
/// Builder for histogram instruments.
pub type HistogramBuilder = @metrics.HistogramBuilder

///|
/// Builder for gauge instruments.
pub type GaugeBuilder = @metrics.GaugeBuilder

///|
/// Monotonic counter instrument.
pub type Counter = @metrics.Counter

///|
/// Additive counter instrument for values that can go up or down.
pub type UpDownCounter = @metrics.UpDownCounter

///|
/// Histogram instrument for distributions such as latency or payload size.
pub type Histogram = @metrics.Histogram

///|
/// Gauge instrument for the latest value of current state.
pub type Gauge = @metrics.Gauge

///|
/// Starts building an SDK tracer provider.
///
/// Applications use the returned builder to configure samplers, span limits,
/// resources, and span processors/exporters.
pub fn tracer_provider_builder() -> @trace.SdkTracerProviderBuilder {
  @trace.SdkTracerProvider::builder()
}

///|
/// Starts building an SDK logger provider.
///
/// Applications use the returned builder to configure resources and log
/// processors/exporters.
pub fn logger_provider_builder() -> @logs.SdkLoggerProviderBuilder {
  @logs.SdkLoggerProvider::builder()
}

///|
/// Starts building an SDK meter provider.
///
/// Applications use the returned builder to configure resources, readers,
/// exporters, and views.
pub fn meter_provider_builder() -> @metrics.SdkMeterProviderBuilder {
  @metrics.SdkMeterProvider::builder()
}

///|
/// Creates an SDK tracer from the current `sdk/global` tracer provider.
///
/// This helper is convenient for application-owned instrumentation. Library
/// instrumentation usually should use the root package or `interface/global`
/// instead so applications can install public API providers.
pub fn tracer(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @trace.SdkTracer {
  @global.tracer(name, version~, schema_url~, attributes~)
}

///|
/// Creates an SDK logger from the current `sdk/global` logger provider.
pub fn logger(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @logs.SdkLogger {
  @global.logger(name, version~, schema_url~, attributes~)
}

///|
/// Creates an SDK meter from the current `sdk/global` meter provider.
pub fn meter(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @metrics.SdkMeter {
  @global.meter(name, version~, schema_url~, attributes~)
}

///|
/// Spawns all `sdk/global` background workers needed by batch processors and
/// periodic metric readers.
///
/// Call this after registering global SDK providers when using
/// `BatchSpanProcessor`, `BatchLogProcessor`, or `PeriodicMetricReader`.
pub fn spawn_background_tasks(
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  @global.spawn_background_tasks(group, allow_failure~)
}
