///|
pub type Key = @common.Key

///|
pub type Value = @common.Value

///|
pub type KeyValue = @common.KeyValue

///|
pub type TraceId = @common.TraceId

///|
pub type SpanId = @common.SpanId

///|
pub type TraceFlags = @common.TraceFlags

///|
pub type TraceState = @common.TraceState

///|
pub type InstrumentationScope = @common.InstrumentationScope

///|
pub type Context = @context.Context

///|
pub type Baggage = @baggage.Baggage

///|
pub type BaggageMetadata = @baggage.BaggageMetadata

///|
pub type KeyValueMetadata = @baggage.KeyValueMetadata

///|
pub fn tracer(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @trace.Tracer {
  @global.tracer(name, version~, schema_url~, attributes~)
}

///|
pub fn meter(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @metrics.Meter {
  @global.meter(name, version~, schema_url~, attributes~)
}

///|
pub fn logger(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @logs.Logger {
  @global.logger(name, version~, schema_url~, attributes~)
}

///|
pub fn[T] get_text_map_propagator(
  f : (@propagation.TextMapPropagator) -> T,
) -> T {
  @global.get_text_map_propagator(f)
}
