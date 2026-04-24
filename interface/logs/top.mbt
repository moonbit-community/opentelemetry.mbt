///|
/// Log body or attribute value accepted by the public logging API.
///
/// Values remain structured when bridged into the SDK and OTLP exporters. Use
/// scalar attributes for common query dimensions and structured bodies for
/// payloads that should stay grouped.
pub(all) enum AnyValue {
  Int(Int64)
  Double(Double)
  String(String)
  Boolean(Bool)
  Bytes(Bytes)
  ListAny(Array[AnyValue])
  Map(Map[String, AnyValue])
} derive(Eq, ToJson, Debug)

///|
/// Public severity ladder matching the OpenTelemetry log data model.
///
/// The variants map to OpenTelemetry's 24 severity slots. `Severity::name()`
/// returns the canonical uppercase text such as `INFO`, `WARN3`, or `ERROR`.
pub(all) enum Severity {
  Trace
  Trace2
  Trace3
  Trace4
  Debug
  Debug2
  Debug3
  Debug4
  Info
  Info2
  Info3
  Info4
  Warn
  Warn2
  Warn3
  Warn4
  Error
  Error2
  Error3
  Error4
  Fatal
  Fatal2
  Fatal3
  Fatal4
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Structured log attribute key/value pair used by the public logging API.
pub struct KeyValue {
  key : @common.Key
  value : AnyValue
} derive(Eq, ToJson, Debug)

///|
/// Mutable log record builder used by `Logger::emit()`.
///
/// Construct records only after checking `Logger::event_enabled()` when
/// formatting or attribute construction is expensive. `emit()` fills missing
/// timestamps and default body values when an SDK logger is installed.
pub struct LogRecord {
  mut event_name : String?
  mut target : String?
  mut timestamp_unix_nano : Int64?
  mut observed_timestamp_unix_nano : Int64?
  mut severity_text : String?
  mut severity_number : Severity?
  mut body : AnyValue?
  attributes : Array[KeyValue]
  mut trace_context : @common.SpanContext?
} derive(Eq, ToJson, Debug)

///|
/// Public logger handle.
///
/// A logger emits records for one instrumentation scope. When backed by a no-op
/// provider, all emissions are silently dropped.
pub struct Logger {
  emit_fn : async (LogRecord) -> Unit
  event_enabled_fn : (Severity, StringView, String?) -> Bool
}

///|
/// Public logger provider.
///
/// Applications install SDK-backed providers through the SDK facade while
/// library code depends only on this API type.
pub struct LoggerProvider {
  logger_with_scope_fn : (@common.InstrumentationScope) -> Logger
}

///|
/// Returns the canonical uppercase text form for one severity variant.
///
/// If `LogRecord::severity_text` is not set, SDK adapters derive it from this
/// method when a severity number exists.
pub fn Severity::name(self : Severity) -> String {
  match self {
    Severity::Trace => "TRACE"
    Severity::Trace2 => "TRACE2"
    Severity::Trace3 => "TRACE3"
    Severity::Trace4 => "TRACE4"
    Severity::Debug => "DEBUG"
    Severity::Debug2 => "DEBUG2"
    Severity::Debug3 => "DEBUG3"
    Severity::Debug4 => "DEBUG4"
    Severity::Info => "INFO"
    Severity::Info2 => "INFO2"
    Severity::Info3 => "INFO3"
    Severity::Info4 => "INFO4"
    Severity::Warn => "WARN"
    Severity::Warn2 => "WARN2"
    Severity::Warn3 => "WARN3"
    Severity::Warn4 => "WARN4"
    Severity::Error => "ERROR"
    Severity::Error2 => "ERROR2"
    Severity::Error3 => "ERROR3"
    Severity::Error4 => "ERROR4"
    Severity::Fatal => "FATAL"
    Severity::Fatal2 => "FATAL2"
    Severity::Fatal3 => "FATAL3"
    Severity::Fatal4 => "FATAL4"
  }
}

///|
fn sorted_keys(values : Map[String, AnyValue]) -> Array[String] {
  let keys = values.keys().to_array()
  for i in 1..<keys.length() {
    let current = keys[i]
    let mut j = i
    while j > 0 && current < keys[j - 1] {
      keys[j] = keys[j - 1]
      j = j - 1
    }
    keys[j] = current
  }
  keys
}

///|
/// Converts a shared attribute value into a public log value.
pub fn AnyValue::from_common(value : @common.Value) -> AnyValue {
  match value {
    @common.Value::Bool(value) => AnyValue::Boolean(value)
    @common.Value::Int64(value) => AnyValue::Int(value)
    @common.Value::Double(value) => AnyValue::Double(value)
    @common.Value::String(value) => AnyValue::String(value)
    @common.Value::Bytes(value) => AnyValue::Bytes(value)
    @common.Value::Array(values) => {
      let converted = []
      for value in values {
        converted.push(AnyValue::from_common(value))
      }
      AnyValue::ListAny(converted)
    }
  }
}

///|
/// Creates a structured log attribute.
pub fn KeyValue::new(key : StringView, value : AnyValue) -> KeyValue {
  { key: @common.Key::new(key), value }
}

///|
/// Converts a shared attribute into a public log attribute.
pub fn KeyValue::from_common(attribute : @common.KeyValue) -> KeyValue {
  { key: attribute.key, value: AnyValue::from_common(attribute.value) }
}

///|
/// Returns a map value with deterministic key insertion order.
pub fn AnyValue::map(values : Map[String, AnyValue]) -> AnyValue {
  let sorted : Map[String, AnyValue] = {}
  for key in sorted_keys(values) {
    guard values.get(key) is Some(value)
    sorted[key] = value
  }
  AnyValue::Map(sorted)
}

///|
/// Creates an empty mutable log record.
///
/// The record is not tied to a logger until passed to `Logger::emit()`.
pub fn LogRecord::new() -> LogRecord {
  {
    event_name: None,
    target: None,
    timestamp_unix_nano: None,
    observed_timestamp_unix_nano: None,
    severity_text: None,
    severity_number: None,
    body: None,
    attributes: [],
    trace_context: None,
  }
}

///|
/// Sets the event name that will later be exported through the OTLP
/// `event_name` field.
pub fn LogRecord::set_event_name(self : LogRecord, name : StringView) -> Unit {
  self.event_name = Some(name.to_string())
}

///|
/// Sets the log target used for export-time scope grouping.
pub fn LogRecord::set_target(self : LogRecord, target : StringView) -> Unit {
  self.target = Some(target.to_string())
}

///|
/// Sets the event timestamp in Unix nanoseconds.
///
/// When omitted, SDK-backed loggers use the current time.
pub fn LogRecord::set_timestamp(
  self : LogRecord,
  timestamp_unix_nano : Int64,
) -> Unit {
  self.timestamp_unix_nano = Some(timestamp_unix_nano)
}

///|
/// Sets the observed timestamp in Unix nanoseconds.
///
/// When omitted, SDK-backed loggers use the current time.
pub fn LogRecord::set_observed_timestamp(
  self : LogRecord,
  observed_timestamp_unix_nano : Int64,
) -> Unit {
  self.observed_timestamp_unix_nano = Some(observed_timestamp_unix_nano)
}

///|
/// Sets the exact severity text to export.
///
/// If this is not set but a severity number is present, SDK-backed loggers
/// derive the text from `Severity::name()`.
pub fn LogRecord::set_severity_text(
  self : LogRecord,
  severity_text : StringView,
) -> Unit {
  self.severity_text = Some(severity_text.to_string())
}

///|
/// Sets the structured severity number to export.
pub fn LogRecord::set_severity_number(
  self : LogRecord,
  severity_number : Severity,
) -> Unit {
  self.severity_number = Some(severity_number)
}

///|
/// Sets the log body.
///
/// If no body is set, SDK-backed loggers export an empty string body.
pub fn LogRecord::set_body(self : LogRecord, body : AnyValue) -> Unit {
  self.body = Some(body)
}

///|
/// Adds one attribute to the log record.
///
/// Attribute keys should be stable names. Prefer scalar values for fields that
/// users will search or group by.
pub fn LogRecord::add_attribute(
  self : LogRecord,
  key : StringView,
  value : AnyValue,
) -> Unit {
  self.attributes.push(KeyValue::new(key, value))
}

///|
/// Appends multiple pre-built attributes to the log record.
pub fn LogRecord::add_attributes(
  self : LogRecord,
  attributes : ArrayView[@common.KeyValue],
) -> Unit {
  for attribute in attributes {
    self.attributes.push(KeyValue::from_common(attribute))
  }
}

///|
/// Stores explicit trace correlation fields on the record.
///
/// Use this when bridging logs from code that already knows the trace and span
/// identifiers. When `trace_flags` is omitted, the trace flags default to zero.
pub fn LogRecord::set_trace_context(
  self : LogRecord,
  trace_id : @common.TraceId,
  span_id : @common.SpanId,
  trace_flags? : @common.TraceFlags? = None,
) -> Unit {
  self.trace_context = Some(
    @common.SpanContext::new(
      trace_id,
      span_id,
      trace_flags=match trace_flags {
        Some(trace_flags) => trace_flags
        None => Default::default()
      },
    ),
  )
}

///|
pub impl Default for LogRecord with default() -> LogRecord {
  LogRecord::new()
}

///|
/// Builds a logger from emission and filtering callbacks.
pub fn Logger::from_functions(
  emit_fn : async (LogRecord) -> Unit,
  event_enabled_fn? : (Severity, StringView, String?) -> Bool = (_, _, _) => {
    true
  },
) -> Logger {
  { emit_fn, event_enabled_fn }
}

///|
/// Builds a logger provider from a scope-to-logger callback.
pub fn LoggerProvider::from_functions(
  logger_with_scope_fn : (@common.InstrumentationScope) -> Logger,
) -> LoggerProvider {
  { logger_with_scope_fn, }
}

///|
/// Returns a no-op logger provider.
///
/// Loggers from this provider report `event_enabled() == false` and drop
/// emitted records.
pub fn LoggerProvider::noop() -> LoggerProvider {
  LoggerProvider::from_functions(_ => {
    Logger::from_functions(_ => (), event_enabled_fn=(_, _, _) => false)
  })
}

///|
/// Returns a logger for one instrumentation name.
///
/// If the provider is no-op, the returned logger is also no-op.
pub fn LoggerProvider::logger(
  self : LoggerProvider,
  name : StringView,
) -> Logger {
  self.logger_with_scope(@common.InstrumentationScope::builder(name).build())
}

///|
/// Returns a logger for a fully constructed instrumentation scope.
///
/// The scope name, version, schema URL, and attributes are forwarded to the SDK
/// provider by SDK adapters.
pub fn LoggerProvider::logger_with_scope(
  self : LoggerProvider,
  scope : @common.InstrumentationScope,
) -> Logger {
  (self.logger_with_scope_fn)(scope)
}

///|
/// Creates a fresh mutable `LogRecord`.
///
/// The returned record is not pre-populated with scope or provider data.
pub fn Logger::create_log_record(self : Logger) -> LogRecord {
  ignore(self)
  LogRecord::new()
}

///|
/// Emits one log record through the underlying logger.
///
/// Missing timestamps, severity text, and body defaults are supplied by SDK
/// adapters. No-op loggers drop the record silently.
pub async fn Logger::emit(self : Logger, record : LogRecord) -> Unit {
  (self.emit_fn)(record)
}

///|
/// Returns whether log emission is currently enabled for this logger.
///
/// Use this as a guard before expensive message formatting or structured body
/// construction.
pub fn Logger::event_enabled(
  self : Logger,
  severity : Severity,
  target : StringView,
  name? : String? = None,
) -> Bool {
  (self.event_enabled_fn)(severity, target, name)
}
