///|
/// Log body/attribute value accepted by the public logging API.
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
/// Mutable log record builder used by `Logger::emit()`.
pub struct LogRecord {
  mut event_name : String?
  mut target : String?
  mut timestamp_unix_nano : Int64?
  mut observed_timestamp_unix_nano : Int64?
  mut severity_text : String?
  mut severity_number : Severity?
  mut body : AnyValue?
  attributes : Array[@sdklogs.KeyValue]
  mut trace_context : @common.SpanContext?
} derive(Eq, ToJson, Debug)

///|
/// Public logger handle.
///
/// When backed by a no-op provider, all emissions are silently dropped.
pub struct Logger {
  sdk_logger : @sdklogs.SdkLogger?
}

///|
/// Public logger provider wrapper around the SDK provider.
///
/// A provider with `sdk_provider = None` behaves as a no-op provider.
pub struct LoggerProvider {
  sdk_provider : @sdklogs.SdkLoggerProvider?
}

///|
/// Returns the canonical uppercase text form for one severity variant.
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
fn to_sdk_severity(severity : Severity?) -> @sdklogs.SeverityNumber? {
  match severity {
    Some(Severity::Trace) => Some(@sdklogs.SeverityNumber::Trace)
    Some(Severity::Trace2) => Some(@sdklogs.SeverityNumber::Trace2)
    Some(Severity::Trace3) => Some(@sdklogs.SeverityNumber::Trace3)
    Some(Severity::Trace4) => Some(@sdklogs.SeverityNumber::Trace4)
    Some(Severity::Debug) => Some(@sdklogs.SeverityNumber::Debug)
    Some(Severity::Debug2) => Some(@sdklogs.SeverityNumber::Debug2)
    Some(Severity::Debug3) => Some(@sdklogs.SeverityNumber::Debug3)
    Some(Severity::Debug4) => Some(@sdklogs.SeverityNumber::Debug4)
    Some(Severity::Info) => Some(@sdklogs.SeverityNumber::Info)
    Some(Severity::Info2) => Some(@sdklogs.SeverityNumber::Info2)
    Some(Severity::Info3) => Some(@sdklogs.SeverityNumber::Info3)
    Some(Severity::Info4) => Some(@sdklogs.SeverityNumber::Info4)
    Some(Severity::Warn) => Some(@sdklogs.SeverityNumber::Warn)
    Some(Severity::Warn2) => Some(@sdklogs.SeverityNumber::Warn2)
    Some(Severity::Warn3) => Some(@sdklogs.SeverityNumber::Warn3)
    Some(Severity::Warn4) => Some(@sdklogs.SeverityNumber::Warn4)
    Some(Severity::Error) => Some(@sdklogs.SeverityNumber::Error)
    Some(Severity::Error2) => Some(@sdklogs.SeverityNumber::Error2)
    Some(Severity::Error3) => Some(@sdklogs.SeverityNumber::Error3)
    Some(Severity::Error4) => Some(@sdklogs.SeverityNumber::Error4)
    Some(Severity::Fatal) => Some(@sdklogs.SeverityNumber::Fatal)
    Some(Severity::Fatal2) => Some(@sdklogs.SeverityNumber::Fatal2)
    Some(Severity::Fatal3) => Some(@sdklogs.SeverityNumber::Fatal3)
    Some(Severity::Fatal4) => Some(@sdklogs.SeverityNumber::Fatal4)
    None => None
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
fn any_value_to_sdk_value(value : AnyValue) -> @sdklogs.AnyValue {
  match value {
    AnyValue::Int(value) => @sdklogs.AnyValue::Int64(value)
    AnyValue::Double(value) => @sdklogs.AnyValue::Double(value)
    AnyValue::String(value) => @sdklogs.AnyValue::String(value)
    AnyValue::Boolean(value) => @sdklogs.AnyValue::Bool(value)
    AnyValue::Bytes(value) => @sdklogs.AnyValue::Bytes(value)
    AnyValue::ListAny(values) => {
      let converted = []
      for value in values {
        converted.push(any_value_to_sdk_value(value))
      }
      @sdklogs.AnyValue::Array(converted)
    }
    AnyValue::Map(values) => {
      let converted = []
      for key in sorted_keys(values) {
        guard values.get(key) is Some(value)
        converted.push(
          @sdklogs.KeyValue::new(key, any_value_to_sdk_value(value)),
        )
      }
      @sdklogs.AnyValue::Map(converted)
    }
  }
}

///|
fn to_sdk_context(context : @common.SpanContext?) -> @sdkcontext.Context {
  match context {
    Some(span_context) if span_context.is_remote() =>
      @sdkcontext.Context::empty().with_remote_span_context(span_context)
    Some(span_context) =>
      @sdkcontext.Context::empty().with_span_context(span_context)
    None => @sdkcontext.Context::empty()
  }
}

///|
/// Creates an empty mutable log record.
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
/// When omitted, `Logger::emit()` uses the current time.
pub fn LogRecord::set_timestamp(
  self : LogRecord,
  timestamp_unix_nano : Int64,
) -> Unit {
  self.timestamp_unix_nano = Some(timestamp_unix_nano)
}

///|
/// Sets the observed timestamp in Unix nanoseconds.
///
/// When omitted, `Logger::emit()` uses the current time.
pub fn LogRecord::set_observed_timestamp(
  self : LogRecord,
  observed_timestamp_unix_nano : Int64,
) -> Unit {
  self.observed_timestamp_unix_nano = Some(observed_timestamp_unix_nano)
}

///|
/// Sets the exact severity text to export.
///
/// If this is not set but a severity number is present, `Logger::emit()`
/// derives the text from `Severity::name()`.
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
/// If no body is set, `Logger::emit()` exports an empty string body.
pub fn LogRecord::set_body(self : LogRecord, body : AnyValue) -> Unit {
  self.body = Some(body)
}

///|
/// Adds one attribute to the log record.
pub fn LogRecord::add_attribute(
  self : LogRecord,
  key : StringView,
  value : AnyValue,
) -> Unit {
  self.attributes.push(
    @sdklogs.KeyValue::new(key, any_value_to_sdk_value(value)),
  )
}

///|
/// Appends multiple pre-built attributes to the log record.
pub fn LogRecord::add_attributes(
  self : LogRecord,
  attributes : ArrayView[@common.KeyValue],
) -> Unit {
  for attribute in attributes {
    self.attributes.push(@sdklogs.KeyValue::from_common(attribute))
  }
}

///|
/// Stores explicit trace correlation fields on the record.
///
/// When `trace_flags` is omitted, the trace flags default to zero.
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
/// Wraps an SDK logger provider in the public API type.
pub fn LoggerProvider::from_sdk(
  provider : @sdklogs.SdkLoggerProvider,
) -> LoggerProvider {
  { sdk_provider: Some(provider) }
}

///|
/// Returns a no-op logger provider.
pub fn LoggerProvider::noop() -> LoggerProvider {
  { sdk_provider: None }
}

///|
/// Returns a logger for one instrumentation name.
///
/// If the provider is no-op, the returned logger is also no-op.
pub fn LoggerProvider::logger(
  self : LoggerProvider,
  name : StringView,
) -> Logger {
  match self.sdk_provider {
    Some(provider) => { sdk_logger: Some(provider.logger(name)) }
    None => { sdk_logger: None }
  }
}

///|
/// Returns a logger for a fully constructed instrumentation scope.
///
/// The scope name, version, schema URL, and attributes are forwarded to the
/// SDK provider as-is.
pub fn LoggerProvider::logger_with_scope(
  self : LoggerProvider,
  scope : @common.InstrumentationScope,
) -> Logger {
  match self.sdk_provider {
    Some(provider) => {
      let logger = provider.logger(
        scope.name(),
        version=scope.version(),
        schema_url=scope.schema_url(),
        attributes=scope.attributes(),
      )
      { sdk_logger: Some(logger) }
    }
    None => { sdk_logger: None }
  }
}

///|
/// Flushes the underlying SDK provider.
///
/// No-op providers report success.
pub async fn LoggerProvider::force_flush(
  self : LoggerProvider,
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
pub async fn LoggerProvider::shutdown(
  self : LoggerProvider,
) -> @error.OTelSdkResult {
  match self.sdk_provider {
    Some(provider) => provider.shutdown()
    None => @error.ok()
  }
}

///|
/// Spawns background loops for batch log processors owned by this provider.
///
/// No-op providers do nothing.
pub fn LoggerProvider::spawn_batch_processor_tasks(
  self : LoggerProvider,
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
/// Creates a fresh mutable `LogRecord`.
///
/// The returned record is not pre-populated with scope or provider data.
pub fn Logger::create_log_record(self : Logger) -> LogRecord {
  ignore(self)
  LogRecord::new()
}

///|
/// Emits one log record through the underlying SDK logger.
///
/// Missing timestamps default to the current time. Missing severity text is
/// derived from the severity number, and missing bodies are exported as empty
/// strings. No-op loggers drop the record silently.
pub async fn Logger::emit(self : Logger, record : LogRecord) -> Unit {
  match self.sdk_logger {
    Some(logger) => {
      let severity_text = match record.severity_text {
        Some(severity_text) => Some(severity_text)
        None => record.severity_number.map(severity => severity.name())
      }
      logger.emit(
        match record.body {
          Some(body) => any_value_to_sdk_value(body)
          None => @sdklogs.AnyValue::String("")
        },
        context=to_sdk_context(record.trace_context),
        severity_number=to_sdk_severity(record.severity_number),
        severity_text~,
        event_name=record.event_name,
        target=record.target,
        attributes=record.attributes,
        timestamp_unix_nano=match record.timestamp_unix_nano {
          Some(timestamp_unix_nano) => timestamp_unix_nano
          None => @common.now_unix_nano()
        },
        observed_timestamp_unix_nano=match record.observed_timestamp_unix_nano {
          Some(observed_timestamp_unix_nano) => observed_timestamp_unix_nano
          None => @common.now_unix_nano()
        },
      )
    }
    None => ()
  }
}

///|
/// Returns whether log emission is currently enabled for this logger.
///
/// The current implementation only checks whether a real SDK logger exists; it
/// does not apply severity-, target-, or name-based filtering yet.
pub fn Logger::event_enabled(
  self : Logger,
  severity : Severity,
  target : StringView,
  name? : String? = None,
) -> Bool {
  ignore(severity)
  ignore(target)
  ignore(name)
  self.sdk_logger is Some(_)
}
