///|
/// OpenTelemetry span kind.
///
/// Use `Server` for inbound request handlers, `Client` for outbound requests,
/// `Producer`/`Consumer` for messaging, and `Internal` for local work.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spankind
pub(all) enum SpanKind {
  Internal
  Client
  Server
  Producer
  Consumer
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Span status code: unset, ok, or error.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub(all) enum StatusCode {
  Unset
  Ok
  Error
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Span status with a code and optional description.
///
/// Status represents the final outcome of the operation. Recording an exception
/// event does not automatically set status; call `Span::set_status()` when the
/// operation should be marked as an error.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub struct Status {
  code : StatusCode
  description : String?
} derive(Eq, ToJson, Debug)

///|
/// Event attached to a span builder.
///
/// Events represent timestamped facts that happened during a span, such as a
/// retry, cache miss, or exception. Use attributes for event-specific detail.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
pub struct Event {
  name : String
  timestamp_unix_nano : Int64
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
} derive(Eq, ToJson, Debug)

///|
/// Link attached to a span builder.
///
/// Links connect this span to another span context without making that span the
/// parent. They are useful for queues, batch jobs, and fan-in/fan-out workflows.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#link
pub struct Link {
  span_context : @common.SpanContext
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
} derive(Eq, ToJson, Debug)

///|
/// Immutable span-construction descriptor used by `Tracer::build*()`.
///
/// Use a builder when a span needs non-default kind, explicit start time,
/// initial attributes, events, or links. For simple spans, `Tracer::start()` is
/// shorter.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
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
/// A span represents one in-flight operation. When created from a no-op tracer,
/// the span still propagates a valid parent context but does not record data.
/// End spans once the represented operation is complete.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span
pub struct Span {
  span_context_fn : () -> @common.SpanContext
  context_fn : () -> @context.Context
  is_recording_fn : () -> Bool
  has_ended_fn : () -> Bool
  add_event_fn : (StringView, Int64, ArrayView[@common.KeyValue]) -> Unit
  set_attribute_fn : (@common.KeyValue) -> Unit
  set_status_fn : (Status) -> Unit
  update_name_fn : (StringView) -> Unit
  add_link_fn : (@common.SpanContext, ArrayView[@common.KeyValue]) -> Unit
  end_fn : async (Int64) -> Unit
}

///|
/// Public tracer handle.
///
/// A tracer creates spans for one instrumentation scope. Tracers are cheap
/// handles; libraries normally keep or reacquire one by instrumentation name.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracer
pub struct Tracer {
  build_with_context_fn : (SpanBuilder, @context.Context) -> Span
}

///|
/// Public tracer provider.
///
/// The default provider is no-op. Applications install SDK-backed providers
/// through the SDK facade while library code depends only on this API type.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracerprovider
pub struct TracerProvider {
  tracer_with_scope_fn : (@common.InstrumentationScope) -> Tracer
}

///|
/// Creates a span status.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub fn Status::new(code : StatusCode, description? : String? = None) -> Status {
  { code, description, }
}

///|
/// Returns the default unset status.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub fn Status::unset() -> Status {
  Status::new(Unset)
}

///|
/// Returns an ok status.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub fn Status::ok() -> Status {
  Status::new(Ok)
}

///|
/// Returns an error status with an optional description.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub fn Status::error(description? : String? = None) -> Status {
  Status::new(Error, description~)
}

///|
pub impl Default for Status with fn default() -> Status {
  Status::unset()
}

///|
/// Creates one span event.
///
/// The timestamp defaults to the current Unix time in nanoseconds. Events added
/// to a no-op span are ignored.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
pub fn Event::new(
  name : StringView,
  timestamp_unix_nano? : Int64 = @utils.now_unix_nano(),
  attributes? : ArrayView[@common.KeyValue] = [],
  dropped_attributes_count? : Int = 0,
) -> Event {
  {
    name: name.to_owned(),
    timestamp_unix_nano,
    attributes: attributes.to_owned(),
    dropped_attributes_count,
  }
}

///|
/// Creates one span link.
///
/// Invalid linked span contexts are ignored later when the span is built. Links
/// do not affect parent/child relationships.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#link
pub fn Link::new(
  span_context : @common.SpanContext,
  attributes? : ArrayView[@common.KeyValue] = [],
  dropped_attributes_count? : Int = 0,
) -> Link {
  { span_context, attributes: attributes.to_owned(), dropped_attributes_count, }
}

///|
/// Starts building a span with the given operation name.
///
/// Names should be low-cardinality and describe the operation shape, such as
/// `http.request`, `db.query`, or `queue.publish`, not a user-specific value.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn SpanBuilder::from_name(name : StringView) -> SpanBuilder {
  {
    span_kind: None,
    name: name.to_owned(),
    start_time_unix_nano: None,
    attributes: [],
    events: [],
    links: [],
  }
}

///|
/// Returns a copy of the builder with the given span kind.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn SpanBuilder::with_kind(
  self : SpanBuilder,
  span_kind : SpanKind,
) -> SpanBuilder {
  { ..self, span_kind: Some(span_kind), }
}

///|
/// Returns a copy of the builder with an explicit start timestamp.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn SpanBuilder::with_start_time(
  self : SpanBuilder,
  start_time_unix_nano : Int64,
) -> SpanBuilder {
  { ..self, start_time_unix_nano: Some(start_time_unix_nano), }
}

///|
/// Returns a copy of the builder with the given attribute list.
///
/// This replaces previously stored builder attributes.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn SpanBuilder::with_attributes(
  self : SpanBuilder,
  attributes : ArrayView[@common.KeyValue],
) -> SpanBuilder {
  { ..self, attributes: attributes.to_owned(), }
}

///|
/// Returns a copy of the builder with the given event list.
///
/// This replaces previously stored builder events.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn SpanBuilder::with_events(
  self : SpanBuilder,
  events : ArrayView[Event],
) -> SpanBuilder {
  { ..self, events: events.to_owned(), }
}

///|
/// Returns a copy of the builder with the given link list.
///
/// This replaces previously stored builder links.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#specifying-links
pub fn SpanBuilder::with_links(
  self : SpanBuilder,
  links : ArrayView[Link],
) -> SpanBuilder {
  { ..self, links: links.to_owned(), }
}

///|
fn propagated_context(
  parent_context : @context.Context,
  span_context : @common.SpanContext,
) -> @context.Context {
  parent_context.with_span_context(span_context)
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
  let ended = Ref(false)
  let context = propagated_context(parent_context, propagated_span_context)
  Span::from_functions(
    () => propagated_span_context,
    () => context,
    () => false,
    () => ended.val,
    (_, _, _) => (),
    _ => (),
    _ => (),
    _ => (),
    (_, _) => (),
    _ => ended.val = true,
  )
}

///|
/// Builds a span handle from callbacks.
///
/// SDK implementations use this to erase their concrete span type into the
/// public API without making the API package depend on the SDK.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span
pub fn Span::from_functions(
  span_context_fn : () -> @common.SpanContext,
  context_fn : () -> @context.Context,
  is_recording_fn : () -> Bool,
  has_ended_fn : () -> Bool,
  add_event_fn : (StringView, Int64, ArrayView[@common.KeyValue]) -> Unit,
  set_attribute_fn : (@common.KeyValue) -> Unit,
  set_status_fn : (Status) -> Unit,
  update_name_fn : (StringView) -> Unit,
  add_link_fn : (@common.SpanContext, ArrayView[@common.KeyValue]) -> Unit,
  end_fn : async (Int64) -> Unit,
) -> Span {
  {
    span_context_fn,
    context_fn,
    is_recording_fn,
    has_ended_fn,
    add_event_fn,
    set_attribute_fn,
    set_status_fn,
    update_name_fn,
    add_link_fn,
    end_fn,
  }
}

///|
/// Builds a tracer from a span-building callback.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracer
pub fn Tracer::from_functions(
  build_with_context_fn : (SpanBuilder, @context.Context) -> Span,
) -> Tracer {
  { build_with_context_fn, }
}

///|
/// Builds a tracer provider from a scope-to-tracer callback.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracerprovider
pub fn TracerProvider::from_functions(
  tracer_with_scope_fn : (@common.InstrumentationScope) -> Tracer,
) -> TracerProvider {
  { tracer_with_scope_fn, }
}

///|
/// Returns a no-op tracer provider.
///
/// Tracers from this provider create non-recording spans. Valid parent context
/// is still propagated so downstream services can continue an existing trace.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#behavior-of-the-api-in-the-absence-of-an-installed-sdk
pub fn TracerProvider::noop() -> TracerProvider {
  TracerProvider::from_functions(_ => {
    Tracer::from_functions((builder, parent_context) => {
      build_noop_span(builder, parent_context)
    })
  })
}

///|
/// Returns a tracer for one instrumentation name.
///
/// If the provider is no-op, the returned tracer creates non-recording spans.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#get-a-tracer
pub fn TracerProvider::tracer(
  self : TracerProvider,
  name : StringView,
) -> Tracer {
  self.tracer_with_scope(@common.InstrumentationScope::builder(name).build())
}

///|
/// Returns a tracer for a fully constructed instrumentation scope.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#get-a-tracer
pub fn TracerProvider::tracer_with_scope(
  self : TracerProvider,
  scope : @common.InstrumentationScope,
) -> Tracer {
  (self.tracer_with_scope_fn)(scope)
}

///|
/// Starts a root span with the given name.
///
/// Use `start_with_context()` when handling an inbound request with an extracted
/// parent context.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn Tracer::start(self : Tracer, name : StringView) -> Span {
  self.start_with_context(name, Default::default())
}

///|
/// Starts a span with an explicit parent context.
///
/// This is the usual entry point after extracting inbound propagation headers or
/// when passing a parent context through asynchronous work.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn Tracer::start_with_context(
  self : Tracer,
  name : StringView,
  parent_context : @context.Context,
) -> Span {
  self.build_with_context(SpanBuilder::from_name(name), parent_context)
}

///|
/// Returns a fresh span builder for `name`.
///
/// The returned builder is independent of the tracer until passed to
/// `build()` or `build_with_context()`.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn Tracer::span_builder(self : Tracer, name : StringView) -> SpanBuilder {
  ignore(self)
  SpanBuilder::from_name(name)
}

///|
/// Builds a span from a builder with an empty parent context.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn Tracer::build(self : Tracer, builder : SpanBuilder) -> Span {
  self.build_with_context(builder, Default::default())
}

///|
/// Builds a span from a builder and parent context.
///
/// No-op tracers still return a span handle whose context propagates the parent
/// span context.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
pub fn Tracer::build_with_context(
  self : Tracer,
  builder : SpanBuilder,
  parent_context : @context.Context,
) -> Span {
  (self.build_with_context_fn)(builder, parent_context)
}

///|
/// Runs `f` inside a root span and returns its result.
///
/// The span is ended after `f` returns successfully. If `f` can fail, record
/// error status or events before returning from the callback.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
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
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
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
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
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
///
/// For no-op spans this may be the valid incoming parent context rather than a
/// newly recorded span context.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#get-context
pub fn Span::span_context(self : Span) -> @common.SpanContext {
  (self.span_context_fn)()
}

///|
/// Returns the context that carries this span as the active span.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#get-context
pub fn Span::context(self : Span) -> @context.Context {
  (self.context_fn)()
}

///|
/// Returns whether the span is currently recording telemetry.
///
/// No-op spans and sampled-out SDK spans report `false`. Use this to avoid
/// constructing expensive attributes or events.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#isrecording
pub fn Span::is_recording(self : Span) -> Bool {
  (self.is_recording_fn)()
}

///|
/// Returns whether the span has already ended.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#end
pub fn Span::has_ended(self : Span) -> Bool {
  (self.has_ended_fn)()
}

///|
/// Adds one event with the current timestamp.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
pub fn Span::add_event(
  self : Span,
  name : StringView,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  self.add_event_with_timestamp(name, @utils.now_unix_nano(), attributes~)
}

///|
/// Adds one event with an explicit timestamp.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
pub fn Span::add_event_with_timestamp(
  self : Span,
  name : StringView,
  timestamp_unix_nano : Int64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_event_fn)(name, timestamp_unix_nano, attributes)
}

///|
/// Records an `"exception"` event carrying `exception.message`.
///
/// This helper does not set the span status automatically. Call
/// `set_status(Status::error(...))` if the operation should be marked failed.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
pub fn Span::record_error(self : Span, message : StringView) -> Unit {
  self.add_event("exception", attributes=[
    @common.KeyValue::new("exception.message", String(message.to_owned())),
  ])
}

///|
/// Sets or replaces one span attribute.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes
pub fn Span::set_attribute(self : Span, attribute : @common.KeyValue) -> Unit {
  (self.set_attribute_fn)(attribute)
}

///|
/// Sets or replaces multiple span attributes.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes
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
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
pub fn Span::set_status(self : Span, status : Status) -> Unit {
  (self.set_status_fn)(status)
}

///|
/// Replaces the span name.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#updatename
pub fn Span::update_name(self : Span, new_name : StringView) -> Unit {
  (self.update_name_fn)(new_name)
}

///|
/// Adds one link to another span context.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#add-link
pub fn Span::add_link(
  self : Span,
  span_context : @common.SpanContext,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_link_fn)(span_context, attributes)
}

///|
/// Ends the span with the current timestamp.
///
/// Ending an SDK span may notify processors and exporters. Ending a no-op span
/// only updates local state.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#end
pub async fn Span::end(self : Span) -> Unit {
  self.end_with_timestamp(@utils.now_unix_nano())
}

///|
/// Ends the span with an explicit timestamp.
///
/// Ending a no-op span only flips its local ended flag.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#end
pub async fn Span::end_with_timestamp(
  self : Span,
  timestamp_unix_nano : Int64,
) -> Unit {
  (self.end_fn)(timestamp_unix_nano)
}
