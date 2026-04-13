///|
pub(all) struct TracezCounts {
  mut spanname : String
  mut latency : Array[UInt]
  mut running : UInt
  mut error : UInt
} derive(Eq)

///|
pub impl @protobuf.Sized for TracezCounts with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.spanname)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = self.latency
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.running)
  size += 1U + @protobuf.size_of(self.error)
  size
}

///|
pub impl Default for TracezCounts with default() -> TracezCounts {
  TracezCounts::{
    spanname: String::default(),
    latency: [],
    running: UInt::default(),
    error: UInt::default(),
  }
}

///|
pub fn TracezCounts::new(
  spanname : String,
  latency : Array[UInt],
  running : UInt,
  error : UInt,
) -> TracezCounts {
  TracezCounts::{ spanname, latency, running, error }
}

///|
pub impl @protobuf.Read for TracezCounts with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> TracezCounts raise {
  let msg = TracezCounts::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.spanname = reader |> @protobuf.read_string()
        (2, _) =>
          msg.latency.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_uint32, None)).iter(),
          )
        (3, _) => msg.running = reader |> @protobuf.read_uint32()
        (4, _) => msg.error = reader |> @protobuf.read_uint32()
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
pub impl @protobuf.Write for TracezCounts with write(
  self : TracezCounts,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_string(self.spanname)
  writer |> @protobuf.write_varint(18UL)
  let size = self.latency.iter().map(@protobuf.size_of).fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.latency {
    writer |> @protobuf.write_uint32(item)
  }
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_uint32(self.running)
  writer |> @protobuf.write_varint(32UL)
  writer |> @protobuf.write_uint32(self.error)
}

///|
pub impl ToJson for TracezCounts with to_json(self) {
  let json : Map[String, Json] = {}
  if self.spanname != Default::default() {
    json["spanname"] = self.spanname.to_json()
  }
  if self.latency != Default::default() {
    json["latency"] = self.latency.to_json()
  }
  if self.running != Default::default() {
    json["running"] = self.running.to_json()
  }
  if self.error != Default::default() {
    json["error"] = self.error.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for TracezCounts with from_json(
  json : Json,
  path : @json.JsonPath,
) -> TracezCounts raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for TracezCounts"))
  }
  let message = TracezCounts::default()
  for key, value in obj {
    match (key, value) {
      ("spanname", value) => message.spanname = @json.from_json(value, path~)
      ("latency", Array(value)) =>
        message.latency = value.map(v => @json.from_json(v, path~))
      ("running", value) => message.running = @json.from_json(value, path~)
      ("error", value) => message.error = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for TracezCounts with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> TracezCounts raise {
  let msg = TracezCounts::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.spanname = reader |> @protobuf.async_read_string()
        (2, _) =>
          msg.latency.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_uint32, None)).iter(),
          )
        (3, _) => msg.running = reader |> @protobuf.async_read_uint32()
        (4, _) => msg.error = reader |> @protobuf.async_read_uint32()
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
pub impl @protobuf.AsyncWrite for TracezCounts with write(
  self : TracezCounts,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_string(self.spanname)
  writer |> @protobuf.async_write_varint(18UL)
  let size = self.latency.iter().map(@protobuf.size_of).fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.latency {
    writer |> @protobuf.async_write_uint32(item)
  }
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_uint32(self.running)
  writer |> @protobuf.async_write_varint(32UL)
  writer |> @protobuf.async_write_uint32(self.error)
}

///|
pub(all) struct LatencyData {
  mut traceid : Bytes
  mut spanid : Bytes
  mut parentid : Bytes
  mut starttime : UInt64
  mut endtime : UInt64
  mut attributes : Array[@v1_dep.KeyValue]
  mut events : Array[@v12.Span_Event]
  mut links : Array[@v12.Span_Link]
} derive(Eq)

///|
pub impl @protobuf.Sized for LatencyData with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.traceid)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.spanid)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.parentid)
      @protobuf.size_of(size) + size
    })
  size += 1U + 8U
  size += 1U + 8U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.events {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.links {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for LatencyData with default() -> LatencyData {
  LatencyData::{
    traceid: Bytes::default(),
    spanid: Bytes::default(),
    parentid: Bytes::default(),
    starttime: UInt64::default(),
    endtime: UInt64::default(),
    attributes: [],
    events: [],
    links: [],
  }
}

///|
pub fn LatencyData::new(
  traceid : Bytes,
  spanid : Bytes,
  parentid : Bytes,
  starttime : UInt64,
  endtime : UInt64,
  attributes : Array[@v1_dep.KeyValue],
  events : Array[@v12.Span_Event],
  links : Array[@v12.Span_Link],
) -> LatencyData {
  LatencyData::{
    traceid,
    spanid,
    parentid,
    starttime,
    endtime,
    attributes,
    events,
    links,
  }
}

///|
pub impl @protobuf.Read for LatencyData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> LatencyData raise {
  let msg = LatencyData::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.traceid = reader |> @protobuf.read_bytes()
        (2, _) => msg.spanid = reader |> @protobuf.read_bytes()
        (3, _) => msg.parentid = reader |> @protobuf.read_bytes()
        (4, _) => msg.starttime = reader |> @protobuf.read_fixed64()
        (5, _) => msg.endtime = reader |> @protobuf.read_fixed64()
        (6, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (7, _) =>
          msg.events.push(
            (reader |> @protobuf.read_message() : @v12.Span_Event),
          )
        (8, _) =>
          msg.links.push((reader |> @protobuf.read_message() : @v12.Span_Link))
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
pub impl @protobuf.Write for LatencyData with write(
  self : LatencyData,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_bytes(self.traceid)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_bytes(self.spanid)
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_bytes(self.parentid)
  writer |> @protobuf.write_varint(33UL)
  writer |> @protobuf.write_fixed64(self.starttime)
  writer |> @protobuf.write_varint(41UL)
  writer |> @protobuf.write_fixed64(self.endtime)
  for item in self.attributes {
    writer |> @protobuf.write_varint(50UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.events {
    writer |> @protobuf.write_varint(58UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.links {
    writer |> @protobuf.write_varint(66UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for LatencyData with to_json(self) {
  let json : Map[String, Json] = {}
  if self.traceid != Default::default() {
    json["traceid"] = @protobuf.base64_encode(self.traceid).to_json()
  }
  if self.spanid != Default::default() {
    json["spanid"] = @protobuf.base64_encode(self.spanid).to_json()
  }
  if self.parentid != Default::default() {
    json["parentid"] = @protobuf.base64_encode(self.parentid).to_json()
  }
  if self.starttime != Default::default() {
    json["starttime"] = self.starttime.to_json()
  }
  if self.endtime != Default::default() {
    json["endtime"] = self.endtime.to_json()
  }
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.events != Default::default() {
    json["events"] = self.events.to_json()
  }
  if self.links != Default::default() {
    json["links"] = self.links.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for LatencyData with from_json(
  json : Json,
  path : @json.JsonPath,
) -> LatencyData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for LatencyData"))
  }
  let message = LatencyData::default()
  for key, value in obj {
    match (key, value) {
      ("traceid", String(value)) =>
        message.traceid = @protobuf.base64_decode(value)
      ("spanid", String(value)) =>
        message.spanid = @protobuf.base64_decode(value)
      ("parentid", String(value)) =>
        message.parentid = @protobuf.base64_decode(value)
      ("starttime", value) => message.starttime = @json.from_json(value, path~)
      ("endtime", value) => message.endtime = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("events", Array(value)) =>
        message.events = value.map(v => @json.from_json(v, path~))
      ("links", Array(value)) =>
        message.links = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for LatencyData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> LatencyData raise {
  let msg = LatencyData::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.traceid = reader |> @protobuf.async_read_bytes()
        (2, _) => msg.spanid = reader |> @protobuf.async_read_bytes()
        (3, _) => msg.parentid = reader |> @protobuf.async_read_bytes()
        (4, _) => msg.starttime = reader |> @protobuf.async_read_fixed64()
        (5, _) => msg.endtime = reader |> @protobuf.async_read_fixed64()
        (6, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (7, _) =>
          msg.events.push(
            (reader |> @protobuf.async_read_message() : @v12.Span_Event),
          )
        (8, _) =>
          msg.links.push(
            (reader |> @protobuf.async_read_message() : @v12.Span_Link),
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
pub impl @protobuf.AsyncWrite for LatencyData with write(
  self : LatencyData,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_bytes(self.traceid)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_bytes(self.spanid)
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_bytes(self.parentid)
  writer |> @protobuf.async_write_varint(33UL)
  writer |> @protobuf.async_write_fixed64(self.starttime)
  writer |> @protobuf.async_write_varint(41UL)
  writer |> @protobuf.async_write_fixed64(self.endtime)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(50UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.events {
    writer |> @protobuf.async_write_varint(58UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.links {
    writer |> @protobuf.async_write_varint(66UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct RunningData {
  mut traceid : Bytes
  mut spanid : Bytes
  mut parentid : Bytes
  mut starttime : UInt64
  mut attributes : Array[@v1_dep.KeyValue]
  mut events : Array[@v12.Span_Event]
  mut links : Array[@v12.Span_Link]
} derive(Eq)

///|
pub impl @protobuf.Sized for RunningData with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.traceid)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.spanid)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.parentid)
      @protobuf.size_of(size) + size
    })
  size += 1U + 8U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.events {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.links {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for RunningData with default() -> RunningData {
  RunningData::{
    traceid: Bytes::default(),
    spanid: Bytes::default(),
    parentid: Bytes::default(),
    starttime: UInt64::default(),
    attributes: [],
    events: [],
    links: [],
  }
}

///|
pub fn RunningData::new(
  traceid : Bytes,
  spanid : Bytes,
  parentid : Bytes,
  starttime : UInt64,
  attributes : Array[@v1_dep.KeyValue],
  events : Array[@v12.Span_Event],
  links : Array[@v12.Span_Link],
) -> RunningData {
  RunningData::{
    traceid,
    spanid,
    parentid,
    starttime,
    attributes,
    events,
    links,
  }
}

///|
pub impl @protobuf.Read for RunningData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> RunningData raise {
  let msg = RunningData::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.traceid = reader |> @protobuf.read_bytes()
        (2, _) => msg.spanid = reader |> @protobuf.read_bytes()
        (3, _) => msg.parentid = reader |> @protobuf.read_bytes()
        (4, _) => msg.starttime = reader |> @protobuf.read_fixed64()
        (5, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (6, _) =>
          msg.events.push(
            (reader |> @protobuf.read_message() : @v12.Span_Event),
          )
        (7, _) =>
          msg.links.push((reader |> @protobuf.read_message() : @v12.Span_Link))
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
pub impl @protobuf.Write for RunningData with write(
  self : RunningData,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_bytes(self.traceid)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_bytes(self.spanid)
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_bytes(self.parentid)
  writer |> @protobuf.write_varint(33UL)
  writer |> @protobuf.write_fixed64(self.starttime)
  for item in self.attributes {
    writer |> @protobuf.write_varint(42UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.events {
    writer |> @protobuf.write_varint(50UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.links {
    writer |> @protobuf.write_varint(58UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for RunningData with to_json(self) {
  let json : Map[String, Json] = {}
  if self.traceid != Default::default() {
    json["traceid"] = @protobuf.base64_encode(self.traceid).to_json()
  }
  if self.spanid != Default::default() {
    json["spanid"] = @protobuf.base64_encode(self.spanid).to_json()
  }
  if self.parentid != Default::default() {
    json["parentid"] = @protobuf.base64_encode(self.parentid).to_json()
  }
  if self.starttime != Default::default() {
    json["starttime"] = self.starttime.to_json()
  }
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.events != Default::default() {
    json["events"] = self.events.to_json()
  }
  if self.links != Default::default() {
    json["links"] = self.links.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for RunningData with from_json(
  json : Json,
  path : @json.JsonPath,
) -> RunningData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for RunningData"))
  }
  let message = RunningData::default()
  for key, value in obj {
    match (key, value) {
      ("traceid", String(value)) =>
        message.traceid = @protobuf.base64_decode(value)
      ("spanid", String(value)) =>
        message.spanid = @protobuf.base64_decode(value)
      ("parentid", String(value)) =>
        message.parentid = @protobuf.base64_decode(value)
      ("starttime", value) => message.starttime = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("events", Array(value)) =>
        message.events = value.map(v => @json.from_json(v, path~))
      ("links", Array(value)) =>
        message.links = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for RunningData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> RunningData raise {
  let msg = RunningData::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.traceid = reader |> @protobuf.async_read_bytes()
        (2, _) => msg.spanid = reader |> @protobuf.async_read_bytes()
        (3, _) => msg.parentid = reader |> @protobuf.async_read_bytes()
        (4, _) => msg.starttime = reader |> @protobuf.async_read_fixed64()
        (5, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (6, _) =>
          msg.events.push(
            (reader |> @protobuf.async_read_message() : @v12.Span_Event),
          )
        (7, _) =>
          msg.links.push(
            (reader |> @protobuf.async_read_message() : @v12.Span_Link),
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
pub impl @protobuf.AsyncWrite for RunningData with write(
  self : RunningData,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_bytes(self.traceid)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_bytes(self.spanid)
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_bytes(self.parentid)
  writer |> @protobuf.async_write_varint(33UL)
  writer |> @protobuf.async_write_fixed64(self.starttime)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(42UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.events {
    writer |> @protobuf.async_write_varint(50UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.links {
    writer |> @protobuf.async_write_varint(58UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ErrorData {
  mut traceid : Bytes
  mut spanid : Bytes
  mut parentid : Bytes
  mut starttime : UInt64
  mut attributes : Array[@v1_dep.KeyValue]
  mut events : Array[@v12.Span_Event]
  mut links : Array[@v12.Span_Link]
  mut status : @v12.Status
} derive(Eq)

///|
pub impl @protobuf.Sized for ErrorData with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.traceid)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.spanid)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.parentid)
      @protobuf.size_of(size) + size
    })
  size += 1U + 8U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.events {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.links {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U +
    ({
      let size = @protobuf.size_of(self.status)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ErrorData with default() -> ErrorData {
  ErrorData::{
    traceid: Bytes::default(),
    spanid: Bytes::default(),
    parentid: Bytes::default(),
    starttime: UInt64::default(),
    attributes: [],
    events: [],
    links: [],
    status: @v12.Status::default(),
  }
}

///|
pub fn ErrorData::new(
  traceid : Bytes,
  spanid : Bytes,
  parentid : Bytes,
  starttime : UInt64,
  attributes : Array[@v1_dep.KeyValue],
  events : Array[@v12.Span_Event],
  links : Array[@v12.Span_Link],
  status : @v12.Status,
) -> ErrorData {
  ErrorData::{
    traceid,
    spanid,
    parentid,
    starttime,
    attributes,
    events,
    links,
    status,
  }
}

///|
pub impl @protobuf.Read for ErrorData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ErrorData raise {
  let msg = ErrorData::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.traceid = reader |> @protobuf.read_bytes()
        (2, _) => msg.spanid = reader |> @protobuf.read_bytes()
        (3, _) => msg.parentid = reader |> @protobuf.read_bytes()
        (4, _) => msg.starttime = reader |> @protobuf.read_fixed64()
        (5, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (6, _) =>
          msg.events.push(
            (reader |> @protobuf.read_message() : @v12.Span_Event),
          )
        (7, _) =>
          msg.links.push((reader |> @protobuf.read_message() : @v12.Span_Link))
        (8, _) =>
          msg.status = (reader |> @protobuf.read_message() : @v12.Status)
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
pub impl @protobuf.Write for ErrorData with write(
  self : ErrorData,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_bytes(self.traceid)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_bytes(self.spanid)
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_bytes(self.parentid)
  writer |> @protobuf.write_varint(33UL)
  writer |> @protobuf.write_fixed64(self.starttime)
  for item in self.attributes {
    writer |> @protobuf.write_varint(42UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.events {
    writer |> @protobuf.write_varint(50UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  for item in self.links {
    writer |> @protobuf.write_varint(58UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(66UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.status))
  @protobuf.Write::write(self.status, writer)
}

///|
pub impl ToJson for ErrorData with to_json(self) {
  let json : Map[String, Json] = {}
  if self.traceid != Default::default() {
    json["traceid"] = @protobuf.base64_encode(self.traceid).to_json()
  }
  if self.spanid != Default::default() {
    json["spanid"] = @protobuf.base64_encode(self.spanid).to_json()
  }
  if self.parentid != Default::default() {
    json["parentid"] = @protobuf.base64_encode(self.parentid).to_json()
  }
  if self.starttime != Default::default() {
    json["starttime"] = self.starttime.to_json()
  }
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.events != Default::default() {
    json["events"] = self.events.to_json()
  }
  if self.links != Default::default() {
    json["links"] = self.links.to_json()
  }
  if self.status != Default::default() {
    json["status"] = self.status.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ErrorData with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ErrorData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ErrorData"))
  }
  let message = ErrorData::default()
  for key, value in obj {
    match (key, value) {
      ("traceid", String(value)) =>
        message.traceid = @protobuf.base64_decode(value)
      ("spanid", String(value)) =>
        message.spanid = @protobuf.base64_decode(value)
      ("parentid", String(value)) =>
        message.parentid = @protobuf.base64_decode(value)
      ("starttime", value) => message.starttime = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("events", Array(value)) =>
        message.events = value.map(v => @json.from_json(v, path~))
      ("links", Array(value)) =>
        message.links = value.map(v => @json.from_json(v, path~))
      ("status", value) => message.status = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ErrorData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ErrorData raise {
  let msg = ErrorData::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.traceid = reader |> @protobuf.async_read_bytes()
        (2, _) => msg.spanid = reader |> @protobuf.async_read_bytes()
        (3, _) => msg.parentid = reader |> @protobuf.async_read_bytes()
        (4, _) => msg.starttime = reader |> @protobuf.async_read_fixed64()
        (5, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (6, _) =>
          msg.events.push(
            (reader |> @protobuf.async_read_message() : @v12.Span_Event),
          )
        (7, _) =>
          msg.links.push(
            (reader |> @protobuf.async_read_message() : @v12.Span_Link),
          )
        (8, _) =>
          msg.status = (reader |> @protobuf.async_read_message() : @v12.Status)
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
pub impl @protobuf.AsyncWrite for ErrorData with write(
  self : ErrorData,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_bytes(self.traceid)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_bytes(self.spanid)
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_bytes(self.parentid)
  writer |> @protobuf.async_write_varint(33UL)
  writer |> @protobuf.async_write_fixed64(self.starttime)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(42UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.events {
    writer |> @protobuf.async_write_varint(50UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  for item in self.links {
    writer |> @protobuf.async_write_varint(58UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(66UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.status))
  @protobuf.AsyncWrite::write(self.status, writer)
}
