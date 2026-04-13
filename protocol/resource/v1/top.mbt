///|
pub(all) struct Resource {
  mut attributes : Array[@v1_dep.KeyValue]
  mut dropped_attributes_count : UInt
  mut entity_refs : Array[@v1_dep.EntityRef]
} derive(Eq)

///|
pub impl @protobuf.Sized for Resource with size_of(self) {
  let mut size = 0U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.dropped_attributes_count)
  for s in self.entity_refs {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for Resource with default() -> Resource {
  Resource::{
    attributes: [],
    dropped_attributes_count: UInt::default(),
    entity_refs: [],
  }
}

///|
pub fn Resource::new(
  attributes : Array[@v1_dep.KeyValue],
  dropped_attributes_count : UInt,
  entity_refs : Array[@v1_dep.EntityRef],
) -> Resource {
  Resource::{ attributes, dropped_attributes_count, entity_refs }
}

///|
pub impl @protobuf.Read for Resource with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Resource raise {
  let msg = Resource::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (2, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.read_uint32()
        (3, _) =>
          msg.entity_refs.push(
            (reader |> @protobuf.read_message() : @v1_dep.EntityRef),
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
pub impl @protobuf.Write for Resource with write(
  self : Resource,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_uint32(self.dropped_attributes_count)
  for item in self.entity_refs {
    writer |> @protobuf.write_varint(26UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for Resource with to_json(self) {
  let json : Map[String, Json] = {}
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.dropped_attributes_count != Default::default() {
    json["droppedAttributesCount"] = self.dropped_attributes_count.to_json()
  }
  if self.entity_refs != Default::default() {
    json["entityRefs"] = self.entity_refs.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Resource with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Resource raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Resource"))
  }
  let message = Resource::default()
  for key, value in obj {
    match (key, value) {
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("droppedAttributesCount", value) =>
        message.dropped_attributes_count = @json.from_json(value, path~)
      ("entityRefs", Array(value)) =>
        message.entity_refs = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Resource with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Resource raise {
  let msg = Resource::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (2, _) =>
          msg.dropped_attributes_count = reader |> @protobuf.async_read_uint32()
        (3, _) =>
          msg.entity_refs.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.EntityRef),
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
pub impl @protobuf.AsyncWrite for Resource with write(
  self : Resource,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_uint32(self.dropped_attributes_count)
  for item in self.entity_refs {
    writer |> @protobuf.async_write_varint(26UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}
