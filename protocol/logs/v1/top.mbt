///|
pub(all) enum SeverityNumber {
  SEVERITY_NUMBER_UNSPECIFIED
  SEVERITY_NUMBER_TRACE
  SEVERITY_NUMBER_TRACE2
  SEVERITY_NUMBER_TRACE3
  SEVERITY_NUMBER_TRACE4
  SEVERITY_NUMBER_DEBUG
  SEVERITY_NUMBER_DEBUG2
  SEVERITY_NUMBER_DEBUG3
  SEVERITY_NUMBER_DEBUG4
  SEVERITY_NUMBER_INFO
  SEVERITY_NUMBER_INFO2
  SEVERITY_NUMBER_INFO3
  SEVERITY_NUMBER_INFO4
  SEVERITY_NUMBER_WARN
  SEVERITY_NUMBER_WARN2
  SEVERITY_NUMBER_WARN3
  SEVERITY_NUMBER_WARN4
  SEVERITY_NUMBER_ERROR
  SEVERITY_NUMBER_ERROR2
  SEVERITY_NUMBER_ERROR3
  SEVERITY_NUMBER_ERROR4
  SEVERITY_NUMBER_FATAL
  SEVERITY_NUMBER_FATAL2
  SEVERITY_NUMBER_FATAL3
  SEVERITY_NUMBER_FATAL4
} derive(Eq)

///|
pub fn SeverityNumber::to_enum(self : SeverityNumber) -> @protobuf.Enum {
  match self {
    SeverityNumber::SEVERITY_NUMBER_UNSPECIFIED => 0
    SeverityNumber::SEVERITY_NUMBER_TRACE => 1
    SeverityNumber::SEVERITY_NUMBER_TRACE2 => 2
    SeverityNumber::SEVERITY_NUMBER_TRACE3 => 3
    SeverityNumber::SEVERITY_NUMBER_TRACE4 => 4
    SeverityNumber::SEVERITY_NUMBER_DEBUG => 5
    SeverityNumber::SEVERITY_NUMBER_DEBUG2 => 6
    SeverityNumber::SEVERITY_NUMBER_DEBUG3 => 7
    SeverityNumber::SEVERITY_NUMBER_DEBUG4 => 8
    SeverityNumber::SEVERITY_NUMBER_INFO => 9
    SeverityNumber::SEVERITY_NUMBER_INFO2 => 10
    SeverityNumber::SEVERITY_NUMBER_INFO3 => 11
    SeverityNumber::SEVERITY_NUMBER_INFO4 => 12
    SeverityNumber::SEVERITY_NUMBER_WARN => 13
    SeverityNumber::SEVERITY_NUMBER_WARN2 => 14
    SeverityNumber::SEVERITY_NUMBER_WARN3 => 15
    SeverityNumber::SEVERITY_NUMBER_WARN4 => 16
    SeverityNumber::SEVERITY_NUMBER_ERROR => 17
    SeverityNumber::SEVERITY_NUMBER_ERROR2 => 18
    SeverityNumber::SEVERITY_NUMBER_ERROR3 => 19
    SeverityNumber::SEVERITY_NUMBER_ERROR4 => 20
    SeverityNumber::SEVERITY_NUMBER_FATAL => 21
    SeverityNumber::SEVERITY_NUMBER_FATAL2 => 22
    SeverityNumber::SEVERITY_NUMBER_FATAL3 => 23
    SeverityNumber::SEVERITY_NUMBER_FATAL4 => 24
  }
}

///|
pub fn SeverityNumber::from_enum(i : @protobuf.Enum) -> SeverityNumber {
  match i.0 {
    0 => SeverityNumber::SEVERITY_NUMBER_UNSPECIFIED
    1 => SeverityNumber::SEVERITY_NUMBER_TRACE
    2 => SeverityNumber::SEVERITY_NUMBER_TRACE2
    3 => SeverityNumber::SEVERITY_NUMBER_TRACE3
    4 => SeverityNumber::SEVERITY_NUMBER_TRACE4
    5 => SeverityNumber::SEVERITY_NUMBER_DEBUG
    6 => SeverityNumber::SEVERITY_NUMBER_DEBUG2
    7 => SeverityNumber::SEVERITY_NUMBER_DEBUG3
    8 => SeverityNumber::SEVERITY_NUMBER_DEBUG4
    9 => SeverityNumber::SEVERITY_NUMBER_INFO
    10 => SeverityNumber::SEVERITY_NUMBER_INFO2
    11 => SeverityNumber::SEVERITY_NUMBER_INFO3
    12 => SeverityNumber::SEVERITY_NUMBER_INFO4
    13 => SeverityNumber::SEVERITY_NUMBER_WARN
    14 => SeverityNumber::SEVERITY_NUMBER_WARN2
    15 => SeverityNumber::SEVERITY_NUMBER_WARN3
    16 => SeverityNumber::SEVERITY_NUMBER_WARN4
    17 => SeverityNumber::SEVERITY_NUMBER_ERROR
    18 => SeverityNumber::SEVERITY_NUMBER_ERROR2
    19 => SeverityNumber::SEVERITY_NUMBER_ERROR3
    20 => SeverityNumber::SEVERITY_NUMBER_ERROR4
    21 => SeverityNumber::SEVERITY_NUMBER_FATAL
    22 => SeverityNumber::SEVERITY_NUMBER_FATAL2
    23 => SeverityNumber::SEVERITY_NUMBER_FATAL3
    24 => SeverityNumber::SEVERITY_NUMBER_FATAL4
    _ => Default::default()
  }
}

///|
pub impl Default for SeverityNumber with default() -> SeverityNumber {
  SeverityNumber::SEVERITY_NUMBER_UNSPECIFIED
}

///|
pub impl @protobuf.Sized for SeverityNumber with size_of(self : SeverityNumber) {
  @protobuf.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for SeverityNumber with from_json(
  json : Json,
  path : @json.JsonPath,
) -> SeverityNumber raise {
  match json {
    String("SEVERITY_NUMBER_UNSPECIFIED") =>
      SeverityNumber::SEVERITY_NUMBER_UNSPECIFIED
    String("SEVERITY_NUMBER_TRACE") => SeverityNumber::SEVERITY_NUMBER_TRACE
    String("SEVERITY_NUMBER_TRACE2") => SeverityNumber::SEVERITY_NUMBER_TRACE2
    String("SEVERITY_NUMBER_TRACE3") => SeverityNumber::SEVERITY_NUMBER_TRACE3
    String("SEVERITY_NUMBER_TRACE4") => SeverityNumber::SEVERITY_NUMBER_TRACE4
    String("SEVERITY_NUMBER_DEBUG") => SeverityNumber::SEVERITY_NUMBER_DEBUG
    String("SEVERITY_NUMBER_DEBUG2") => SeverityNumber::SEVERITY_NUMBER_DEBUG2
    String("SEVERITY_NUMBER_DEBUG3") => SeverityNumber::SEVERITY_NUMBER_DEBUG3
    String("SEVERITY_NUMBER_DEBUG4") => SeverityNumber::SEVERITY_NUMBER_DEBUG4
    String("SEVERITY_NUMBER_INFO") => SeverityNumber::SEVERITY_NUMBER_INFO
    String("SEVERITY_NUMBER_INFO2") => SeverityNumber::SEVERITY_NUMBER_INFO2
    String("SEVERITY_NUMBER_INFO3") => SeverityNumber::SEVERITY_NUMBER_INFO3
    String("SEVERITY_NUMBER_INFO4") => SeverityNumber::SEVERITY_NUMBER_INFO4
    String("SEVERITY_NUMBER_WARN") => SeverityNumber::SEVERITY_NUMBER_WARN
    String("SEVERITY_NUMBER_WARN2") => SeverityNumber::SEVERITY_NUMBER_WARN2
    String("SEVERITY_NUMBER_WARN3") => SeverityNumber::SEVERITY_NUMBER_WARN3
    String("SEVERITY_NUMBER_WARN4") => SeverityNumber::SEVERITY_NUMBER_WARN4
    String("SEVERITY_NUMBER_ERROR") => SeverityNumber::SEVERITY_NUMBER_ERROR
    String("SEVERITY_NUMBER_ERROR2") => SeverityNumber::SEVERITY_NUMBER_ERROR2
    String("SEVERITY_NUMBER_ERROR3") => SeverityNumber::SEVERITY_NUMBER_ERROR3
    String("SEVERITY_NUMBER_ERROR4") => SeverityNumber::SEVERITY_NUMBER_ERROR4
    String("SEVERITY_NUMBER_FATAL") => SeverityNumber::SEVERITY_NUMBER_FATAL
    String("SEVERITY_NUMBER_FATAL2") => SeverityNumber::SEVERITY_NUMBER_FATAL2
    String("SEVERITY_NUMBER_FATAL3") => SeverityNumber::SEVERITY_NUMBER_FATAL3
    String("SEVERITY_NUMBER_FATAL4") => SeverityNumber::SEVERITY_NUMBER_FATAL4
    Number(0, ..) => SeverityNumber::SEVERITY_NUMBER_UNSPECIFIED
    Number(1, ..) => SeverityNumber::SEVERITY_NUMBER_TRACE
    Number(2, ..) => SeverityNumber::SEVERITY_NUMBER_TRACE2
    Number(3, ..) => SeverityNumber::SEVERITY_NUMBER_TRACE3
    Number(4, ..) => SeverityNumber::SEVERITY_NUMBER_TRACE4
    Number(5, ..) => SeverityNumber::SEVERITY_NUMBER_DEBUG
    Number(6, ..) => SeverityNumber::SEVERITY_NUMBER_DEBUG2
    Number(7, ..) => SeverityNumber::SEVERITY_NUMBER_DEBUG3
    Number(8, ..) => SeverityNumber::SEVERITY_NUMBER_DEBUG4
    Number(9, ..) => SeverityNumber::SEVERITY_NUMBER_INFO
    Number(10, ..) => SeverityNumber::SEVERITY_NUMBER_INFO2
    Number(11, ..) => SeverityNumber::SEVERITY_NUMBER_INFO3
    Number(12, ..) => SeverityNumber::SEVERITY_NUMBER_INFO4
    Number(13, ..) => SeverityNumber::SEVERITY_NUMBER_WARN
    Number(14, ..) => SeverityNumber::SEVERITY_NUMBER_WARN2
    Number(15, ..) => SeverityNumber::SEVERITY_NUMBER_WARN3
    Number(16, ..) => SeverityNumber::SEVERITY_NUMBER_WARN4
    Number(17, ..) => SeverityNumber::SEVERITY_NUMBER_ERROR
    Number(18, ..) => SeverityNumber::SEVERITY_NUMBER_ERROR2
    Number(19, ..) => SeverityNumber::SEVERITY_NUMBER_ERROR3
    Number(20, ..) => SeverityNumber::SEVERITY_NUMBER_ERROR4
    Number(21, ..) => SeverityNumber::SEVERITY_NUMBER_FATAL
    Number(22, ..) => SeverityNumber::SEVERITY_NUMBER_FATAL2
    Number(23, ..) => SeverityNumber::SEVERITY_NUMBER_FATAL3
    Number(24, ..) => SeverityNumber::SEVERITY_NUMBER_FATAL4
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for SeverityNumber with to_json(self : SeverityNumber) -> Json {
  match self {
    SeverityNumber::SEVERITY_NUMBER_UNSPECIFIED => "SEVERITY_NUMBER_UNSPECIFIED"
    SeverityNumber::SEVERITY_NUMBER_TRACE => "SEVERITY_NUMBER_TRACE"
    SeverityNumber::SEVERITY_NUMBER_TRACE2 => "SEVERITY_NUMBER_TRACE2"
    SeverityNumber::SEVERITY_NUMBER_TRACE3 => "SEVERITY_NUMBER_TRACE3"
    SeverityNumber::SEVERITY_NUMBER_TRACE4 => "SEVERITY_NUMBER_TRACE4"
    SeverityNumber::SEVERITY_NUMBER_DEBUG => "SEVERITY_NUMBER_DEBUG"
    SeverityNumber::SEVERITY_NUMBER_DEBUG2 => "SEVERITY_NUMBER_DEBUG2"
    SeverityNumber::SEVERITY_NUMBER_DEBUG3 => "SEVERITY_NUMBER_DEBUG3"
    SeverityNumber::SEVERITY_NUMBER_DEBUG4 => "SEVERITY_NUMBER_DEBUG4"
    SeverityNumber::SEVERITY_NUMBER_INFO => "SEVERITY_NUMBER_INFO"
    SeverityNumber::SEVERITY_NUMBER_INFO2 => "SEVERITY_NUMBER_INFO2"
    SeverityNumber::SEVERITY_NUMBER_INFO3 => "SEVERITY_NUMBER_INFO3"
    SeverityNumber::SEVERITY_NUMBER_INFO4 => "SEVERITY_NUMBER_INFO4"
    SeverityNumber::SEVERITY_NUMBER_WARN => "SEVERITY_NUMBER_WARN"
    SeverityNumber::SEVERITY_NUMBER_WARN2 => "SEVERITY_NUMBER_WARN2"
    SeverityNumber::SEVERITY_NUMBER_WARN3 => "SEVERITY_NUMBER_WARN3"
    SeverityNumber::SEVERITY_NUMBER_WARN4 => "SEVERITY_NUMBER_WARN4"
    SeverityNumber::SEVERITY_NUMBER_ERROR => "SEVERITY_NUMBER_ERROR"
    SeverityNumber::SEVERITY_NUMBER_ERROR2 => "SEVERITY_NUMBER_ERROR2"
    SeverityNumber::SEVERITY_NUMBER_ERROR3 => "SEVERITY_NUMBER_ERROR3"
    SeverityNumber::SEVERITY_NUMBER_ERROR4 => "SEVERITY_NUMBER_ERROR4"
    SeverityNumber::SEVERITY_NUMBER_FATAL => "SEVERITY_NUMBER_FATAL"
    SeverityNumber::SEVERITY_NUMBER_FATAL2 => "SEVERITY_NUMBER_FATAL2"
    SeverityNumber::SEVERITY_NUMBER_FATAL3 => "SEVERITY_NUMBER_FATAL3"
    SeverityNumber::SEVERITY_NUMBER_FATAL4 => "SEVERITY_NUMBER_FATAL4"
  }
}

///|
pub(all) enum LogRecordFlags {
  LOG_RECORD_FLAGS_DO_NOT_USE
  LOG_RECORD_FLAGS_TRACE_FLAGS_MASK
} derive(Eq)

///|
pub fn LogRecordFlags::to_enum(self : LogRecordFlags) -> @protobuf.Enum {
  match self {
    LogRecordFlags::LOG_RECORD_FLAGS_DO_NOT_USE => 0
    LogRecordFlags::LOG_RECORD_FLAGS_TRACE_FLAGS_MASK => 255
  }
}

///|
pub fn LogRecordFlags::from_enum(i : @protobuf.Enum) -> LogRecordFlags {
  match i.0 {
    0 => LogRecordFlags::LOG_RECORD_FLAGS_DO_NOT_USE
    255 => LogRecordFlags::LOG_RECORD_FLAGS_TRACE_FLAGS_MASK
    _ => Default::default()
  }
}

///|
pub impl Default for LogRecordFlags with default() -> LogRecordFlags {
  LogRecordFlags::LOG_RECORD_FLAGS_DO_NOT_USE
}

///|
pub impl @protobuf.Sized for LogRecordFlags with size_of(self : LogRecordFlags) {
  @protobuf.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for LogRecordFlags with from_json(
  json : Json,
  path : @json.JsonPath,
) -> LogRecordFlags raise {
  match json {
    String("LOG_RECORD_FLAGS_DO_NOT_USE") =>
      LogRecordFlags::LOG_RECORD_FLAGS_DO_NOT_USE
    String("LOG_RECORD_FLAGS_TRACE_FLAGS_MASK") =>
      LogRecordFlags::LOG_RECORD_FLAGS_TRACE_FLAGS_MASK
    Number(0, ..) => LogRecordFlags::LOG_RECORD_FLAGS_DO_NOT_USE
    Number(255, ..) => LogRecordFlags::LOG_RECORD_FLAGS_TRACE_FLAGS_MASK
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for LogRecordFlags with to_json(self : LogRecordFlags) -> Json {
  match self {
    LogRecordFlags::LOG_RECORD_FLAGS_DO_NOT_USE => "LOG_RECORD_FLAGS_DO_NOT_USE"
    LogRecordFlags::LOG_RECORD_FLAGS_TRACE_FLAGS_MASK =>
      "LOG_RECORD_FLAGS_TRACE_FLAGS_MASK"
  }
}

///|
pub(all) struct LogsData {
  mut resource_logs : Array[ResourceLogs]
} derive(Eq)

///|
pub impl @protobuf.Sized for LogsData with size_of(self) {
  let mut size = 0U
  for s in self.resource_logs {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for LogsData with default() -> LogsData {
  LogsData::{ resource_logs: [] }
}

///|
pub fn LogsData::new(resource_logs : Array[ResourceLogs]) -> LogsData {
  LogsData::{ resource_logs, }
}

///|
pub impl @protobuf.Read for LogsData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> LogsData raise {
  let msg = LogsData::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_logs.push(
            (reader |> @protobuf.read_message() : ResourceLogs),
          )
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for LogsData with write(
  self : LogsData,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.resource_logs {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for LogsData with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource_logs != Default::default() {
    json["resourceLogs"] = self.resource_logs.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LogsData with from_json(
  json : Json,
  path : @json.JsonPath,
) -> LogsData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for LogsData"))
  }
  let message = LogsData::default()
  for key, value in obj {
    match (key, value) {
      ("resourceLogs", Array(value)) =>
        message.resource_logs = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for LogsData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> LogsData raise {
  let msg = LogsData::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_logs.push(
            (reader |> @protobuf.async_read_message() : ResourceLogs),
          )
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for LogsData with write(
  self : LogsData,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.resource_logs {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ResourceLogs {
  mut resource : @v11.Resource
  mut scope_logs : Array[ScopeLogs]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ResourceLogs with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.resource)
      @protobuf.size_of(size) + size
    })
  for s in self.scope_logs {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U +
    ({
      let size = @protobuf.size_of(self.schema_url)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ResourceLogs with default() -> ResourceLogs {
  ResourceLogs::{
    resource: @v11.Resource::default(),
    scope_logs: [],
    schema_url: String::default(),
  }
}

///|
pub fn ResourceLogs::new(
  resource : @v11.Resource,
  scope_logs : Array[ScopeLogs],
  schema_url : String,
) -> ResourceLogs {
  ResourceLogs::{ resource, scope_logs, schema_url }
}

///|
pub impl @protobuf.Read for ResourceLogs with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ResourceLogs raise {
  let msg = ResourceLogs::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource = (reader |> @protobuf.read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_logs.push((reader |> @protobuf.read_message() : ScopeLogs))
        (3, _) => msg.schema_url = reader |> @protobuf.read_string()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for ResourceLogs with write(
  self : ResourceLogs,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.resource))
  @protobuf.Write::write(self.resource, writer)
  for item in self.scope_logs {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ResourceLogs with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource != Default::default() {
    json["resource"] = self.resource.to_json()
  }
  if self.scope_logs != Default::default() {
    json["scopeLogs"] = self.scope_logs.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ResourceLogs with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ResourceLogs raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ResourceLogs"))
  }
  let message = ResourceLogs::default()
  for key, value in obj {
    match (key, value) {
      ("resource", value) => message.resource = @json.from_json(value, path~)
      ("scopeLogs", Array(value)) =>
        message.scope_logs = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ResourceLogs with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ResourceLogs raise {
  let msg = ResourceLogs::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource = (
            reader |> @protobuf.async_read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_logs.push(
            (reader |> @protobuf.async_read_message() : ScopeLogs),
          )
        (3, _) => msg.schema_url = reader |> @protobuf.async_read_string()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for ResourceLogs with write(
  self : ResourceLogs,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.resource))
  @protobuf.AsyncWrite::write(self.resource, writer)
  for item in self.scope_logs {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) struct ScopeLogs {
  mut scope : @v1_dep.InstrumentationScope
  mut log_records : Array[LogRecord]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ScopeLogs with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.scope)
      @protobuf.size_of(size) + size
    })
  for s in self.log_records {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U +
    ({
      let size = @protobuf.size_of(self.schema_url)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ScopeLogs with default() -> ScopeLogs {
  ScopeLogs::{
    scope: @v1_dep.InstrumentationScope::default(),
    log_records: [],
    schema_url: String::default(),
  }
}

///|
pub fn ScopeLogs::new(
  scope : @v1_dep.InstrumentationScope,
  log_records : Array[LogRecord],
  schema_url : String,
) -> ScopeLogs {
  ScopeLogs::{ scope, log_records, schema_url }
}

///|
pub impl @protobuf.Read for ScopeLogs with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ScopeLogs raise {
  let msg = ScopeLogs::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.read_message() : @v1_dep.InstrumentationScope)
        (2, _) =>
          msg.log_records.push((reader |> @protobuf.read_message() : LogRecord))
        (3, _) => msg.schema_url = reader |> @protobuf.read_string()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for ScopeLogs with write(
  self : ScopeLogs,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.scope))
  @protobuf.Write::write(self.scope, writer)
  for item in self.log_records {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ScopeLogs with to_json(self) {
  let json : Map[String, Json] = {}
  if self.scope != Default::default() {
    json["scope"] = self.scope.to_json()
  }
  if self.log_records != Default::default() {
    json["logRecords"] = self.log_records.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ScopeLogs with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ScopeLogs raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ScopeLogs"))
  }
  let message = ScopeLogs::default()
  for key, value in obj {
    match (key, value) {
      ("scope", value) => message.scope = @json.from_json(value, path~)
      ("logRecords", Array(value)) =>
        message.log_records = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ScopeLogs with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ScopeLogs raise {
  let msg = ScopeLogs::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.async_read_message() :
            @v1_dep.InstrumentationScope)
        (2, _) =>
          msg.log_records.push(
            (reader |> @protobuf.async_read_message() : LogRecord),
          )
        (3, _) => msg.schema_url = reader |> @protobuf.async_read_string()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for ScopeLogs with write(
  self : ScopeLogs,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.scope))
  @protobuf.AsyncWrite::write(self.scope, writer)
  for item in self.log_records {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) struct LogRecord {
  mut time_unix_nano : UInt64
  mut observed_time_unix_nano : UInt64
  mut severity_number : SeverityNumber
  mut severity_text : String
  mut body : @v1_dep.AnyValue
  mut attributes : Array[@v1_dep.KeyValue]
  mut dropped_attributes_count : UInt
  mut flags : UInt
  mut trace_id : Bytes
  mut span_id : Bytes
  mut event_name : String
} derive(Eq)

///|
pub impl @protobuf.Sized for LogRecord with size_of(self) {
  let mut size = 0U
  size += 1U + 8U
  size += 1U + 8U
  size += 1U + @protobuf.size_of(self.severity_number)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.severity_text)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.body)
      @protobuf.size_of(size) + size
    })
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.dropped_attributes_count)
  size += 1U + 4U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.trace_id)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.span_id)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.event_name)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for LogRecord with default() -> LogRecord {
  LogRecord::{
    time_unix_nano: UInt64::default(),
    observed_time_unix_nano: UInt64::default(),
    severity_number: SeverityNumber::default(),
    severity_text: String::default(),
    body: @v1_dep.AnyValue::default(),
    attributes: [],
    dropped_attributes_count: UInt::default(),
    flags: UInt::default(),
    trace_id: Bytes::default(),
    span_id: Bytes::default(),
    event_name: String::default(),
  }
}

///|
pub fn LogRecord::new(
  time_unix_nano : UInt64,
  observed_time_unix_nano : UInt64,
  severity_number : SeverityNumber,
  severity_text : String,
  body : @v1_dep.AnyValue,
  attributes : Array[@v1_dep.KeyValue],
  dropped_attributes_count : UInt,
  flags : UInt,
  trace_id : Bytes,
  span_id : Bytes,
  event_name : String,
) -> LogRecord {
  LogRecord::{
    time_unix_nano,
    observed_time_unix_nano,
    severity_number,
    severity_text,
    body,
    attributes,
    dropped_attributes_count,
    flags,
    trace_id,
    span_id,
    event_name,
  }
}

///|
pub impl @protobuf.Read for LogRecord with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> LogRecord raise {
  let msg = LogRecord::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (11, _) =>
          msg.observed_time_unix_nano = reader |> @protobuf.read_fixed64()
        (2, _) =>
          msg.severity_number = reader
            |> @protobuf.read_enum()
            |> SeverityNumber::from_enum
        (3, _) => msg.severity_text = reader |> @protobuf.read_string()
        (5, _) =>
          msg.body = (reader |> @protobuf.read_message() : @v1_dep.AnyValue)
        (6, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (7, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.read_uint32()
        (8, _) => msg.flags = reader |> @protobuf.read_fixed32()
        (9, _) => msg.trace_id = reader |> @protobuf.read_bytes()
        (10, _) => msg.span_id = reader |> @protobuf.read_bytes()
        (12, _) => msg.event_name = reader |> @protobuf.read_string()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for LogRecord with write(
  self : LogRecord,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(9UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  writer |> @protobuf.write_varint(89UL)
  writer |> @protobuf.write_fixed64(self.observed_time_unix_nano)
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_enum(self.severity_number.to_enum())
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.severity_text)
  writer |> @protobuf.write_varint(42UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.body))
  @protobuf.Write::write(self.body, writer)
  for item in self.attributes {
    writer |> @protobuf.write_varint(50UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(56UL)
  writer |> @protobuf.write_uint32(self.dropped_attributes_count)
  writer |> @protobuf.write_varint(69UL)
  writer |> @protobuf.write_fixed32(self.flags)
  writer |> @protobuf.write_varint(74UL)
  writer |> @protobuf.write_bytes(self.trace_id)
  writer |> @protobuf.write_varint(82UL)
  writer |> @protobuf.write_bytes(self.span_id)
  writer |> @protobuf.write_varint(98UL)
  writer |> @protobuf.write_string(self.event_name)
}

///|
pub impl ToJson for LogRecord with to_json(self) {
  let json : Map[String, Json] = {}
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.observed_time_unix_nano != Default::default() {
    json["observedTimeUnixNano"] = self.observed_time_unix_nano.to_json()
  }
  if self.severity_number != Default::default() {
    json["severityNumber"] = self.severity_number.to_json()
  }
  if self.severity_text != Default::default() {
    json["severityText"] = self.severity_text.to_json()
  }
  if self.body != Default::default() {
    json["body"] = self.body.to_json()
  }
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.dropped_attributes_count != Default::default() {
    json["droppedAttributesCount"] = self.dropped_attributes_count.to_json()
  }
  if self.flags != Default::default() {
    json["flags"] = self.flags.to_json()
  }
  if self.trace_id != Default::default() {
    json["traceId"] = @protobuf.base64_encode(self.trace_id).to_json()
  }
  if self.span_id != Default::default() {
    json["spanId"] = @protobuf.base64_encode(self.span_id).to_json()
  }
  if self.event_name != Default::default() {
    json["eventName"] = self.event_name.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LogRecord with from_json(
  json : Json,
  path : @json.JsonPath,
) -> LogRecord raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for LogRecord"))
  }
  let message = LogRecord::default()
  for key, value in obj {
    match (key, value) {
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("observedTimeUnixNano", value) =>
        message.observed_time_unix_nano = @json.from_json(value, path~)
      ("severityNumber", value) =>
        message.severity_number = @json.from_json(value, path~)
      ("severityText", value) =>
        message.severity_text = @json.from_json(value, path~)
      ("body", value) => message.body = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("droppedAttributesCount", value) =>
        message.dropped_attributes_count = @json.from_json(value, path~)
      ("flags", value) => message.flags = @json.from_json(value, path~)
      ("traceId", String(value)) =>
        message.trace_id = @protobuf.base64_decode(value)
      ("spanId", String(value)) =>
        message.span_id = @protobuf.base64_decode(value)
      ("eventName", value) => message.event_name = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for LogRecord with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> LogRecord raise {
  let msg = LogRecord::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (11, _) =>
          msg.observed_time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (2, _) =>
          msg.severity_number = reader
            |> @protobuf.async_read_enum()
            |> SeverityNumber::from_enum
        (3, _) => msg.severity_text = reader |> @protobuf.async_read_string()
        (5, _) =>
          msg.body = (
            reader |> @protobuf.async_read_message() : @v1_dep.AnyValue)
        (6, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (7, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.async_read_uint32()
        (8, _) => msg.flags = reader |> @protobuf.async_read_fixed32()
        (9, _) => msg.trace_id = reader |> @protobuf.async_read_bytes()
        (10, _) => msg.span_id = reader |> @protobuf.async_read_bytes()
        (12, _) => msg.event_name = reader |> @protobuf.async_read_string()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for LogRecord with write(
  self : LogRecord,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(9UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  writer |> @protobuf.async_write_varint(89UL)
  writer |> @protobuf.async_write_fixed64(self.observed_time_unix_nano)
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_enum(self.severity_number.to_enum())
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.severity_text)
  writer |> @protobuf.async_write_varint(42UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.body))
  @protobuf.AsyncWrite::write(self.body, writer)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(50UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(56UL)
  writer |> @protobuf.async_write_uint32(self.dropped_attributes_count)
  writer |> @protobuf.async_write_varint(69UL)
  writer |> @protobuf.async_write_fixed32(self.flags)
  writer |> @protobuf.async_write_varint(74UL)
  writer |> @protobuf.async_write_bytes(self.trace_id)
  writer |> @protobuf.async_write_varint(82UL)
  writer |> @protobuf.async_write_bytes(self.span_id)
  writer |> @protobuf.async_write_varint(98UL)
  writer |> @protobuf.async_write_string(self.event_name)
}
