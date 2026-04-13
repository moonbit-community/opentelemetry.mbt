///|
pub(all) struct ProfilesDictionary {
  mut mapping_table : Array[Mapping]
  mut location_table : Array[Location]
  mut function_table : Array[Function]
  mut link_table : Array[Link]
  mut string_table : Array[String]
  mut attribute_table : Array[KeyValueAndUnit]
  mut stack_table : Array[Stack]
} derive(Eq)

///|
pub impl @protobuf.Sized for ProfilesDictionary with size_of(self) {
  let mut size = 0U
  for s in self.mapping_table {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.location_table {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.function_table {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.link_table {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.string_table {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.attribute_table {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.stack_table {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for ProfilesDictionary with default() -> ProfilesDictionary {
  ProfilesDictionary::{
    mapping_table: [],
    location_table: [],
    function_table: [],
    link_table: [],
    string_table: [],
    attribute_table: [],
    stack_table: [],
  }
}

///|
pub fn ProfilesDictionary::new(
  mapping_table : Array[Mapping],
  location_table : Array[Location],
  function_table : Array[Function],
  link_table : Array[Link],
  string_table : Array[String],
  attribute_table : Array[KeyValueAndUnit],
  stack_table : Array[Stack],
) -> ProfilesDictionary {
  ProfilesDictionary::{
    mapping_table,
    location_table,
    function_table,
    link_table,
    string_table,
    attribute_table,
    stack_table,
  }
}

///|
pub impl @protobuf.Read for ProfilesDictionary with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ProfilesDictionary raise {
  let msg = ProfilesDictionary::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.mapping_table.push((reader |> @protobuf.read_message() : Mapping))
        (2, _) =>
          msg.location_table.push(
            (reader |> @protobuf.read_message() : Location),
          )
        (3, _) =>
          msg.function_table.push(
            (reader |> @protobuf.read_message() : Function),
          )
        (4, _) =>
          msg.link_table.push((reader |> @protobuf.read_message() : Link))
        (5, _) => msg.string_table.push(reader |> @protobuf.read_string())
        (6, _) =>
          msg.attribute_table.push(
            (reader |> @protobuf.read_message() : KeyValueAndUnit),
          )
        (7, _) =>
          msg.stack_table.push((reader |> @protobuf.read_message() : Stack))
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
pub impl @protobuf.Write for ProfilesDictionary with write(
  self : ProfilesDictionary,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.mapping_table {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.location_table {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.function_table {
    writer |> @protobuf.write_varint(26UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.link_table {
    writer |> @protobuf.write_varint(34UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.string_table {
    writer |> @protobuf.write_varint(42UL)
    writer |> @protobuf.write_string(item)
  }
  for item in self.attribute_table {
    writer |> @protobuf.write_varint(50UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.stack_table {
    writer |> @protobuf.write_varint(58UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for ProfilesDictionary with to_json(self) {
  let json : Map[String, Json] = {}
  if self.mapping_table != Default::default() {
    json["mappingTable"] = self.mapping_table.to_json()
  }
  if self.location_table != Default::default() {
    json["locationTable"] = self.location_table.to_json()
  }
  if self.function_table != Default::default() {
    json["functionTable"] = self.function_table.to_json()
  }
  if self.link_table != Default::default() {
    json["linkTable"] = self.link_table.to_json()
  }
  if self.string_table != Default::default() {
    json["stringTable"] = self.string_table.to_json()
  }
  if self.attribute_table != Default::default() {
    json["attributeTable"] = self.attribute_table.to_json()
  }
  if self.stack_table != Default::default() {
    json["stackTable"] = self.stack_table.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ProfilesDictionary with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ProfilesDictionary raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ProfilesDictionary"),
    )
  }
  let message = ProfilesDictionary::default()
  for key, value in obj {
    match (key, value) {
      ("mappingTable", Array(value)) =>
        message.mapping_table = value.map(v => @json.from_json(v, path~))
      ("locationTable", Array(value)) =>
        message.location_table = value.map(v => @json.from_json(v, path~))
      ("functionTable", Array(value)) =>
        message.function_table = value.map(v => @json.from_json(v, path~))
      ("linkTable", Array(value)) =>
        message.link_table = value.map(v => @json.from_json(v, path~))
      ("stringTable", Array(value)) =>
        message.string_table = value.map(v => @json.from_json(v, path~))
      ("attributeTable", Array(value)) =>
        message.attribute_table = value.map(v => @json.from_json(v, path~))
      ("stackTable", Array(value)) =>
        message.stack_table = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ProfilesDictionary with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ProfilesDictionary raise {
  let msg = ProfilesDictionary::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.mapping_table.push(
            (reader |> @protobuf.async_read_message() : Mapping),
          )
        (2, _) =>
          msg.location_table.push(
            (reader |> @protobuf.async_read_message() : Location),
          )
        (3, _) =>
          msg.function_table.push(
            (reader |> @protobuf.async_read_message() : Function),
          )
        (4, _) =>
          msg.link_table.push((reader |> @protobuf.async_read_message() : Link))
        (5, _) => msg.string_table.push(reader |> @protobuf.async_read_string())
        (6, _) =>
          msg.attribute_table.push(
            (reader |> @protobuf.async_read_message() : KeyValueAndUnit),
          )
        (7, _) =>
          msg.stack_table.push(
            (reader |> @protobuf.async_read_message() : Stack),
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
pub impl @protobuf.AsyncWrite for ProfilesDictionary with write(
  self : ProfilesDictionary,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.mapping_table {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.location_table {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.function_table {
    writer |> @protobuf.async_write_varint(26UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.link_table {
    writer |> @protobuf.async_write_varint(34UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.string_table {
    writer |> @protobuf.async_write_varint(42UL)
    writer |> @protobuf.async_write_string(item)
  }
  for item in self.attribute_table {
    writer |> @protobuf.async_write_varint(50UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.stack_table {
    writer |> @protobuf.async_write_varint(58UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ProfilesData {
  mut resource_profiles : Array[ResourceProfiles]
  mut dictionary : ProfilesDictionary
} derive(Eq)

///|
pub impl @protobuf.Sized for ProfilesData with size_of(self) {
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
pub impl Default for ProfilesData with default() -> ProfilesData {
  ProfilesData::{
    resource_profiles: [],
    dictionary: ProfilesDictionary::default(),
  }
}

///|
pub fn ProfilesData::new(
  resource_profiles : Array[ResourceProfiles],
  dictionary : ProfilesDictionary,
) -> ProfilesData {
  ProfilesData::{ resource_profiles, dictionary }
}

///|
pub impl @protobuf.Read for ProfilesData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ProfilesData raise {
  let msg = ProfilesData::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_profiles.push(
            (reader |> @protobuf.read_message() : ResourceProfiles),
          )
        (2, _) =>
          msg.dictionary = (
            reader |> @protobuf.read_message() : ProfilesDictionary)
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
pub impl @protobuf.Write for ProfilesData with write(
  self : ProfilesData,
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
pub impl ToJson for ProfilesData with to_json(self) {
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
pub impl @json.FromJson for ProfilesData with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ProfilesData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ProfilesData"))
  }
  let message = ProfilesData::default()
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
pub impl @protobuf.AsyncRead for ProfilesData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ProfilesData raise {
  let msg = ProfilesData::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_profiles.push(
            (reader |> @protobuf.async_read_message() : ResourceProfiles),
          )
        (2, _) =>
          msg.dictionary = (
            reader |> @protobuf.async_read_message() : ProfilesDictionary)
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
pub impl @protobuf.AsyncWrite for ProfilesData with write(
  self : ProfilesData,
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
pub(all) struct ResourceProfiles {
  mut resource : @v11.Resource
  mut scope_profiles : Array[ScopeProfiles]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ResourceProfiles with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.resource)
      @protobuf.size_of(size) + size
    })
  for s in self.scope_profiles {
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
pub impl Default for ResourceProfiles with default() -> ResourceProfiles {
  ResourceProfiles::{
    resource: @v11.Resource::default(),
    scope_profiles: [],
    schema_url: String::default(),
  }
}

///|
pub fn ResourceProfiles::new(
  resource : @v11.Resource,
  scope_profiles : Array[ScopeProfiles],
  schema_url : String,
) -> ResourceProfiles {
  ResourceProfiles::{ resource, scope_profiles, schema_url }
}

///|
pub impl @protobuf.Read for ResourceProfiles with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ResourceProfiles raise {
  let msg = ResourceProfiles::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource = (reader |> @protobuf.read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_profiles.push(
            (reader |> @protobuf.read_message() : ScopeProfiles),
          )
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
pub impl @protobuf.Write for ResourceProfiles with write(
  self : ResourceProfiles,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.resource))
  @protobuf.Write::write(self.resource, writer)
  for item in self.scope_profiles {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ResourceProfiles with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource != Default::default() {
    json["resource"] = self.resource.to_json()
  }
  if self.scope_profiles != Default::default() {
    json["scopeProfiles"] = self.scope_profiles.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ResourceProfiles with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ResourceProfiles raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ResourceProfiles"),
    )
  }
  let message = ResourceProfiles::default()
  for key, value in obj {
    match (key, value) {
      ("resource", value) => message.resource = @json.from_json(value, path~)
      ("scopeProfiles", Array(value)) =>
        message.scope_profiles = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ResourceProfiles with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ResourceProfiles raise {
  let msg = ResourceProfiles::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource = (
            reader |> @protobuf.async_read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_profiles.push(
            (reader |> @protobuf.async_read_message() : ScopeProfiles),
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
pub impl @protobuf.AsyncWrite for ResourceProfiles with write(
  self : ResourceProfiles,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.resource))
  @protobuf.AsyncWrite::write(self.resource, writer)
  for item in self.scope_profiles {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) struct ScopeProfiles {
  mut scope : @v1.InstrumentationScope
  mut profiles : Array[Profile]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ScopeProfiles with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.scope)
      @protobuf.size_of(size) + size
    })
  for s in self.profiles {
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
pub impl Default for ScopeProfiles with default() -> ScopeProfiles {
  ScopeProfiles::{
    scope: @v1.InstrumentationScope::default(),
    profiles: [],
    schema_url: String::default(),
  }
}

///|
pub fn ScopeProfiles::new(
  scope : @v1.InstrumentationScope,
  profiles : Array[Profile],
  schema_url : String,
) -> ScopeProfiles {
  ScopeProfiles::{ scope, profiles, schema_url }
}

///|
pub impl @protobuf.Read for ScopeProfiles with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ScopeProfiles raise {
  let msg = ScopeProfiles::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.read_message() : @v1.InstrumentationScope)
        (2, _) =>
          msg.profiles.push((reader |> @protobuf.read_message() : Profile))
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
pub impl @protobuf.Write for ScopeProfiles with write(
  self : ScopeProfiles,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.scope))
  @protobuf.Write::write(self.scope, writer)
  for item in self.profiles {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ScopeProfiles with to_json(self) {
  let json : Map[String, Json] = {}
  if self.scope != Default::default() {
    json["scope"] = self.scope.to_json()
  }
  if self.profiles != Default::default() {
    json["profiles"] = self.profiles.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ScopeProfiles with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ScopeProfiles raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ScopeProfiles"))
  }
  let message = ScopeProfiles::default()
  for key, value in obj {
    match (key, value) {
      ("scope", value) => message.scope = @json.from_json(value, path~)
      ("profiles", Array(value)) =>
        message.profiles = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ScopeProfiles with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ScopeProfiles raise {
  let msg = ScopeProfiles::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.async_read_message() : @v1.InstrumentationScope)
        (2, _) =>
          msg.profiles.push(
            (reader |> @protobuf.async_read_message() : Profile),
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
pub impl @protobuf.AsyncWrite for ScopeProfiles with write(
  self : ScopeProfiles,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.scope))
  @protobuf.AsyncWrite::write(self.scope, writer)
  for item in self.profiles {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) struct Profile {
  mut sample_type : ValueType
  mut samples : Array[Sample]
  mut time_unix_nano : UInt64
  mut duration_nano : UInt64
  mut period_type : ValueType
  mut period : Int64
  mut profile_id : Bytes
  mut dropped_attributes_count : UInt
  mut original_payload_format : String
  mut original_payload : Bytes
  mut attribute_indices : Array[Int]
} derive(Eq)

///|
pub impl @protobuf.Sized for Profile with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.sample_type)
      @protobuf.size_of(size) + size
    })
  for s in self.samples {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + 8U
  size += 1U + @protobuf.size_of(self.duration_nano)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.period_type)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.period)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.profile_id)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.dropped_attributes_count)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.original_payload_format)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.original_payload)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = self.attribute_indices
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for Profile with default() -> Profile {
  Profile::{
    sample_type: ValueType::default(),
    samples: [],
    time_unix_nano: UInt64::default(),
    duration_nano: UInt64::default(),
    period_type: ValueType::default(),
    period: Int64::default(),
    profile_id: Bytes::default(),
    dropped_attributes_count: UInt::default(),
    original_payload_format: String::default(),
    original_payload: Bytes::default(),
    attribute_indices: [],
  }
}

///|
pub fn Profile::new(
  sample_type : ValueType,
  samples : Array[Sample],
  time_unix_nano : UInt64,
  duration_nano : UInt64,
  period_type : ValueType,
  period : Int64,
  profile_id : Bytes,
  dropped_attributes_count : UInt,
  original_payload_format : String,
  original_payload : Bytes,
  attribute_indices : Array[Int],
) -> Profile {
  Profile::{
    sample_type,
    samples,
    time_unix_nano,
    duration_nano,
    period_type,
    period,
    profile_id,
    dropped_attributes_count,
    original_payload_format,
    original_payload,
    attribute_indices,
  }
}

///|
pub impl @protobuf.Read for Profile with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Profile raise {
  let msg = Profile::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.sample_type = (reader |> @protobuf.read_message() : ValueType)
        (2, _) =>
          msg.samples.push((reader |> @protobuf.read_message() : Sample))
        (3, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (4, _) => msg.duration_nano = reader |> @protobuf.read_uint64()
        (5, _) =>
          msg.period_type = (reader |> @protobuf.read_message() : ValueType)
        (6, _) => msg.period = reader |> @protobuf.read_int64()
        (7, _) => msg.profile_id = reader |> @protobuf.read_bytes()
        (8, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.read_uint32()
        (9, _) =>
          msg.original_payload_format = reader |> @protobuf.read_string()
        (10, _) => msg.original_payload = reader |> @protobuf.read_bytes()
        (11, _) =>
          msg.attribute_indices.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_int32, None)).iter(),
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
pub impl @protobuf.Write for Profile with write(
  self : Profile,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.sample_type))
  @protobuf.Write::write(self.sample_type, writer)
  for item in self.samples {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(25UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  writer |> @protobuf.write_varint(32UL)
  writer |> @protobuf.write_uint64(self.duration_nano)
  writer |> @protobuf.write_varint(42UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.period_type))
  @protobuf.Write::write(self.period_type, writer)
  writer |> @protobuf.write_varint(48UL)
  writer |> @protobuf.write_int64(self.period)
  writer |> @protobuf.write_varint(58UL)
  writer |> @protobuf.write_bytes(self.profile_id)
  writer |> @protobuf.write_varint(64UL)
  writer |> @protobuf.write_uint32(self.dropped_attributes_count)
  writer |> @protobuf.write_varint(74UL)
  writer |> @protobuf.write_string(self.original_payload_format)
  writer |> @protobuf.write_varint(82UL)
  writer |> @protobuf.write_bytes(self.original_payload)
  writer |> @protobuf.write_varint(90UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.write_int32(item)
  }
}

///|
pub impl ToJson for Profile with to_json(self) {
  let json : Map[String, Json] = {}
  if self.sample_type != Default::default() {
    json["sampleType"] = self.sample_type.to_json()
  }
  if self.samples != Default::default() {
    json["samples"] = self.samples.to_json()
  }
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.duration_nano != Default::default() {
    json["durationNano"] = self.duration_nano.to_json()
  }
  if self.period_type != Default::default() {
    json["periodType"] = self.period_type.to_json()
  }
  if self.period != Default::default() {
    json["period"] = self.period.to_json()
  }
  if self.profile_id != Default::default() {
    json["profileId"] = @protobuf.base64_encode(self.profile_id).to_json()
  }
  if self.dropped_attributes_count != Default::default() {
    json["droppedAttributesCount"] = self.dropped_attributes_count.to_json()
  }
  if self.original_payload_format != Default::default() {
    json["originalPayloadFormat"] = self.original_payload_format.to_json()
  }
  if self.original_payload != Default::default() {
    json["originalPayload"] = @protobuf.base64_encode(self.original_payload).to_json()
  }
  if self.attribute_indices != Default::default() {
    json["attributeIndices"] = self.attribute_indices.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Profile with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Profile raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Profile"))
  }
  let message = Profile::default()
  for key, value in obj {
    match (key, value) {
      ("sampleType", value) =>
        message.sample_type = @json.from_json(value, path~)
      ("samples", Array(value)) =>
        message.samples = value.map(v => @json.from_json(v, path~))
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("durationNano", value) =>
        message.duration_nano = @json.from_json(value, path~)
      ("periodType", value) =>
        message.period_type = @json.from_json(value, path~)
      ("period", value) => message.period = @json.from_json(value, path~)
      ("profileId", String(value)) =>
        message.profile_id = @protobuf.base64_decode(value)
      ("droppedAttributesCount", value) =>
        message.dropped_attributes_count = @json.from_json(value, path~)
      ("originalPayloadFormat", value) =>
        message.original_payload_format = @json.from_json(value, path~)
      ("originalPayload", String(value)) =>
        message.original_payload = @protobuf.base64_decode(value)
      ("attributeIndices", Array(value)) =>
        message.attribute_indices = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Profile with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Profile raise {
  let msg = Profile::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.sample_type = (
            reader |> @protobuf.async_read_message() : ValueType)
        (2, _) =>
          msg.samples.push((reader |> @protobuf.async_read_message() : Sample))
        (3, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (4, _) => msg.duration_nano = reader |> @protobuf.async_read_uint64()
        (5, _) =>
          msg.period_type = (
            reader |> @protobuf.async_read_message() : ValueType)
        (6, _) => msg.period = reader |> @protobuf.async_read_int64()
        (7, _) => msg.profile_id = reader |> @protobuf.async_read_bytes()
        (8, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.async_read_uint32()
        (9, _) =>
          msg.original_payload_format = reader |> @protobuf.async_read_string()
        (10, _) => msg.original_payload = reader |> @protobuf.async_read_bytes()
        (11, _) =>
          msg.attribute_indices.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_int32, None)).iter(),
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
pub impl @protobuf.AsyncWrite for Profile with write(
  self : Profile,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.sample_type))
  @protobuf.AsyncWrite::write(self.sample_type, writer)
  for item in self.samples {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(25UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  writer |> @protobuf.async_write_varint(32UL)
  writer |> @protobuf.async_write_uint64(self.duration_nano)
  writer |> @protobuf.async_write_varint(42UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.period_type))
  @protobuf.AsyncWrite::write(self.period_type, writer)
  writer |> @protobuf.async_write_varint(48UL)
  writer |> @protobuf.async_write_int64(self.period)
  writer |> @protobuf.async_write_varint(58UL)
  writer |> @protobuf.async_write_bytes(self.profile_id)
  writer |> @protobuf.async_write_varint(64UL)
  writer |> @protobuf.async_write_uint32(self.dropped_attributes_count)
  writer |> @protobuf.async_write_varint(74UL)
  writer |> @protobuf.async_write_string(self.original_payload_format)
  writer |> @protobuf.async_write_varint(82UL)
  writer |> @protobuf.async_write_bytes(self.original_payload)
  writer |> @protobuf.async_write_varint(90UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.async_write_int32(item)
  }
}

///|
pub(all) struct Link {
  mut trace_id : Bytes
  mut span_id : Bytes
} derive(Eq)

///|
pub impl @protobuf.Sized for Link with size_of(self) {
  let mut size = 0U
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
  size
}

///|
pub impl Default for Link with default() -> Link {
  Link::{ trace_id: Bytes::default(), span_id: Bytes::default() }
}

///|
pub fn Link::new(trace_id : Bytes, span_id : Bytes) -> Link {
  Link::{ trace_id, span_id }
}

///|
pub impl @protobuf.Read for Link with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Link raise {
  let msg = Link::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.trace_id = reader |> @protobuf.read_bytes()
        (2, _) => msg.span_id = reader |> @protobuf.read_bytes()
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
pub impl @protobuf.Write for Link with write(
  self : Link,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_bytes(self.trace_id)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_bytes(self.span_id)
}

///|
pub impl ToJson for Link with to_json(self) {
  let json : Map[String, Json] = {}
  if self.trace_id != Default::default() {
    json["traceId"] = @protobuf.base64_encode(self.trace_id).to_json()
  }
  if self.span_id != Default::default() {
    json["spanId"] = @protobuf.base64_encode(self.span_id).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Link with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Link raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Link"))
  }
  let message = Link::default()
  for key, value in obj {
    match (key, value) {
      ("traceId", String(value)) =>
        message.trace_id = @protobuf.base64_decode(value)
      ("spanId", String(value)) =>
        message.span_id = @protobuf.base64_decode(value)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Link with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Link raise {
  let msg = Link::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.trace_id = reader |> @protobuf.async_read_bytes()
        (2, _) => msg.span_id = reader |> @protobuf.async_read_bytes()
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
pub impl @protobuf.AsyncWrite for Link with write(
  self : Link,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_bytes(self.trace_id)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_bytes(self.span_id)
}

///|
pub(all) struct ValueType {
  mut type_strindex : Int
  mut unit_strindex : Int
} derive(Eq)

///|
pub impl @protobuf.Sized for ValueType with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.type_strindex)
  size += 1U + @protobuf.size_of(self.unit_strindex)
  size
}

///|
pub impl Default for ValueType with default() -> ValueType {
  ValueType::{ type_strindex: Int::default(), unit_strindex: Int::default() }
}

///|
pub fn ValueType::new(type_strindex : Int, unit_strindex : Int) -> ValueType {
  ValueType::{ type_strindex, unit_strindex }
}

///|
pub impl @protobuf.Read for ValueType with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ValueType raise {
  let msg = ValueType::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.type_strindex = reader |> @protobuf.read_int32()
        (2, _) => msg.unit_strindex = reader |> @protobuf.read_int32()
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
pub impl @protobuf.Write for ValueType with write(
  self : ValueType,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int32(self.type_strindex)
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_int32(self.unit_strindex)
}

///|
pub impl ToJson for ValueType with to_json(self) {
  let json : Map[String, Json] = {}
  if self.type_strindex != Default::default() {
    json["typeStrindex"] = self.type_strindex.to_json()
  }
  if self.unit_strindex != Default::default() {
    json["unitStrindex"] = self.unit_strindex.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ValueType with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ValueType raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ValueType"))
  }
  let message = ValueType::default()
  for key, value in obj {
    match (key, value) {
      ("typeStrindex", value) =>
        message.type_strindex = @json.from_json(value, path~)
      ("unitStrindex", value) =>
        message.unit_strindex = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ValueType with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ValueType raise {
  let msg = ValueType::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.type_strindex = reader |> @protobuf.async_read_int32()
        (2, _) => msg.unit_strindex = reader |> @protobuf.async_read_int32()
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
pub impl @protobuf.AsyncWrite for ValueType with write(
  self : ValueType,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int32(self.type_strindex)
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_int32(self.unit_strindex)
}

///|
pub(all) struct Sample {
  mut stack_index : Int
  mut attribute_indices : Array[Int]
  mut link_index : Int
  mut values : Array[Int64]
  mut timestamps_unix_nano : Array[UInt64]
} derive(Eq)

///|
pub impl @protobuf.Sized for Sample with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.stack_index)
  size += 1U +
    ({
      let size = self.attribute_indices
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.link_index)
  size += 1U +
    ({
      let size = self.values
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = self.timestamps_unix_nano.length().reinterpret_as_uint() * 8
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for Sample with default() -> Sample {
  Sample::{
    stack_index: Int::default(),
    attribute_indices: [],
    link_index: Int::default(),
    values: [],
    timestamps_unix_nano: [],
  }
}

///|
pub fn Sample::new(
  stack_index : Int,
  attribute_indices : Array[Int],
  link_index : Int,
  values : Array[Int64],
  timestamps_unix_nano : Array[UInt64],
) -> Sample {
  Sample::{
    stack_index,
    attribute_indices,
    link_index,
    values,
    timestamps_unix_nano,
  }
}

///|
pub impl @protobuf.Read for Sample with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Sample raise {
  let msg = Sample::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.stack_index = reader |> @protobuf.read_int32()
        (2, _) =>
          msg.attribute_indices.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_int32, None)).iter(),
          )
        (3, _) => msg.link_index = reader |> @protobuf.read_int32()
        (4, _) =>
          msg.values.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_int64, None)).iter(),
          )
        (5, _) =>
          msg.timestamps_unix_nano.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_fixed64, Some(8))).iter(),
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
pub impl @protobuf.Write for Sample with write(
  self : Sample,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int32(self.stack_index)
  writer |> @protobuf.write_varint(18UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.write_int32(item)
  }
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_int32(self.link_index)
  writer |> @protobuf.write_varint(34UL)
  let size = self.values.iter().map(@protobuf.size_of).fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.values {
    writer |> @protobuf.write_int64(item)
  }
  writer |> @protobuf.write_varint(42UL)
  let size = self.timestamps_unix_nano.length().reinterpret_as_uint() * 8
  writer |> @protobuf.write_uint32(size)
  for item in self.timestamps_unix_nano {
    writer |> @protobuf.write_fixed64(item)
  }
}

///|
pub impl ToJson for Sample with to_json(self) {
  let json : Map[String, Json] = {}
  if self.stack_index != Default::default() {
    json["stackIndex"] = self.stack_index.to_json()
  }
  if self.attribute_indices != Default::default() {
    json["attributeIndices"] = self.attribute_indices.to_json()
  }
  if self.link_index != Default::default() {
    json["linkIndex"] = self.link_index.to_json()
  }
  if self.values != Default::default() {
    json["values"] = self.values.to_json()
  }
  if self.timestamps_unix_nano != Default::default() {
    json["timestampsUnixNano"] = self.timestamps_unix_nano.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Sample with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Sample raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Sample"))
  }
  let message = Sample::default()
  for key, value in obj {
    match (key, value) {
      ("stackIndex", value) =>
        message.stack_index = @json.from_json(value, path~)
      ("attributeIndices", Array(value)) =>
        message.attribute_indices = value.map(v => @json.from_json(v, path~))
      ("linkIndex", value) => message.link_index = @json.from_json(value, path~)
      ("values", Array(value)) =>
        message.values = value.map(v => @json.from_json(v, path~))
      ("timestampsUnixNano", Array(value)) =>
        message.timestamps_unix_nano = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Sample with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Sample raise {
  let msg = Sample::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.stack_index = reader |> @protobuf.async_read_int32()
        (2, _) =>
          msg.attribute_indices.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_int32, None)).iter(),
          )
        (3, _) => msg.link_index = reader |> @protobuf.async_read_int32()
        (4, _) =>
          msg.values.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_int64, None)).iter(),
          )
        (5, _) =>
          msg.timestamps_unix_nano.push_iter(
            (reader
            |> @protobuf.async_read_packed(
              @protobuf.async_read_fixed64,
              Some(8),
            )).iter(),
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
pub impl @protobuf.AsyncWrite for Sample with write(
  self : Sample,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int32(self.stack_index)
  writer |> @protobuf.async_write_varint(18UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.async_write_int32(item)
  }
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_int32(self.link_index)
  writer |> @protobuf.async_write_varint(34UL)
  let size = self.values.iter().map(@protobuf.size_of).fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.values {
    writer |> @protobuf.async_write_int64(item)
  }
  writer |> @protobuf.async_write_varint(42UL)
  let size = self.timestamps_unix_nano.length().reinterpret_as_uint() * 8
  writer |> @protobuf.async_write_uint32(size)
  for item in self.timestamps_unix_nano {
    writer |> @protobuf.async_write_fixed64(item)
  }
}

///|
pub(all) struct Mapping {
  mut memory_start : UInt64
  mut memory_limit : UInt64
  mut file_offset : UInt64
  mut filename_strindex : Int
  mut attribute_indices : Array[Int]
} derive(Eq)

///|
pub impl @protobuf.Sized for Mapping with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.memory_start)
  size += 1U + @protobuf.size_of(self.memory_limit)
  size += 1U + @protobuf.size_of(self.file_offset)
  size += 1U + @protobuf.size_of(self.filename_strindex)
  size += 1U +
    ({
      let size = self.attribute_indices
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for Mapping with default() -> Mapping {
  Mapping::{
    memory_start: UInt64::default(),
    memory_limit: UInt64::default(),
    file_offset: UInt64::default(),
    filename_strindex: Int::default(),
    attribute_indices: [],
  }
}

///|
pub fn Mapping::new(
  memory_start : UInt64,
  memory_limit : UInt64,
  file_offset : UInt64,
  filename_strindex : Int,
  attribute_indices : Array[Int],
) -> Mapping {
  Mapping::{
    memory_start,
    memory_limit,
    file_offset,
    filename_strindex,
    attribute_indices,
  }
}

///|
pub impl @protobuf.Read for Mapping with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Mapping raise {
  let msg = Mapping::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.memory_start = reader |> @protobuf.read_uint64()
        (2, _) => msg.memory_limit = reader |> @protobuf.read_uint64()
        (3, _) => msg.file_offset = reader |> @protobuf.read_uint64()
        (4, _) => msg.filename_strindex = reader |> @protobuf.read_int32()
        (5, _) =>
          msg.attribute_indices.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_int32, None)).iter(),
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
pub impl @protobuf.Write for Mapping with write(
  self : Mapping,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_uint64(self.memory_start)
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_uint64(self.memory_limit)
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_uint64(self.file_offset)
  writer |> @protobuf.write_varint(32UL)
  writer |> @protobuf.write_int32(self.filename_strindex)
  writer |> @protobuf.write_varint(42UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.write_int32(item)
  }
}

///|
pub impl ToJson for Mapping with to_json(self) {
  let json : Map[String, Json] = {}
  if self.memory_start != Default::default() {
    json["memoryStart"] = self.memory_start.to_json()
  }
  if self.memory_limit != Default::default() {
    json["memoryLimit"] = self.memory_limit.to_json()
  }
  if self.file_offset != Default::default() {
    json["fileOffset"] = self.file_offset.to_json()
  }
  if self.filename_strindex != Default::default() {
    json["filenameStrindex"] = self.filename_strindex.to_json()
  }
  if self.attribute_indices != Default::default() {
    json["attributeIndices"] = self.attribute_indices.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Mapping with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Mapping raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Mapping"))
  }
  let message = Mapping::default()
  for key, value in obj {
    match (key, value) {
      ("memoryStart", value) =>
        message.memory_start = @json.from_json(value, path~)
      ("memoryLimit", value) =>
        message.memory_limit = @json.from_json(value, path~)
      ("fileOffset", value) =>
        message.file_offset = @json.from_json(value, path~)
      ("filenameStrindex", value) =>
        message.filename_strindex = @json.from_json(value, path~)
      ("attributeIndices", Array(value)) =>
        message.attribute_indices = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Mapping with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Mapping raise {
  let msg = Mapping::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.memory_start = reader |> @protobuf.async_read_uint64()
        (2, _) => msg.memory_limit = reader |> @protobuf.async_read_uint64()
        (3, _) => msg.file_offset = reader |> @protobuf.async_read_uint64()
        (4, _) => msg.filename_strindex = reader |> @protobuf.async_read_int32()
        (5, _) =>
          msg.attribute_indices.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_int32, None)).iter(),
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
pub impl @protobuf.AsyncWrite for Mapping with write(
  self : Mapping,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_uint64(self.memory_start)
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_uint64(self.memory_limit)
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_uint64(self.file_offset)
  writer |> @protobuf.async_write_varint(32UL)
  writer |> @protobuf.async_write_int32(self.filename_strindex)
  writer |> @protobuf.async_write_varint(42UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.async_write_int32(item)
  }
}

///|
pub(all) struct Stack {
  mut location_indices : Array[Int]
} derive(Eq)

///|
pub impl @protobuf.Sized for Stack with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = self.location_indices
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for Stack with default() -> Stack {
  Stack::{ location_indices: [] }
}

///|
pub fn Stack::new(location_indices : Array[Int]) -> Stack {
  Stack::{ location_indices, }
}

///|
pub impl @protobuf.Read for Stack with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Stack raise {
  let msg = Stack::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.location_indices.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_int32, None)).iter(),
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
pub impl @protobuf.Write for Stack with write(
  self : Stack,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  let size = self.location_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.location_indices {
    writer |> @protobuf.write_int32(item)
  }
}

///|
pub impl ToJson for Stack with to_json(self) {
  let json : Map[String, Json] = {}
  if self.location_indices != Default::default() {
    json["locationIndices"] = self.location_indices.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Stack with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Stack raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Stack"))
  }
  let message = Stack::default()
  for key, value in obj {
    match (key, value) {
      ("locationIndices", Array(value)) =>
        message.location_indices = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Stack with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Stack raise {
  let msg = Stack::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.location_indices.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_int32, None)).iter(),
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
pub impl @protobuf.AsyncWrite for Stack with write(
  self : Stack,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  let size = self.location_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.location_indices {
    writer |> @protobuf.async_write_int32(item)
  }
}

///|
pub(all) struct Location {
  mut mapping_index : Int
  mut address : UInt64
  mut lines : Array[Line]
  mut attribute_indices : Array[Int]
} derive(Eq)

///|
pub impl @protobuf.Sized for Location with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.mapping_index)
  size += 1U + @protobuf.size_of(self.address)
  for s in self.lines {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U +
    ({
      let size = self.attribute_indices
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for Location with default() -> Location {
  Location::{
    mapping_index: Int::default(),
    address: UInt64::default(),
    lines: [],
    attribute_indices: [],
  }
}

///|
pub fn Location::new(
  mapping_index : Int,
  address : UInt64,
  lines : Array[Line],
  attribute_indices : Array[Int],
) -> Location {
  Location::{ mapping_index, address, lines, attribute_indices }
}

///|
pub impl @protobuf.Read for Location with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Location raise {
  let msg = Location::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.mapping_index = reader |> @protobuf.read_int32()
        (2, _) => msg.address = reader |> @protobuf.read_uint64()
        (3, _) => msg.lines.push((reader |> @protobuf.read_message() : Line))
        (4, _) =>
          msg.attribute_indices.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_int32, None)).iter(),
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
pub impl @protobuf.Write for Location with write(
  self : Location,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int32(self.mapping_index)
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_uint64(self.address)
  for item in self.lines {
    writer |> @protobuf.write_varint(26UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(34UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.write_int32(item)
  }
}

///|
pub impl ToJson for Location with to_json(self) {
  let json : Map[String, Json] = {}
  if self.mapping_index != Default::default() {
    json["mappingIndex"] = self.mapping_index.to_json()
  }
  if self.address != Default::default() {
    json["address"] = self.address.to_json()
  }
  if self.lines != Default::default() {
    json["lines"] = self.lines.to_json()
  }
  if self.attribute_indices != Default::default() {
    json["attributeIndices"] = self.attribute_indices.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Location with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Location raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Location"))
  }
  let message = Location::default()
  for key, value in obj {
    match (key, value) {
      ("mappingIndex", value) =>
        message.mapping_index = @json.from_json(value, path~)
      ("address", value) => message.address = @json.from_json(value, path~)
      ("lines", Array(value)) =>
        message.lines = value.map(v => @json.from_json(v, path~))
      ("attributeIndices", Array(value)) =>
        message.attribute_indices = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Location with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Location raise {
  let msg = Location::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.mapping_index = reader |> @protobuf.async_read_int32()
        (2, _) => msg.address = reader |> @protobuf.async_read_uint64()
        (3, _) =>
          msg.lines.push((reader |> @protobuf.async_read_message() : Line))
        (4, _) =>
          msg.attribute_indices.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_int32, None)).iter(),
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
pub impl @protobuf.AsyncWrite for Location with write(
  self : Location,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int32(self.mapping_index)
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_uint64(self.address)
  for item in self.lines {
    writer |> @protobuf.async_write_varint(26UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(34UL)
  let size = self.attribute_indices
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.attribute_indices {
    writer |> @protobuf.async_write_int32(item)
  }
}

///|
pub(all) struct Line {
  mut function_index : Int
  mut line : Int64
  mut column : Int64
} derive(Eq)

///|
pub impl @protobuf.Sized for Line with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.function_index)
  size += 1U + @protobuf.size_of(self.line)
  size += 1U + @protobuf.size_of(self.column)
  size
}

///|
pub impl Default for Line with default() -> Line {
  Line::{
    function_index: Int::default(),
    line: Int64::default(),
    column: Int64::default(),
  }
}

///|
pub fn Line::new(function_index : Int, line : Int64, column : Int64) -> Line {
  Line::{ function_index, line, column }
}

///|
pub impl @protobuf.Read for Line with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Line raise {
  let msg = Line::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.function_index = reader |> @protobuf.read_int32()
        (2, _) => msg.line = reader |> @protobuf.read_int64()
        (3, _) => msg.column = reader |> @protobuf.read_int64()
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
pub impl @protobuf.Write for Line with write(
  self : Line,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int32(self.function_index)
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_int64(self.line)
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_int64(self.column)
}

///|
pub impl ToJson for Line with to_json(self) {
  let json : Map[String, Json] = {}
  if self.function_index != Default::default() {
    json["functionIndex"] = self.function_index.to_json()
  }
  if self.line != Default::default() {
    json["line"] = self.line.to_json()
  }
  if self.column != Default::default() {
    json["column"] = self.column.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Line with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Line raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Line"))
  }
  let message = Line::default()
  for key, value in obj {
    match (key, value) {
      ("functionIndex", value) =>
        message.function_index = @json.from_json(value, path~)
      ("line", value) => message.line = @json.from_json(value, path~)
      ("column", value) => message.column = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Line with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Line raise {
  let msg = Line::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.function_index = reader |> @protobuf.async_read_int32()
        (2, _) => msg.line = reader |> @protobuf.async_read_int64()
        (3, _) => msg.column = reader |> @protobuf.async_read_int64()
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
pub impl @protobuf.AsyncWrite for Line with write(
  self : Line,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int32(self.function_index)
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_int64(self.line)
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_int64(self.column)
}

///|
pub(all) struct Function {
  mut name_strindex : Int
  mut system_name_strindex : Int
  mut filename_strindex : Int
  mut start_line : Int64
} derive(Eq)

///|
pub impl @protobuf.Sized for Function with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.name_strindex)
  size += 1U + @protobuf.size_of(self.system_name_strindex)
  size += 1U + @protobuf.size_of(self.filename_strindex)
  size += 1U + @protobuf.size_of(self.start_line)
  size
}

///|
pub impl Default for Function with default() -> Function {
  Function::{
    name_strindex: Int::default(),
    system_name_strindex: Int::default(),
    filename_strindex: Int::default(),
    start_line: Int64::default(),
  }
}

///|
pub fn Function::new(
  name_strindex : Int,
  system_name_strindex : Int,
  filename_strindex : Int,
  start_line : Int64,
) -> Function {
  Function::{
    name_strindex,
    system_name_strindex,
    filename_strindex,
    start_line,
  }
}

///|
pub impl @protobuf.Read for Function with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Function raise {
  let msg = Function::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.name_strindex = reader |> @protobuf.read_int32()
        (2, _) => msg.system_name_strindex = reader |> @protobuf.read_int32()
        (3, _) => msg.filename_strindex = reader |> @protobuf.read_int32()
        (4, _) => msg.start_line = reader |> @protobuf.read_int64()
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
pub impl @protobuf.Write for Function with write(
  self : Function,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int32(self.name_strindex)
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_int32(self.system_name_strindex)
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_int32(self.filename_strindex)
  writer |> @protobuf.write_varint(32UL)
  writer |> @protobuf.write_int64(self.start_line)
}

///|
pub impl ToJson for Function with to_json(self) {
  let json : Map[String, Json] = {}
  if self.name_strindex != Default::default() {
    json["nameStrindex"] = self.name_strindex.to_json()
  }
  if self.system_name_strindex != Default::default() {
    json["systemNameStrindex"] = self.system_name_strindex.to_json()
  }
  if self.filename_strindex != Default::default() {
    json["filenameStrindex"] = self.filename_strindex.to_json()
  }
  if self.start_line != Default::default() {
    json["startLine"] = self.start_line.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Function with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Function raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Function"))
  }
  let message = Function::default()
  for key, value in obj {
    match (key, value) {
      ("nameStrindex", value) =>
        message.name_strindex = @json.from_json(value, path~)
      ("systemNameStrindex", value) =>
        message.system_name_strindex = @json.from_json(value, path~)
      ("filenameStrindex", value) =>
        message.filename_strindex = @json.from_json(value, path~)
      ("startLine", value) => message.start_line = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Function with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Function raise {
  let msg = Function::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.name_strindex = reader |> @protobuf.async_read_int32()
        (2, _) =>
          msg.system_name_strindex = reader |> @protobuf.async_read_int32()
        (3, _) => msg.filename_strindex = reader |> @protobuf.async_read_int32()
        (4, _) => msg.start_line = reader |> @protobuf.async_read_int64()
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
pub impl @protobuf.AsyncWrite for Function with write(
  self : Function,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int32(self.name_strindex)
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_int32(self.system_name_strindex)
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_int32(self.filename_strindex)
  writer |> @protobuf.async_write_varint(32UL)
  writer |> @protobuf.async_write_int64(self.start_line)
}

///|
pub(all) struct KeyValueAndUnit {
  mut key_strindex : Int
  mut value : @v1.AnyValue
  mut unit_strindex : Int
} derive(Eq)

///|
pub impl @protobuf.Sized for KeyValueAndUnit with size_of(self) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.key_strindex)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.value)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.unit_strindex)
  size
}

///|
pub impl Default for KeyValueAndUnit with default() -> KeyValueAndUnit {
  KeyValueAndUnit::{
    key_strindex: Int::default(),
    value: @v1.AnyValue::default(),
    unit_strindex: Int::default(),
  }
}

///|
pub fn KeyValueAndUnit::new(
  key_strindex : Int,
  value : @v1.AnyValue,
  unit_strindex : Int,
) -> KeyValueAndUnit {
  KeyValueAndUnit::{ key_strindex, value, unit_strindex }
}

///|
pub impl @protobuf.Read for KeyValueAndUnit with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> KeyValueAndUnit raise {
  let msg = KeyValueAndUnit::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.key_strindex = reader |> @protobuf.read_int32()
        (2, _) =>
          msg.value = (reader |> @protobuf.read_message() : @v1.AnyValue)
        (3, _) => msg.unit_strindex = reader |> @protobuf.read_int32()
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
pub impl @protobuf.Write for KeyValueAndUnit with write(
  self : KeyValueAndUnit,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_int32(self.key_strindex)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.value))
  @protobuf.Write::write(self.value, writer)
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_int32(self.unit_strindex)
}

///|
pub impl ToJson for KeyValueAndUnit with to_json(self) {
  let json : Map[String, Json] = {}
  if self.key_strindex != Default::default() {
    json["keyStrindex"] = self.key_strindex.to_json()
  }
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  if self.unit_strindex != Default::default() {
    json["unitStrindex"] = self.unit_strindex.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for KeyValueAndUnit with from_json(
  json : Json,
  path : @json.JsonPath,
) -> KeyValueAndUnit raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for KeyValueAndUnit"),
    )
  }
  let message = KeyValueAndUnit::default()
  for key, value in obj {
    match (key, value) {
      ("keyStrindex", value) =>
        message.key_strindex = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      ("unitStrindex", value) =>
        message.unit_strindex = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for KeyValueAndUnit with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> KeyValueAndUnit raise {
  let msg = KeyValueAndUnit::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.key_strindex = reader |> @protobuf.async_read_int32()
        (2, _) =>
          msg.value = (reader |> @protobuf.async_read_message() : @v1.AnyValue)
        (3, _) => msg.unit_strindex = reader |> @protobuf.async_read_int32()
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
pub impl @protobuf.AsyncWrite for KeyValueAndUnit with write(
  self : KeyValueAndUnit,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_int32(self.key_strindex)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.value))
  @protobuf.AsyncWrite::write(self.value, writer)
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_int32(self.unit_strindex)
}
