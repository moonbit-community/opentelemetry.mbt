///|
/// Immutable context container shared across traces, logs, metrics, and
/// propagation.
///
/// Each `with_*` helper returns a new value instead of mutating the original
/// context.
pub struct Context {
  span_context : @common.SpanContext?
  baggage : @baggage.Baggage
  suppress_telemetry : Bool
} derive(Eq, ToJson, Debug)

///|
/// Returns a new empty context.
///
/// This is an alias for `Context::empty()`.
pub fn Context::new() -> Context {
  Context::empty()
}

///|
/// Returns a context with no span, no baggage, and telemetry suppression
/// disabled.
pub fn Context::empty() -> Context {
  { span_context: None, baggage: Default::default(), suppress_telemetry: false }
}

///|
/// Returns the stored span context, if any.
pub fn Context::span_context(self : Context) -> @common.SpanContext? {
  self.span_context
}

///|
/// Returns whether the context contains a valid active span context.
pub fn Context::has_active_span(self : Context) -> Bool {
  match self.span_context {
    Some(span_context) => span_context.is_valid()
    None => false
  }
}

///|
/// Returns a copy of the context with a local span context attached.
///
/// The stored span context is forced to `is_remote = false`.
pub fn Context::with_span_context(
  self : Context,
  span_context : @common.SpanContext,
) -> Context {
  { ..self, span_context: Some(span_context.with_remote(false)) }
}

///|
/// Returns a copy of the context with a remote span context attached.
///
/// The stored span context is forced to `is_remote = true`.
pub fn Context::with_remote_span_context(
  self : Context,
  span_context : @common.SpanContext,
) -> Context {
  { ..self, span_context: Some(span_context.with_remote(true)) }
}

///|
/// Returns the baggage stored in the context.
pub fn Context::baggage(self : Context) -> @baggage.Baggage {
  self.baggage
}

///|
/// Returns a copy of the context with the given baggage value.
pub fn Context::with_baggage(
  self : Context,
  baggage : @baggage.Baggage,
) -> Context {
  { ..self, baggage, }
}

///|
/// Returns a copy of the context with one baggage item inserted or replaced.
///
/// The same validation and limit rules as `Baggage::insert_with_metadata()`
/// apply.
pub fn Context::with_baggage_item(
  self : Context,
  key : StringView,
  value : StringView,
  metadata? : @baggage.BaggageMetadata = Default::default(),
) -> Context {
  { ..self, baggage: self.baggage.insert_with_metadata(key, value, metadata) }
}

///|
/// Returns whether telemetry is suppressed for work performed in this context.
pub fn Context::is_telemetry_suppressed(self : Context) -> Bool {
  self.suppress_telemetry
}

///|
/// Returns a copy of the context with telemetry suppression toggled.
///
/// The default argument enables suppression.
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
