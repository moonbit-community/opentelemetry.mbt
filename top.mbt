///|
/// Attribute key type used by all OpenTelemetry signals.
///
/// Keys should be stable, low-cardinality names. Prefer semantic-convention
/// constants from `semantics/*` when a standard key exists.
pub type Key = @common.Key

///|
/// Attribute value type accepted by traces, metrics, resources, and baggage
/// conversion helpers.
pub type Value = @common.Value

///|
/// One OpenTelemetry attribute key/value pair.
///
/// Attributes add searchable dimensions to spans, metrics, logs, and resources.
/// Avoid unbounded values such as user IDs or raw URLs on metrics because they
/// can create high-cardinality time series.
pub type KeyValue = @common.KeyValue

///|
/// 16-byte trace identifier propagated across process boundaries.
pub type TraceId = @common.TraceId

///|
/// 8-byte span identifier for one operation inside a trace.
pub type SpanId = @common.SpanId

///|
/// W3C trace flags, including the sampled bit.
pub type TraceFlags = @common.TraceFlags

///|
/// W3C trace state container used by distributed tracing propagators.
pub type TraceState = @common.TraceState

///|
/// Metadata describing the library or component that produced telemetry.
///
/// Instrumentation scope is attached to exported telemetry. Use a stable name
/// such as a package or module name, and set version/schema URL when known.
pub type InstrumentationScope = @common.InstrumentationScope

///|
/// Immutable context container carrying active span context, baggage, and
/// telemetry suppression.
pub type Context = @context.Context

///|
/// Baggage container for small cross-process key/value metadata.
///
/// Baggage is propagated to downstream services, so do not store secrets or
/// high-cardinality values in it.
pub type Baggage = @baggage.Baggage

///|
/// Metadata associated with one baggage entry.
pub type BaggageMetadata = @baggage.BaggageMetadata

///|
/// One baggage entry plus its metadata.
pub type KeyValueMetadata = @baggage.KeyValueMetadata

///|
/// Returns a tracer from the current global tracer provider.
///
/// This is the preferred trace entry point for library instrumentation. The
/// final application can register a real SDK provider through
/// `interface/global`; if it does not, the returned tracer is no-op and spans do
/// not record telemetry.
///
/// `name` should identify the instrumentation library or component. Optional
/// version, schema URL, and attributes are folded into the instrumentation scope
/// attached to spans created by the returned tracer.
pub fn tracer(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @trace.Tracer {
  @global.tracer(name, version~, schema_url~, attributes~)
}

///|
/// Returns a meter from the current global meter provider.
///
/// Use meters to create reusable metric instruments. If the final application
/// has not registered a meter provider, created instruments are no-op and
/// measurements are discarded.
///
/// Optional version, schema URL, and attributes are folded into the
/// instrumentation scope attached to instruments created by the returned meter.
pub fn meter(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @metrics.Meter {
  @global.meter(name, version~, schema_url~, attributes~)
}

///|
/// Returns a logger from the current global logger provider.
///
/// This is the public logs bridge entry point. Use `Logger::event_enabled()` to
/// avoid constructing expensive log records when no real SDK logger is
/// installed.
///
/// Optional version, schema URL, and attributes are folded into the
/// instrumentation scope attached to emitted log records.
pub fn logger(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @logs.Logger {
  @global.logger(name, version~, schema_url~, attributes~)
}

///|
/// Calls `f` with the currently registered global text-map propagator.
///
/// Use this to inject or extract trace context and baggage for text carriers
/// such as HTTP headers. The default propagator combines W3C trace context and
/// baggage propagation.
///
/// The callback shape avoids exposing the mutable global reference directly
/// while still letting callers use the current propagator.
pub fn[T] get_text_map_propagator(
  f : (@propagation.TextMapPropagator) -> T,
) -> T {
  @global.get_text_map_propagator(f)
}
