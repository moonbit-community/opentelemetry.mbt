///|
/// Convenient alias for the shared attribute key type.
pub type Key = @common.Key

///|
/// Convenient alias for the shared attribute value type.
pub type Value = @common.Value

///|
/// Convenient alias for a key/value attribute pair.
pub type KeyValue = @common.KeyValue

///|
pub type TraceState = @common.TraceState

///|
pub type TraceFlags = @common.TraceFlags

///|
pub type TraceId = @common.TraceId

///|
pub type SpanId = @common.SpanId

///|
pub type SpanContext = @common.SpanContext

///|
pub type InstrumentationScope = @common.InstrumentationScope

///|
pub type Context = @context.Context

///|
pub type Baggage = @context.Baggage

///|
pub type OTelSdkError = @error.OTelSdkError

///|
pub type OTelSdkResult = @error.OTelSdkResult

///|
pub type Resource = @resource.Resource

///|
pub type ResourceBuilder = @resource.ResourceBuilder

///|
pub type ResourceDetector = @resource.ResourceDetector

///|
pub type TextMapPropagator = @propagation.TextMapPropagator

///|
pub type BaggagePropagator = @propagation.BaggagePropagator

///|
pub type TraceContextPropagator = @propagation.TraceContextPropagator

///|
pub type TextMapCompositePropagator = @propagation.TextMapCompositePropagator

///|
pub type SdkTracerProvider = @trace.SdkTracerProvider

///|
pub type SdkTracerProviderBuilder = @trace.SdkTracerProviderBuilder

///|
pub type SdkTracer = @trace.SdkTracer

///|
pub type Span = @trace.Span

///|
pub type SpanData = @trace.SpanData

///|
pub type Sampler = @trace.Sampler

///|
pub type SamplingDecision = @trace.SamplingDecision

///|
pub type SamplingResult = @trace.SamplingResult

///|
pub type SpanKind = @trace.SpanKind

///|
pub type Status = @trace.Status

///|
pub type StatusCode = @trace.StatusCode

///|
pub type SpanEvent = @trace.SpanEvent

///|
pub type SpanLink = @trace.SpanLink

///|
pub type SpanLimits = @trace.SpanLimits

///|
pub type BatchConfig = @trace.BatchConfig

///|
pub type Config = @trace.Config

///|
pub type SpanExporter = @trace.SpanExporter

///|
pub type SpanProcessor = @trace.SpanProcessor

///|
pub type SimpleSpanProcessor = @trace.SimpleSpanProcessor

///|
pub type BatchSpanProcessor = @trace.BatchSpanProcessor

///|
pub type InMemorySpanExporter = @trace.InMemorySpanExporter

///|
pub type SdkLoggerProvider = @logs.SdkLoggerProvider

///|
pub type SdkLoggerProviderBuilder = @logs.SdkLoggerProviderBuilder

///|
pub type SdkLogger = @logs.SdkLogger

///|
pub type LogRecord = @logs.LogRecord

///|
pub type SeverityNumber = @logs.SeverityNumber

///|
pub type LogExporter = @logs.LogExporter

///|
pub type LogProcessor = @logs.LogProcessor

///|
pub type SimpleLogProcessor = @logs.SimpleLogProcessor

///|
pub type BatchLogProcessor = @logs.BatchLogProcessor

///|
pub type InMemoryLogExporter = @logs.InMemoryLogExporter

///|
pub type SdkMeterProvider = @metrics.SdkMeterProvider

///|
pub type SdkMeterProviderBuilder = @metrics.SdkMeterProviderBuilder

///|
pub type SdkMeter = @metrics.SdkMeter

///|
pub type ManualReader = @metrics.ManualReader

///|
pub type PeriodicMetricReader = @metrics.PeriodicMetricReader

///|
pub type MetricExporter = @metrics.MetricExporter

///|
pub type InMemoryMetricExporter = @metrics.InMemoryMetricExporter

///|
pub type InstrumentKind = @metrics.InstrumentKind

///|
pub type Number = @metrics.Number

///|
pub type HistogramSummary = @metrics.HistogramSummary

///|
pub type Aggregation = @metrics.Aggregation

///|
pub type MetricData = @metrics.MetricData

///|
pub type CounterBuilder = @metrics.CounterBuilder

///|
pub type UpDownCounterBuilder = @metrics.UpDownCounterBuilder

///|
pub type HistogramBuilder = @metrics.HistogramBuilder

///|
pub type GaugeBuilder = @metrics.GaugeBuilder

///|
pub type Counter = @metrics.Counter

///|
pub type UpDownCounter = @metrics.UpDownCounter

///|
pub type Histogram = @metrics.Histogram

///|
pub type Gauge = @metrics.Gauge

///|
/// Starts building a tracer provider.
pub fn tracer_provider_builder() -> @trace.SdkTracerProviderBuilder {
  @trace.SdkTracerProvider::builder()
}

///|
/// Starts building a logger provider.
pub fn logger_provider_builder() -> @logs.SdkLoggerProviderBuilder {
  @logs.SdkLoggerProvider::builder()
}

///|
/// Starts building a meter provider.
pub fn meter_provider_builder() -> @metrics.SdkMeterProviderBuilder {
  @metrics.SdkMeterProvider::builder()
}

///|
/// Creates a tracer from the current global tracer provider.
pub fn tracer(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @trace.SdkTracer {
  @global.tracer(name, version~, schema_url~, attributes~)
}

///|
/// Creates a logger from the current global logger provider.
pub fn logger(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @logs.SdkLogger {
  @global.logger(name, version~, schema_url~, attributes~)
}

///|
/// Creates a meter from the current global meter provider.
pub fn meter(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @metrics.SdkMeter {
  @global.meter(name, version~, schema_url~, attributes~)
}

///|
/// Spawns all global background workers needed by batch processors and periodic
/// metric readers.
pub fn spawn_background_tasks(
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  @global.spawn_background_tasks(group, allow_failure~)
}
