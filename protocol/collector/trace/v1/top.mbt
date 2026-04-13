///|
pub(all) struct ExportTraceServiceRequest {
  mut resource_spans : Array[@v12.ResourceSpans]
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportTraceServiceRequest with size_of(self) {
  let mut size = 0U
  for s in self.resource_spans {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for ExportTraceServiceRequest with default() -> ExportTraceServiceRequest {
  ExportTraceServiceRequest::{ resource_spans: [] }
}

///|
pub fn ExportTraceServiceRequest::new(
  resource_spans : Array[@v12.ResourceSpans],
) -> ExportTraceServiceRequest {
  ExportTraceServiceRequest::{ resource_spans, }
}

///|
pub impl @protobuf.Read for ExportTraceServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportTraceServiceRequest raise {
  let msg = ExportTraceServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_spans.push(
            (reader |> @protobuf.read_message() : @v12.ResourceSpans),
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
pub impl @protobuf.Write for ExportTraceServiceRequest with write(
  self : ExportTraceServiceRequest,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.resource_spans {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for ExportTraceServiceRequest with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource_spans != Default::default() {
    json["resourceSpans"] = self.resource_spans.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportTraceServiceRequest with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportTraceServiceRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportTraceServiceRequest"),
    )
  }
  let message = ExportTraceServiceRequest::default()
  for key, value in obj {
    match (key, value) {
      ("resourceSpans", Array(value)) =>
        message.resource_spans = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportTraceServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportTraceServiceRequest raise {
  let msg = ExportTraceServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_spans.push(
            (reader |> @protobuf.async_read_message() : @v12.ResourceSpans),
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
pub impl @protobuf.AsyncWrite for ExportTraceServiceRequest with write(
  self : ExportTraceServiceRequest,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.resource_spans {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ExportTraceServiceResponse {
  mut partial_success : ExportTracePartialSuccess
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportTraceServiceResponse with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.partial_success)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportTraceServiceResponse with default() -> ExportTraceServiceResponse {
  ExportTraceServiceResponse::{
    partial_success: ExportTracePartialSuccess::default(),
  }
}

///|
pub fn ExportTraceServiceResponse::new(
  partial_success : ExportTracePartialSuccess,
) -> ExportTraceServiceResponse {
  ExportTraceServiceResponse::{ partial_success, }
}

///|
pub impl @protobuf.Read for ExportTraceServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportTraceServiceResponse raise {
  let msg = ExportTraceServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.read_message() : ExportTracePartialSuccess)
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
pub impl @protobuf.Write for ExportTraceServiceResponse with write(
  self : ExportTraceServiceResponse,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.Write::write(self.partial_success, writer)
}

///|
pub impl ToJson for ExportTraceServiceResponse with to_json(self) {
  let json : Map[String, Json] = {}
  if self.partial_success != Default::default() {
    json["partialSuccess"] = self.partial_success.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportTraceServiceResponse with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportTraceServiceResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportTraceServiceResponse"),
    )
  }
  let message = ExportTraceServiceResponse::default()
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
pub impl @protobuf.AsyncRead for ExportTraceServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportTraceServiceResponse raise {
  let msg = ExportTraceServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.async_read_message() : ExportTracePartialSuccess)
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
pub impl @protobuf.AsyncWrite for ExportTraceServiceResponse with write(
  self : ExportTraceServiceResponse,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer
  |> @protobuf.async_write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.AsyncWrite::write(self.partial_success, writer)
}

///|
pub(all) struct ExportTracePartialSuccess {
  mut rejected_spans : Int64
  mut error_message : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportTracePartialSuccess with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.rejected_spans)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.error_message)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportTracePartialSuccess with default() -> ExportTracePartialSuccess {
  ExportTracePartialSuccess::{
    rejected_spans: Int64::default(),
    error_message: String::default(),
  }
}

///|
pub fn ExportTracePartialSuccess::new(
  rejected_spans : Int64,
  error_message : String,
) -> ExportTracePartialSuccess {
  ExportTracePartialSuccess::{ rejected_spans, error_message }
}

///|
pub impl @protobuf.Read for ExportTracePartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportTracePartialSuccess raise {
  let msg = ExportTracePartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.rejected_spans = reader |> @protobuf.read_int64()
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
pub impl @protobuf.Write for ExportTracePartialSuccess with write(
  self : ExportTracePartialSuccess,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int64(self.rejected_spans)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.error_message)
}

///|
pub impl ToJson for ExportTracePartialSuccess with to_json(self) {
  let json : Map[String, Json] = {}
  if self.rejected_spans != Default::default() {
    json["rejectedSpans"] = self.rejected_spans.to_json()
  }
  if self.error_message != Default::default() {
    json["errorMessage"] = self.error_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportTracePartialSuccess with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportTracePartialSuccess raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportTracePartialSuccess"),
    )
  }
  let message = ExportTracePartialSuccess::default()
  for key, value in obj {
    match (key, value) {
      ("rejectedSpans", value) =>
        message.rejected_spans = @json.from_json(value, path~)
      ("errorMessage", value) =>
        message.error_message = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportTracePartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportTracePartialSuccess raise {
  let msg = ExportTracePartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.rejected_spans = reader |> @protobuf.async_read_int64()
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
pub impl @protobuf.AsyncWrite for ExportTracePartialSuccess with write(
  self : ExportTracePartialSuccess,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int64(self.rejected_spans)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.error_message)
}
