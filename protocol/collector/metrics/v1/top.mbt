///|
pub(all) struct ExportMetricsServiceRequest {
  mut resource_metrics : Array[@v13.ResourceMetrics]
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportMetricsServiceRequest with size_of(self) {
  let mut size = 0U
  for s in self.resource_metrics {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for ExportMetricsServiceRequest with default() -> ExportMetricsServiceRequest {
  ExportMetricsServiceRequest::{ resource_metrics: [] }
}

///|
pub fn ExportMetricsServiceRequest::new(
  resource_metrics : Array[@v13.ResourceMetrics],
) -> ExportMetricsServiceRequest {
  ExportMetricsServiceRequest::{ resource_metrics, }
}

///|
pub impl @protobuf.Read for ExportMetricsServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportMetricsServiceRequest raise {
  let msg = ExportMetricsServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_metrics.push(
            (reader |> @protobuf.read_message() : @v13.ResourceMetrics),
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
pub impl @protobuf.Write for ExportMetricsServiceRequest with write(
  self : ExportMetricsServiceRequest,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.resource_metrics {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for ExportMetricsServiceRequest with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource_metrics != Default::default() {
    json["resourceMetrics"] = self.resource_metrics.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportMetricsServiceRequest with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportMetricsServiceRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportMetricsServiceRequest"),
    )
  }
  let message = ExportMetricsServiceRequest::default()
  for key, value in obj {
    match (key, value) {
      ("resourceMetrics", Array(value)) =>
        message.resource_metrics = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportMetricsServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportMetricsServiceRequest raise {
  let msg = ExportMetricsServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_metrics.push(
            (reader |> @protobuf.async_read_message() : @v13.ResourceMetrics),
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
pub impl @protobuf.AsyncWrite for ExportMetricsServiceRequest with write(
  self : ExportMetricsServiceRequest,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.resource_metrics {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ExportMetricsServiceResponse {
  mut partial_success : ExportMetricsPartialSuccess
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportMetricsServiceResponse with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.partial_success)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportMetricsServiceResponse with default() -> ExportMetricsServiceResponse {
  ExportMetricsServiceResponse::{
    partial_success: ExportMetricsPartialSuccess::default(),
  }
}

///|
pub fn ExportMetricsServiceResponse::new(
  partial_success : ExportMetricsPartialSuccess,
) -> ExportMetricsServiceResponse {
  ExportMetricsServiceResponse::{ partial_success, }
}

///|
pub impl @protobuf.Read for ExportMetricsServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportMetricsServiceResponse raise {
  let msg = ExportMetricsServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.read_message() : ExportMetricsPartialSuccess)
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
pub impl @protobuf.Write for ExportMetricsServiceResponse with write(
  self : ExportMetricsServiceResponse,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.Write::write(self.partial_success, writer)
}

///|
pub impl ToJson for ExportMetricsServiceResponse with to_json(self) {
  let json : Map[String, Json] = {}
  if self.partial_success != Default::default() {
    json["partialSuccess"] = self.partial_success.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportMetricsServiceResponse with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportMetricsServiceResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportMetricsServiceResponse"),
    )
  }
  let message = ExportMetricsServiceResponse::default()
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
pub impl @protobuf.AsyncRead for ExportMetricsServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportMetricsServiceResponse raise {
  let msg = ExportMetricsServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.async_read_message() :
            ExportMetricsPartialSuccess)
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
pub impl @protobuf.AsyncWrite for ExportMetricsServiceResponse with write(
  self : ExportMetricsServiceResponse,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer
  |> @protobuf.async_write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.AsyncWrite::write(self.partial_success, writer)
}

///|
pub(all) struct ExportMetricsPartialSuccess {
  mut rejected_data_points : Int64
  mut error_message : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportMetricsPartialSuccess with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.rejected_data_points)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.error_message)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportMetricsPartialSuccess with default() -> ExportMetricsPartialSuccess {
  ExportMetricsPartialSuccess::{
    rejected_data_points: Int64::default(),
    error_message: String::default(),
  }
}

///|
pub fn ExportMetricsPartialSuccess::new(
  rejected_data_points : Int64,
  error_message : String,
) -> ExportMetricsPartialSuccess {
  ExportMetricsPartialSuccess::{ rejected_data_points, error_message }
}

///|
pub impl @protobuf.Read for ExportMetricsPartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportMetricsPartialSuccess raise {
  let msg = ExportMetricsPartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.rejected_data_points = reader |> @protobuf.read_int64()
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
pub impl @protobuf.Write for ExportMetricsPartialSuccess with write(
  self : ExportMetricsPartialSuccess,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int64(self.rejected_data_points)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.error_message)
}

///|
pub impl ToJson for ExportMetricsPartialSuccess with to_json(self) {
  let json : Map[String, Json] = {}
  if self.rejected_data_points != Default::default() {
    json["rejectedDataPoints"] = self.rejected_data_points.to_json()
  }
  if self.error_message != Default::default() {
    json["errorMessage"] = self.error_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportMetricsPartialSuccess with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportMetricsPartialSuccess raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportMetricsPartialSuccess"),
    )
  }
  let message = ExportMetricsPartialSuccess::default()
  for key, value in obj {
    match (key, value) {
      ("rejectedDataPoints", value) =>
        message.rejected_data_points = @json.from_json(value, path~)
      ("errorMessage", value) =>
        message.error_message = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportMetricsPartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportMetricsPartialSuccess raise {
  let msg = ExportMetricsPartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.rejected_data_points = reader |> @protobuf.async_read_int64()
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
pub impl @protobuf.AsyncWrite for ExportMetricsPartialSuccess with write(
  self : ExportMetricsPartialSuccess,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int64(self.rejected_data_points)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.error_message)
}
