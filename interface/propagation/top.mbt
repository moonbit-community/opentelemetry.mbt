///|
/// Write side of a text-map carrier used for outbound propagation.
///
/// Implement this for HTTP header maps or other text carriers that need
/// outgoing trace context and baggage injection.
pub(open) trait Injector {
  set(Self, String, String) -> Unit
}

///|
/// Read side of a text-map carrier used for inbound propagation.
///
/// Implement this for HTTP header maps or other text carriers that need
/// incoming trace context and baggage extraction. `keys()` is optional but lets
/// propagators handle case-insensitive carriers more efficiently.
pub(open) trait Extractor {
  get(Self, StringView) -> String?
  keys(Self) -> Array[String] = _
}

///|
impl Extractor with keys(_) {
  []
}

///|
fn normalize_ascii_lower(value : StringView) -> String {
  let builder = StringBuilder::new()
  for _, ch in value {
    builder.write_char(ch.to_ascii_lowercase())
  }
  builder.to_string()
}

///|
fn get_case_insensitive(
  values : Map[String, String],
  key : StringView,
) -> String? {
  let normalized_key = normalize_ascii_lower(key)
  match values.get_from_string(normalized_key) {
    Some(value) => Some(value)
    None => {
      for candidate_key, candidate_value in values {
        if normalize_ascii_lower(candidate_key) == normalized_key {
          return Some(candidate_value)
        }
      }
      None
    }
  }
}

///|
pub impl Injector for Map[String, String] with set(self, key, value) {
  self[normalize_ascii_lower(key)] = value
}

///|
pub impl Extractor for Map[String, String] with get(self, key) {
  get_case_insensitive(self, key)
}

///|
fn merge_baggage(
  current : @baggage.Baggage,
  incoming : @baggage.Baggage,
) -> @baggage.Baggage {
  let mut merged = current
  for entry in incoming.entries() {
    merged = merged.insert_with_metadata(
      entry.key.as_string(),
      entry.value,
      entry.metadata,
    )
  }
  merged
}

///|
pub impl Extractor for Map[String, String] with keys(self) {
  self.keys().to_array()
}

///|
/// Erased text-map propagator built from inject/extract callbacks.
///
/// Use this as the common type for concrete propagators and custom propagation
/// formats.
pub struct TextMapPropagator {
  inject_fn : (@context.Context, &Injector) -> Unit
  extract_fn : (@context.Context, &Extractor) -> @context.Context
  fields_fn : () -> Array[String]
}

///|
/// W3C baggage propagator wrapper.
///
/// Reads and writes the `baggage` header.
pub struct BaggagePropagator {
  inner : TextMapPropagator
}

///|
/// W3C trace-context propagator wrapper.
///
/// Reads and writes `traceparent` and `tracestate`.
pub struct TraceContextPropagator {
  inner : TextMapPropagator
}

///|
/// Composite propagator that applies multiple propagators in sequence.
///
/// The default global propagator uses this to combine trace context and
/// baggage.
pub struct TextMapCompositePropagator {
  inner : TextMapPropagator
}

///|
/// Creates a custom text-map propagator from inject/extract/fields callbacks.
pub fn TextMapPropagator::from_functions(
  inject_fn : (@context.Context, &Injector) -> Unit,
  extract_fn : (@context.Context, &Extractor) -> @context.Context,
  fields_fn : () -> Array[String],
) -> TextMapPropagator {
  { inject_fn, extract_fn, fields_fn }
}

///|
/// Injects values from `context` into the supplied carrier.
///
/// Call this before making an outbound request so downstream services can join
/// the same trace and receive baggage.
pub fn TextMapPropagator::inject_context(
  self : TextMapPropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  (self.inject_fn)(context, injector)
}

///|
/// Extracts values from the carrier and returns an updated context.
///
/// Call this when handling an inbound request, then use the returned context as
/// the parent context for server spans and downstream work.
pub fn TextMapPropagator::extract_with_context(
  self : TextMapPropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  (self.extract_fn)(context, extractor)
}

///|
/// Returns the header names this propagator may read or write.
pub fn TextMapPropagator::fields(self : TextMapPropagator) -> Array[String] {
  (self.fields_fn)()
}

///|
fn hex_digit(value : Int) -> String {
  if value < 10 {
    value.to_string()
  } else {
    (value - 10 + 'A'.to_int()).unsafe_to_char().to_string()
  }
}

///|
fn write_percent_encoded(builder : StringBuilder, ch : Char) -> Unit {
  let value = ch.to_int()
  builder.write_char('%')
  builder.write_string(hex_digit(value / 16))
  builder.write_string(hex_digit(value % 16))
}

///|
fn is_unreserved_baggage_char(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') ||
  (ch >= 'A' && ch <= 'Z') ||
  (ch >= '0' && ch <= '9') ||
  ch == '-' ||
  ch == '.' ||
  ch == '_' ||
  ch == '~'
}

///|
fn encode_baggage_component(value : StringView) -> String {
  let builder = StringBuilder::new()
  for _, ch in value {
    if is_unreserved_baggage_char(ch) {
      builder.write_char(ch)
    } else if ch.to_int() <= 127 {
      write_percent_encoded(builder, ch)
    } else {
      builder.write_char(ch)
    }
  }
  builder.to_string()
}

///|
fn is_hex_digit(value : StringView) -> Bool {
  value.length() == 1 &&
  (
    (value >= "0" && value <= "9") ||
    (value >= "a" && value <= "f") ||
    (value >= "A" && value <= "F")
  )
}

///|
fn decode_baggage_component(value : StringView) -> String {
  let builder = StringBuilder::new()
  let mut index = 0
  while index < value.length() {
    let ch = value[index:index + 1]
    if ch == "%" &&
      index + 2 < value.length() &&
      is_hex_digit(value[index + 1:index + 2]) &&
      is_hex_digit(value[index + 2:index + 3]) {
      let part = value[index + 1:index + 3].to_string()
      let decoded = @string.parse_int(part, base=16) catch { _ => -1 }
      if decoded >= 0 && decoded < 128 {
        match decoded.to_char() {
          Some(decoded_char) => builder.write_char(decoded_char)
          None => builder.write_string(value[index:index + 3].to_string())
        }
      } else {
        builder.write_string(value[index:index + 3].to_string())
      }
      index += 3
    } else {
      builder.write_string(ch.to_string())
      index += 1
    }
  }
  builder.to_string()
}

///|
fn encode_baggage(baggage : @baggage.Baggage) -> String? {
  if baggage.is_empty() {
    return None
  }
  let builder = StringBuilder::new()
  let mut is_first = true
  for entry in baggage.entries() {
    let key = entry.key.as_string().trim()
    if key == "" {
      continue
    }
    if !is_first {
      builder.write_char(',')
    }
    is_first = false
    builder.write_string(encode_baggage_component(key))
    builder.write_char('=')
    builder.write_string(encode_baggage_component(entry.value.trim()))
    let metadata = entry.metadata.as_string()
    if metadata != "" {
      builder.write_char(';')
      builder.write_string(metadata)
    }
  }
  Some(builder.to_string())
}

///|
fn decode_baggage(header : StringView) -> @baggage.Baggage {
  let mut baggage : @baggage.Baggage = Default::default()
  for item in header.split(",") {
    let item = item.trim()
    if item.is_empty() {
      continue
    }
    let baggage_item = match item.find(";") {
      Some(index) => (item[:index], item[index + 1:])
      None => (item, "")
    }
    guard baggage_item.0.find("=") is Some(index)
    let key = decode_baggage_component(baggage_item.0[:index].trim())
      .trim()
      .to_string()
    let value = decode_baggage_component(baggage_item.0[index + 1:].trim())
      .trim()
      .to_string()
    baggage = baggage.insert_with_metadata(
      key,
      value,
      @baggage.BaggageMetadata::new(baggage_item.1),
    )
  }
  baggage
}

///|
fn is_lower_hex(value : StringView) -> Bool {
  for _, ch in value {
    if !((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f')) {
      return false
    }
  }
  true
}

///|
fn masked_trace_flags(trace_flags : @common.TraceFlags) -> @common.TraceFlags {
  let masked : @common.TraceFlags = Default::default()
  masked.with_sampled(trace_flags.is_sampled())
}

///|
fn extract_span_context(extractor : &Extractor) -> @common.SpanContext? {
  guard extractor.get("traceparent") is Some(traceparent) else { return None }
  let traceparent = traceparent.trim()
  let parts = traceparent.split("-").to_array()
  if parts.length() < 4 {
    return None
  }
  let version = parts[0]
  if version.length() != 2 || !is_lower_hex(version) {
    return None
  }
  let version = @string.parse_int(version.to_string(), base=16) catch {
    _ => return None
  }
  if version > 254 || (version == 0 && parts.length() != 4) {
    return None
  }
  let trace_id_part = parts[1]
  let span_id_part = parts[2]
  let trace_flags_part = parts[3]
  if trace_id_part.length() != 32 ||
    span_id_part.length() != 16 ||
    trace_flags_part.length() != 2 ||
    !is_lower_hex(trace_id_part) ||
    !is_lower_hex(span_id_part) ||
    !is_lower_hex(trace_flags_part) {
    return None
  }
  guard @common.TraceId::from_hex(trace_id_part) is Some(trace_id) else {
    return None
  }
  guard @common.SpanId::from_hex(span_id_part) is Some(span_id) else {
    return None
  }
  guard @common.TraceFlags::from_hex(trace_flags_part) is Some(trace_flags) else {
    return None
  }
  let trace_state = match extractor.get("tracestate") {
    Some(value) => @common.TraceState::from_header(value)
    None => Default::default()
  }
  let span_context = @common.SpanContext::new(
    trace_id,
    span_id,
    trace_flags=masked_trace_flags(trace_flags),
    is_remote=true,
    trace_state~,
  )
  if !span_context.is_valid() {
    None
  } else {
    Some(span_context)
  }
}

///|
/// Creates a baggage propagator that reads and writes the `baggage` header.
///
/// Extraction is forgiving: malformed entries are ignored and valid entries are
/// merged into the provided context.
pub fn BaggagePropagator::new() -> BaggagePropagator {
  {
    inner: TextMapPropagator::from_functions(
      (context, injector) => {
        if encode_baggage(context.baggage()) is Some(header) {
          injector.set("baggage", header)
        }
      },
      (context, extractor) => {
        if extractor.get("baggage") is Some(header) {
          context.with_baggage(
            merge_baggage(context.baggage(), decode_baggage(header)),
          )
        } else {
          context
        }
      },
      () => ["baggage"],
    ),
  }
}

///|
/// Injects baggage from `context` into the carrier.
pub fn BaggagePropagator::inject_context(
  self : BaggagePropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
/// Extracts baggage from the carrier and returns an updated context.
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
/// Creates a trace-context propagator that reads and writes `traceparent` and
/// `tracestate`.
///
/// Invalid headers are ignored and leave the incoming context unchanged.
pub fn TraceContextPropagator::new() -> TraceContextPropagator {
  {
    inner: TextMapPropagator::from_functions(
      (context, injector) => {
        match context.span_context() {
          Some(span_context) if span_context.is_valid() => {
            injector.set(
              "traceparent",
              "00-\{span_context.trace_id().to_hex()}-\{span_context.span_id().to_hex()}-\{span_context.trace_flags().to_hex()}",
            )
            if span_context.trace_state().to_header() is Some(tracestate) {
              injector.set("tracestate", tracestate)
            }
          }
          _ => ()
        }
      },
      (context, extractor) => {
        match extract_span_context(extractor) {
          Some(span_context) => context.with_remote_span_context(span_context)
          None => context
        }
      },
      () => ["traceparent", "tracestate"],
    ),
  }
}

///|
/// Injects the current span context into the carrier when it is valid.
pub fn TraceContextPropagator::inject_context(
  self : TraceContextPropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
/// Extracts a remote span context from the carrier when the headers are valid.
pub fn TraceContextPropagator::extract_with_context(
  self : TraceContextPropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  self.inner.extract_with_context(context, extractor)
}

///|
/// Erases the concrete trace-context propagator type into `TextMapPropagator`.
pub fn TraceContextPropagator::into_text_map(
  self : TraceContextPropagator,
) -> TextMapPropagator {
  self.inner
}

///|
/// Creates a propagator that runs multiple propagators in order.
///
/// Injection runs every propagator. Extraction threads the context through the
/// propagators from left to right. Reported fields are de-duplicated.
pub fn TextMapCompositePropagator::new(
  propagators : ArrayView[TextMapPropagator],
) -> TextMapCompositePropagator {
  let propagators = propagators.to_array()
  {
    inner: TextMapPropagator::from_functions(
      (context, injector) => {
        for propagator in propagators {
          propagator.inject_context(context, injector)
        }
      },
      (context, extractor) => {
        let mut current = context
        for propagator in propagators {
          current = propagator.extract_with_context(current, extractor)
        }
        current
      },
      () => {
        let fields : Map[String, Unit] = {}
        for propagator in propagators {
          for field in propagator.fields() {
            fields[field] = ()
          }
        }
        fields.keys().to_array()
      },
    ),
  }
}

///|
/// Injects using every child propagator in order.
pub fn TextMapCompositePropagator::inject_context(
  self : TextMapCompositePropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
/// Extracts using every child propagator in order.
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
