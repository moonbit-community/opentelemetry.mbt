///|
/// Baggage is modeled as a simple string-to-string map.
pub type Baggage = Map[String, String]

///|
/// Immutable context used by the SDK to carry active span state, baggage, and
/// suppression flags.
pub struct Context {
  span_context : @common.SpanContext?
  baggage : Baggage
  suppress_telemetry : Bool
} derive(Eq, ToJson, Debug)

///|
/// Returns an empty context with no active span, no baggage, and telemetry
/// enabled.
pub fn Context::empty() -> Context {
  { span_context: None, baggage: {}, suppress_telemetry: false }
}

///|
/// Returns the current span context, if present.
pub fn Context::span_context(self : Context) -> @common.SpanContext? {
  self.span_context
}

///|
/// Returns whether the context carries a valid active span context.
pub fn Context::has_active_span(self : Context) -> Bool {
  match self.span_context {
    Some(span_context) => span_context.is_valid()
    None => false
  }
}

///|
/// Returns a copy with a local span context attached.
pub fn Context::with_span_context(
  self : Context,
  span_context : @common.SpanContext,
) -> Context {
  { ..self, span_context: Some(span_context.with_remote(false)) }
}

///|
/// Returns a copy with a remote span context attached. Propagators use this
/// after extracting from inbound carriers.
pub fn Context::with_remote_span_context(
  self : Context,
  span_context : @common.SpanContext,
) -> Context {
  { ..self, span_context: Some(span_context.with_remote(true)) }
}

///|
/// Returns a copy of the baggage map.
pub fn Context::baggage(self : Context) -> Baggage {
  self.baggage.copy()
}

///|
/// Returns a copy with baggage replaced.
pub fn Context::with_baggage(self : Context, baggage : Baggage) -> Context {
  { ..self, baggage: baggage.copy() }
}

///|
/// Returns a copy with one baggage item inserted or updated.
pub fn Context::with_baggage_item(
  self : Context,
  key : StringView,
  value : StringView,
) -> Context {
  let baggage = self.baggage.copy()
  baggage[key.to_string()] = value.to_string()
  { ..self, baggage, }
}

///|
/// Returns whether telemetry emission should be suppressed for this context.
pub fn Context::is_telemetry_suppressed(self : Context) -> Bool {
  self.suppress_telemetry
}

///|
/// Returns a copy with telemetry suppression toggled.
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
