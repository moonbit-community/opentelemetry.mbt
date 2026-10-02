///|
pub(all) enum SpanFlags {
  SPAN_FLAGS_DO_NOT_USE
  SPAN_FLAGS_TRACE_FLAGS_MASK
  SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK
  SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK
} derive(Eq)

///|
pub fn SpanFlags::to_enum(self : SpanFlags) -> @protobuf.Enum {
  match self {
    SPAN_FLAGS_DO_NOT_USE => 0
    SPAN_FLAGS_TRACE_FLAGS_MASK => 255
    SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK => 256
    SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK => 512
  }
}

///|
pub fn SpanFlags::from_enum(i : @protobuf.Enum) -> SpanFlags {
  match i.0 {
    0 => SPAN_FLAGS_DO_NOT_USE
    255 => SPAN_FLAGS_TRACE_FLAGS_MASK
    256 => SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK
    512 => SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK
    _ => Default::default()
  }
}

///|
pub impl Default for SpanFlags with fn default() -> SpanFlags {
  SPAN_FLAGS_DO_NOT_USE
}

///|
pub impl @protobuf.Sized for SpanFlags with fn size_of(self : SpanFlags) {
  @protobuf.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for SpanFlags with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> SpanFlags raise {
  match json {
    String("SPAN_FLAGS_DO_NOT_USE") => SPAN_FLAGS_DO_NOT_USE
    String("SPAN_FLAGS_TRACE_FLAGS_MASK") => SPAN_FLAGS_TRACE_FLAGS_MASK
    String("SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK") =>
      SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK
    String("SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK") =>
      SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK
    Number(0, ..) => SPAN_FLAGS_DO_NOT_USE
    Number(255, ..) => SPAN_FLAGS_TRACE_FLAGS_MASK
    Number(256, ..) => SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK
    Number(512, ..) => SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK
    _ => raise JsonDecodeError((path, "Expected a number or string for enum"))
  }
}

///|
pub impl ToJson for SpanFlags with fn to_json(self : SpanFlags) -> Json {
  match self {
    SPAN_FLAGS_DO_NOT_USE => "SPAN_FLAGS_DO_NOT_USE"
    SPAN_FLAGS_TRACE_FLAGS_MASK => "SPAN_FLAGS_TRACE_FLAGS_MASK"
    SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK =>
      "SPAN_FLAGS_CONTEXT_HAS_IS_REMOTE_MASK"
    SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK => "SPAN_FLAGS_CONTEXT_IS_REMOTE_MASK"
  }
}

///|
pub(all) struct TracesData {
  mut resource_spans : Array[ResourceSpans]
} derive(Eq)

///|
pub impl @protobuf.Sized for TracesData with fn size_of(self) {
  let mut size = 0U
  for s in self.resource_spans {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for TracesData with fn default() -> TracesData {
  { resource_spans: [], }
}

///|
pub fn TracesData::new(resource_spans : Array[ResourceSpans]) -> TracesData {
  { resource_spans, }
}

///|
pub impl @protobuf.Read for TracesData with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> TracesData raise {
  let msg : TracesData = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_spans.push(
            (reader |> @protobuf.read_message() : ResourceSpans),
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
pub impl @protobuf.Write for TracesData with fn write(
  self : TracesData,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.resource_spans {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for TracesData with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.resource_spans != Default::default() {
    json["resourceSpans"] = self.resource_spans.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for TracesData with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> TracesData raise {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "Expected an object for TracesData"))
  }
  let message : TracesData = Default::default()
  for key, value in obj {
    match (key, value) {
      ("resourceSpans", Array(value)) =>
        message.resource_spans = value.map(v => @json.from_json(v, path~))
      (key, _) => raise JsonDecodeError((path, "Unknown field " + key))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for TracesData with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> TracesData raise {
  let msg : TracesData = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_spans.push(
            (reader |> @protobuf.async_read_message() : ResourceSpans),
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
pub impl @protobuf.AsyncWrite for TracesData with fn write(
  self : TracesData,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.resource_spans {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ResourceSpans {
  mut resource : @v11.Resource
  mut scope_spans : Array[ScopeSpans]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ResourceSpans with fn size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.resource)
      @protobuf.size_of(size) + size
    })
  for s in self.scope_spans {
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
pub impl Default for ResourceSpans with fn default() -> ResourceSpans {
  {
    resource: @v11.Resource::default(),
    scope_spans: [],
    schema_url: Default::default(),
  }
}

///|
pub fn ResourceSpans::new(
  resource : @v11.Resource,
  scope_spans : Array[ScopeSpans],
  schema_url : String,
) -> ResourceSpans {
  { resource, scope_spans, schema_url, }
}

///|
pub impl @protobuf.Read for ResourceSpans with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ResourceSpans raise {
  let msg : ResourceSpans = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource = (reader |> @protobuf.read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_spans.push(
            (reader |> @protobuf.read_message() : ScopeSpans),
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
pub impl @protobuf.Write for ResourceSpans with fn write(
  self : ResourceSpans,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.resource))
  @protobuf.Write::write(self.resource, writer)
  for item in self.scope_spans {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ResourceSpans with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.resource != Default::default() {
    json["resource"] = self.resource.to_json()
  }
  if self.scope_spans != Default::default() {
    json["scopeSpans"] = self.scope_spans.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ResourceSpans with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ResourceSpans raise {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "Expected an object for ResourceSpans"))
  }
  let message : ResourceSpans = Default::default()
  for key, value in obj {
    match (key, value) {
      ("resource", value) => message.resource = @json.from_json(value, path~)
      ("scopeSpans", Array(value)) =>
        message.scope_spans = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      (key, _) => raise JsonDecodeError((path, "Unknown field " + key))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ResourceSpans with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ResourceSpans raise {
  let msg : ResourceSpans = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource = (
            reader |> @protobuf.async_read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_spans.push(
            (reader |> @protobuf.async_read_message() : ScopeSpans),
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
pub impl @protobuf.AsyncWrite for ResourceSpans with fn write(
  self : ResourceSpans,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.resource))
  @protobuf.AsyncWrite::write(self.resource, writer)
  for item in self.scope_spans {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) struct ScopeSpans {
  mut scope : @v1_dep.InstrumentationScope
  mut spans : Array[Span]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ScopeSpans with fn size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.scope)
      @protobuf.size_of(size) + size
    })
  for s in self.spans {
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
pub impl Default for ScopeSpans with fn default() -> ScopeSpans {
  {
    scope: @v1_dep.InstrumentationScope::default(),
    spans: [],
    schema_url: Default::default(),
  }
}

///|
pub fn ScopeSpans::new(
  scope : @v1_dep.InstrumentationScope,
  spans : Array[Span],
  schema_url : String,
) -> ScopeSpans {
  { scope, spans, schema_url, }
}

///|
pub impl @protobuf.Read for ScopeSpans with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ScopeSpans raise {
  let msg : ScopeSpans = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.read_message() : @v1_dep.InstrumentationScope)
        (2, _) => msg.spans.push((reader |> @protobuf.read_message() : Span))
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
pub impl @protobuf.Write for ScopeSpans with fn write(
  self : ScopeSpans,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.scope))
  @protobuf.Write::write(self.scope, writer)
  for item in self.spans {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ScopeSpans with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.scope != Default::default() {
    json["scope"] = self.scope.to_json()
  }
  if self.spans != Default::default() {
    json["spans"] = self.spans.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ScopeSpans with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ScopeSpans raise {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "Expected an object for ScopeSpans"))
  }
  let message : ScopeSpans = Default::default()
  for key, value in obj {
    match (key, value) {
      ("scope", value) => message.scope = @json.from_json(value, path~)
      ("spans", Array(value)) =>
        message.spans = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      (key, _) => raise JsonDecodeError((path, "Unknown field " + key))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ScopeSpans with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ScopeSpans raise {
  let msg : ScopeSpans = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.async_read_message() :
            @v1_dep.InstrumentationScope)
        (2, _) =>
          msg.spans.push((reader |> @protobuf.async_read_message() : Span))
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
pub impl @protobuf.AsyncWrite for ScopeSpans with fn write(
  self : ScopeSpans,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.scope))
  @protobuf.AsyncWrite::write(self.scope, writer)
  for item in self.spans {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) enum Span_SpanKind {
  SPAN_KIND_UNSPECIFIED
  SPAN_KIND_INTERNAL
  SPAN_KIND_SERVER
  SPAN_KIND_CLIENT
  SPAN_KIND_PRODUCER
  SPAN_KIND_CONSUMER
} derive(Eq)

///|
pub fn Span_SpanKind::to_enum(self : Span_SpanKind) -> @protobuf.Enum {
  match self {
    SPAN_KIND_UNSPECIFIED => 0
    SPAN_KIND_INTERNAL => 1
    SPAN_KIND_SERVER => 2
    SPAN_KIND_CLIENT => 3
    SPAN_KIND_PRODUCER => 4
    SPAN_KIND_CONSUMER => 5
  }
}

///|
pub fn Span_SpanKind::from_enum(i : @protobuf.Enum) -> Span_SpanKind {
  match i.0 {
    0 => SPAN_KIND_UNSPECIFIED
    1 => SPAN_KIND_INTERNAL
    2 => SPAN_KIND_SERVER
    3 => SPAN_KIND_CLIENT
    4 => SPAN_KIND_PRODUCER
    5 => SPAN_KIND_CONSUMER
    _ => Default::default()
  }
}

///|
pub impl Default for Span_SpanKind with fn default() -> Span_SpanKind {
  SPAN_KIND_UNSPECIFIED
}

///|
pub impl @protobuf.Sized for Span_SpanKind with fn size_of(self : Span_SpanKind) {
  @protobuf.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for Span_SpanKind with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Span_SpanKind raise {
  match json {
    String("SPAN_KIND_UNSPECIFIED") => SPAN_KIND_UNSPECIFIED
    String("SPAN_KIND_INTERNAL") => SPAN_KIND_INTERNAL
    String("SPAN_KIND_SERVER") => SPAN_KIND_SERVER
    String("SPAN_KIND_CLIENT") => SPAN_KIND_CLIENT
    String("SPAN_KIND_PRODUCER") => SPAN_KIND_PRODUCER
    String("SPAN_KIND_CONSUMER") => SPAN_KIND_CONSUMER
    Number(0, ..) => SPAN_KIND_UNSPECIFIED
    Number(1, ..) => SPAN_KIND_INTERNAL
    Number(2, ..) => SPAN_KIND_SERVER
    Number(3, ..) => SPAN_KIND_CLIENT
    Number(4, ..) => SPAN_KIND_PRODUCER
    Number(5, ..) => SPAN_KIND_CONSUMER
    _ => raise JsonDecodeError((path, "Expected a number or string for enum"))
  }
}

///|
pub impl ToJson for Span_SpanKind with fn to_json(self : Span_SpanKind) -> Json {
  match self {
    SPAN_KIND_UNSPECIFIED => "SPAN_KIND_UNSPECIFIED"
    SPAN_KIND_INTERNAL => "SPAN_KIND_INTERNAL"
    SPAN_KIND_SERVER => "SPAN_KIND_SERVER"
    SPAN_KIND_CLIENT => "SPAN_KIND_CLIENT"
    SPAN_KIND_PRODUCER => "SPAN_KIND_PRODUCER"
    SPAN_KIND_CONSUMER => "SPAN_KIND_CONSUMER"
  }
}

///|
pub(all) struct Span_Event {
  mut time_unix_nano : UInt64
  mut name : String
  mut attributes : Array[@v1_dep.KeyValue]
  mut dropped_attributes_count : UInt
} derive(Eq)

///|
pub impl @protobuf.Sized for Span_Event with fn size_of(self) {
  let mut size = 0U
  size += 1U + 8U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.name)
      @protobuf.size_of(size) + size
    })
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.dropped_attributes_count)
  size
}

///|
pub impl Default for Span_Event with fn default() -> Span_Event {
  {
    time_unix_nano: Default::default(),
    name: Default::default(),
    attributes: [],
    dropped_attributes_count: Default::default(),
  }
}

///|
pub fn Span_Event::new(
  time_unix_nano : UInt64,
  name : String,
  attributes : Array[@v1_dep.KeyValue],
  dropped_attributes_count : UInt,
) -> Span_Event {
  { time_unix_nano, name, attributes, dropped_attributes_count, }
}

///|
pub impl @protobuf.Read for Span_Event with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Span_Event raise {
  let msg : Span_Event = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (2, _) => msg.name = reader |> @protobuf.read_string()
        (3, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (4, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.read_uint32()
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
pub impl @protobuf.Write for Span_Event with fn write(
  self : Span_Event,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(9UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.name)
  for item in self.attributes {
    writer |> @protobuf.write_varint(26UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(32UL)
  writer |> @protobuf.write_uint32(self.dropped_attributes_count)
}

///|
pub impl ToJson for Span_Event with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.dropped_attributes_count != Default::default() {
    json["droppedAttributesCount"] = self.dropped_attributes_count.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Span_Event with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Span_Event raise {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "Expected an object for Span_Event"))
  }
  let message : Span_Event = Default::default()
  for key, value in obj {
    match (key, value) {
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("droppedAttributesCount", value) =>
        message.dropped_attributes_count = @json.from_json(value, path~)
      (key, _) => raise JsonDecodeError((path, "Unknown field " + key))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Span_Event with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Span_Event raise {
  let msg : Span_Event = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (2, _) => msg.name = reader |> @protobuf.async_read_string()
        (3, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (4, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.async_read_uint32()
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
pub impl @protobuf.AsyncWrite for Span_Event with fn write(
  self : Span_Event,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(9UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.name)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(26UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(32UL)
  writer |> @protobuf.async_write_uint32(self.dropped_attributes_count)
}

///|
pub(all) struct Span_Link {
  mut trace_id : Bytes
  mut span_id : Bytes
  mut trace_state : String
  mut attributes : Array[@v1_dep.KeyValue]
  mut dropped_attributes_count : UInt
  mut flags : UInt
} derive(Eq)

///|
pub impl @protobuf.Sized for Span_Link with fn size_of(self) {
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
  size += 1U +
    ({
      let size = @protobuf.size_of(self.trace_state)
      @protobuf.size_of(size) + size
    })
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.dropped_attributes_count)
  size += 1U + 4U
  size
}

///|
pub impl Default for Span_Link with fn default() -> Span_Link {
  {
    trace_id: Default::default(),
    span_id: Default::default(),
    trace_state: Default::default(),
    attributes: [],
    dropped_attributes_count: Default::default(),
    flags: Default::default(),
  }
}

///|
pub fn Span_Link::new(
  trace_id : Bytes,
  span_id : Bytes,
  trace_state : String,
  attributes : Array[@v1_dep.KeyValue],
  dropped_attributes_count : UInt,
  flags : UInt,
) -> Span_Link {
  {
    trace_id,
    span_id,
    trace_state,
    attributes,
    dropped_attributes_count,
    flags,
  }
}

///|
pub impl @protobuf.Read for Span_Link with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Span_Link raise {
  let msg : Span_Link = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.trace_id = reader |> @protobuf.read_bytes()
        (2, _) => msg.span_id = reader |> @protobuf.read_bytes()
        (3, _) => msg.trace_state = reader |> @protobuf.read_string()
        (4, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (5, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.read_uint32()
        (6, _) => msg.flags = reader |> @protobuf.read_fixed32()
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
pub impl @protobuf.Write for Span_Link with fn write(
  self : Span_Link,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_bytes(self.trace_id)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_bytes(self.span_id)
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.trace_state)
  for item in self.attributes {
    writer |> @protobuf.write_varint(34UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(40UL)
  writer |> @protobuf.write_uint32(self.dropped_attributes_count)
  writer |> @protobuf.write_varint(53UL)
  writer |> @protobuf.write_fixed32(self.flags)
}

///|
pub impl ToJson for Span_Link with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.trace_id != Default::default() {
    json["traceId"] = @protobuf.base64_encode(self.trace_id).to_json()
  }
  if self.span_id != Default::default() {
    json["spanId"] = @protobuf.base64_encode(self.span_id).to_json()
  }
  if self.trace_state != Default::default() {
    json["traceState"] = self.trace_state.to_json()
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
  Json::object(json)
}

///|
pub impl @json.FromJson for Span_Link with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Span_Link raise {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "Expected an object for Span_Link"))
  }
  let message : Span_Link = Default::default()
  for key, value in obj {
    match (key, value) {
      ("traceId", String(value)) =>
        message.trace_id = @protobuf.base64_decode(value)
      ("spanId", String(value)) =>
        message.span_id = @protobuf.base64_decode(value)
      ("traceState", value) =>
        message.trace_state = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("droppedAttributesCount", value) =>
        message.dropped_attributes_count = @json.from_json(value, path~)
      ("flags", value) => message.flags = @json.from_json(value, path~)
      (key, _) => raise JsonDecodeError((path, "Unknown field " + key))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Span_Link with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Span_Link raise {
  let msg : Span_Link = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.trace_id = reader |> @protobuf.async_read_bytes()
        (2, _) => msg.span_id = reader |> @protobuf.async_read_bytes()
        (3, _) => msg.trace_state = reader |> @protobuf.async_read_string()
        (4, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (5, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.async_read_uint32()
        (6, _) => msg.flags = reader |> @protobuf.async_read_fixed32()
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
pub impl @protobuf.AsyncWrite for Span_Link with fn write(
  self : Span_Link,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_bytes(self.trace_id)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_bytes(self.span_id)
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.trace_state)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(34UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(40UL)
  writer |> @protobuf.async_write_uint32(self.dropped_attributes_count)
  writer |> @protobuf.async_write_varint(53UL)
  writer |> @protobuf.async_write_fixed32(self.flags)
}

///|
pub(all) struct Span {
  mut trace_id : Bytes
  mut span_id : Bytes
  mut trace_state : String
  mut parent_span_id : Bytes
  mut flags : UInt
  mut name : String
  mut kind : Span_SpanKind
  mut start_time_unix_nano : UInt64
  mut end_time_unix_nano : UInt64
  mut attributes : Array[@v1_dep.KeyValue]
  mut dropped_attributes_count : UInt
  mut events : Array[Span_Event]
  mut dropped_events_count : UInt
  mut links : Array[Span_Link]
  mut dropped_links_count : UInt
  mut status : Status
} derive(Eq)

///|
pub impl @protobuf.Sized for Span with fn size_of(self) {
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
  size += 1U +
    ({
      let size = @protobuf.size_of(self.trace_state)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.parent_span_id)
      @protobuf.size_of(size) + size
    })
  size += 2U + 4U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.name)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.kind)
  size += 1U + 8U
  size += 1U + 8U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.dropped_attributes_count)
  for s in self.events {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.dropped_events_count)
  for s in self.links {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.dropped_links_count)
  size += 1U +
    ({
      let size = @protobuf.size_of(self.status)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for Span with fn default() -> Span {
  {
    trace_id: Default::default(),
    span_id: Default::default(),
    trace_state: Default::default(),
    parent_span_id: Default::default(),
    flags: Default::default(),
    name: Default::default(),
    kind: Default::default(),
    start_time_unix_nano: Default::default(),
    end_time_unix_nano: Default::default(),
    attributes: [],
    dropped_attributes_count: Default::default(),
    events: [],
    dropped_events_count: Default::default(),
    links: [],
    dropped_links_count: Default::default(),
    status: Default::default(),
  }
}

///|
pub fn Span::new(
  trace_id : Bytes,
  span_id : Bytes,
  trace_state : String,
  parent_span_id : Bytes,
  flags : UInt,
  name : String,
  kind : Span_SpanKind,
  start_time_unix_nano : UInt64,
  end_time_unix_nano : UInt64,
  attributes : Array[@v1_dep.KeyValue],
  dropped_attributes_count : UInt,
  events : Array[Span_Event],
  dropped_events_count : UInt,
  links : Array[Span_Link],
  dropped_links_count : UInt,
  status : Status,
) -> Span {
  {
    trace_id,
    span_id,
    trace_state,
    parent_span_id,
    flags,
    name,
    kind,
    start_time_unix_nano,
    end_time_unix_nano,
    attributes,
    dropped_attributes_count,
    events,
    dropped_events_count,
    links,
    dropped_links_count,
    status,
  }
}

///|
pub impl @protobuf.Read for Span with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Span raise {
  let msg : Span = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.trace_id = reader |> @protobuf.read_bytes()
        (2, _) => msg.span_id = reader |> @protobuf.read_bytes()
        (3, _) => msg.trace_state = reader |> @protobuf.read_string()
        (4, _) => msg.parent_span_id = reader |> @protobuf.read_bytes()
        (16, _) => msg.flags = reader |> @protobuf.read_fixed32()
        (5, _) => msg.name = reader |> @protobuf.read_string()
        (6, _) =>
          msg.kind = reader |> @protobuf.read_enum() |> Span_SpanKind::from_enum
        (7, _) => msg.start_time_unix_nano = reader |> @protobuf.read_fixed64()
        (8, _) => msg.end_time_unix_nano = reader |> @protobuf.read_fixed64()
        (9, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (10, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.read_uint32()
        (11, _) =>
          msg.events.push((reader |> @protobuf.read_message() : Span_Event))
        (12, _) => msg.dropped_events_count = reader |> @protobuf.read_uint32()
        (13, _) =>
          msg.links.push((reader |> @protobuf.read_message() : Span_Link))
        (14, _) => msg.dropped_links_count = reader |> @protobuf.read_uint32()
        (15, _) => msg.status = (reader |> @protobuf.read_message() : Status)
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
pub impl @protobuf.Write for Span with fn write(
  self : Span,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_bytes(self.trace_id)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_bytes(self.span_id)
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.trace_state)
  writer |> @protobuf.write_varint(34UL)
  writer |> @protobuf.write_bytes(self.parent_span_id)
  writer |> @protobuf.write_varint(133UL)
  writer |> @protobuf.write_fixed32(self.flags)
  writer |> @protobuf.write_varint(42UL)
  writer |> @protobuf.write_string(self.name)
  writer |> @protobuf.write_varint(48UL)
  writer |> @protobuf.write_enum(self.kind.to_enum())
  writer |> @protobuf.write_varint(57UL)
  writer |> @protobuf.write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.write_varint(65UL)
  writer |> @protobuf.write_fixed64(self.end_time_unix_nano)
  for item in self.attributes {
    writer |> @protobuf.write_varint(74UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(80UL)
  writer |> @protobuf.write_uint32(self.dropped_attributes_count)
  for item in self.events {
    writer |> @protobuf.write_varint(90UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(96UL)
  writer |> @protobuf.write_uint32(self.dropped_events_count)
  for item in self.links {
    writer |> @protobuf.write_varint(106UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(112UL)
  writer |> @protobuf.write_uint32(self.dropped_links_count)
  writer |> @protobuf.write_varint(122UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.status))
  @protobuf.Write::write(self.status, writer)
}

///|
pub impl ToJson for Span with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.trace_id != Default::default() {
    json["traceId"] = @protobuf.base64_encode(self.trace_id).to_json()
  }
  if self.span_id != Default::default() {
    json["spanId"] = @protobuf.base64_encode(self.span_id).to_json()
  }
  if self.trace_state != Default::default() {
    json["traceState"] = self.trace_state.to_json()
  }
  if self.parent_span_id != Default::default() {
    json["parentSpanId"] = @protobuf.base64_encode(self.parent_span_id).to_json()
  }
  if self.flags != Default::default() {
    json["flags"] = self.flags.to_json()
  }
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.kind != Default::default() {
    json["kind"] = ToJson::to_json(self.kind)
  }
  if self.start_time_unix_nano != Default::default() {
    json["startTimeUnixNano"] = self.start_time_unix_nano.to_json()
  }
  if self.end_time_unix_nano != Default::default() {
    json["endTimeUnixNano"] = self.end_time_unix_nano.to_json()
  }
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.dropped_attributes_count != Default::default() {
    json["droppedAttributesCount"] = self.dropped_attributes_count.to_json()
  }
  if self.events != Default::default() {
    json["events"] = self.events.to_json()
  }
  if self.dropped_events_count != Default::default() {
    json["droppedEventsCount"] = self.dropped_events_count.to_json()
  }
  if self.links != Default::default() {
    json["links"] = self.links.to_json()
  }
  if self.dropped_links_count != Default::default() {
    json["droppedLinksCount"] = self.dropped_links_count.to_json()
  }
  if self.status != Default::default() {
    json["status"] = ToJson::to_json(self.status)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Span with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Span raise {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "Expected an object for Span"))
  }
  let message : Span = Default::default()
  for key, value in obj {
    match (key, value) {
      ("traceId", String(value)) =>
        message.trace_id = @protobuf.base64_decode(value)
      ("spanId", String(value)) =>
        message.span_id = @protobuf.base64_decode(value)
      ("traceState", value) =>
        message.trace_state = @json.from_json(value, path~)
      ("parentSpanId", String(value)) =>
        message.parent_span_id = @protobuf.base64_decode(value)
      ("flags", value) => message.flags = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("kind", value) => message.kind = @json.from_json(value, path~)
      ("startTimeUnixNano", value) =>
        message.start_time_unix_nano = @json.from_json(value, path~)
      ("endTimeUnixNano", value) =>
        message.end_time_unix_nano = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("droppedAttributesCount", value) =>
        message.dropped_attributes_count = @json.from_json(value, path~)
      ("events", Array(value)) =>
        message.events = value.map(v => @json.from_json(v, path~))
      ("droppedEventsCount", value) =>
        message.dropped_events_count = @json.from_json(value, path~)
      ("links", Array(value)) =>
        message.links = value.map(v => @json.from_json(v, path~))
      ("droppedLinksCount", value) =>
        message.dropped_links_count = @json.from_json(value, path~)
      ("status", value) => message.status = @json.from_json(value, path~)
      (key, _) => raise JsonDecodeError((path, "Unknown field " + key))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Span with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Span raise {
  let msg : Span = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.trace_id = reader |> @protobuf.async_read_bytes()
        (2, _) => msg.span_id = reader |> @protobuf.async_read_bytes()
        (3, _) => msg.trace_state = reader |> @protobuf.async_read_string()
        (4, _) => msg.parent_span_id = reader |> @protobuf.async_read_bytes()
        (16, _) => msg.flags = reader |> @protobuf.async_read_fixed32()
        (5, _) => msg.name = reader |> @protobuf.async_read_string()
        (6, _) =>
          msg.kind = reader
            |> @protobuf.async_read_enum()
            |> Span_SpanKind::from_enum
        (7, _) =>
          msg.start_time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (8, _) =>
          msg.end_time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (9, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (10, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.async_read_uint32()
        (11, _) =>
          msg.events.push(
            (reader |> @protobuf.async_read_message() : Span_Event),
          )
        (12, _) =>
          msg.dropped_events_count = reader |> @protobuf.async_read_uint32()
        (13, _) =>
          msg.links.push((reader |> @protobuf.async_read_message() : Span_Link))
        (14, _) =>
          msg.dropped_links_count = reader |> @protobuf.async_read_uint32()
        (15, _) =>
          msg.status = (reader |> @protobuf.async_read_message() : Status)
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
pub impl @protobuf.AsyncWrite for Span with fn write(
  self : Span,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_bytes(self.trace_id)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_bytes(self.span_id)
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.trace_state)
  writer |> @protobuf.async_write_varint(34UL)
  writer |> @protobuf.async_write_bytes(self.parent_span_id)
  writer |> @protobuf.async_write_varint(133UL)
  writer |> @protobuf.async_write_fixed32(self.flags)
  writer |> @protobuf.async_write_varint(42UL)
  writer |> @protobuf.async_write_string(self.name)
  writer |> @protobuf.async_write_varint(48UL)
  writer |> @protobuf.async_write_enum(self.kind.to_enum())
  writer |> @protobuf.async_write_varint(57UL)
  writer |> @protobuf.async_write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.async_write_varint(65UL)
  writer |> @protobuf.async_write_fixed64(self.end_time_unix_nano)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(74UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(80UL)
  writer |> @protobuf.async_write_uint32(self.dropped_attributes_count)
  for item in self.events {
    writer |> @protobuf.async_write_varint(90UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(96UL)
  writer |> @protobuf.async_write_uint32(self.dropped_events_count)
  for item in self.links {
    writer |> @protobuf.async_write_varint(106UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(112UL)
  writer |> @protobuf.async_write_uint32(self.dropped_links_count)
  writer |> @protobuf.async_write_varint(122UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.status))
  @protobuf.AsyncWrite::write(self.status, writer)
}

///|
pub(all) enum Status_StatusCode {
  STATUS_CODE_UNSET
  STATUS_CODE_OK
  STATUS_CODE_ERROR
} derive(Eq)

///|
pub fn Status_StatusCode::to_enum(self : Status_StatusCode) -> @protobuf.Enum {
  match self {
    STATUS_CODE_UNSET => 0
    STATUS_CODE_OK => 1
    STATUS_CODE_ERROR => 2
  }
}

///|
pub fn Status_StatusCode::from_enum(i : @protobuf.Enum) -> Status_StatusCode {
  match i.0 {
    0 => STATUS_CODE_UNSET
    1 => STATUS_CODE_OK
    2 => STATUS_CODE_ERROR
    _ => Default::default()
  }
}

///|
pub impl Default for Status_StatusCode with fn default() -> Status_StatusCode {
  STATUS_CODE_UNSET
}

///|
pub impl @protobuf.Sized for Status_StatusCode with fn size_of(
  self : Status_StatusCode,
) {
  @protobuf.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for Status_StatusCode with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Status_StatusCode raise {
  match json {
    String("STATUS_CODE_UNSET") => STATUS_CODE_UNSET
    String("STATUS_CODE_OK") => STATUS_CODE_OK
    String("STATUS_CODE_ERROR") => STATUS_CODE_ERROR
    Number(0, ..) => STATUS_CODE_UNSET
    Number(1, ..) => STATUS_CODE_OK
    Number(2, ..) => STATUS_CODE_ERROR
    _ => raise JsonDecodeError((path, "Expected a number or string for enum"))
  }
}

///|
pub impl ToJson for Status_StatusCode with fn to_json(self : Status_StatusCode) -> Json {
  match self {
    STATUS_CODE_UNSET => "STATUS_CODE_UNSET"
    STATUS_CODE_OK => "STATUS_CODE_OK"
    STATUS_CODE_ERROR => "STATUS_CODE_ERROR"
  }
}

///|
pub(all) struct Status {
  mut message : String
  mut code : Status_StatusCode
} derive(Eq)

///|
pub impl @protobuf.Sized for Status with fn size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.message)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.code)
  size
}

///|
pub impl Default for Status with fn default() -> Status {
  { message: Default::default(), code: Default::default(), }
}

///|
pub fn Status::new(message : String, code : Status_StatusCode) -> Status {
  { message, code, }
}

///|
pub impl @protobuf.Read for Status with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Status raise {
  let msg : Status = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (2, _) => msg.message = reader |> @protobuf.read_string()
        (3, _) =>
          msg.code = reader
            |> @protobuf.read_enum()
            |> Status_StatusCode::from_enum
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
pub impl @protobuf.Write for Status with fn write(
  self : Status,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.message)
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_enum(self.code.to_enum())
}

///|
pub impl ToJson for Status with fn to_json(self) {
  let json : Map[String, Json] = Map([])
  if self.message != Default::default() {
    json["message"] = self.message.to_json()
  }
  if self.code != Default::default() {
    json["code"] = ToJson::to_json(self.code)
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Status with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Status raise {
  guard json is Object(obj) else {
    raise JsonDecodeError((path, "Expected an object for Status"))
  }
  let message : Status = Default::default()
  for key, value in obj {
    match (key, value) {
      ("message", value) => message.message = @json.from_json(value, path~)
      ("code", value) => message.code = @json.from_json(value, path~)
      (key, _) => raise JsonDecodeError((path, "Unknown field " + key))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Status with fn read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Status raise {
  let msg : Status = Default::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (2, _) => msg.message = reader |> @protobuf.async_read_string()
        (3, _) =>
          msg.code = reader
            |> @protobuf.async_read_enum()
            |> Status_StatusCode::from_enum
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
pub impl @protobuf.AsyncWrite for Status with fn write(
  self : Status,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.message)
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_enum(self.code.to_enum())
}

///|
pub extend SpanFlags with Eq::{equal, not_equal}

///|
pub extend SpanFlags with Default::{default}

///|
pub extend SpanFlags with @protobuf.Sized::{size_of}

///|
pub extend SpanFlags with @json.FromJson::{from_json}

///|
pub extend SpanFlags with ToJson::{to_json}

///|
pub extend TracesData with Eq::{equal, not_equal}

///|
pub extend TracesData with @protobuf.Sized::{size_of}

///|
pub extend TracesData with Default::{default}

///|
pub extend TracesData with @protobuf.Read::{read, read_with_limit}

///|
pub extend TracesData with @protobuf.Write::{write}

///|
pub extend TracesData with ToJson::{to_json}

///|
pub extend TracesData with @json.FromJson::{from_json}

///|
pub extend ResourceSpans with Eq::{equal, not_equal}

///|
pub extend ResourceSpans with @protobuf.Sized::{size_of}

///|
pub extend ResourceSpans with Default::{default}

///|
pub extend ResourceSpans with @protobuf.Read::{read, read_with_limit}

///|
pub extend ResourceSpans with @protobuf.Write::{write}

///|
pub extend ResourceSpans with ToJson::{to_json}

///|
pub extend ResourceSpans with @json.FromJson::{from_json}

///|
pub extend ScopeSpans with Eq::{equal, not_equal}

///|
pub extend ScopeSpans with @protobuf.Sized::{size_of}

///|
pub extend ScopeSpans with Default::{default}

///|
pub extend ScopeSpans with @protobuf.Read::{read, read_with_limit}

///|
pub extend ScopeSpans with @protobuf.Write::{write}

///|
pub extend ScopeSpans with ToJson::{to_json}

///|
pub extend ScopeSpans with @json.FromJson::{from_json}

///|
pub extend Span_SpanKind with Eq::{equal, not_equal}

///|
pub extend Span_SpanKind with Default::{default}

///|
pub extend Span_SpanKind with @protobuf.Sized::{size_of}

///|
pub extend Span_SpanKind with @json.FromJson::{from_json}

///|
pub extend Span_SpanKind with ToJson::{to_json}

///|
pub extend Span_Event with Eq::{equal, not_equal}

///|
pub extend Span_Event with @protobuf.Sized::{size_of}

///|
pub extend Span_Event with Default::{default}

///|
pub extend Span_Event with @protobuf.Read::{read, read_with_limit}

///|
pub extend Span_Event with @protobuf.Write::{write}

///|
pub extend Span_Event with ToJson::{to_json}

///|
pub extend Span_Event with @json.FromJson::{from_json}

///|
pub extend Span_Link with Eq::{equal, not_equal}

///|
pub extend Span_Link with @protobuf.Sized::{size_of}

///|
pub extend Span_Link with Default::{default}

///|
pub extend Span_Link with @protobuf.Read::{read, read_with_limit}

///|
pub extend Span_Link with @protobuf.Write::{write}

///|
pub extend Span_Link with ToJson::{to_json}

///|
pub extend Span_Link with @json.FromJson::{from_json}

///|
pub extend Span with Eq::{equal, not_equal}

///|
pub extend Span with @protobuf.Sized::{size_of}

///|
pub extend Span with Default::{default}

///|
pub extend Span with @protobuf.Read::{read, read_with_limit}

///|
pub extend Span with @protobuf.Write::{write}

///|
pub extend Span with ToJson::{to_json}

///|
pub extend Span with @json.FromJson::{from_json}

///|
pub extend Status_StatusCode with Eq::{equal, not_equal}

///|
pub extend Status_StatusCode with Default::{default}

///|
pub extend Status_StatusCode with @protobuf.Sized::{size_of}

///|
pub extend Status_StatusCode with @json.FromJson::{from_json}

///|
pub extend Status_StatusCode with ToJson::{to_json}

///|
pub extend Status with Eq::{equal, not_equal}

///|
pub extend Status with @protobuf.Sized::{size_of}

///|
pub extend Status with Default::{default}

///|
pub extend Status with @protobuf.Read::{read, read_with_limit}

///|
pub extend Status with @protobuf.Write::{write}

///|
pub extend Status with ToJson::{to_json}

///|
pub extend Status with @json.FromJson::{from_json}
