///|
/// Outbound text carrier writer.
pub(open) trait Injector {
  set(Self, String, String) -> Unit
}

///|
/// Inbound text carrier reader.
pub(open) trait Extractor {
  get(Self, StringView) -> String?
  keys(Self) -> Array[String] = _
}

///|
impl Extractor with keys(_) {
  []
}

///|
pub impl Injector for Map[String, String] with set(self, key, value) {
  self[key] = value
}

///|
pub impl Extractor for Map[String, String] with get(self, key) {
  self.get_from_string(key)
}

///|
pub impl Extractor for Map[String, String] with keys(self) {
  self.keys().to_array()
}

///|
/// Signal-agnostic text map propagator.
pub struct TextMapPropagator {
  inject_fn : (@context.Context, &Injector) -> Unit
  extract_fn : (@context.Context, &Extractor) -> @context.Context
  fields_fn : () -> Array[String]
}

///|
/// Builds a text map propagator from inject, extract, and field callbacks.
pub fn TextMapPropagator::from_functions(
  inject_fn : (@context.Context, &Injector) -> Unit,
  extract_fn : (@context.Context, &Extractor) -> @context.Context,
  fields_fn : () -> Array[String],
) -> TextMapPropagator {
  { inject_fn, extract_fn, fields_fn }
}

///|
/// Injects context values into an outbound carrier.
pub fn TextMapPropagator::inject_context(
  self : TextMapPropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  (self.inject_fn)(context, injector)
}

///|
/// Extracts context values from an inbound carrier and merges them into the
/// provided context.
pub fn TextMapPropagator::extract_with_context(
  self : TextMapPropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  (self.extract_fn)(context, extractor)
}

///|
/// Returns the header fields this propagator reads or writes.
pub fn TextMapPropagator::fields(self : TextMapPropagator) -> Array[String] {
  (self.fields_fn)()
}

///|
/// Propagates the OpenTelemetry `baggage` header.
pub struct BaggagePropagator {
  inner : TextMapPropagator
}

///|
/// Propagates W3C `traceparent` and `tracestate` headers.
pub struct TraceContextPropagator {
  inner : TextMapPropagator
}

///|
/// Chains multiple text map propagators in order.
pub struct TextMapCompositePropagator {
  inner : TextMapPropagator
}

///|
fn encode_baggage(baggage : @context.Baggage) -> String? {
  if baggage.is_empty() {
    return None
  }
  let builder = StringBuilder::new()
  let mut is_first = true
  for key, value in baggage {
    if !is_first {
      builder.write_char(',')
    }
    is_first = false
    builder.write_string(key)
    builder.write_char('=')
    builder.write_string(value)
  }
  Some(builder.to_string())
}

///|
fn decode_baggage(header : StringView) -> @context.Baggage {
  let baggage : @context.Baggage = {}
  for item in header.split(",") {
    let item = item.trim()
    if item.is_empty() {
      continue
    }
    guard item.find("=") is Some(index)
    let key = item[:index].trim().to_string()
    let value = item[index + 1:].trim().to_string()
    if key != "" {
      baggage[key] = value
    }
  }
  baggage
}

///|
/// Creates a baggage propagator. Empty baggage is not injected.
pub fn BaggagePropagator::new() -> BaggagePropagator {
  {
    inner: TextMapPropagator::from_functions(
      (context : @context.Context, injector : &Injector) => {
        if encode_baggage(context.baggage()) is Some(header) {
          injector.set("baggage", header)
        }
      },
      (context : @context.Context, extractor : &Extractor) => {
        if extractor.get("baggage") is Some(header) {
          context.with_baggage(decode_baggage(header))
        } else {
          context
        }
      },
      () => ["baggage"],
    ),
  }
}

///|
/// Injects baggage into the outbound carrier.
pub fn BaggagePropagator::inject_context(
  self : BaggagePropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
/// Extracts baggage from the inbound carrier.
pub fn BaggagePropagator::extract_with_context(
  self : BaggagePropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  self.inner.extract_with_context(context, extractor)
}

///|
/// Erases the concrete baggage propagator type into `TextMapPropagator`.
pub fn BaggagePropagator::into_text_map(
  self : BaggagePropagator,
) -> TextMapPropagator {
  self.inner
}

///|
/// Creates a trace context propagator. Invalid headers are ignored and leave
/// the input context unchanged.
pub fn TraceContextPropagator::new() -> TraceContextPropagator {
  {
    inner: TextMapPropagator::from_functions(
      (context : @context.Context, injector : &Injector) => {
        match context.span_context() {
          Some(span_context) if span_context.is_valid() => {
            // The current implementation always emits version `00` and uses the
            // canonical lowercase hexadecimal identifiers from the span context.
            let traceparent = "00-\{span_context.trace_id().to_hex()}-\{span_context.span_id().to_hex()}-\{span_context.trace_flags().to_hex()}"
            injector.set("traceparent", traceparent)
            if span_context.trace_state().to_header() is Some(tracestate) {
              injector.set("tracestate", tracestate)
            }
          }
          _ => ()
        }
      },
      (context : @context.Context, extractor : &Extractor) => {
        guard extractor.get("traceparent") is Some(traceparent) else {
          return context
        }
        // Extraction is deliberately forgiving: malformed carriers are skipped
        // instead of failing the entire request path.
        let parts = traceparent.split("-").to_array()
        if parts.length() != 4 {
          return context
        }
        guard @common.TraceId::from_hex(parts[1]) is Some(trace_id) else {
          return context
        }
        guard @common.SpanId::from_hex(parts[2]) is Some(span_id) else {
          return context
        }
        guard @common.TraceFlags::from_hex(parts[3]) is Some(trace_flags) else {
          return context
        }
        let trace_state = match extractor.get("tracestate") {
          Some(value) => @common.TraceState::from_header(value)
          None => Default::default()
        }
        let span_context = @common.SpanContext::new(
          trace_id,
          span_id,
          trace_flags~,
          is_remote=true,
          trace_state~,
        )
        context.with_remote_span_context(span_context)
      },
      () => ["traceparent", "tracestate"],
    ),
  }
}

///|
/// Injects trace context into the outbound carrier.
pub fn TraceContextPropagator::inject_context(
  self : TraceContextPropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
/// Extracts trace context from the inbound carrier.
pub fn TraceContextPropagator::extract_with_context(
  self : TraceContextPropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  self.inner.extract_with_context(context, extractor)
}

///|
/// Erases the concrete trace context propagator type into `TextMapPropagator`.
pub fn TraceContextPropagator::into_text_map(
  self : TraceContextPropagator,
) -> TextMapPropagator {
  self.inner
}

///|
/// Creates a propagator that runs each propagator in order for injection and
/// extraction.
pub fn TextMapCompositePropagator::new(
  propagators : ArrayView[TextMapPropagator],
) -> TextMapCompositePropagator {
  let propagators = propagators.to_array()
  {
    inner: TextMapPropagator::from_functions(
      (context : @context.Context, injector : &Injector) => {
        for propagator in propagators {
          propagator.inject_context(context, injector)
        }
      },
      (context : @context.Context, extractor : &Extractor) => {
        let mut current = context
        for propagator in propagators {
          current = propagator.extract_with_context(current, extractor)
        }
        current
      },
      () => {
        let fields = []
        for propagator in propagators {
          fields.append(propagator.fields())
        }
        fields
      },
    ),
  }
}

///|
/// Injects context with all child propagators.
pub fn TextMapCompositePropagator::inject_context(
  self : TextMapCompositePropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
/// Extracts context with all child propagators in sequence.
pub fn TextMapCompositePropagator::extract_with_context(
  self : TextMapCompositePropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  self.inner.extract_with_context(context, extractor)
}

///|
/// Erases the concrete composite propagator type into `TextMapPropagator`.
pub fn TextMapCompositePropagator::into_text_map(
  self : TextMapCompositePropagator,
) -> TextMapPropagator {
  self.inner
}
