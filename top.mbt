///|
/// Convenient alias for the shared attribute key type.
pub type Key = @common.Key

///|
/// Convenient alias for the shared attribute value type.
pub type Value = @common.Value

///|
/// Convenient alias for one attribute key/value pair.
pub type KeyValue = @common.KeyValue

///|
/// Convenient alias for the 16-byte trace identifier type.
pub type TraceId = @common.TraceId

///|
/// Convenient alias for the 8-byte span identifier type.
pub type SpanId = @common.SpanId

///|
/// Convenient alias for the W3C trace flags type.
pub type TraceFlags = @common.TraceFlags

///|
/// Convenient alias for the W3C trace state container.
pub type TraceState = @common.TraceState

///|
/// Convenient alias for instrumentation library metadata.
pub type InstrumentationScope = @common.InstrumentationScope

///|
/// Convenient alias for the immutable context container.
pub type Context = @context.Context

///|
/// Convenient alias for the baggage container.
pub type Baggage = @baggage.Baggage

///|
/// Convenient alias for one baggage metadata payload.
pub type BaggageMetadata = @baggage.BaggageMetadata

///|
/// Convenient alias for one baggage entry plus metadata.
pub type KeyValueMetadata = @baggage.KeyValueMetadata

///|
/// Returns a tracer from the current global tracer provider.
///
/// The optional version, schema URL, and attributes are folded into the
/// instrumentation scope attached to all spans created by the returned tracer.
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
/// The optional version, schema URL, and attributes are folded into the
/// instrumentation scope attached to all instruments created by the meter.
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
/// The optional version, schema URL, and attributes are folded into the
/// instrumentation scope attached to all log records emitted by the logger.
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
/// This avoids exposing the mutable global reference directly while still
/// letting callers inject or extract propagation headers.
pub fn[T] get_text_map_propagator(
  f : (@propagation.TextMapPropagator) -> T,
) -> T {
  @global.get_text_map_propagator(f)
}
