///|
/// Alias for the span-kind enum used by the SDK.
pub type SpanKind = @sdktrace.SpanKind

///|
/// Alias for the span status struct used by the SDK.
pub type Status = @sdktrace.Status

///|
/// Alias for the span status-code enum used by the SDK.
pub type StatusCode = @sdktrace.StatusCode

///|
/// Event attached to a span builder.
pub struct Event {
  name : String
  timestamp_unix_nano : Int64
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
} derive(Eq, ToJson, Debug)

///|
/// Link attached to a span builder.
pub struct Link {
  span_context : @common.SpanContext
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
} derive(Eq, ToJson, Debug)

///|
/// Immutable span-construction descriptor used by `Tracer::build*()`.
pub struct SpanBuilder {
  span_kind : SpanKind?
  name : String
  start_time_unix_nano : Int64?
  attributes : Array[@common.KeyValue]
  events : Array[Event]
  links : Array[Link]
} derive(Eq, ToJson, Debug)

///|
/// Public span handle.
///
/// When created from a no-op tracer, the span still propagates context but does
/// not record data.
pub struct Span {
  sdk_span : @sdktrace.Span?
  propagated_span_context : @common.SpanContext
  noop_ended : Ref[Bool]
  context : @context.Context
}

///|
/// Public tracer handle.
pub struct Tracer {
  sdk_tracer : @sdktrace.SdkTracer?
}

///|
/// Public tracer provider wrapper around the SDK provider.
pub struct TracerProvider {
  sdk_provider : @sdktrace.SdkTracerProvider?
}

///|
/// Creates one span event.
///
/// The timestamp defaults to the current Unix time in nanoseconds.
pub fn Event::new(
  name : StringView,
  timestamp_unix_nano? : Int64 = @common.now_unix_nano(),
  attributes? : ArrayView[@common.KeyValue] = [],
  dropped_attributes_count? : Int = 0,
) -> Event {
  {
    name: name.to_string(),
    timestamp_unix_nano,
    attributes: attributes.to_array(),
    dropped_attributes_count,
  }
}

///|
/// Creates one span link.
///
/// Invalid linked span contexts are ignored later when the span is built.
pub fn Link::new(
  span_context : @common.SpanContext,
  attributes? : ArrayView[@common.KeyValue] = [],
  dropped_attributes_count? : Int = 0,
) -> Link {
  { span_context, attributes: attributes.to_array(), dropped_attributes_count }
}

///|
/// Starts building a span with the given name.
pub fn SpanBuilder::from_name(name : StringView) -> SpanBuilder {
  {
    span_kind: None,
    name: name.to_string(),
    start_time_unix_nano: None,
    attributes: [],
    events: [],
    links: [],
  }
}

///|
/// Returns a copy of the builder with the given span kind.
pub fn SpanBuilder::with_kind(
  self : SpanBuilder,
  span_kind : SpanKind,
) -> SpanBuilder {
  { ..self, span_kind: Some(span_kind) }
}

///|
/// Returns a copy of the builder with an explicit start timestamp.
pub fn SpanBuilder::with_start_time(
  self : SpanBuilder,
  start_time_unix_nano : Int64,
) -> SpanBuilder {
  { ..self, start_time_unix_nano: Some(start_time_unix_nano) }
}

///|
/// Returns a copy of the builder with the given attribute list.
///
/// This replaces previously stored builder attributes.
pub fn SpanBuilder::with_attributes(
  self : SpanBuilder,
  attributes : ArrayView[@common.KeyValue],
) -> SpanBuilder {
  { ..self, attributes: attributes.to_array() }
}

///|
/// Returns a copy of the builder with the given event list.
///
/// This replaces previously stored builder events.
pub fn SpanBuilder::with_events(
  self : SpanBuilder,
  events : ArrayView[Event],
) -> SpanBuilder {
  { ..self, events: events.to_array() }
}

///|
/// Returns a copy of the builder with the given link list.
///
/// This replaces previously stored builder links.
pub fn SpanBuilder::with_links(
  self : SpanBuilder,
  links : ArrayView[Link],
) -> SpanBuilder {
  { ..self, links: links.to_array() }
}

///|
fn to_sdk_context(context : @context.Context) -> @context_sdk.Context {
  let sdk_context = @context_sdk.Context::empty()
  let sdk_context = match context.span_context() {
    Some(span_context) if span_context.is_remote() =>
      sdk_context.with_remote_span_context(span_context)
    Some(span_context) => sdk_context.with_span_context(span_context)
    None => sdk_context
  }
  let sdk_baggage = {}
  for entry in context.baggage().entries() {
    sdk_baggage[entry.key.as_string()] = entry.value
  }
  sdk_context
  .with_baggage(sdk_baggage)
  .with_telemetry_suppressed(suppressed=context.is_telemetry_suppressed())
}

///|
fn propagated_context(
  parent_context : @context.Context,
  span_context : @common.SpanContext,
) -> @context.Context {
  parent_context.with_span_context(span_context)
}

///|
fn build_sdk_span(
  sdk_tracer : @sdktrace.SdkTracer,
  builder : SpanBuilder,
  parent_context : @context.Context,
) -> Span {
  let links = []
  for link in builder.links {
    if link.span_context.is_valid() {
      links.push(
        @sdktrace.SpanLink::new(link.span_context, attributes=link.attributes),
      )
    }
  }
  let sdk_span = sdk_tracer.start(
    builder.name,
    parent_context=to_sdk_context(parent_context),
    kind=match builder.span_kind {
      Some(kind) => kind
      None => @sdktrace.SpanKind::Internal
    },
    attributes=builder.attributes,
    links~,
    start_time_unix_nano=match builder.start_time_unix_nano {
      Some(start_time) => start_time
      None => @common.now_unix_nano()
    },
  )
  for event in builder.events {
    sdk_span.add_event(
      event.name,
      attributes=event.attributes,
      timestamp_unix_nano=event.timestamp_unix_nano,
    )
  }
  let span_context = sdk_span.span_context()
  {
    sdk_span: Some(sdk_span),
    propagated_span_context: span_context,
    noop_ended: Ref::new(false),
    context: propagated_context(parent_context, span_context),
  }
}

///|
fn build_noop_span(
  builder : SpanBuilder,
  parent_context : @context.Context,
) -> Span {
  ignore(builder)
  let propagated_span_context = match parent_context.span_context() {
    Some(span_context) if span_context.is_valid() => span_context
    _ => @common.SpanContext::empty()
  }
  {
    sdk_span: None,
    propagated_span_context,
    noop_ended: Ref::new(false),
    context: propagated_context(parent_context, propagated_span_context),
  }
}

///|
/// Wraps an SDK tracer provider in the public API type.
pub fn TracerProvider::from_sdk(
  provider : @sdktrace.SdkTracerProvider,
) -> TracerProvider {
  { sdk_provider: Some(provider) }
}

///|
/// Returns a no-op tracer provider.
pub fn TracerProvider::noop() -> TracerProvider {
  { sdk_provider: None }
}

///|
/// Returns a tracer for one instrumentation name.
///
/// If the provider is no-op, the returned tracer creates non-recording spans.
pub fn TracerProvider::tracer(
  self : TracerProvider,
  name : StringView,
) -> Tracer {
  match self.sdk_provider {
    Some(provider) => { sdk_tracer: Some(provider.tracer(name)) }
    None => { sdk_tracer: None }
  }
}

///|
/// Returns a tracer for a fully constructed instrumentation scope.
pub fn TracerProvider::tracer_with_scope(
  self : TracerProvider,
  scope : @common.InstrumentationScope,
) -> Tracer {
  match self.sdk_provider {
    Some(provider) => {
      let tracer = provider.tracer(
        scope.name(),
        version=scope.version(),
        schema_url=scope.schema_url(),
        attributes=scope.attributes(),
      )
      { sdk_tracer: Some(tracer) }
    }
    None => { sdk_tracer: None }
  }
}

///|
/// Flushes the underlying SDK provider.
///
/// No-op providers report success.
pub async fn TracerProvider::force_flush(
  self : TracerProvider,
) -> @error.OTelSdkResult {
  match self.sdk_provider {
    Some(provider) => provider.force_flush()
    None => @error.ok()
  }
}

///|
/// Shuts down the underlying SDK provider.
///
/// No-op providers report success.
pub async fn TracerProvider::shutdown(
  self : TracerProvider,
) -> @error.OTelSdkResult {
  match self.sdk_provider {
    Some(provider) => provider.shutdown()
    None => @error.ok()
  }
}

///|
/// Spawns background loops for batch span processors owned by this provider.
///
/// No-op providers do nothing.
pub fn TracerProvider::spawn_batch_processor_tasks(
  self : TracerProvider,
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  match self.sdk_provider {
    Some(provider) =>
      provider.spawn_batch_processor_tasks(group, allow_failure~)
    None => ()
  }
}

///|
/// Starts a root span with the given name.
pub fn Tracer::start(self : Tracer, name : StringView) -> Span {
  self.start_with_context(name, Default::default())
}

///|
/// Starts a span with an explicit parent context.
pub fn Tracer::start_with_context(
  self : Tracer,
  name : StringView,
  parent_context : @context.Context,
) -> Span {
  self.build_with_context(SpanBuilder::from_name(name), parent_context)
}

///|
/// Returns a fresh span builder for `name`.
pub fn Tracer::span_builder(self : Tracer, name : StringView) -> SpanBuilder {
  ignore(self)
  SpanBuilder::from_name(name)
}

///|
/// Builds a span from a builder with an empty parent context.
pub fn Tracer::build(self : Tracer, builder : SpanBuilder) -> Span {
  self.build_with_context(builder, Default::default())
}

///|
/// Builds a span from a builder and parent context.
///
/// No-op tracers still return a span handle whose context propagates the parent
/// span context.
pub fn Tracer::build_with_context(
  self : Tracer,
  builder : SpanBuilder,
  parent_context : @context.Context,
) -> Span {
  match self.sdk_tracer {
    Some(sdk_tracer) => build_sdk_span(sdk_tracer, builder, parent_context)
    None => build_noop_span(builder, parent_context)
  }
}

///|
/// Runs `f` inside a root span and returns its result.
///
/// The span is ended after `f` returns successfully.
pub async fn[T] Tracer::in_span(
  self : Tracer,
  name : StringView,
  f : async (@context.Context) -> T,
) -> T {
  self.in_span_with_context(name, Default::default(), f)
}

///|
/// Runs `f` inside a span with an explicit parent context.
///
/// The span is ended after `f` returns successfully.
pub async fn[T] Tracer::in_span_with_context(
  self : Tracer,
  name : StringView,
  parent_context : @context.Context,
  f : async (@context.Context) -> T,
) -> T {
  self.in_span_with_builder(SpanBuilder::from_name(name), parent_context, f)
}

///|
/// Runs `f` inside a span built from `builder`.
///
/// The returned child context carries the new span context. The span is ended
/// after `f` returns successfully.
pub async fn[T] Tracer::in_span_with_builder(
  self : Tracer,
  builder : SpanBuilder,
  parent_context : @context.Context,
  f : async (@context.Context) -> T,
) -> T {
  let span = self.build_with_context(builder, parent_context)
  let context = span.context()
  let result = f(context)
  span.end()
  result
}

///|
/// Returns the span context that should be propagated downstream.
pub fn Span::span_context(self : Span) -> @common.SpanContext {
  match self.sdk_span {
    Some(span) => span.span_context()
    None => self.propagated_span_context
  }
}

///|
/// Returns the context that carries this span as the active span.
pub fn Span::context(self : Span) -> @context.Context {
  self.context
}

///|
/// Returns whether the span is currently recording telemetry.
///
/// No-op spans always report `false`.
pub fn Span::is_recording(self : Span) -> Bool {
  match self.sdk_span {
    Some(span) => span.is_recording()
    None => false
  }
}

///|
/// Returns whether the span has already ended.
pub fn Span::has_ended(self : Span) -> Bool {
  match self.sdk_span {
    Some(span) => span.has_ended()
    None => self.noop_ended.val
  }
}

///|
/// Adds one event with the current timestamp.
pub fn Span::add_event(
  self : Span,
  name : StringView,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  self.add_event_with_timestamp(name, @common.now_unix_nano(), attributes~)
}

///|
/// Adds one event with an explicit timestamp.
pub fn Span::add_event_with_timestamp(
  self : Span,
  name : StringView,
  timestamp_unix_nano : Int64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  match self.sdk_span {
    Some(span) => span.add_event(name, attributes~, timestamp_unix_nano~)
    None => ()
  }
}

///|
/// Records an `"exception"` event carrying `exception.message`.
///
/// This helper does not set the span status automatically.
pub fn Span::record_error(self : Span, message : StringView) -> Unit {
  self.add_event("exception", attributes=[
    @common.KeyValue::new(
      "exception.message",
      @common.Value::String(message.to_string()),
    ),
  ])
}

///|
/// Sets or replaces one span attribute.
pub fn Span::set_attribute(self : Span, attribute : @common.KeyValue) -> Unit {
  match self.sdk_span {
    Some(span) => span.set_attribute(attribute.key.as_string(), attribute.value)
    None => ()
  }
}

///|
/// Sets or replaces multiple span attributes.
pub fn Span::set_attributes(
  self : Span,
  attributes : ArrayView[@common.KeyValue],
) -> Unit {
  for attribute in attributes {
    self.set_attribute(attribute)
  }
}

///|
/// Sets the span status.
pub fn Span::set_status(self : Span, status : Status) -> Unit {
  match self.sdk_span {
    Some(span) => span.set_status(status)
    None => ()
  }
}

///|
/// Replaces the span name.
pub fn Span::update_name(self : Span, new_name : StringView) -> Unit {
  match self.sdk_span {
    Some(span) => span.update_name(new_name)
    None => ()
  }
}

///|
/// Adds one link to another span context.
pub fn Span::add_link(
  self : Span,
  span_context : @common.SpanContext,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  match self.sdk_span {
    Some(span) => span.add_link(span_context, attributes~)
    None => ()
  }
}

///|
/// Ends the span with the current timestamp.
pub async fn Span::end(self : Span) -> Unit {
  self.end_with_timestamp(@common.now_unix_nano())
}

///|
/// Ends the span with an explicit timestamp.
///
/// Ending a no-op span only flips its local ended flag.
pub async fn Span::end_with_timestamp(
  self : Span,
  timestamp_unix_nano : Int64,
) -> Unit {
  match self.sdk_span {
    Some(span) => span.end(end_time_unix_nano=timestamp_unix_nano)
    None => self.noop_ended.val = true
  }
}
