///|
pub struct Context {
  span_context : @common.SpanContext?
  baggage : @baggage.Baggage
  suppress_telemetry : Bool
} derive(Eq, ToJson, Debug)

///|
pub fn Context::new() -> Context {
  Context::empty()
}

///|
pub fn Context::empty() -> Context {
  { span_context: None, baggage: Default::default(), suppress_telemetry: false }
}

///|
pub fn Context::span_context(self : Context) -> @common.SpanContext? {
  self.span_context
}

///|
pub fn Context::has_active_span(self : Context) -> Bool {
  match self.span_context {
    Some(span_context) => span_context.is_valid()
    None => false
  }
}

///|
pub fn Context::with_span_context(
  self : Context,
  span_context : @common.SpanContext,
) -> Context {
  { ..self, span_context: Some(span_context.with_remote(false)) }
}

///|
pub fn Context::with_remote_span_context(
  self : Context,
  span_context : @common.SpanContext,
) -> Context {
  { ..self, span_context: Some(span_context.with_remote(true)) }
}

///|
pub fn Context::baggage(self : Context) -> @baggage.Baggage {
  self.baggage
}

///|
pub fn Context::with_baggage(
  self : Context,
  baggage : @baggage.Baggage,
) -> Context {
  { ..self, baggage, }
}

///|
pub fn Context::with_baggage_item(
  self : Context,
  key : StringView,
  value : StringView,
  metadata? : @baggage.BaggageMetadata = Default::default(),
) -> Context {
  { ..self, baggage: self.baggage.insert_with_metadata(key, value, metadata) }
}

///|
pub fn Context::is_telemetry_suppressed(self : Context) -> Bool {
  self.suppress_telemetry
}

///|
pub fn Context::with_telemetry_suppressed(
  self : Context,
  suppressed? : Bool = true,
) -> Context {
  { ..self, suppress_telemetry: suppressed }
}

///|
pub impl Default for Context with default() -> Context {
  Context::empty()
}
