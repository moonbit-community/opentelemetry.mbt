///|
pub(open) trait Injector {
  set(Self, String, String) -> Unit
}

///|
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
pub impl Injector for Map[String, String] with set(self, key, value) {
  self[normalize_ascii_lower(key)] = value
}

///|
pub impl Extractor for Map[String, String] with get(self, key) {
  self.get_from_string(normalize_ascii_lower(key))
}

///|
pub impl Extractor for Map[String, String] with keys(self) {
  self.keys().to_array()
}

///|
pub struct TextMapPropagator {
  inject_fn : (@context.Context, &Injector) -> Unit
  extract_fn : (@context.Context, &Extractor) -> @context.Context
  fields_fn : () -> Array[String]
}

///|
pub struct BaggagePropagator {
  inner : TextMapPropagator
}

///|
pub struct TraceContextPropagator {
  inner : TextMapPropagator
}

///|
pub struct TextMapCompositePropagator {
  inner : TextMapPropagator
}

///|
pub fn TextMapPropagator::from_functions(
  inject_fn : (@context.Context, &Injector) -> Unit,
  extract_fn : (@context.Context, &Extractor) -> @context.Context,
  fields_fn : () -> Array[String],
) -> TextMapPropagator {
  { inject_fn, extract_fn, fields_fn }
}

///|
pub fn TextMapPropagator::inject_context(
  self : TextMapPropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  (self.inject_fn)(context, injector)
}

///|
pub fn TextMapPropagator::extract_with_context(
  self : TextMapPropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  (self.extract_fn)(context, extractor)
}

///|
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
pub fn BaggagePropagator::inject_context(
  self : BaggagePropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
pub fn BaggagePropagator::extract_with_context(
  self : BaggagePropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  self.inner.extract_with_context(context, extractor)
}

///|
pub fn BaggagePropagator::into_text_map(
  self : BaggagePropagator,
) -> TextMapPropagator {
  self.inner
}

///|
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
pub fn TraceContextPropagator::inject_context(
  self : TraceContextPropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
pub fn TraceContextPropagator::extract_with_context(
  self : TraceContextPropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  self.inner.extract_with_context(context, extractor)
}

///|
pub fn TraceContextPropagator::into_text_map(
  self : TraceContextPropagator,
) -> TextMapPropagator {
  self.inner
}

///|
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
pub fn TextMapCompositePropagator::inject_context(
  self : TextMapCompositePropagator,
  context : @context.Context,
  injector : &Injector,
) -> Unit {
  self.inner.inject_context(context, injector)
}

///|
pub fn TextMapCompositePropagator::extract_with_context(
  self : TextMapCompositePropagator,
  context : @context.Context,
  extractor : &Extractor,
) -> @context.Context {
  self.inner.extract_with_context(context, extractor)
}

///|
pub fn TextMapCompositePropagator::into_text_map(
  self : TextMapCompositePropagator,
) -> TextMapPropagator {
  self.inner
}
