///|
pub(all) struct ExportProfilesServiceRequest {
  mut resource_profiles : Array[@v1development_dep.ResourceProfiles]
  mut dictionary : @v1development_dep.ProfilesDictionary
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportProfilesServiceRequest with size_of(self) {
  let mut size = 0U
  for s in self.resource_profiles {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U +
    ({
      let size = @protobuf.size_of(self.dictionary)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportProfilesServiceRequest with default() -> ExportProfilesServiceRequest {
  ExportProfilesServiceRequest::{
    resource_profiles: [],
    dictionary: @v1development_dep.ProfilesDictionary::default(),
  }
}

///|
pub fn ExportProfilesServiceRequest::new(
  resource_profiles : Array[@v1development_dep.ResourceProfiles],
  dictionary : @v1development_dep.ProfilesDictionary,
) -> ExportProfilesServiceRequest {
  ExportProfilesServiceRequest::{ resource_profiles, dictionary }
}

///|
pub impl @protobuf.Read for ExportProfilesServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportProfilesServiceRequest raise {
  let msg = ExportProfilesServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_profiles.push(
            (
              reader |> @protobuf.read_message() :
              @v1development_dep.ResourceProfiles),
          )
        (2, _) =>
          msg.dictionary = (
            reader |> @protobuf.read_message() :
            @v1development_dep.ProfilesDictionary)
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
pub impl @protobuf.Write for ExportProfilesServiceRequest with write(
  self : ExportProfilesServiceRequest,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.resource_profiles {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.dictionary))
  @protobuf.Write::write(self.dictionary, writer)
}

///|
pub impl ToJson for ExportProfilesServiceRequest with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource_profiles != Default::default() {
    json["resourceProfiles"] = self.resource_profiles.to_json()
  }
  if self.dictionary != Default::default() {
    json["dictionary"] = self.dictionary.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportProfilesServiceRequest with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportProfilesServiceRequest raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportProfilesServiceRequest"),
    )
  }
  let message = ExportProfilesServiceRequest::default()
  for key, value in obj {
    match (key, value) {
      ("resourceProfiles", Array(value)) =>
        message.resource_profiles = value.map(v => @json.from_json(v, path~))
      ("dictionary", value) =>
        message.dictionary = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportProfilesServiceRequest with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportProfilesServiceRequest raise {
  let msg = ExportProfilesServiceRequest::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_profiles.push(
            (
              reader |> @protobuf.async_read_message() :
              @v1development_dep.ResourceProfiles),
          )
        (2, _) =>
          msg.dictionary = (
            reader |> @protobuf.async_read_message() :
            @v1development_dep.ProfilesDictionary)
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
pub impl @protobuf.AsyncWrite for ExportProfilesServiceRequest with write(
  self : ExportProfilesServiceRequest,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.resource_profiles {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.dictionary))
  @protobuf.AsyncWrite::write(self.dictionary, writer)
}

///|
pub(all) struct ExportProfilesServiceResponse {
  mut partial_success : ExportProfilesPartialSuccess
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportProfilesServiceResponse with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.partial_success)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportProfilesServiceResponse with default() -> ExportProfilesServiceResponse {
  ExportProfilesServiceResponse::{
    partial_success: ExportProfilesPartialSuccess::default(),
  }
}

///|
pub fn ExportProfilesServiceResponse::new(
  partial_success : ExportProfilesPartialSuccess,
) -> ExportProfilesServiceResponse {
  ExportProfilesServiceResponse::{ partial_success, }
}

///|
pub impl @protobuf.Read for ExportProfilesServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportProfilesServiceResponse raise {
  let msg = ExportProfilesServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.read_message() : ExportProfilesPartialSuccess)
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
pub impl @protobuf.Write for ExportProfilesServiceResponse with write(
  self : ExportProfilesServiceResponse,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.Write::write(self.partial_success, writer)
}

///|
pub impl ToJson for ExportProfilesServiceResponse with to_json(self) {
  let json : Map[String, Json] = {}
  if self.partial_success != Default::default() {
    json["partialSuccess"] = self.partial_success.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportProfilesServiceResponse with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportProfilesServiceResponse raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportProfilesServiceResponse"),
    )
  }
  let message = ExportProfilesServiceResponse::default()
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
pub impl @protobuf.AsyncRead for ExportProfilesServiceResponse with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportProfilesServiceResponse raise {
  let msg = ExportProfilesServiceResponse::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.partial_success = (
            reader |> @protobuf.async_read_message() :
            ExportProfilesPartialSuccess)
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
pub impl @protobuf.AsyncWrite for ExportProfilesServiceResponse with write(
  self : ExportProfilesServiceResponse,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer
  |> @protobuf.async_write_uint32(@protobuf.size_of(self.partial_success))
  @protobuf.AsyncWrite::write(self.partial_success, writer)
}

///|
pub(all) struct ExportProfilesPartialSuccess {
  mut rejected_profiles : Int64
  mut error_message : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ExportProfilesPartialSuccess with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.rejected_profiles)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.error_message)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExportProfilesPartialSuccess with default() -> ExportProfilesPartialSuccess {
  ExportProfilesPartialSuccess::{
    rejected_profiles: Int64::default(),
    error_message: String::default(),
  }
}

///|
pub fn ExportProfilesPartialSuccess::new(
  rejected_profiles : Int64,
  error_message : String,
) -> ExportProfilesPartialSuccess {
  ExportProfilesPartialSuccess::{ rejected_profiles, error_message }
}

///|
pub impl @protobuf.Read for ExportProfilesPartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExportProfilesPartialSuccess raise {
  let msg = ExportProfilesPartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.rejected_profiles = reader |> @protobuf.read_int64()
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
pub impl @protobuf.Write for ExportProfilesPartialSuccess with write(
  self : ExportProfilesPartialSuccess,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int64(self.rejected_profiles)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.error_message)
}

///|
pub impl ToJson for ExportProfilesPartialSuccess with to_json(self) {
  let json : Map[String, Json] = {}
  if self.rejected_profiles != Default::default() {
    json["rejectedProfiles"] = self.rejected_profiles.to_json()
  }
  if self.error_message != Default::default() {
    json["errorMessage"] = self.error_message.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExportProfilesPartialSuccess with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExportProfilesPartialSuccess raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExportProfilesPartialSuccess"),
    )
  }
  let message = ExportProfilesPartialSuccess::default()
  for key, value in obj {
    match (key, value) {
      ("rejectedProfiles", value) =>
        message.rejected_profiles = @json.from_json(value, path~)
      ("errorMessage", value) =>
        message.error_message = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExportProfilesPartialSuccess with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExportProfilesPartialSuccess raise {
  let msg = ExportProfilesPartialSuccess::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.rejected_profiles = reader |> @protobuf.async_read_int64()
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
pub impl @protobuf.AsyncWrite for ExportProfilesPartialSuccess with write(
  self : ExportProfilesPartialSuccess,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int64(self.rejected_profiles)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.error_message)
}
