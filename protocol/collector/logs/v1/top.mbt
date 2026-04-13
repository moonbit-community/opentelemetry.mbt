///|
pub(all) struct ExportLogsServiceRequest {
  mut resource_logs : Array[@v14.ResourceLogs]
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportLogsServiceRequest with size_of(self) {
  let mut size = 0U
  for s in self.resource_logs {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for ExportLogsServiceRequest with default() -> ExportLogsServiceRequest {
  ExportLogsServiceRequest::{ resource_logs: [] }
}

///|
pub fn ExportLogsServiceRequest::new(
  resource_logs : Array[@v14.ResourceLogs],
) -> ExportLogsServiceRequest {
  ExportLogsServiceRequest::{ resource_logs, }
}

///|
pub impl @protobuf.Read for ExportLogsServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportLogsServiceRequest raise {
  let msg = ExportLogsServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_logs.push(
            (reader |> @protobuf.read_message() : @v14.ResourceLogs),
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
pub impl @protobuf.Write for ExportLogsServiceRequest with write(
  self : ExportLogsServiceRequest,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.resource_logs {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for ExportLogsServiceRequest with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource_logs != Default::default() {
    json["resourceLogs"] = self.resource_logs.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportLogsServiceRequest with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportLogsServiceRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportLogsServiceRequest"),
    )
  }
  let message = ExportLogsServiceRequest::default()
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
pub impl @protobuf.AsyncRead for ExportLogsServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportLogsServiceRequest raise {
  let msg = ExportLogsServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_logs.push(
            (reader |> @protobuf.async_read_message() : @v14.ResourceLogs),
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
pub impl @protobuf.AsyncWrite for ExportLogsServiceRequest with write(
  self : ExportLogsServiceRequest,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.resource_logs {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ExportLogsServiceResponse {
  mut partial_success : ExportLogsPartialSuccess
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportLogsServiceResponse with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.partial_success)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportLogsServiceResponse with default() -> ExportLogsServiceResponse {
  ExportLogsServiceResponse::{
    partial_success: ExportLogsPartialSuccess::default(),
  }
}

///|
pub fn ExportLogsServiceResponse::new(
  partial_success : ExportLogsPartialSuccess,
) -> ExportLogsServiceResponse {
  ExportLogsServiceResponse::{ partial_success, }
}

///|
pub impl @protobuf.Read for ExportLogsServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportLogsServiceResponse raise {
  let msg = ExportLogsServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.read_message() : ExportLogsPartialSuccess)
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
pub impl @protobuf.Write for ExportLogsServiceResponse with write(
  self : ExportLogsServiceResponse,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.Write::write(self.partial_success, writer)
}

///|
pub impl ToJson for ExportLogsServiceResponse with to_json(self) {
  let json : Map[String, Json] = {}
  if self.partial_success != Default::default() {
    json["partialSuccess"] = self.partial_success.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportLogsServiceResponse with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportLogsServiceResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportLogsServiceResponse"),
    )
  }
  let message = ExportLogsServiceResponse::default()
  for key, value in obj {
    match (key, value) {
      ("partialSuccess", value) =>
        message.partial_success = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportLogsServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportLogsServiceResponse raise {
  let msg = ExportLogsServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.async_read_message() : ExportLogsPartialSuccess)
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
pub impl @protobuf.AsyncWrite for ExportLogsServiceResponse with write(
  self : ExportLogsServiceResponse,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer
  |> @protobuf.async_write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.AsyncWrite::write(self.partial_success, writer)
}

///|
pub(all) struct ExportLogsPartialSuccess {
  mut rejected_log_records : Int64
  mut error_message : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportLogsPartialSuccess with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.rejected_log_records)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.error_message)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportLogsPartialSuccess with default() -> ExportLogsPartialSuccess {
  ExportLogsPartialSuccess::{
    rejected_log_records: Int64::default(),
    error_message: String::default(),
  }
}

///|
pub fn ExportLogsPartialSuccess::new(
  rejected_log_records : Int64,
  error_message : String,
) -> ExportLogsPartialSuccess {
  ExportLogsPartialSuccess::{ rejected_log_records, error_message }
}

///|
pub impl @protobuf.Read for ExportLogsPartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportLogsPartialSuccess raise {
  let msg = ExportLogsPartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.rejected_log_records = reader |> @protobuf.read_int64()
        (2, _) => msg.error_message = reader |> @protobuf.read_string()
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
pub impl @protobuf.Write for ExportLogsPartialSuccess with write(
  self : ExportLogsPartialSuccess,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int64(self.rejected_log_records)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.error_message)
}

///|
pub impl ToJson for ExportLogsPartialSuccess with to_json(self) {
  let json : Map[String, Json] = {}
  if self.rejected_log_records != Default::default() {
    json["rejectedLogRecords"] = self.rejected_log_records.to_json()
  }
  if self.error_message != Default::default() {
    json["errorMessage"] = self.error_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportLogsPartialSuccess with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportLogsPartialSuccess raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportLogsPartialSuccess"),
    )
  }
  let message = ExportLogsPartialSuccess::default()
  for key, value in obj {
    match (key, value) {
      ("rejectedLogRecords", value) =>
        message.rejected_log_records = @json.from_json(value, path~)
      ("errorMessage", value) =>
        message.error_message = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportLogsPartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportLogsPartialSuccess raise {
  let msg = ExportLogsPartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.rejected_log_records = reader |> @protobuf.async_read_int64()
        (2, _) => msg.error_message = reader |> @protobuf.async_read_string()
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
pub impl @protobuf.AsyncWrite for ExportLogsPartialSuccess with write(
  self : ExportLogsPartialSuccess,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int64(self.rejected_log_records)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.error_message)
}
