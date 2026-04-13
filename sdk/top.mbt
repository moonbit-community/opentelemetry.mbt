///|
/// Attribute key type shared by all SDK signals.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#attribute
pub type Key = @common.Key

///|
/// Attribute value type shared by spans, metrics, logs, and resources.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#anyvalue
pub type Value = @common.Value

///|
/// One OpenTelemetry attribute key/value pair.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#attribute
pub type KeyValue = @common.KeyValue

///|
/// W3C trace state container used by trace propagation.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub type TraceState = @common.TraceState

///|
/// W3C trace flags, including the sampled bit.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub type TraceFlags = @common.TraceFlags

///|
/// 16-byte trace identifier.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub type TraceId = @common.TraceId

///|
/// 8-byte span identifier.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub type SpanId = @common.SpanId

///|
/// Trace/span identity plus flags, remote marker, and trace state.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub type SpanContext = @common.SpanContext

///|
/// Metadata naming the instrumentation library or component producing telemetry.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub type InstrumentationScope = @common.InstrumentationScope

///|
/// SDK context carrying span context, baggage, and telemetry suppression.
/// Spec: https://opentelemetry.io/docs/specs/otel/context/#overview
pub type Context = @context.Context

///|
/// SDK baggage map carried through context and propagation.
/// Spec: https://opentelemetry.io/docs/specs/otel/baggage/api/#overview
pub type Baggage = @baggage.Baggage

///|
/// Error type returned by SDK exporters, processors, readers, and providers.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub type OTelSdkError = @error.OTelSdkError

///|
/// Standard SDK result alias.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub type OTelSdkResult = @error.OTelSdkResult

///|
/// Resource attributes describing the entity that produced telemetry.
/// Spec: https://opentelemetry.io/docs/specs/otel/resource/data-model/#resource-data-model
pub type Resource = @resource.Resource

///|
/// Builder for resources and resource detector output.
/// Spec: https://opentelemetry.io/docs/specs/otel/resource/sdk/#resource-creation
pub type ResourceBuilder = @resource.ResourceBuilder

///|
/// Callback wrapper for detecting resource attributes.
/// Spec: https://opentelemetry.io/docs/specs/otel/resource/sdk/#detecting-resource-information-from-the-environment
pub type ResourceDetector = @resource.ResourceDetector

///|
/// Erased text-map propagator used by SDK global state.
/// Spec: https://opentelemetry.io/docs/specs/otel/context/api-propagators/#textmap-propagator
pub type TextMapPropagator = @propagation.TextMapPropagator

///|
/// W3C baggage propagator.
/// Spec: https://opentelemetry.io/docs/specs/otel/baggage/api/#propagation
pub type BaggagePropagator = @propagation.BaggagePropagator

///|
/// W3C trace-context propagator for `traceparent` and `tracestate`.
/// Spec: https://opentelemetry.io/docs/specs/otel/context/api-propagators/#w3c-trace-context-requirements
pub type TraceContextPropagator = @propagation.TraceContextPropagator

///|
/// Composite propagator that runs multiple text-map propagators.
/// Spec: https://opentelemetry.io/docs/specs/otel/context/api-propagators/#composite-propagator
pub type TextMapCompositePropagator = @propagation.TextMapCompositePropagator

///|
/// SDK trace provider owning sampler, ID generator, span limits, resource, and processors.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer-provider
pub type SdkTracerProvider = @trace.SdkTracerProvider

///|
/// Builder for SDK trace providers.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer-provider
pub type SdkTracerProviderBuilder = @trace.SdkTracerProviderBuilder

///|
/// SDK tracer scoped to one instrumentation library.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer
pub type SdkTracer = @trace.SdkTracer

///|
/// SDK span handle for one in-flight operation.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span
pub type Span = @trace.Span

///|
/// Immutable snapshot of a completed or in-flight span.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span
pub type SpanData = @trace.SpanData

///|
/// Sampling policy evaluated when a span starts.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
pub type Sampler = @trace.Sampler

///|
/// Sampling decision controlling recording and sampled trace flag.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
pub type SamplingDecision = @trace.SamplingDecision

///|
/// Sampler output: decision plus attributes and trace state.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling
pub type SamplingResult = @trace.SamplingResult

///|
/// OpenTelemetry span kind: internal, client, server, producer, or consumer.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spankind
pub type SpanKind = @trace.SpanKind

///|
/// Span status with code and optional description.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub type Status = @trace.Status

///|
/// Span status code.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub type StatusCode = @trace.StatusCode

///|
/// Timestamped span event.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
pub type SpanEvent = @trace.SpanEvent

///|
/// Relationship from one span to another span context.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#link
pub type SpanLink = @trace.SpanLink

///|
/// Per-span limits for attributes, events, and links.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
pub type SpanLimits = @trace.SpanLimits

///|
/// Batch span/log processor configuration.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-processor
pub type BatchConfig = @trace.BatchConfig

///|
/// Trace provider configuration.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer-provider
pub type Config = @trace.Config

///|
/// Callback wrapper for exporting finished span batches.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-exporter
pub type SpanExporter = @trace.SpanExporter

///|
/// Processing hook called when spans start and end.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-processor
pub type SpanProcessor = @trace.SpanProcessor

///|
/// Span processor that exports every ended span immediately.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#simple-processor
pub type SimpleSpanProcessor = @trace.SimpleSpanProcessor

///|
/// Span processor that queues ended spans and exports batches from a background loop.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-processor
pub type BatchSpanProcessor = @trace.BatchSpanProcessor

///|
/// Test span exporter that stores finished spans in memory.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-exporter
pub type InMemorySpanExporter = @trace.InMemorySpanExporter

///|
/// SDK logger provider owning resource and log processors.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#loggerprovider
pub type SdkLoggerProvider = @logs.SdkLoggerProvider

///|
/// Builder for SDK logger providers.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#loggerprovider
pub type SdkLoggerProviderBuilder = @logs.SdkLoggerProviderBuilder

///|
/// SDK logger scoped to one instrumentation library.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#logger
pub type SdkLogger = @logs.SdkLogger

///|
/// Immutable SDK log record snapshot.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#additional-logrecord-interfaces
pub type LogRecord = @logs.LogRecord

///|
/// OpenTelemetry log severity number.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/data-model/#field-severitynumber
pub type SeverityNumber = @logs.SeverityNumber

///|
/// Callback wrapper for exporting log batches.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecordexporter
pub type LogExporter = @logs.LogExporter

///|
/// Processing hook for emitted log records.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecordprocessor
pub type LogProcessor = @logs.LogProcessor

///|
/// Log processor that exports every record immediately.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#simple-processor
pub type SimpleLogProcessor = @logs.SimpleLogProcessor

///|
/// Log processor that queues records and exports batches from a background loop.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#batching-processor
pub type BatchLogProcessor = @logs.BatchLogProcessor

///|
/// Test log exporter that stores emitted logs in memory.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#logrecordexporter
pub type InMemoryLogExporter = @logs.InMemoryLogExporter

///|
/// SDK meter provider owning metric instruments, readers, exporters, views, and resource.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meterprovider
pub type SdkMeterProvider = @metrics.SdkMeterProvider

///|
/// Builder for SDK meter providers.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meterprovider
pub type SdkMeterProviderBuilder = @metrics.SdkMeterProviderBuilder

///|
/// SDK meter scoped to one instrumentation library.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#meter
pub type SdkMeter = @metrics.SdkMeter

///|
/// Pull-based metric reader.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#metricreader
pub type ManualReader = @metrics.ManualReader

///|
/// Background metric reader that exports on an interval.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#periodic-exporting-metricreader
pub type PeriodicMetricReader = @metrics.PeriodicMetricReader

///|
/// Callback wrapper for exporting metric batches.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#metricexporter
pub type MetricExporter = @metrics.MetricExporter

///|
/// Test metric exporter that stores exported metrics in memory.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk_exporters/in-memory/#metrics-exporter---in-memory
pub type InMemoryMetricExporter = @metrics.InMemoryMetricExporter

///|
/// Metric instrument kind.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument
pub type InstrumentKind = @metrics.InstrumentKind

///|
/// Numeric value stored inside metric aggregations.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation
pub type Number = @metrics.Number

///|
/// Compact histogram aggregation summary.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation
pub type HistogramSummary = @metrics.HistogramSummary

///|
/// Aggregated metric payload for one attribute set.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation
pub type Aggregation = @metrics.Aggregation

///|
/// Immutable metric data item exported by readers.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#metricreader
pub type MetricData = @metrics.MetricData

///|
/// Builder for monotonic counter instruments.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument
pub type CounterBuilder = @metrics.CounterBuilder

///|
/// Builder for up-down counter instruments.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument
pub type UpDownCounterBuilder = @metrics.UpDownCounterBuilder

///|
/// Builder for histogram instruments.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument
pub type HistogramBuilder = @metrics.HistogramBuilder

///|
/// Builder for gauge instruments.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument
pub type GaugeBuilder = @metrics.GaugeBuilder

///|
/// Monotonic counter instrument.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#counter
pub type Counter = @metrics.Counter

///|
/// Additive counter instrument for values that can go up or down.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#updowncounter
pub type UpDownCounter = @metrics.UpDownCounter

///|
/// Histogram instrument for distributions such as latency or payload size.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#histogram
pub type Histogram = @metrics.Histogram

///|
/// Gauge instrument for the latest value of current state.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/api/#gauge
pub type Gauge = @metrics.Gauge

///|
/// Starts building an SDK tracer provider.
///
/// Applications use the returned builder to configure samplers, span limits,
/// resources, and span processors/exporters.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer-provider
pub fn tracer_provider_builder() -> @trace.SdkTracerProviderBuilder {
  @trace.SdkTracerProvider::builder()
}

///|
/// Starts building an SDK logger provider.
///
/// Applications use the returned builder to configure resources and log
/// processors/exporters.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#loggerprovider
pub fn logger_provider_builder() -> @logs.SdkLoggerProviderBuilder {
  @logs.SdkLoggerProvider::builder()
}

///|
/// Starts building an SDK meter provider.
///
/// Applications use the returned builder to configure resources, readers,
/// exporters, and views.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meterprovider
pub fn meter_provider_builder() -> @metrics.SdkMeterProviderBuilder {
  @metrics.SdkMeterProvider::builder()
}

///|
/// Creates an SDK tracer from the current `sdk/global` tracer provider.
///
/// This helper is convenient for application-owned instrumentation. Library
/// instrumentation usually should use the root package or `interface/global`
/// instead so applications can install public API providers.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer-creation
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
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#logger-creation
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
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meter
pub fn meter(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @metrics.SdkMeter {
  @global.meter(name, version~, schema_url~, attributes~)
}

///|
/// Registers the global SDK tracer provider and updates the public API global.
///
/// Library instrumentation obtained through the root package or
/// `interface/global` will create spans backed by this SDK provider.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer-provider
pub fn set_tracer_provider(provider : @trace.SdkTracerProvider) -> Unit {
  @global.set_tracer_provider(provider)
  @api_global.set_tracer_provider(provider.into_tracer_provider())
}

///|
/// Registers the global SDK logger provider and updates the public API global.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/sdk/#loggerprovider
pub fn set_logger_provider(provider : @logs.SdkLoggerProvider) -> Unit {
  @global.set_logger_provider(provider)
  @api_global.set_logger_provider(provider.into_logger_provider())
}

///|
/// Registers the global SDK meter provider and updates the public API global.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meterprovider
pub fn set_meter_provider(provider : @metrics.SdkMeterProvider) -> Unit {
  @global.set_meter_provider(provider)
  @api_global.set_meter_provider(provider.into_meter_provider())
}

///|
/// Spawns all `sdk/global` background workers needed by batch processors and
/// periodic metric readers.
///
/// Call this after registering global SDK providers when using
/// `BatchSpanProcessor`, `BatchLogProcessor`, or `PeriodicMetricReader`.
/// Specs:
/// - https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-processor
/// - https://opentelemetry.io/docs/specs/otel/logs/sdk/#batching-processor
/// - https://opentelemetry.io/docs/specs/otel/metrics/sdk/#periodic-exporting-metricreader
pub fn spawn_background_tasks(
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  @global.spawn_background_tasks(group, allow_failure~)
}

///|
/// Flushes all globally registered SDK providers, ignoring individual errors.
/// Specs:
/// - https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflush
/// - https://opentelemetry.io/docs/specs/otel/logs/sdk/#forceflush
/// - https://opentelemetry.io/docs/specs/otel/metrics/sdk/#forceflush
pub async fn force_flush() -> Unit {
  @global.force_flush()
}

///|
/// Shuts down all globally registered SDK providers, ignoring individual errors.
/// Specs:
/// - https://opentelemetry.io/docs/specs/otel/trace/sdk/#shutdown
/// - https://opentelemetry.io/docs/specs/otel/logs/sdk/#shutdown
/// - https://opentelemetry.io/docs/specs/otel/metrics/sdk/#shutdown
pub async fn shutdown() -> Unit {
  @global.shutdown()
}
