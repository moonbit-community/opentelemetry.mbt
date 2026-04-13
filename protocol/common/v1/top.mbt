///|
pub(all) struct AnyValue {
  mut value : AnyValue_Value
} derive(Eq)

///|
pub(all) enum AnyValue_Value {
  StringValue(String)
  BoolValue(Bool)
  IntValue(Int64)
  DoubleValue(Double)
  ArrayValue(ArrayValue)
  KvlistValue(KeyValueList)
  BytesValue(Bytes)
  StringValueStrindex(Int)
  NotSet
} derive(Eq)

///|
pub impl Default for AnyValue_Value with default() -> AnyValue_Value {
  NotSet
}

///|
pub impl @json.FromJson for AnyValue_Value with from_json(
  json : Json,
  path : @json.JsonPath,
) -> AnyValue_Value raise {
  try AnyValue_Value::StringValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try AnyValue_Value::BoolValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try AnyValue_Value::IntValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try AnyValue_Value::DoubleValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try AnyValue_Value::ArrayValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try AnyValue_Value::KvlistValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try AnyValue_Value::BytesValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try
    AnyValue_Value::StringValueStrindex(json |> @json.from_json(path~))
  catch {
    _ => ()
  } noraise {
    v => return v
  }
  AnyValue_Value::NotSet
}

///|
pub impl ToJson for AnyValue_Value with to_json(self : AnyValue_Value) -> Json {
  match self {
    AnyValue_Value::StringValue(v) => v.to_json()
    AnyValue_Value::BoolValue(v) => v.to_json()
    AnyValue_Value::IntValue(v) => v.to_json()
    AnyValue_Value::DoubleValue(v) => v.to_json()
    AnyValue_Value::ArrayValue(v) => v.to_json()
    AnyValue_Value::KvlistValue(v) => v.to_json()
    AnyValue_Value::BytesValue(v) => v.to_json()
    AnyValue_Value::StringValueStrindex(v) => v.to_json()
    AnyValue_Value::NotSet => Json::null()
  }
}

///|
pub impl @protobuf.Sized for AnyValue with size_of(self) {
  let mut size = 0U
  match self.value {
    StringValue(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    BoolValue(v) => size += 1U + @protobuf.size_of(v)
    IntValue(v) => size += 1U + @protobuf.size_of(v)
    DoubleValue(_) => size += 1U + 8U
    ArrayValue(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    KvlistValue(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    BytesValue(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    StringValueStrindex(v) => size += 1U + @protobuf.size_of(v)
    NotSet => ()
  }
  size
}

///|
pub impl Default for AnyValue with default() -> AnyValue {
  AnyValue::{ value: AnyValue_Value::NotSet }
}

///|
pub fn AnyValue::new(
  value? : AnyValue_Value = AnyValue_Value::NotSet,
) -> AnyValue {
  AnyValue::{ value, }
}

///|
pub impl @protobuf.Read for AnyValue with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> AnyValue raise {
  let msg = AnyValue::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.value = reader
            |> @protobuf.read_string()
            |> AnyValue_Value::StringValue
        (2, _) =>
          msg.value = reader
            |> @protobuf.read_bool()
            |> AnyValue_Value::BoolValue
        (3, _) =>
          msg.value = reader
            |> @protobuf.read_int64()
            |> AnyValue_Value::IntValue
        (4, _) =>
          msg.value = reader
            |> @protobuf.read_double()
            |> AnyValue_Value::DoubleValue
        (5, _) =>
          msg.value = (reader |> @protobuf.read_message() : ArrayValue)
            |> AnyValue_Value::ArrayValue
        (6, _) =>
          msg.value = (reader |> @protobuf.read_message() : KeyValueList)
            |> AnyValue_Value::KvlistValue
        (7, _) =>
          msg.value = reader
            |> @protobuf.read_bytes()
            |> AnyValue_Value::BytesValue
        (8, _) =>
          msg.value = reader
            |> @protobuf.read_int32()
            |> AnyValue_Value::StringValueStrindex
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
pub impl @protobuf.Write for AnyValue with write(
  self : AnyValue,
  writer : &@protobuf.Writer,
) -> Unit raise {
  match self.value {
    AnyValue_Value::StringValue(v) => {
      writer |> @protobuf.write_varint(10UL)
      writer |> @protobuf.write_string(v)
    }
    AnyValue_Value::BoolValue(v) => {
      writer |> @protobuf.write_varint(16UL)
      writer |> @protobuf.write_bool(v)
    }
    AnyValue_Value::IntValue(v) => {
      writer |> @protobuf.write_varint(24UL)
      writer |> @protobuf.write_int64(v)
    }
    AnyValue_Value::DoubleValue(v) => {
      writer |> @protobuf.write_varint(33UL)
      writer |> @protobuf.write_double(v)
    }
    AnyValue_Value::ArrayValue(v) => {
      writer |> @protobuf.write_varint(42UL)
      writer |> @protobuf.write_uint32(@protobuf.size_of(v))
      @protobuf.Write::write(v, writer)
    }
    AnyValue_Value::KvlistValue(v) => {
      writer |> @protobuf.write_varint(50UL)
      writer |> @protobuf.write_uint32(@protobuf.size_of(v))
      @protobuf.Write::write(v, writer)
    }
    AnyValue_Value::BytesValue(v) => {
      writer |> @protobuf.write_varint(58UL)
      writer |> @protobuf.write_bytes(v)
    }
    AnyValue_Value::StringValueStrindex(v) => {
      writer |> @protobuf.write_varint(64UL)
      writer |> @protobuf.write_int32(v)
    }
    AnyValue_Value::NotSet => ()
  }
}

///|
pub impl ToJson for AnyValue with to_json(self) {
  let json : Map[String, Json] = {}
  match self.value {
    NotSet => ()
    StringValue(v) => json["stringValue"] = v.to_json()
    BoolValue(v) => json["boolValue"] = v.to_json()
    IntValue(v) => json["intValue"] = v.to_json()
    DoubleValue(v) => json["doubleValue"] = v.to_json()
    ArrayValue(v) => json["arrayValue"] = v.to_json()
    KvlistValue(v) => json["kvlistValue"] = v.to_json()
    BytesValue(v) => json["bytesValue"] = v.to_json()
    StringValueStrindex(v) => json["stringValueStrindex"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for AnyValue with from_json(
  json : Json,
  path : @json.JsonPath,
) -> AnyValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for AnyValue"))
  }
  let message = AnyValue::default()
  for key, value in obj {
    match (key, value) {
      ("stringValue", value) => message.value = @json.from_json(value, path~)
      ("boolValue", value) => message.value = @json.from_json(value, path~)
      ("intValue", value) => message.value = @json.from_json(value, path~)
      ("doubleValue", value) => message.value = @json.from_json(value, path~)
      ("arrayValue", value) => message.value = @json.from_json(value, path~)
      ("kvlistValue", value) => message.value = @json.from_json(value, path~)
      ("bytesValue", value) => message.value = @json.from_json(value, path~)
      ("stringValueStrindex", value) =>
        message.value = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for AnyValue with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> AnyValue raise {
  let msg = AnyValue::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.value = reader
            |> @protobuf.async_read_string()
            |> AnyValue_Value::StringValue
        (2, _) =>
          msg.value = reader
            |> @protobuf.async_read_bool()
            |> AnyValue_Value::BoolValue
        (3, _) =>
          msg.value = reader
            |> @protobuf.async_read_int64()
            |> AnyValue_Value::IntValue
        (4, _) =>
          msg.value = reader
            |> @protobuf.async_read_double()
            |> AnyValue_Value::DoubleValue
        (5, _) =>
          msg.value = (reader |> @protobuf.async_read_message() : ArrayValue)
            |> AnyValue_Value::ArrayValue
        (6, _) =>
          msg.value = (reader |> @protobuf.async_read_message() : KeyValueList)
            |> AnyValue_Value::KvlistValue
        (7, _) =>
          msg.value = reader
            |> @protobuf.async_read_bytes()
            |> AnyValue_Value::BytesValue
        (8, _) =>
          msg.value = reader
            |> @protobuf.async_read_int32()
            |> AnyValue_Value::StringValueStrindex
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
pub impl @protobuf.AsyncWrite for AnyValue with write(
  self : AnyValue,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  match self.value {
    AnyValue_Value::StringValue(v) => {
      writer |> @protobuf.async_write_varint(10UL)
      writer |> @protobuf.async_write_string(v)
    }
    AnyValue_Value::BoolValue(v) => {
      writer |> @protobuf.async_write_varint(16UL)
      writer |> @protobuf.async_write_bool(v)
    }
    AnyValue_Value::IntValue(v) => {
      writer |> @protobuf.async_write_varint(24UL)
      writer |> @protobuf.async_write_int64(v)
    }
    AnyValue_Value::DoubleValue(v) => {
      writer |> @protobuf.async_write_varint(33UL)
      writer |> @protobuf.async_write_double(v)
    }
    AnyValue_Value::ArrayValue(v) => {
      writer |> @protobuf.async_write_varint(42UL)
      writer |> @protobuf.async_write_uint32(@protobuf.size_of(v))
      @protobuf.AsyncWrite::write(v, writer)
    }
    AnyValue_Value::KvlistValue(v) => {
      writer |> @protobuf.async_write_varint(50UL)
      writer |> @protobuf.async_write_uint32(@protobuf.size_of(v))
      @protobuf.AsyncWrite::write(v, writer)
    }
    AnyValue_Value::BytesValue(v) => {
      writer |> @protobuf.async_write_varint(58UL)
      writer |> @protobuf.async_write_bytes(v)
    }
    AnyValue_Value::StringValueStrindex(v) => {
      writer |> @protobuf.async_write_varint(64UL)
      writer |> @protobuf.async_write_int32(v)
    }
    AnyValue_Value::NotSet => ()
  }
}

///|
pub(all) struct ArrayValue {
  mut values : Array[AnyValue]
} derive(Eq)

///|
pub impl @protobuf.Sized for ArrayValue with size_of(self) {
  let mut size = 0U
  for s in self.values {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for ArrayValue with default() -> ArrayValue {
  ArrayValue::{ values: [] }
}

///|
pub fn ArrayValue::new(values : Array[AnyValue]) -> ArrayValue {
  ArrayValue::{ values, }
}

///|
pub impl @protobuf.Read for ArrayValue with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ArrayValue raise {
  let msg = ArrayValue::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.values.push((reader |> @protobuf.read_message() : AnyValue))
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
pub impl @protobuf.Write for ArrayValue with write(
  self : ArrayValue,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.values {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for ArrayValue with to_json(self) {
  let json : Map[String, Json] = {}
  if self.values != Default::default() {
    json["values"] = self.values.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ArrayValue with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ArrayValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ArrayValue"))
  }
  let message = ArrayValue::default()
  for key, value in obj {
    match (key, value) {
      ("values", Array(value)) =>
        message.values = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ArrayValue with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ArrayValue raise {
  let msg = ArrayValue::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.values.push((reader |> @protobuf.async_read_message() : AnyValue))
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
pub impl @protobuf.AsyncWrite for ArrayValue with write(
  self : ArrayValue,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.values {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct KeyValueList {
  mut values : Array[KeyValue]
} derive(Eq)

///|
pub impl @protobuf.Sized for KeyValueList with size_of(self) {
  let mut size = 0U
  for s in self.values {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for KeyValueList with default() -> KeyValueList {
  KeyValueList::{ values: [] }
}

///|
pub fn KeyValueList::new(values : Array[KeyValue]) -> KeyValueList {
  KeyValueList::{ values, }
}

///|
pub impl @protobuf.Read for KeyValueList with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> KeyValueList raise {
  let msg = KeyValueList::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.values.push((reader |> @protobuf.read_message() : KeyValue))
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
pub impl @protobuf.Write for KeyValueList with write(
  self : KeyValueList,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.values {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for KeyValueList with to_json(self) {
  let json : Map[String, Json] = {}
  if self.values != Default::default() {
    json["values"] = self.values.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for KeyValueList with from_json(
  json : Json,
  path : @json.JsonPath,
) -> KeyValueList raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for KeyValueList"))
  }
  let message = KeyValueList::default()
  for key, value in obj {
    match (key, value) {
      ("values", Array(value)) =>
        message.values = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for KeyValueList with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> KeyValueList raise {
  let msg = KeyValueList::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.values.push((reader |> @protobuf.async_read_message() : KeyValue))
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
pub impl @protobuf.AsyncWrite for KeyValueList with write(
  self : KeyValueList,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.values {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct KeyValue {
  mut key : String
  mut value : AnyValue
  mut key_strindex : Int
} derive(Eq)

///|
pub impl @protobuf.Sized for KeyValue with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.key)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.value)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.key_strindex)
  size
}

///|
pub impl Default for KeyValue with default() -> KeyValue {
  KeyValue::{
    key: String::default(),
    value: AnyValue::default(),
    key_strindex: Int::default(),
  }
}

///|
pub fn KeyValue::new(
  key : String,
  value : AnyValue,
  key_strindex : Int,
) -> KeyValue {
  KeyValue::{ key, value, key_strindex }
}

///|
pub impl @protobuf.Read for KeyValue with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> KeyValue raise {
  let msg = KeyValue::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.key = reader |> @protobuf.read_string()
        (2, _) => msg.value = (reader |> @protobuf.read_message() : AnyValue)
        (3, _) => msg.key_strindex = reader |> @protobuf.read_int32()
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
pub impl @protobuf.Write for KeyValue with write(
  self : KeyValue,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_string(self.key)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.value))
  @protobuf.Write::write(self.value, writer)
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_int32(self.key_strindex)
}

///|
pub impl ToJson for KeyValue with to_json(self) {
  let json : Map[String, Json] = {}
  if self.key != Default::default() {
    json["key"] = self.key.to_json()
  }
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  if self.key_strindex != Default::default() {
    json["keyStrindex"] = self.key_strindex.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for KeyValue with from_json(
  json : Json,
  path : @json.JsonPath,
) -> KeyValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for KeyValue"))
  }
  let message = KeyValue::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      ("keyStrindex", value) =>
        message.key_strindex = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for KeyValue with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> KeyValue raise {
  let msg = KeyValue::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.key = reader |> @protobuf.async_read_string()
        (2, _) =>
          msg.value = (reader |> @protobuf.async_read_message() : AnyValue)
        (3, _) => msg.key_strindex = reader |> @protobuf.async_read_int32()
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
pub impl @protobuf.AsyncWrite for KeyValue with write(
  self : KeyValue,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_string(self.key)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.value))
  @protobuf.AsyncWrite::write(self.value, writer)
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_int32(self.key_strindex)
}

///|
pub(all) struct InstrumentationScope {
  mut name : String
  mut version : String
  mut attributes : Array[KeyValue]
  mut dropped_attributes_count : UInt
} derive(Eq)

///|
pub impl @protobuf.Sized for InstrumentationScope with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.name)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.version)
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
pub impl Default for InstrumentationScope with default() -> InstrumentationScope {
  InstrumentationScope::{
    name: String::default(),
    version: String::default(),
    attributes: [],
    dropped_attributes_count: UInt::default(),
  }
}

///|
pub fn InstrumentationScope::new(
  name : String,
  version : String,
  attributes : Array[KeyValue],
  dropped_attributes_count : UInt,
) -> InstrumentationScope {
  InstrumentationScope::{ name, version, attributes, dropped_attributes_count }
}

///|
pub impl @protobuf.Read for InstrumentationScope with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> InstrumentationScope raise {
  let msg = InstrumentationScope::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.name = reader |> @protobuf.read_string()
        (2, _) => msg.version = reader |> @protobuf.read_string()
        (3, _) =>
          msg.attributes.push((reader |> @protobuf.read_message() : KeyValue))
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
pub impl @protobuf.Write for InstrumentationScope with write(
  self : InstrumentationScope,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_string(self.name)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.version)
  for item in self.attributes {
    writer |> @protobuf.write_varint(26UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(32UL)
  writer |> @protobuf.write_uint32(self.dropped_attributes_count)
}

///|
pub impl ToJson for InstrumentationScope with to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.version != Default::default() {
    json["version"] = self.version.to_json()
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
pub impl @json.FromJson for InstrumentationScope with from_json(
  json : Json,
  path : @json.JsonPath,
) -> InstrumentationScope raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for InstrumentationScope"),
    )
  }
  let message = InstrumentationScope::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("version", value) => message.version = @json.from_json(value, path~)
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("droppedAttributesCount", value) =>
        message.dropped_attributes_count = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for InstrumentationScope with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> InstrumentationScope raise {
  let msg = InstrumentationScope::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.name = reader |> @protobuf.async_read_string()
        (2, _) => msg.version = reader |> @protobuf.async_read_string()
        (3, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : KeyValue),
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
pub impl @protobuf.AsyncWrite for InstrumentationScope with write(
  self : InstrumentationScope,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_string(self.name)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.version)
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(26UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(32UL)
  writer |> @protobuf.async_write_uint32(self.dropped_attributes_count)
}

///|
pub(all) struct EntityRef {
  mut schema_url : String
  mut type_ : String
  mut id_keys : Array[String]
  mut description_keys : Array[String]
} derive(Eq)

///|
pub impl @protobuf.Sized for EntityRef with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.schema_url)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.type_)
      @protobuf.size_of(size) + size
    })
  for s in self.id_keys {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  for s in self.description_keys {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for EntityRef with default() -> EntityRef {
  EntityRef::{
    schema_url: String::default(),
    type_: String::default(),
    id_keys: [],
    description_keys: [],
  }
}

///|
pub fn EntityRef::new(
  schema_url : String,
  type_ : String,
  id_keys : Array[String],
  description_keys : Array[String],
) -> EntityRef {
  EntityRef::{ schema_url, type_, id_keys, description_keys }
}

///|
pub impl @protobuf.Read for EntityRef with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> EntityRef raise {
  let msg = EntityRef::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.schema_url = reader |> @protobuf.read_string()
        (2, _) => msg.type_ = reader |> @protobuf.read_string()
        (3, _) => msg.id_keys.push(reader |> @protobuf.read_string())
        (4, _) => msg.description_keys.push(reader |> @protobuf.read_string())
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
pub impl @protobuf.Write for EntityRef with write(
  self : EntityRef,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_string(self.schema_url)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.type_)
  for item in self.id_keys {
    writer |> @protobuf.write_varint(26UL)
    writer |> @protobuf.write_string(item)
  }
  for item in self.description_keys {
    writer |> @protobuf.write_varint(34UL)
    writer |> @protobuf.write_string(item)
  }
}

///|
pub impl ToJson for EntityRef with to_json(self) {
  let json : Map[String, Json] = {}
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  if self.type_ != Default::default() {
    json["type"] = self.type_.to_json()
  }
  if self.id_keys != Default::default() {
    json["idKeys"] = self.id_keys.to_json()
  }
  if self.description_keys != Default::default() {
    json["descriptionKeys"] = self.description_keys.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for EntityRef with from_json(
  json : Json,
  path : @json.JsonPath,
) -> EntityRef raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for EntityRef"))
  }
  let message = EntityRef::default()
  for key, value in obj {
    match (key, value) {
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      ("type", value) => message.type_ = @json.from_json(value, path~)
      ("idKeys", Array(value)) =>
        message.id_keys = value.map(v => @json.from_json(v, path~))
      ("descriptionKeys", Array(value)) =>
        message.description_keys = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for EntityRef with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> EntityRef raise {
  let msg = EntityRef::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.schema_url = reader |> @protobuf.async_read_string()
        (2, _) => msg.type_ = reader |> @protobuf.async_read_string()
        (3, _) => msg.id_keys.push(reader |> @protobuf.async_read_string())
        (4, _) =>
          msg.description_keys.push(reader |> @protobuf.async_read_string())
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
pub impl @protobuf.AsyncWrite for EntityRef with write(
  self : EntityRef,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_string(self.schema_url)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.type_)
  for item in self.id_keys {
    writer |> @protobuf.async_write_varint(26UL)
    writer |> @protobuf.async_write_string(item)
  }
  for item in self.description_keys {
    writer |> @protobuf.async_write_varint(34UL)
    writer |> @protobuf.async_write_string(item)
  }
}
