///|
pub const OTEL_EXPORTER_OTLP_ENDPOINT : String = "OTEL_EXPORTER_OTLP_ENDPOINT"

///|
pub const OTEL_EXPORTER_OTLP_ENDPOINT_DEFAULT : String = "http://localhost:4318"

///|
pub const OTEL_EXPORTER_OTLP_HEADERS : String = "OTEL_EXPORTER_OTLP_HEADERS"

///|
pub const OTEL_EXPORTER_OTLP_PROTOCOL : String = "OTEL_EXPORTER_OTLP_PROTOCOL"

///|
pub const OTEL_EXPORTER_OTLP_PROTOCOL_GRPC : String = "grpc"

///|
pub const OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_PROTOBUF : String = "http/protobuf"

///|
pub const OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_JSON : String = "http/json"

///|
pub const OTEL_EXPORTER_OTLP_TIMEOUT : String = "OTEL_EXPORTER_OTLP_TIMEOUT"

///|
pub const OTEL_EXPORTER_OTLP_TIMEOUT_DEFAULT : Int = 10000

///|
pub const OTEL_EXPORTER_OTLP_COMPRESSION : String = "OTEL_EXPORTER_OTLP_COMPRESSION"

///|
pub const OTEL_EXPORTER_OTLP_TRACES_ENDPOINT : String = "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"

///|
pub const OTEL_EXPORTER_OTLP_TRACES_TIMEOUT : String = "OTEL_EXPORTER_OTLP_TRACES_TIMEOUT"

///|
pub const OTEL_EXPORTER_OTLP_TRACES_HEADERS : String = "OTEL_EXPORTER_OTLP_TRACES_HEADERS"

///|
pub const OTEL_EXPORTER_OTLP_TRACES_COMPRESSION : String = "OTEL_EXPORTER_OTLP_TRACES_COMPRESSION"

///|
pub const OTEL_EXPORTER_OTLP_METRICS_ENDPOINT : String = "OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"

///|
pub const OTEL_EXPORTER_OTLP_METRICS_TIMEOUT : String = "OTEL_EXPORTER_OTLP_METRICS_TIMEOUT"

///|
pub const OTEL_EXPORTER_OTLP_METRICS_HEADERS : String = "OTEL_EXPORTER_OTLP_METRICS_HEADERS"

///|
pub const OTEL_EXPORTER_OTLP_METRICS_COMPRESSION : String = "OTEL_EXPORTER_OTLP_METRICS_COMPRESSION"

///|
pub const OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE : String = "OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE"

///|
pub const OTEL_EXPORTER_OTLP_LOGS_ENDPOINT : String = "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"

///|
pub const OTEL_EXPORTER_OTLP_LOGS_TIMEOUT : String = "OTEL_EXPORTER_OTLP_LOGS_TIMEOUT"

///|
pub const OTEL_EXPORTER_OTLP_LOGS_HEADERS : String = "OTEL_EXPORTER_OTLP_LOGS_HEADERS"

///|
pub const OTEL_EXPORTER_OTLP_LOGS_COMPRESSION : String = "OTEL_EXPORTER_OTLP_LOGS_COMPRESSION"

///|
/// OTLP transport protocol selection.
///
/// The current exporter implementation supports the HTTP transports. `Grpc` is
/// kept for API parity but rejected during exporter construction.
pub(all) enum Protocol {
  Grpc
  HttpBinary
  HttpJson
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
pub impl Default for Protocol with default() -> Protocol {
  Protocol::HttpBinary
}

///|
/// Requested payload compression algorithm.
///
/// Compression is not implemented yet; setting it currently causes exporter
/// construction to fail with `UnsupportedCompressionAlgorithm`.
pub(all) enum Compression {
  Gzip
  Zstd
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Error returned when exporter configuration cannot be resolved.
pub(all) enum ExporterBuildError {
  InvalidConfig(String, String)
  UnsupportedProtocol(String)
  UnsupportedCompressionAlgorithm(String)
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
struct SignalConfig {
  signal_name : String
  endpoint : String
  protocol : Protocol
  timeout_millis : Int
  headers : Map[String, String]
}

///|
struct SignalExporterState {
  is_shutdown : Bool
}

///|
/// Builder for OTLP span exporters.
pub struct SpanExporterBuilder {
  mut endpoint : String?
  mut protocol : Protocol?
  mut timeout_millis : Int?
  mut headers : Map[String, String]
  mut compression : Compression?
}

///|
/// Builder for OTLP log exporters.
pub struct LogExporterBuilder {
  mut endpoint : String?
  mut protocol : Protocol?
  mut timeout_millis : Int?
  mut headers : Map[String, String]
  mut compression : Compression?
}

///|
/// Builder for OTLP metric exporters.
pub struct MetricExporterBuilder {
  mut endpoint : String?
  mut protocol : Protocol?
  mut timeout_millis : Int?
  mut headers : Map[String, String]
  mut compression : Compression?
  mut temporality : @sdkmetrics.Temporality?
}

///|
/// OTLP span exporter.
pub struct SpanExporter {
  state : Ref[SignalExporterState]
  config : SignalConfig
}

///|
/// OTLP log exporter.
pub struct LogExporter {
  state : Ref[SignalExporterState]
  config : SignalConfig
}

///|
/// OTLP metric exporter.
pub struct MetricExporter {
  state : Ref[SignalExporterState]
  config : SignalConfig
  temporality : @sdkmetrics.Temporality
}

///|
#coverage.skip
fn _socket_import_marker() -> Unit {
  ignore(@socket.Addr::new(0U, 0))
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
fn is_hex_digit(value : StringView) -> Bool {
  value == "0" ||
  value == "1" ||
  value == "2" ||
  value == "3" ||
  value == "4" ||
  value == "5" ||
  value == "6" ||
  value == "7" ||
  value == "8" ||
  value == "9" ||
  value == "a" ||
  value == "b" ||
  value == "c" ||
  value == "d" ||
  value == "e" ||
  value == "f" ||
  value == "A" ||
  value == "B" ||
  value == "C" ||
  value == "D" ||
  value == "E" ||
  value == "F"
}

///|
fn percent_decode(value : StringView) -> String {
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
      index = index + 3
      continue
    }
    builder.write_string(ch.to_string())
    index = index + 1
  }
  builder.to_string()
}

///|
fn parse_header_string(value : StringView) -> Map[String, String] {
  let headers : Map[String, String] = {}
  for item in value.split(",") {
    let item = item.trim()
    if item.is_empty() {
      continue
    }
    guard item.find("=") is Some(index)
    let key = normalize_ascii_lower(item[:index].trim())
    let header_value = percent_decode(item[index + 1:].trim())
    if key != "" {
      headers[key] = header_value
    }
  }
  headers
}

///|
fn normalize_headers(headers : Map[String, String]) -> Map[String, String] {
  let normalized : Map[String, String] = {}
  for key, value in headers {
    normalized[normalize_ascii_lower(key)] = value
  }
  normalized
}

///|
fn merge_headers(
  base : Map[String, String],
  overlay : Map[String, String],
) -> Map[String, String] {
  let merged = base.copy()
  for key, value in overlay {
    merged[key] = value
  }
  merged
}

///|
fn default_headers() -> Map[String, String] {
  { "user-agent": "OTel-OTLP-Exporter-MoonBit/0.1.0" }
}

///|
fn is_http_endpoint(value : StringView) -> Bool {
  (value.length() >= 7 && value[:7] == "http://") ||
  (value.length() >= 8 && value[:8] == "https://")
}

///|
fn strip_trailing_slashes(value : StringView) -> String {
  let mut end = value.length()
  while end > 0 && value[end - 1:end] == "/" {
    end = end - 1
  }
  value[:end].to_string()
}

///|
fn strip_leading_slashes(value : StringView) -> String {
  let mut start = 0
  while start < value.length() && value[start:start + 1] == "/" {
    start = start + 1
  }
  value[start:].to_string()
}

///|
fn protocol_to_string(protocol : Protocol) -> String {
  match protocol {
    Protocol::Grpc => OTEL_EXPORTER_OTLP_PROTOCOL_GRPC
    Protocol::HttpBinary => OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_PROTOBUF
    Protocol::HttpJson => OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_JSON
  }
}

///|
fn compression_to_string(compression : Compression) -> String {
  match compression {
    Compression::Gzip => "gzip"
    Compression::Zstd => "zstd"
  }
}

///|
fn parse_protocol(value : StringView) -> Result[Protocol, ExporterBuildError] {
  match normalize_ascii_lower(value) {
    OTEL_EXPORTER_OTLP_PROTOCOL_GRPC => Ok(Protocol::Grpc)
    OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_PROTOBUF => Ok(Protocol::HttpBinary)
    OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_JSON => Ok(Protocol::HttpJson)
    other =>
      Err(
        ExporterBuildError::InvalidConfig(
          OTEL_EXPORTER_OTLP_PROTOCOL,
          "unsupported value \{other}",
        ),
      )
  }
}

///|
fn parse_compression(
  value : StringView,
) -> Result[Compression, ExporterBuildError] {
  match normalize_ascii_lower(value) {
    "gzip" => Ok(Compression::Gzip)
    "zstd" => Ok(Compression::Zstd)
    other => Err(ExporterBuildError::UnsupportedCompressionAlgorithm(other))
  }
}

///|
fn parse_positive_int(
  key : String,
  value : StringView,
) -> Result[Int, ExporterBuildError] {
  let value = value.trim()
  if value == "" {
    return Err(
      ExporterBuildError::InvalidConfig(key, "value must not be empty"),
    )
  }
  let parsed = @string.parse_int(value.to_string()) catch {
    _ =>
      return Err(
        ExporterBuildError::InvalidConfig(
          key,
          "value \{value.to_string()} is not an integer",
        ),
      )
  }
  if parsed <= 0 {
    Err(ExporterBuildError::InvalidConfig(key, "value must be > 0"))
  } else {
    Ok(parsed)
  }
}

///|
fn resolve_protocol(
  provided : Protocol?,
) -> Result[Protocol, ExporterBuildError] {
  let protocol = match provided {
    Some(protocol) => protocol
    None =>
      match @env.get_env_var(OTEL_EXPORTER_OTLP_PROTOCOL) {
        Some(value) =>
          match parse_protocol(value) {
            Ok(protocol) => protocol
            Err(err) => return Err(err)
          }
        None => Protocol::HttpBinary
      }
  }
  match protocol {
    Protocol::HttpBinary | Protocol::HttpJson => Ok(protocol)
    Protocol::Grpc =>
      Err(ExporterBuildError::UnsupportedProtocol(protocol_to_string(protocol)))
  }
}

///|
fn resolve_timeout(
  signal_timeout_var : String,
  provided : Int?,
) -> Result[Int, ExporterBuildError] {
  match provided {
    Some(timeout_millis) =>
      parse_positive_int(signal_timeout_var, timeout_millis.to_string())
    None =>
      match @env.get_env_var(signal_timeout_var) {
        Some(value) => parse_positive_int(signal_timeout_var, value)
        None =>
          match @env.get_env_var(OTEL_EXPORTER_OTLP_TIMEOUT) {
            Some(value) => parse_positive_int(OTEL_EXPORTER_OTLP_TIMEOUT, value)
            None => Ok(OTEL_EXPORTER_OTLP_TIMEOUT_DEFAULT)
          }
      }
  }
}

///|
fn validate_endpoint(
  key : String,
  value : StringView,
) -> Result[String, ExporterBuildError] {
  let value = value.trim()
  if value == "" {
    return Err(
      ExporterBuildError::InvalidConfig(key, "endpoint must not be empty"),
    )
  }
  if !is_http_endpoint(value) {
    return Err(
      ExporterBuildError::InvalidConfig(
        key, "endpoint must start with http:// or https://",
      ),
    )
  }
  Ok(value.to_string())
}

///|
fn append_signal_path(
  base : StringView,
  signal_path : StringView,
) -> Result[String, ExporterBuildError] {
  match validate_endpoint(OTEL_EXPORTER_OTLP_ENDPOINT, base) {
    Ok(base) => {
      let base = strip_trailing_slashes(base)
      let signal_path = strip_leading_slashes(signal_path)
      if signal_path == "" {
        Ok(base)
      } else {
        Ok("\{base}/\{signal_path}")
      }
    }
    Err(err) => Err(err)
  }
}

///|
fn resolve_endpoint(
  signal_endpoint_var : String,
  signal_path : String,
  provided : String?,
) -> Result[String, ExporterBuildError] {
  match provided {
    Some(endpoint) => validate_endpoint(signal_endpoint_var, endpoint)
    None =>
      match @env.get_env_var(signal_endpoint_var) {
        Some(endpoint) => validate_endpoint(signal_endpoint_var, endpoint)
        None =>
          match @env.get_env_var(OTEL_EXPORTER_OTLP_ENDPOINT) {
            Some(endpoint) => append_signal_path(endpoint, signal_path)
            None =>
              append_signal_path(
                OTEL_EXPORTER_OTLP_ENDPOINT_DEFAULT,
                signal_path,
              )
          }
      }
  }
}

///|
fn resolve_headers(
  signal_headers_var : String,
  provided : Map[String, String],
) -> Map[String, String] {
  let mut headers = default_headers()
  if @env.get_env_var(OTEL_EXPORTER_OTLP_HEADERS) is Some(value) {
    headers = merge_headers(headers, parse_header_string(value))
  }
  if @env.get_env_var(signal_headers_var) is Some(value) {
    headers = merge_headers(headers, parse_header_string(value))
  }
  merge_headers(headers, normalize_headers(provided))
}

///|
fn resolve_compression(
  signal_compression_var : String,
  provided : Compression?,
) -> Result[Unit, ExporterBuildError] {
  let compression = match provided {
    Some(compression) => Some(compression)
    None =>
      match @env.get_env_var(signal_compression_var) {
        Some(value) =>
          match parse_compression(value) {
            Ok(compression) => Some(compression)
            Err(err) => return Err(err)
          }
        None =>
          match @env.get_env_var(OTEL_EXPORTER_OTLP_COMPRESSION) {
            Some(value) =>
              match parse_compression(value) {
                Ok(compression) => Some(compression)
                Err(err) => return Err(err)
              }
            None => None
          }
      }
  }
  match compression {
    Some(compression) =>
      Err(
        ExporterBuildError::UnsupportedCompressionAlgorithm(
          compression_to_string(compression),
        ),
      )
    None => Ok(())
  }
}

///|
fn use_delta_temporality(
  kind : @sdkmetrics.InstrumentKind,
  temporality : @sdkmetrics.Temporality,
) -> Bool {
  match temporality {
    @sdkmetrics.Temporality::Cumulative => false
    @sdkmetrics.Temporality::Delta =>
      match kind {
        @sdkmetrics.InstrumentKind::Counter => true
        @sdkmetrics.InstrumentKind::Histogram => true
        @sdkmetrics.InstrumentKind::ObservableCounter => true
        @sdkmetrics.InstrumentKind::Gauge => true
        @sdkmetrics.InstrumentKind::ObservableGauge => true
        _ => false
      }
    @sdkmetrics.Temporality::LowMemory =>
      match kind {
        @sdkmetrics.InstrumentKind::Counter => true
        @sdkmetrics.InstrumentKind::Histogram => true
        _ => false
      }
  }
}

///|
fn parse_temporality(
  value : StringView,
) -> Result[@sdkmetrics.Temporality, ExporterBuildError] {
  match normalize_ascii_lower(value) {
    "cumulative" => Ok(@sdkmetrics.Temporality::Cumulative)
    "delta" => Ok(@sdkmetrics.Temporality::Delta)
    "lowmemory" => Ok(@sdkmetrics.Temporality::LowMemory)
    other =>
      Err(
        ExporterBuildError::InvalidConfig(
          OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE,
          "unsupported value \{other}",
        ),
      )
  }
}

///|
fn resolve_temporality(
  provided : @sdkmetrics.Temporality?,
) -> Result[@sdkmetrics.Temporality, ExporterBuildError] {
  match provided {
    Some(temporality) => Ok(temporality)
    None =>
      match
        @env.get_env_var(OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE) {
        Some(value) => parse_temporality(value)
        None => Ok(@sdkmetrics.Temporality::Cumulative)
      }
  }
}

///|
fn build_signal_config(
  signal_name : String,
  signal_path : String,
  signal_endpoint_var : String,
  signal_timeout_var : String,
  signal_headers_var : String,
  signal_compression_var : String,
  endpoint : String?,
  protocol : Protocol?,
  timeout_millis : Int?,
  headers : Map[String, String],
  compression : Compression?,
) -> Result[SignalConfig, ExporterBuildError] {
  let protocol = resolve_protocol(protocol)
  match resolve_compression(signal_compression_var, compression) {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let endpoint = resolve_endpoint(signal_endpoint_var, signal_path, endpoint)
  let timeout_millis = resolve_timeout(signal_timeout_var, timeout_millis)
  match (protocol, endpoint, timeout_millis) {
    (Ok(protocol), Ok(endpoint), Ok(timeout_millis)) =>
      Ok({
        signal_name,
        endpoint,
        protocol,
        timeout_millis,
        headers: resolve_headers(signal_headers_var, headers),
      })
    (Err(err), _, _) => Err(err)
    (_, Err(err), _) => Err(err)
    (_, _, Err(err)) => Err(err)
  }
}

///|
fn sorted_strings(values : Array[String]) -> Array[String] {
  let sorted = values.copy()
  for i in 1..<sorted.length() {
    let current = sorted[i]
    let mut j = i
    while j > 0 && current < sorted[j - 1] {
      sorted[j] = sorted[j - 1]
      j = j - 1
    }
    sorted[j] = current
  }
  sorted
}

///|
fn string_or_empty(value : String?) -> String {
  match value {
    Some(value) => value
    None => ""
  }
}

///|
fn to_uint_non_negative(value : Int) -> UInt {
  if value <= 0 {
    0U
  } else {
    value.reinterpret_as_uint()
  }
}

///|
fn to_uint64_non_negative(value : Int64) -> UInt64 {
  if value <= 0L {
    0UL
  } else {
    value.reinterpret_as_uint64()
  }
}

///|
fn trace_flags_uint(trace_flags : @common.TraceFlags) -> UInt {
  let parsed = @string.parse_int(trace_flags.to_hex(), base=16) catch { _ => 0 }
  parsed.reinterpret_as_uint()
}

///|
fn span_context_flags(span_context : @common.SpanContext) -> UInt {
  let mut flags = trace_flags_uint(span_context.trace_flags()) | 0x100U
  if span_context.is_remote() {
    flags = flags | 0x200U
  }
  flags
}

///|
fn trace_state_header(trace_state : @common.TraceState) -> String {
  match trace_state.to_header() {
    Some(value) => value
    None => ""
  }
}

///|
fn any_value_from_sdk(value : @common.Value) -> @otlpcommon.AnyValue {
  let value = match value {
    @common.Value::Bool(value) => @otlpcommon.AnyValue_Value::BoolValue(value)
    @common.Value::Int64(value) => @otlpcommon.AnyValue_Value::IntValue(value)
    @common.Value::Double(value) =>
      @otlpcommon.AnyValue_Value::DoubleValue(value)
    @common.Value::String(value) =>
      @otlpcommon.AnyValue_Value::StringValue(value)
    @common.Value::Bytes(value) => @otlpcommon.AnyValue_Value::BytesValue(value)
    @common.Value::Array(values) =>
      @otlpcommon.AnyValue_Value::ArrayValue(
        @otlpcommon.ArrayValue::new(values.map(any_value_from_sdk)),
      )
  }
  @otlpcommon.AnyValue::new(value~)
}

///|
fn log_any_value_from_sdk(value : @sdklogs.AnyValue) -> @otlpcommon.AnyValue {
  let value = match value {
    @sdklogs.AnyValue::Bool(value) =>
      @otlpcommon.AnyValue_Value::BoolValue(value)
    @sdklogs.AnyValue::Int64(value) =>
      @otlpcommon.AnyValue_Value::IntValue(value)
    @sdklogs.AnyValue::Double(value) =>
      @otlpcommon.AnyValue_Value::DoubleValue(value)
    @sdklogs.AnyValue::String(value) =>
      @otlpcommon.AnyValue_Value::StringValue(value)
    @sdklogs.AnyValue::Bytes(value) =>
      @otlpcommon.AnyValue_Value::BytesValue(value)
    @sdklogs.AnyValue::Array(values) =>
      @otlpcommon.AnyValue_Value::ArrayValue(
        @otlpcommon.ArrayValue::new(values.map(log_any_value_from_sdk)),
      )
    @sdklogs.AnyValue::Map(values) =>
      @otlpcommon.AnyValue_Value::KvlistValue(
        @otlpcommon.KeyValueList::new(values.map(log_key_value_from_sdk)),
      )
  }
  @otlpcommon.AnyValue::new(value~)
}

///|
fn common_key_value_from_sdk(
  attribute : @common.KeyValue,
) -> @otlpcommon.KeyValue {
  @otlpcommon.KeyValue::new(
    attribute.key.as_string(),
    any_value_from_sdk(attribute.value),
    0,
  )
}

///|
fn log_key_value_from_sdk(
  attribute : @sdklogs.KeyValue,
) -> @otlpcommon.KeyValue {
  @otlpcommon.KeyValue::new(
    attribute.key.as_string(),
    log_any_value_from_sdk(attribute.value),
    0,
  )
}

///|
fn otlp_attributes(
  attributes : ArrayView[@common.KeyValue],
) -> Array[@otlpcommon.KeyValue] {
  attributes.map(common_key_value_from_sdk)
}

///|
fn otlp_log_attributes(
  attributes : ArrayView[@sdklogs.KeyValue],
) -> Array[@otlpcommon.KeyValue] {
  attributes.map(log_key_value_from_sdk)
}

///|
fn resource_attributes(
  resource : @resource.Resource,
) -> Array[@otlpcommon.KeyValue] {
  let attributes = resource.attributes()
  let result = []
  let keys = sorted_strings(attributes.keys().to_array())
  for key in keys {
    guard attributes.get(key) is Some(value)
    result.push(@otlpcommon.KeyValue::new(key, any_value_from_sdk(value), 0))
  }
  result
}

///|
fn otlp_resource(resource : @resource.Resource) -> @otlpresource.Resource {
  @otlpresource.Resource::new(resource_attributes(resource), 0U, [])
}

///|
fn otlp_scope(
  instrumentation_scope : @common.InstrumentationScope,
) -> @otlpcommon.InstrumentationScope {
  @otlpcommon.InstrumentationScope::new(
    instrumentation_scope.name(),
    string_or_empty(instrumentation_scope.version()),
    otlp_attributes(instrumentation_scope.attributes()),
    0U,
  )
}

///|
fn otlp_span_kind(kind : @sdktrace.SpanKind) -> @otlptrace.Span_SpanKind {
  match kind {
    @sdktrace.SpanKind::Internal => @otlptrace.Span_SpanKind::SPAN_KIND_INTERNAL
    @sdktrace.SpanKind::Client => @otlptrace.Span_SpanKind::SPAN_KIND_CLIENT
    @sdktrace.SpanKind::Server => @otlptrace.Span_SpanKind::SPAN_KIND_SERVER
    @sdktrace.SpanKind::Producer => @otlptrace.Span_SpanKind::SPAN_KIND_PRODUCER
    @sdktrace.SpanKind::Consumer => @otlptrace.Span_SpanKind::SPAN_KIND_CONSUMER
  }
}

///|
fn otlp_status_code(
  code : @sdktrace.StatusCode,
) -> @otlptrace.Status_StatusCode {
  match code {
    @sdktrace.StatusCode::Unset =>
      @otlptrace.Status_StatusCode::STATUS_CODE_UNSET
    @sdktrace.StatusCode::Ok => @otlptrace.Status_StatusCode::STATUS_CODE_OK
    @sdktrace.StatusCode::Error =>
      @otlptrace.Status_StatusCode::STATUS_CODE_ERROR
  }
}

///|
fn otlp_span_status(status : @sdktrace.Status) -> @otlptrace.Status {
  @otlptrace.Status::new(
    string_or_empty(status.description),
    otlp_status_code(status.code),
  )
}

///|
fn otlp_span_event(event : @sdktrace.SpanEvent) -> @otlptrace.Span_Event {
  @otlptrace.Span_Event::new(
    to_uint64_non_negative(event.timestamp_unix_nano),
    event.name,
    otlp_attributes(event.attributes),
    to_uint_non_negative(event.dropped_attributes_count),
  )
}

///|
fn otlp_span_link(link : @sdktrace.SpanLink) -> @otlptrace.Span_Link {
  let span_context = link.span_context
  @otlptrace.Span_Link::new(
    span_context.trace_id().bytes(),
    span_context.span_id().bytes(),
    trace_state_header(span_context.trace_state()),
    otlp_attributes(link.attributes),
    to_uint_non_negative(link.dropped_attributes_count),
    span_context_flags(span_context),
  )
}

///|
fn otlp_span(span : @sdktrace.SpanData) -> @otlptrace.Span {
  let parent_span_id = match span.parent_span_context {
    Some(parent_span_context) => parent_span_context.span_id().bytes()
    None => b""
  }
  @otlptrace.Span::new(
    span.span_context.trace_id().bytes(),
    span.span_context.span_id().bytes(),
    trace_state_header(span.span_context.trace_state()),
    parent_span_id,
    span_context_flags(span.span_context),
    span.name,
    otlp_span_kind(span.kind),
    to_uint64_non_negative(span.start_time_unix_nano),
    to_uint64_non_negative(
      match span.end_time_unix_nano {
        Some(end_time_unix_nano) => end_time_unix_nano
        None => 0L
      },
    ),
    otlp_attributes(span.attributes),
    to_uint_non_negative(span.dropped_attributes_count),
    span.events.map(otlp_span_event),
    to_uint_non_negative(span.dropped_events_count),
    span.links.map(otlp_span_link),
    to_uint_non_negative(span.dropped_links_count),
    otlp_span_status(span.status),
  )
}

///|
fn otlp_severity_number(
  severity_number : @sdklogs.SeverityNumber?,
) -> @otlplogs.SeverityNumber {
  match severity_number {
    Some(@sdklogs.SeverityNumber::Trace) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_TRACE
    Some(@sdklogs.SeverityNumber::Trace2) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_TRACE2
    Some(@sdklogs.SeverityNumber::Trace3) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_TRACE3
    Some(@sdklogs.SeverityNumber::Trace4) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_TRACE4
    Some(@sdklogs.SeverityNumber::Debug) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_DEBUG
    Some(@sdklogs.SeverityNumber::Debug2) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_DEBUG2
    Some(@sdklogs.SeverityNumber::Debug3) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_DEBUG3
    Some(@sdklogs.SeverityNumber::Debug4) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_DEBUG4
    Some(@sdklogs.SeverityNumber::Info) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_INFO
    Some(@sdklogs.SeverityNumber::Info2) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_INFO2
    Some(@sdklogs.SeverityNumber::Info3) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_INFO3
    Some(@sdklogs.SeverityNumber::Info4) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_INFO4
    Some(@sdklogs.SeverityNumber::Warn) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_WARN
    Some(@sdklogs.SeverityNumber::Warn2) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_WARN2
    Some(@sdklogs.SeverityNumber::Warn3) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_WARN3
    Some(@sdklogs.SeverityNumber::Warn4) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_WARN4
    Some(@sdklogs.SeverityNumber::Error) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_ERROR
    Some(@sdklogs.SeverityNumber::Error2) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_ERROR2
    Some(@sdklogs.SeverityNumber::Error3) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_ERROR3
    Some(@sdklogs.SeverityNumber::Error4) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_ERROR4
    Some(@sdklogs.SeverityNumber::Fatal) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_FATAL
    Some(@sdklogs.SeverityNumber::Fatal2) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_FATAL2
    Some(@sdklogs.SeverityNumber::Fatal3) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_FATAL3
    Some(@sdklogs.SeverityNumber::Fatal4) =>
      @otlplogs.SeverityNumber::SEVERITY_NUMBER_FATAL4
    None => @otlplogs.SeverityNumber::SEVERITY_NUMBER_UNSPECIFIED
  }
}

///|
fn otlp_log_record(record : @sdklogs.LogRecord) -> @otlplogs.LogRecord {
  let (flags, trace_id, span_id) = match record.trace_context {
    Some(span_context) =>
      (
        trace_flags_uint(span_context.trace_flags()),
        span_context.trace_id().bytes(),
        span_context.span_id().bytes(),
      )
    None => (0U, b"", b"")
  }
  @otlplogs.LogRecord::new(
    to_uint64_non_negative(record.timestamp_unix_nano),
    to_uint64_non_negative(record.observed_timestamp_unix_nano),
    otlp_severity_number(record.severity_number),
    string_or_empty(record.severity_text),
    log_any_value_from_sdk(record.body),
    otlp_log_attributes(record.attributes),
    0U,
    flags,
    trace_id,
    span_id,
    string_or_empty(record.event_name),
  )
}

///|
fn otlp_aggregation_temporality(
  kind : @sdkmetrics.InstrumentKind,
  temporality : @sdkmetrics.Temporality,
) -> @otlpmetrics.AggregationTemporality {
  if use_delta_temporality(kind, temporality) {
    @otlpmetrics.AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA
  } else {
    @otlpmetrics.AggregationTemporality::AGGREGATION_TEMPORALITY_CUMULATIVE
  }
}

///|
fn metric_is_monotonic(kind : @sdkmetrics.InstrumentKind) -> Bool {
  match kind {
    @sdkmetrics.InstrumentKind::Counter => true
    @sdkmetrics.InstrumentKind::ObservableCounter => true
    _ => false
  }
}

///|
fn sdkmetrics_number_to_double(number : @sdkmetrics.Number) -> Double {
  match number {
    @sdkmetrics.Number::Int64(value) => value.to_double()
    @sdkmetrics.Number::UInt64(value) => value.to_double()
    @sdkmetrics.Number::Double(value) => value
  }
}

///|
fn otlp_number_value(
  number : @sdkmetrics.Number,
) -> @otlpmetrics.NumberDataPoint_Value {
  match number {
    @sdkmetrics.Number::Int64(value) =>
      @otlpmetrics.NumberDataPoint_Value::AsInt(value)
    @sdkmetrics.Number::UInt64(value) =>
      if value <= 9223372036854775807UL {
        @otlpmetrics.NumberDataPoint_Value::AsInt(value.reinterpret_as_int64())
      } else {
        @otlpmetrics.NumberDataPoint_Value::AsDouble(value.to_double())
      }
    @sdkmetrics.Number::Double(value) =>
      @otlpmetrics.NumberDataPoint_Value::AsDouble(value)
  }
}

///|
fn otlp_number_point(
  metric : @sdkmetrics.MetricData,
  number : @sdkmetrics.Number,
) -> @otlpmetrics.NumberDataPoint {
  @otlpmetrics.NumberDataPoint::new(
    otlp_attributes(metric.attributes),
    0UL,
    to_uint64_non_negative(metric.time_unix_nano),
    [],
    0U,
    value=otlp_number_value(number),
  )
}

///|
fn otlp_histogram_point(
  metric : @sdkmetrics.MetricData,
  summary : @sdkmetrics.HistogramSummary,
) -> @otlpmetrics.HistogramDataPoint {
  let count = to_uint64_non_negative(summary.count)
  {
    attributes: otlp_attributes(metric.attributes),
    start_time_unix_nano: 0UL,
    time_unix_nano: to_uint64_non_negative(metric.time_unix_nano),
    count,
    sum: Some(sdkmetrics_number_to_double(summary.sum)),
    bucket_counts: [count],
    explicit_bounds: [],
    exemplars: [],
    flags: 0U,
    min: summary.min.map(value => sdkmetrics_number_to_double(value)),
    max: summary.max.map(value => sdkmetrics_number_to_double(value)),
  }
}

///|
fn otlp_metric(
  metric : @sdkmetrics.MetricData,
  temporality : @sdkmetrics.Temporality,
) -> @otlpmetrics.Metric {
  let data = match metric.aggregation {
    @sdkmetrics.Aggregation::Gauge(number) =>
      @otlpmetrics.Metric_Data::Gauge(
        @otlpmetrics.Gauge::new([otlp_number_point(metric, number)]),
      )
    @sdkmetrics.Aggregation::Sum(number) =>
      @otlpmetrics.Metric_Data::Sum(
        @otlpmetrics.Sum::new(
          [otlp_number_point(metric, number)],
          otlp_aggregation_temporality(metric.kind, temporality),
          metric_is_monotonic(metric.kind),
        ),
      )
    @sdkmetrics.Aggregation::Histogram(summary) =>
      @otlpmetrics.Metric_Data::Histogram(
        @otlpmetrics.Histogram::new(
          [otlp_histogram_point(metric, summary)],
          otlp_aggregation_temporality(metric.kind, temporality),
        ),
      )
  }
  @otlpmetrics.Metric::new(
    metric.name,
    string_or_empty(metric.description),
    string_or_empty(metric.unit),
    [],
    data~,
  )
}

///|
fn[T : @protobuf.Write] encode_protobuf(message : T) -> Result[Bytes, String] {
  try {
    let buffer = @buffer.new()
    @protobuf.Write::write(message, buffer)
    Ok(buffer.to_bytes())
  } catch {
    err => Err(@debug.to_string(err))
  }
}

///|
fn encode_trace_id_json(value : String) -> Json {
  let bytes = @protobuf.base64_decode(value)
  match @common.TraceId::from_bytes(bytes) {
    Some(trace_id) => Json::string(trace_id.to_hex())
    None => Json::string(value)
  }
}

///|
fn encode_span_id_json(value : String, allow_empty : Bool) -> Json {
  if allow_empty && value == "" {
    return Json::string("")
  }
  let bytes = @protobuf.base64_decode(value)
  match @common.SpanId::from_bytes(bytes) {
    Some(span_id) => Json::string(span_id.to_hex())
    None => Json::string(value)
  }
}

///|
fn decode_trace_id_json(value : String) -> Json {
  match @common.TraceId::from_hex(value) {
    Some(trace_id) => Json::string(@protobuf.base64_encode(trace_id.bytes()))
    None => Json::string(value)
  }
}

///|
fn decode_span_id_json(value : String, allow_empty : Bool) -> Json {
  if allow_empty && value == "" {
    return Json::string("")
  }
  match @common.SpanId::from_hex(value) {
    Some(span_id) => Json::string(@protobuf.base64_encode(span_id.bytes()))
    None => Json::string(value)
  }
}

///|
fn normalize_otlp_http_json_request(json : Json) -> Json {
  match json {
    Object(obj) => {
      let normalized : Map[String, Json] = {}
      for key, value in obj {
        normalized[key] = match value {
          String(value) =>
            match key {
              "traceId" => encode_trace_id_json(value)
              "spanId" => encode_span_id_json(value, false)
              "parentSpanId" => encode_span_id_json(value, true)
              _ => Json::string(value)
            }
          _ => normalize_otlp_http_json_request(value)
        }
      }
      Json::object(normalized)
    }
    Array(values) =>
      Json::array(values.map(value => normalize_otlp_http_json_request(value)))
    _ => json
  }
}

///|
fn normalize_otlp_http_json_response(json : Json) -> Json {
  match json {
    Object(obj) => {
      let normalized : Map[String, Json] = {}
      for key, value in obj {
        normalized[key] = match value {
          String(value) =>
            match key {
              "traceId" => decode_trace_id_json(value)
              "spanId" => decode_span_id_json(value, false)
              "parentSpanId" => decode_span_id_json(value, true)
              _ => Json::string(value)
            }
          _ => normalize_otlp_http_json_response(value)
        }
      }
      Json::object(normalized)
    }
    Array(values) =>
      Json::array(values.map(value => normalize_otlp_http_json_response(value)))
    _ => json
  }
}

///|
fn[T : ToJson] encode_json_message(message : T) -> Bytes {
  @utf8.encode(normalize_otlp_http_json_request(message.to_json()).stringify())
}

///|
fn[T : @json.FromJson] decode_json_message(bytes : Bytes) -> Result[T, String] {
  let text = @utf8.decode(bytes) catch {
    _ => return Err("response body is not valid utf-8")
  }
  let json = @json.parse(text) catch {
    _ => return Err("response body is not valid json")
  }
  try {
    let message : T = @json.from_json(normalize_otlp_http_json_response(json))
    Ok(message)
  } catch {
    _ => Err("response body does not match OTLP json schema")
  }
}

///|
fn decode_trace_response(
  bytes : Bytes,
) -> Result[@collectortrace.ExportTraceServiceResponse, String] {
  try {
    let reader = @protobuf.BytesReader::from_bytes(bytes)
    let message : @collectortrace.ExportTraceServiceResponse = @protobuf.Read::read(
      reader,
    )
    Ok(message)
  } catch {
    err => Err(@debug.to_string(err))
  }
}

///|
fn decode_logs_response(
  bytes : Bytes,
) -> Result[@collectorlogs.ExportLogsServiceResponse, String] {
  try {
    let reader = @protobuf.BytesReader::from_bytes(bytes)
    let message : @collectorlogs.ExportLogsServiceResponse = @protobuf.Read::read(
      reader,
    )
    Ok(message)
  } catch {
    err => Err(@debug.to_string(err))
  }
}

///|
fn decode_metrics_response(
  bytes : Bytes,
) -> Result[@collectormetrics.ExportMetricsServiceResponse, String] {
  try {
    let reader = @protobuf.BytesReader::from_bytes(bytes)
    let message : @collectormetrics.ExportMetricsServiceResponse = @protobuf.Read::read(
      reader,
    )
    Ok(message)
  } catch {
    err => Err(@debug.to_string(err))
  }
}

///|
fn build_trace_request(
  batch : ArrayView[@sdktrace.SpanData],
) -> @collectortrace.ExportTraceServiceRequest {
  let resource_spans = []
  for span in batch {
    resource_spans.push(
      @otlptrace.ResourceSpans::new(
        otlp_resource(span.resource),
        [
          @otlptrace.ScopeSpans::new(
            otlp_scope(span.instrumentation_scope),
            [otlp_span(span)],
            string_or_empty(span.instrumentation_scope.schema_url()),
          ),
        ],
        string_or_empty(span.resource.schema_url()),
      ),
    )
  }
  @collectortrace.ExportTraceServiceRequest::new(resource_spans)
}

///|
priv struct LogsRequestGroup {
  resource_key : String
  scope_key : String
  resource : @otlpresource.Resource
  resource_schema_url : String
  scope : @otlpcommon.InstrumentationScope
  scope_schema_url : String
  log_records : Array[@otlplogs.LogRecord]
}

///|
fn resource_identity(resource : @resource.Resource) -> String {
  let builder = StringBuilder::new()
  builder.write_string(string_or_empty(resource.schema_url()))
  let attributes = resource.attributes()
  let keys = sorted_strings(attributes.keys().to_array())
  for key in keys {
    guard attributes.get(key) is Some(value)
    builder.write_char('|')
    builder.write_string(key)
    builder.write_char('=')
    builder.write_string(value.to_json().stringify())
  }
  builder.to_string()
}

///|
fn scope_identity(
  instrumentation_scope : @common.InstrumentationScope,
  target : String?,
) -> String {
  match target {
    Some(target) => "target|\{target}"
    None => {
      let builder = StringBuilder::new()
      builder.write_string(instrumentation_scope.name())
      builder.write_char('|')
      builder.write_string(string_or_empty(instrumentation_scope.version()))
      builder.write_char('|')
      builder.write_string(string_or_empty(instrumentation_scope.schema_url()))
      for attribute in otlp_attributes(instrumentation_scope.attributes()) {
        builder.write_char('|')
        builder.write_string(attribute.key)
        builder.write_char('=')
        builder.write_string(attribute.value.to_json().stringify())
      }
      builder.to_string()
    }
  }
}

///|
fn log_scope(record : @sdklogs.LogRecord) -> @otlpcommon.InstrumentationScope {
  match record.target {
    Some(target) => @otlpcommon.InstrumentationScope::new(target, "", [], 0U)
    None => otlp_scope(record.instrumentation_scope)
  }
}

///|
fn log_scope_schema_url(record : @sdklogs.LogRecord) -> String {
  match record.target {
    Some(_) => ""
    None => string_or_empty(record.instrumentation_scope.schema_url())
  }
}

///|
fn build_logs_request(
  batch : ArrayView[@sdklogs.LogRecord],
) -> @collectorlogs.ExportLogsServiceRequest {
  let groups : Array[Ref[LogsRequestGroup]] = []
  for record in batch {
    let resource_key = resource_identity(record.resource)
    let scope_key = scope_identity(record.instrumentation_scope, record.target)
    let otlp_record = otlp_log_record(record)
    let mut matched_group : Ref[LogsRequestGroup]? = None
    for group in groups {
      if group.val.resource_key == resource_key &&
        group.val.scope_key == scope_key {
        matched_group = Some(group)
        break
      }
    }
    match matched_group {
      Some(group) => group.val.log_records.push(otlp_record)
      None =>
        groups.push(
          Ref::new({
            resource_key,
            scope_key,
            resource: otlp_resource(record.resource),
            resource_schema_url: string_or_empty(record.resource.schema_url()),
            scope: log_scope(record),
            scope_schema_url: log_scope_schema_url(record),
            log_records: [otlp_record],
          }),
        )
    }
  }
  let resource_logs = []
  for group in groups {
    resource_logs.push(
      @otlplogs.ResourceLogs::new(
        group.val.resource,
        [
          @otlplogs.ScopeLogs::new(
            group.val.scope,
            group.val.log_records,
            group.val.scope_schema_url,
          ),
        ],
        group.val.resource_schema_url,
      ),
    )
  }
  @collectorlogs.ExportLogsServiceRequest::new(resource_logs)
}

///|
fn build_metrics_request(
  batch : ArrayView[@sdkmetrics.MetricData],
  temporality : @sdkmetrics.Temporality,
) -> @collectormetrics.ExportMetricsServiceRequest {
  let resource_metrics = []
  for metric in batch {
    resource_metrics.push(
      @otlpmetrics.ResourceMetrics::new(
        otlp_resource(metric.resource),
        [
          @otlpmetrics.ScopeMetrics::new(
            otlp_scope(metric.instrumentation_scope),
            [otlp_metric(metric, temporality)],
            string_or_empty(metric.instrumentation_scope.schema_url()),
          ),
        ],
        string_or_empty(metric.resource.schema_url()),
      ),
    )
  }
  @collectormetrics.ExportMetricsServiceRequest::new(resource_metrics)
}

///|
fn format_http_failure(
  signal_name : String,
  response : @http.Response,
  body : &@io.Data,
) -> String {
  let body_text = body.text() catch { _ => "" }
  if body_text == "" {
    "\{signal_name} export failed with HTTP \{response.code} \{response.reason}"
  } else {
    "\{signal_name} export failed with HTTP \{response.code} \{response.reason}: \{body_text}"
  }
}

///|
async fn post_payload(
  config : SignalConfig,
  payload : Bytes,
  content_type : String,
) -> Result[Bytes, String] {
  let headers = config.headers.copy()
  headers["content-type"] = content_type
  guard @async.with_timeout_opt(config.timeout_millis, () => {
      @http.post(config.endpoint, payload, headers~)
    })
    is Some((response, body)) else {
    return Err(
      "\{config.signal_name} export timed out after \{config.timeout_millis}ms",
    )
  }
  if response.code < 200 || response.code >= 300 {
    return Err(format_http_failure(config.signal_name, response, body))
  }
  Ok(body.binary())
}

///|
fn validate_trace_response(
  protocol : Protocol,
  body : Bytes,
) -> Result[Unit, String] {
  if body.length() == 0 {
    return Ok(())
  }
  let response : @collectortrace.ExportTraceServiceResponse = match protocol {
    Protocol::HttpBinary =>
      match decode_trace_response(body) {
        Ok(response) => response
        Err(err) => return Err(err)
      }
    Protocol::HttpJson =>
      match decode_json_message(body) {
        Ok(response) => response
        Err(err) => return Err(err)
      }
    Protocol::Grpc =>
      return Err("grpc transport is not supported by HTTP exporters")
  }
  let partial_success = response.partial_success
  if partial_success.rejected_spans > 0L || partial_success.error_message != "" {
    Err(
      "trace export partial success: rejected_spans=\{partial_success.rejected_spans}, message=\{partial_success.error_message}",
    )
  } else {
    Ok(())
  }
}

///|
fn validate_logs_response(
  protocol : Protocol,
  body : Bytes,
) -> Result[Unit, String] {
  if body.length() == 0 {
    return Ok(())
  }
  let response : @collectorlogs.ExportLogsServiceResponse = match protocol {
    Protocol::HttpBinary =>
      match decode_logs_response(body) {
        Ok(response) => response
        Err(err) => return Err(err)
      }
    Protocol::HttpJson =>
      match decode_json_message(body) {
        Ok(response) => response
        Err(err) => return Err(err)
      }
    Protocol::Grpc =>
      return Err("grpc transport is not supported by HTTP exporters")
  }
  let partial_success = response.partial_success
  if partial_success.rejected_log_records > 0L ||
    partial_success.error_message != "" {
    Err(
      "logs export partial success: rejected_log_records=\{partial_success.rejected_log_records}, message=\{partial_success.error_message}",
    )
  } else {
    Ok(())
  }
}

///|
fn validate_metrics_response(
  protocol : Protocol,
  body : Bytes,
) -> Result[Unit, String] {
  if body.length() == 0 {
    return Ok(())
  }
  let response : @collectormetrics.ExportMetricsServiceResponse = match
    protocol {
    Protocol::HttpBinary =>
      match decode_metrics_response(body) {
        Ok(response) => response
        Err(err) => return Err(err)
      }
    Protocol::HttpJson =>
      match decode_json_message(body) {
        Ok(response) => response
        Err(err) => return Err(err)
      }
    Protocol::Grpc =>
      return Err("grpc transport is not supported by HTTP exporters")
  }
  let partial_success = response.partial_success
  if partial_success.rejected_data_points > 0L ||
    partial_success.error_message != "" {
    Err(
      "metrics export partial success: rejected_data_points=\{partial_success.rejected_data_points}, message=\{partial_success.error_message}",
    )
  } else {
    Ok(())
  }
}

///|
/// Starts building a span exporter.
pub fn SpanExporter::builder() -> SpanExporterBuilder {
  {
    endpoint: None,
    protocol: None,
    timeout_millis: None,
    headers: {},
    compression: None,
  }
}

///|
/// Starts building a log exporter.
pub fn LogExporter::builder() -> LogExporterBuilder {
  {
    endpoint: None,
    protocol: None,
    timeout_millis: None,
    headers: {},
    compression: None,
  }
}

///|
/// Starts building a metric exporter.
pub fn MetricExporter::builder() -> MetricExporterBuilder {
  {
    endpoint: None,
    protocol: None,
    timeout_millis: None,
    headers: {},
    compression: None,
    temporality: None,
  }
}

///|
/// Builds a span exporter from defaults plus environment variables.
pub fn SpanExporter::new() -> Result[SpanExporter, ExporterBuildError] {
  SpanExporter::builder().build()
}

///|
/// Builds a log exporter from defaults plus environment variables.
pub fn LogExporter::new() -> Result[LogExporter, ExporterBuildError] {
  LogExporter::builder().build()
}

///|
/// Builds a metric exporter from defaults plus environment variables.
pub fn MetricExporter::new() -> Result[MetricExporter, ExporterBuildError] {
  MetricExporter::builder().build()
}

///|
/// Selects HTTP protobuf transport explicitly.
pub fn SpanExporterBuilder::with_http(
  self : SpanExporterBuilder,
) -> SpanExporterBuilder {
  self.protocol = Some(Protocol::HttpBinary)
  self
}

///|
/// Selects HTTP protobuf transport explicitly.
pub fn LogExporterBuilder::with_http(
  self : LogExporterBuilder,
) -> LogExporterBuilder {
  self.protocol = Some(Protocol::HttpBinary)
  self
}

///|
/// Selects HTTP protobuf transport explicitly.
pub fn MetricExporterBuilder::with_http(
  self : MetricExporterBuilder,
) -> MetricExporterBuilder {
  self.protocol = Some(Protocol::HttpBinary)
  self
}

///|
/// Sets an explicit OTLP endpoint for the span exporter.
///
/// This value overrides any endpoint derived from the environment.
pub fn SpanExporterBuilder::with_endpoint(
  self : SpanExporterBuilder,
  endpoint : StringView,
) -> SpanExporterBuilder {
  self.endpoint = Some(endpoint.to_string())
  self
}

///|
/// Sets an explicit OTLP endpoint for the log exporter.
///
/// This value overrides any endpoint derived from the environment.
pub fn LogExporterBuilder::with_endpoint(
  self : LogExporterBuilder,
  endpoint : StringView,
) -> LogExporterBuilder {
  self.endpoint = Some(endpoint.to_string())
  self
}

///|
/// Sets an explicit OTLP endpoint for the metric exporter.
///
/// This value overrides any endpoint derived from the environment.
pub fn MetricExporterBuilder::with_endpoint(
  self : MetricExporterBuilder,
  endpoint : StringView,
) -> MetricExporterBuilder {
  self.endpoint = Some(endpoint.to_string())
  self
}

///|
/// Sets the OTLP protocol for the span exporter.
///
/// `Protocol::Grpc` is currently rejected during `build()`.
pub fn SpanExporterBuilder::with_protocol(
  self : SpanExporterBuilder,
  protocol : Protocol,
) -> SpanExporterBuilder {
  self.protocol = Some(protocol)
  self
}

///|
/// Sets the OTLP protocol for the log exporter.
///
/// `Protocol::Grpc` is currently rejected during `build()`.
pub fn LogExporterBuilder::with_protocol(
  self : LogExporterBuilder,
  protocol : Protocol,
) -> LogExporterBuilder {
  self.protocol = Some(protocol)
  self
}

///|
/// Sets the OTLP protocol for the metric exporter.
///
/// `Protocol::Grpc` is currently rejected during `build()`.
pub fn MetricExporterBuilder::with_protocol(
  self : MetricExporterBuilder,
  protocol : Protocol,
) -> MetricExporterBuilder {
  self.protocol = Some(protocol)
  self
}

///|
/// Sets the request timeout in milliseconds for the span exporter.
///
/// The value must be greater than zero.
pub fn SpanExporterBuilder::with_timeout(
  self : SpanExporterBuilder,
  timeout_millis : Int,
) -> SpanExporterBuilder {
  self.timeout_millis = Some(timeout_millis)
  self
}

///|
/// Sets the request timeout in milliseconds for the log exporter.
///
/// The value must be greater than zero.
pub fn LogExporterBuilder::with_timeout(
  self : LogExporterBuilder,
  timeout_millis : Int,
) -> LogExporterBuilder {
  self.timeout_millis = Some(timeout_millis)
  self
}

///|
/// Sets the request timeout in milliseconds for the metric exporter.
///
/// The value must be greater than zero.
pub fn MetricExporterBuilder::with_timeout(
  self : MetricExporterBuilder,
  timeout_millis : Int,
) -> MetricExporterBuilder {
  self.timeout_millis = Some(timeout_millis)
  self
}

///|
/// Adds explicit headers for the span exporter.
///
/// Header names are normalized to lowercase and override environment-derived
/// headers with the same name.
pub fn SpanExporterBuilder::with_headers(
  self : SpanExporterBuilder,
  headers : Map[String, String],
) -> SpanExporterBuilder {
  self.headers = normalize_headers(headers)
  self
}

///|
/// Adds explicit headers for the log exporter.
///
/// Header names are normalized to lowercase and override environment-derived
/// headers with the same name.
pub fn LogExporterBuilder::with_headers(
  self : LogExporterBuilder,
  headers : Map[String, String],
) -> LogExporterBuilder {
  self.headers = normalize_headers(headers)
  self
}

///|
/// Adds explicit headers for the metric exporter.
///
/// Header names are normalized to lowercase and override environment-derived
/// headers with the same name.
pub fn MetricExporterBuilder::with_headers(
  self : MetricExporterBuilder,
  headers : Map[String, String],
) -> MetricExporterBuilder {
  self.headers = normalize_headers(headers)
  self
}

///|
/// Requests compression for the span exporter.
///
/// Compression is not implemented yet, so `build()` will fail when this is set.
pub fn SpanExporterBuilder::with_compression(
  self : SpanExporterBuilder,
  compression : Compression,
) -> SpanExporterBuilder {
  self.compression = Some(compression)
  self
}

///|
/// Requests compression for the log exporter.
///
/// Compression is not implemented yet, so `build()` will fail when this is set.
pub fn LogExporterBuilder::with_compression(
  self : LogExporterBuilder,
  compression : Compression,
) -> LogExporterBuilder {
  self.compression = Some(compression)
  self
}

///|
/// Requests compression for the metric exporter.
///
/// Compression is not implemented yet, so `build()` will fail when this is set.
pub fn MetricExporterBuilder::with_compression(
  self : MetricExporterBuilder,
  compression : Compression,
) -> MetricExporterBuilder {
  self.compression = Some(compression)
  self
}

///|
/// Sets the temporality preference used when exporting metrics.
pub fn MetricExporterBuilder::with_temporality(
  self : MetricExporterBuilder,
  temporality : @sdkmetrics.Temporality,
) -> MetricExporterBuilder {
  self.temporality = Some(temporality)
  self
}

///|
/// Resolves configuration and builds a span exporter.
///
/// Explicit builder options override environment-derived defaults.
pub fn SpanExporterBuilder::build(
  self : SpanExporterBuilder,
) -> Result[SpanExporter, ExporterBuildError] {
  let config = build_signal_config(
    "traces",
    "/v1/traces",
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
    OTEL_EXPORTER_OTLP_TRACES_TIMEOUT,
    OTEL_EXPORTER_OTLP_TRACES_HEADERS,
    OTEL_EXPORTER_OTLP_TRACES_COMPRESSION,
    self.endpoint,
    self.protocol,
    self.timeout_millis,
    self.headers,
    self.compression,
  )
  match config {
    Ok(config) => Ok({ state: Ref::new({ is_shutdown: false }), config })
    Err(err) => Err(err)
  }
}

///|
/// Resolves configuration and builds a log exporter.
///
/// Explicit builder options override environment-derived defaults.
pub fn LogExporterBuilder::build(
  self : LogExporterBuilder,
) -> Result[LogExporter, ExporterBuildError] {
  let config = build_signal_config(
    "logs",
    "/v1/logs",
    OTEL_EXPORTER_OTLP_LOGS_ENDPOINT,
    OTEL_EXPORTER_OTLP_LOGS_TIMEOUT,
    OTEL_EXPORTER_OTLP_LOGS_HEADERS,
    OTEL_EXPORTER_OTLP_LOGS_COMPRESSION,
    self.endpoint,
    self.protocol,
    self.timeout_millis,
    self.headers,
    self.compression,
  )
  match config {
    Ok(config) => Ok({ state: Ref::new({ is_shutdown: false }), config })
    Err(err) => Err(err)
  }
}

///|
/// Resolves configuration and builds a metric exporter.
///
/// Explicit builder options override environment-derived defaults.
pub fn MetricExporterBuilder::build(
  self : MetricExporterBuilder,
) -> Result[MetricExporter, ExporterBuildError] {
  let config = build_signal_config(
    "metrics",
    "/v1/metrics",
    OTEL_EXPORTER_OTLP_METRICS_ENDPOINT,
    OTEL_EXPORTER_OTLP_METRICS_TIMEOUT,
    OTEL_EXPORTER_OTLP_METRICS_HEADERS,
    OTEL_EXPORTER_OTLP_METRICS_COMPRESSION,
    self.endpoint,
    self.protocol,
    self.timeout_millis,
    self.headers,
    self.compression,
  )
  let temporality = resolve_temporality(self.temporality)
  match (config, temporality) {
    (Ok(config), Ok(temporality)) =>
      Ok({ state: Ref::new({ is_shutdown: false }), config, temporality })
    (Err(err), _) => Err(err)
    (_, Err(err)) => Err(err)
  }
}

///|
/// Returns the temporality chosen for metric export.
pub fn MetricExporter::temporality(
  self : MetricExporter,
) -> @sdkmetrics.Temporality {
  self.temporality
}

///|
/// Returns the exporter name reported to the SDK.
pub fn SpanExporter::name(self : SpanExporter) -> String {
  ignore(self)
  "otlp"
}

///|
/// Returns the exporter name reported to the SDK.
pub fn LogExporter::name(self : LogExporter) -> String {
  ignore(self)
  "otlp"
}

///|
/// Returns the exporter name reported to the SDK.
pub fn MetricExporter::name(self : MetricExporter) -> String {
  ignore(self)
  "otlp"
}

///|
/// Exports one batch of finished spans.
///
/// Empty batches succeed immediately. After shutdown, the call returns
/// `AlreadyShutdown`.
pub async fn SpanExporter::export_batch(
  self : SpanExporter,
  batch : ArrayView[@sdktrace.SpanData],
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  if batch.length() == 0 {
    return @error.ok()
  }
  let request = build_trace_request(batch)
  let (payload, content_type) = match self.config.protocol {
    Protocol::HttpBinary =>
      match encode_protobuf(request) {
        Ok(payload) => (payload, "application/x-protobuf")
        Err(message) =>
          return @error.export_failure(
            self.name(),
            "failed to encode trace request: \{message}",
          )
      }
    Protocol::HttpJson => (encode_json_message(request), "application/json")
    Protocol::Grpc =>
      return @error.export_failure(
        self.name(),
        "grpc transport is not supported by HTTP exporters",
      )
  }
  let response = post_payload(self.config, payload, content_type)
  match response {
    Ok(body) =>
      match validate_trace_response(self.config.protocol, body) {
        Ok(_) => @error.ok()
        Err(message) => @error.export_failure(self.name(), message)
      }
    Err(message) => @error.export_failure(self.name(), message)
  }
}

///|
/// Exports one batch of log records.
///
/// Empty batches succeed immediately. After shutdown, the call returns
/// `AlreadyShutdown`.
pub async fn LogExporter::export_batch(
  self : LogExporter,
  batch : ArrayView[@sdklogs.LogRecord],
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  if batch.length() == 0 {
    return @error.ok()
  }
  let request = build_logs_request(batch)
  let (payload, content_type) = match self.config.protocol {
    Protocol::HttpBinary =>
      match encode_protobuf(request) {
        Ok(payload) => (payload, "application/x-protobuf")
        Err(message) =>
          return @error.export_failure(
            self.name(),
            "failed to encode logs request: \{message}",
          )
      }
    Protocol::HttpJson => (encode_json_message(request), "application/json")
    Protocol::Grpc =>
      return @error.export_failure(
        self.name(),
        "grpc transport is not supported by HTTP exporters",
      )
  }
  let response = post_payload(self.config, payload, content_type)
  match response {
    Ok(body) =>
      match validate_logs_response(self.config.protocol, body) {
        Ok(_) => @error.ok()
        Err(message) => @error.export_failure(self.name(), message)
      }
    Err(message) => @error.export_failure(self.name(), message)
  }
}

///|
/// Exports one batch of metrics.
///
/// Empty batches succeed immediately. After shutdown, the call returns
/// `AlreadyShutdown`.
pub async fn MetricExporter::export_batch(
  self : MetricExporter,
  batch : ArrayView[@sdkmetrics.MetricData],
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  if batch.length() == 0 {
    return @error.ok()
  }
  let request = build_metrics_request(batch, self.temporality)
  let (payload, content_type) = match self.config.protocol {
    Protocol::HttpBinary =>
      match encode_protobuf(request) {
        Ok(payload) => (payload, "application/x-protobuf")
        Err(message) =>
          return @error.export_failure(
            self.name(),
            "failed to encode metrics request: \{message}",
          )
      }
    Protocol::HttpJson => (encode_json_message(request), "application/json")
    Protocol::Grpc =>
      return @error.export_failure(
        self.name(),
        "grpc transport is not supported by HTTP exporters",
      )
  }
  let response = post_payload(self.config, payload, content_type)
  match response {
    Ok(body) =>
      match validate_metrics_response(self.config.protocol, body) {
        Ok(_) => @error.ok()
        Err(message) => @error.export_failure(self.name(), message)
      }
    Err(message) => @error.export_failure(self.name(), message)
  }
}

///|
/// Flushes the span exporter.
///
/// The current implementation has no extra buffered work, so this is a no-op
/// unless the exporter has already been shut down.
#warnings("-unused_async")
pub async fn SpanExporter::force_flush(
  self : SpanExporter,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    @error.already_shutdown()
  } else {
    @error.ok()
  }
}

///|
/// Flushes the log exporter.
///
/// The current implementation has no extra buffered work, so this is a no-op
/// unless the exporter has already been shut down.
#warnings("-unused_async")
pub async fn LogExporter::force_flush(
  self : LogExporter,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    @error.already_shutdown()
  } else {
    @error.ok()
  }
}

///|
/// Flushes the metric exporter.
///
/// The current implementation has no extra buffered work, so this is a no-op
/// unless the exporter has already been shut down.
#warnings("-unused_async")
pub async fn MetricExporter::force_flush(
  self : MetricExporter,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    @error.already_shutdown()
  } else {
    @error.ok()
  }
}

///|
/// Shuts down the span exporter.
///
/// `timeout_millis` is accepted for API parity but is not used by the current
/// implementation.
#warnings("-unused_async")
pub async fn SpanExporter::shutdown_with_timeout(
  self : SpanExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = { is_shutdown: true }
  @error.ok()
}

///|
/// Shuts down the log exporter.
///
/// `timeout_millis` is accepted for API parity but is not used by the current
/// implementation.
#warnings("-unused_async")
pub async fn LogExporter::shutdown_with_timeout(
  self : LogExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = { is_shutdown: true }
  @error.ok()
}

///|
/// Shuts down the metric exporter.
///
/// `timeout_millis` is accepted for API parity but is not used by the current
/// implementation.
#warnings("-unused_async")
pub async fn MetricExporter::shutdown_with_timeout(
  self : MetricExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = { is_shutdown: true }
  @error.ok()
}

///|
/// Shuts down the span exporter using the default timeout budget.
pub async fn SpanExporter::shutdown(
  self : SpanExporter,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Shuts down the log exporter using the default timeout budget.
pub async fn LogExporter::shutdown(self : LogExporter) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Shuts down the metric exporter using the default timeout budget.
pub async fn MetricExporter::shutdown(
  self : MetricExporter,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Erases the concrete span exporter type into `@sdktrace.SpanExporter`.
pub fn SpanExporter::into_span_exporter(
  self : SpanExporter,
) -> @sdktrace.SpanExporter {
  @sdktrace.SpanExporter::new(
    (batch : ArrayView[@sdktrace.SpanData]) => self.export_batch(batch),
    force_flush_fn=() => self.force_flush(),
    shutdown_fn=() => self.shutdown(),
    name_fn=() => self.name(),
  )
}

///|
/// Erases the concrete log exporter type into `@sdklogs.LogExporter`.
pub fn LogExporter::into_log_exporter(
  self : LogExporter,
) -> @sdklogs.LogExporter {
  @sdklogs.LogExporter::new(
    (batch : ArrayView[@sdklogs.LogRecord]) => self.export_batch(batch),
    force_flush_fn=() => self.force_flush(),
    shutdown_fn=() => self.shutdown(),
    name_fn=() => self.name(),
  )
}

///|
/// Erases the concrete metric exporter type into `@sdkmetrics.MetricExporter`.
pub fn MetricExporter::into_metric_exporter(
  self : MetricExporter,
) -> @sdkmetrics.MetricExporter {
  @sdkmetrics.MetricExporter::new(
    (batch : ArrayView[@sdkmetrics.MetricData]) => self.export_batch(batch),
    force_flush_fn=() => self.force_flush(),
    shutdown_fn=() => self.shutdown(),
    name_fn=() => self.name(),
  )
}

///|
/// Builds a periodic reader using this exporter's resolved temporality.
///
/// When `interval_millis` is negative, the SDK reader default is used.
pub fn MetricExporter::into_periodic_reader(
  self : MetricExporter,
  interval_millis? : Int = -1,
) -> @sdkmetrics.PeriodicMetricReader {
  let builder = @sdkmetrics.PeriodicMetricReader::builder(
    self.into_metric_exporter(),
  ).with_temporality(self.temporality)
  if interval_millis < 0 {
    builder.build()
  } else {
    builder.with_interval(interval_millis).build()
  }
}
