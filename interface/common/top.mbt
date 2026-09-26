///|
/// Shared attribute key used across traces, logs, metrics, and resources.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#attribute
pub struct Key {
  name : String
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Creates a key from its canonical string representation.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#attribute
pub fn Key::new(name : StringView) -> Key {
  { name: name.to_owned(), }
}

///|
/// Returns the original key name.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#attribute
pub fn Key::as_string(self : Key) -> String {
  self.name
}

///|
pub impl Default for Key with fn default() -> Key {
  Key::new("")
}

///|
/// Attribute value supported by this SDK implementation.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#anyvalue
pub(all) enum Value {
  Bool(Bool)
  Int64(Int64)
  Double(Double)
  String(String)
  Bytes(Bytes)
  Array(Array[Value])
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Pair of attribute key and value.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#attribute
pub struct KeyValue {
  key : Key
  value : Value
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Creates a key/value pair using a string key.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/#attribute
pub fn KeyValue::new(key : StringView, value : Value) -> KeyValue {
  { key: Key::new(key), value, }
}

///|
/// Parsed representation of the W3C `tracestate` header.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub struct TraceState {
  entries : Map[String, String]
} derive(Eq, ToJson, Debug)

///|
/// Creates trace state from a full entry map.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn TraceState::new(entries : Map[String, String]) -> TraceState {
  { entries, }
}

///|
/// Returns an empty trace state.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn TraceState::empty() -> TraceState {
  { entries: {}, }
}

///|
/// Looks up one trace state member by key.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn TraceState::get(self : TraceState, key : StringView) -> String? {
  self.entries.get_from_string(key)
}

///|
/// Returns a copy with one key updated or inserted.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn TraceState::set(
  self : TraceState,
  key : StringView,
  value : StringView,
) -> TraceState {
  let entries = self.entries.copy()
  entries[key.to_owned()] = value.to_owned()
  { entries, }
}

///|
/// Returns a copy of all trace state entries.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn TraceState::entries(self : TraceState) -> Map[String, String] {
  self.entries.copy()
}

///|
/// Serializes the trace state into a `tracestate` header value.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn TraceState::to_header(self : TraceState) -> String? {
  if self.entries.is_empty() {
    return None
  }
  let builder = StringBuilder::new()
  let mut is_first = true
  for key, value in self.entries {
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
/// Parses a `tracestate` header value, ignoring malformed members.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn TraceState::from_header(value : StringView) -> TraceState {
  let entries : Map[String, String] = Map([])
  for item in value.split(",") {
    let item = item.trim()
    if item.is_empty() {
      continue
    }
    guard item.find("=") is Some(index) else { continue }
    let key = item[:index].trim().to_owned()
    let val = item[index + 1:].trim().to_owned()
    if key != "" && val != "" {
      entries[key] = val
    }
  }
  { entries, }
}

///|
pub impl Default for TraceState with fn default() -> TraceState {
  TraceState::empty()
}

///|
/// Low 8 bits of the W3C trace flags field.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub struct TraceFlags {
  flags : UInt
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Creates trace flags while masking away bits outside the W3C byte.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn TraceFlags::new(flags : UInt) -> TraceFlags {
  { flags: flags & 0xffU, }
}

///|
/// Returns whether the sampled bit is set.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn TraceFlags::is_sampled(self : TraceFlags) -> Bool {
  (self.flags & 0x1U) == 0x1U
}

///|
/// Returns a copy with the sampled bit toggled.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn TraceFlags::with_sampled(
  self : TraceFlags,
  sampled : Bool,
) -> TraceFlags {
  if sampled {
    TraceFlags::new(self.flags | 0x1U)
  } else {
    TraceFlags::new(self.flags & 0xfeU)
  }
}

///|
/// Serializes trace flags into the two-character lowercase hex form used by
/// `traceparent`.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn TraceFlags::to_hex(self : TraceFlags) -> String {
  let hex = self.flags.reinterpret_as_int().to_string(radix=16)
  if self.flags < 16U {
    "0" + hex
  } else {
    hex
  }
}

///|
/// Parses the two-character lowercase or uppercase hex form used by
/// `traceparent`.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn TraceFlags::from_hex(value : StringView) -> TraceFlags? {
  if value.length() != 2 {
    return None
  }
  let parsed = @string.parse_int(value.to_owned(), base=16) catch {
    _ => return None
  }
  Some(TraceFlags::new(parsed.reinterpret_as_uint()))
}

///|
pub impl Default for TraceFlags with fn default() -> TraceFlags {
  TraceFlags::new(0U)
}

///|
/// 16-byte trace identifier.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub struct TraceId {
  bytes : Bytes
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// 8-byte span identifier.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub struct SpanId {
  bytes : Bytes
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
fn all_zero(bytes : Bytes) -> Bool {
  for byte in bytes {
    if byte != b'\x00' {
      break false
    }
  } nobreak {
    true
  }
}

///|
fn encode_hex(bytes : Bytes) -> String {
  let builder = StringBuilder::new()
  for byte in bytes {
    let value = byte.to_int()
    if value < 16 {
      builder.write_char('0')
    }
    builder.write_string(value.to_string(radix=16))
  }
  builder.to_string()
}

///|
fn decode_hex(hex : StringView, expected_len : Int) -> Bytes? {
  if hex.length() != expected_len * 2 {
    return None
  }
  let bytes = []
  for i = 0; i < hex.length(); i = i + 2 {
    let part = hex[i:i + 2].to_owned()
    let value = @string.parse_int(part, base=16) catch { _ => return None }
    bytes.push(value.to_byte())
  }
  Some(Bytes::from_array(bytes))
}

///|
/// Returns the invalid all-zero trace ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn TraceId::invalid() -> TraceId {
  { bytes: Bytes::make(16, b'\x00'), }
}

///|
/// Creates a trace ID from raw bytes when the width is correct.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn TraceId::from_bytes(bytes : Bytes) -> TraceId? {
  if bytes.length() != 16 {
    None
  } else {
    Some({ bytes, })
  }
}

///|
/// Parses a 32-character hexadecimal trace ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn TraceId::from_hex(hex : StringView) -> TraceId? {
  decode_hex(hex, 16).map(bytes => { bytes, })
}

///|
/// Returns the lowercase hexadecimal representation of this trace ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn TraceId::to_hex(self : TraceId) -> String {
  encode_hex(self.bytes)
}

///|
/// Returns the raw bytes backing this trace ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn TraceId::bytes(self : TraceId) -> Bytes {
  self.bytes
}

///|
/// Reports whether this trace ID has the correct width and is not all zeros.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#isvalid
pub fn TraceId::is_valid(self : TraceId) -> Bool {
  self.bytes.length() == 16 && !all_zero(self.bytes)
}

///|
pub impl Default for TraceId with fn default() -> TraceId {
  TraceId::invalid()
}

///|
/// Returns the invalid all-zero span ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn SpanId::invalid() -> SpanId {
  { bytes: Bytes::make(8, b'\x00'), }
}

///|
/// Creates a span ID from raw bytes when the width is correct.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn SpanId::from_bytes(bytes : Bytes) -> SpanId? {
  if bytes.length() != 8 {
    None
  } else {
    Some({ bytes, })
  }
}

///|
/// Parses a 16-character hexadecimal span ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn SpanId::from_hex(hex : StringView) -> SpanId? {
  decode_hex(hex, 8).map(bytes => { bytes, })
}

///|
/// Returns the lowercase hexadecimal representation of this span ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn SpanId::to_hex(self : SpanId) -> String {
  encode_hex(self.bytes)
}

///|
/// Returns the raw bytes backing this span ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn SpanId::bytes(self : SpanId) -> Bytes {
  self.bytes
}

///|
/// Reports whether this span ID has the correct width and is not all zeros.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#isvalid
pub fn SpanId::is_valid(self : SpanId) -> Bool {
  self.bytes.length() == 8 && !all_zero(self.bytes)
}

///|
pub impl Default for SpanId with fn default() -> SpanId {
  SpanId::invalid()
}

///|
/// Immutable span identity and propagation state carried in contexts, spans,
/// logs, and links.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub struct SpanContext {
  trace_id : TraceId
  span_id : SpanId
  trace_flags : TraceFlags
  is_remote : Bool
  trace_state : TraceState
} derive(Eq, ToJson, Debug)

///|
/// Creates a span context with explicit trace identity, flags, and state.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn SpanContext::new(
  trace_id : TraceId,
  span_id : SpanId,
  trace_flags? : TraceFlags = Default::default(),
  is_remote? : Bool = false,
  trace_state? : TraceState = Default::default(),
) -> SpanContext {
  { trace_id, span_id, trace_flags, is_remote, trace_state, }
}

///|
/// Returns an empty invalid span context.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn SpanContext::empty() -> SpanContext {
  SpanContext::new(TraceId::invalid(), SpanId::invalid())
}

///|
/// Returns the trace ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn SpanContext::trace_id(self : SpanContext) -> TraceId {
  self.trace_id
}

///|
/// Returns the span ID.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#retrieving-the-traceid-and-spanid
pub fn SpanContext::span_id(self : SpanContext) -> SpanId {
  self.span_id
}

///|
/// Returns the trace flags.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn SpanContext::trace_flags(self : SpanContext) -> TraceFlags {
  self.trace_flags
}

///|
/// Returns the trace state.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
pub fn SpanContext::trace_state(self : SpanContext) -> TraceState {
  self.trace_state
}

///|
/// Returns whether this context came from an inbound carrier.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#isremote
pub fn SpanContext::is_remote(self : SpanContext) -> Bool {
  self.is_remote
}

///|
/// Reports whether both trace ID and span ID are valid.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#isvalid
pub fn SpanContext::is_valid(self : SpanContext) -> Bool {
  self.trace_id.is_valid() && self.span_id.is_valid()
}

///|
/// Reports whether the sampled bit is set.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
pub fn SpanContext::is_sampled(self : SpanContext) -> Bool {
  self.trace_flags.is_sampled()
}

///|
/// Returns a copy with the remote/local marker updated.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#isremote
pub fn SpanContext::with_remote(
  self : SpanContext,
  is_remote : Bool,
) -> SpanContext {
  { ..self, is_remote, }
}

///|
pub impl Default for SpanContext with fn default() -> SpanContext {
  SpanContext::empty()
}

///|
/// Identifies the instrumentation library or component that produced telemetry.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub struct InstrumentationScope {
  name : String
  version : String?
  schema_url : String?
  attributes : Array[KeyValue]
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Builder for `InstrumentationScope`.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub struct InstrumentationScopeBuilder {
  name : String
  mut version : String?
  mut schema_url : String?
  mut attributes : Array[KeyValue]
}

///|
/// Starts building an instrumentation scope for the given library name.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScope::builder(
  name : StringView,
) -> InstrumentationScopeBuilder {
  { name: name.to_owned(), version: None, schema_url: None, attributes: [], }
}

///|
/// Returns the scope name.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScope::name(self : InstrumentationScope) -> String {
  self.name
}

///|
/// Returns the optional scope version.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScope::version(self : InstrumentationScope) -> String? {
  self.version
}

///|
/// Returns the optional schema URL applied to telemetry from this scope.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScope::schema_url(self : InstrumentationScope) -> String? {
  self.schema_url
}

///|
/// Returns the scope attributes.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScope::attributes(
  self : InstrumentationScope,
) -> Array[KeyValue] {
  self.attributes
}

///|
/// Sets the instrumentation library version.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScopeBuilder::with_version(
  self : InstrumentationScopeBuilder,
  version : StringView,
) -> InstrumentationScopeBuilder {
  self.version = Some(version.to_owned())
  self
}

///|
/// Sets the schema URL attached to this scope.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScopeBuilder::with_schema_url(
  self : InstrumentationScopeBuilder,
  schema_url : StringView,
) -> InstrumentationScopeBuilder {
  self.schema_url = Some(schema_url.to_owned())
  self
}

///|
/// Sets the attributes attached to this scope.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScopeBuilder::with_attributes(
  self : InstrumentationScopeBuilder,
  attributes : ArrayView[KeyValue],
) -> InstrumentationScopeBuilder {
  self.attributes = attributes.to_owned()
  self
}

///|
/// Finishes the scope builder.
/// Spec: https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
pub fn InstrumentationScopeBuilder::build(
  self : InstrumentationScopeBuilder,
) -> InstrumentationScope {
  {
    name: self.name,
    version: self.version,
    schema_url: self.schema_url,
    attributes: self.attributes,
  }
}

///|
pub impl Default for InstrumentationScope with fn default() -> InstrumentationScope {
  InstrumentationScope::builder("").build()
}
