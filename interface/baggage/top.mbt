///|
let max_key_value_pairs = 64

///|
let max_len_of_all_pairs = 8192

///|
/// Metadata attached to one baggage entry.
///
/// The stored text is trimmed when constructed.
pub struct BaggageMetadata {
  metadata : String
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// One baggage entry together with its metadata payload.
pub struct KeyValueMetadata {
  key : @common.Key
  value : String
  metadata : BaggageMetadata
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Immutable baggage map used for cross-process propagation.
///
/// The implementation enforces OpenTelemetry-style limits on key count and
/// serialized size. Updates that violate those limits leave the baggage
/// unchanged.
pub struct Baggage {
  entries : Map[String, KeyValueMetadata]
  kv_content_len : Int
} derive(Eq, ToJson, Debug)

///|
/// Creates metadata from one text fragment after trimming surrounding
/// whitespace.
pub fn BaggageMetadata::new(metadata : StringView) -> BaggageMetadata {
  { metadata: metadata.trim().to_string() }
}

///|
/// Returns the stored metadata text.
pub fn BaggageMetadata::as_string(self : BaggageMetadata) -> String {
  self.metadata
}

///|
pub impl Default for BaggageMetadata with default() -> BaggageMetadata {
  BaggageMetadata::new("")
}

///|
/// Creates one baggage entry description.
///
/// This only packages the data. Validation happens when the entry is inserted
/// into a `Baggage`.
pub fn KeyValueMetadata::new(
  key : StringView,
  value : StringView,
  metadata? : BaggageMetadata = Default::default(),
) -> KeyValueMetadata {
  { key: @common.Key::new(key), value: value.to_string(), metadata }
}

///|
/// Returns an empty baggage value.
pub fn Baggage::new() -> Baggage {
  { entries: {}, kv_content_len: 0 }
}

///|
fn key_value_metadata_bytes_size(
  key : StringView,
  value : StringView,
  metadata : StringView,
) -> Int {
  let base = key.length() + value.length() + 1
  if metadata == "" {
    base
  } else {
    base + metadata.length() + 1
  }
}

///|
fn is_ascii_lower_or_digit(byte : Byte) -> Bool {
  (byte >= b'a' && byte <= b'z') || (byte >= b'0' && byte <= b'9')
}

///|
fn is_key_valid(key : StringView) -> Bool {
  if key == "" || key.length() > 256 {
    return false
  }
  let mut vendor_start : Int? = None
  for index = 0; index < key.length(); index = index + 1 {
    let byte = key.unsafe_get(index).to_byte()
    let is_allowed_special = byte == b'_' ||
      byte == b'-' ||
      byte == b'*' ||
      byte == b'/'
    if !(is_ascii_lower_or_digit(byte) || is_allowed_special || byte == b'@') {
      return false
    }
    if index == 0 && !is_ascii_lower_or_digit(byte) {
      return false
    }
    if byte == b'@' {
      if vendor_start is Some(_) || index + 14 < key.length() {
        return false
      }
      vendor_start = Some(index)
    } else {
      match vendor_start {
        Some(start) if index == start + 1 && !is_ascii_lower_or_digit(byte) =>
          return false
        _ => ()
      }
    }
  }
  true
}

///|
fn is_value_valid(value : StringView) -> Bool {
  value.length() <= 256 && !value.contains(",") && !value.contains("=")
}

///|
fn baggage_with_entries(entries : Map[String, KeyValueMetadata]) -> Baggage {
  let mut kv_content_len = 0
  for _, entry in entries {
    kv_content_len += key_value_metadata_bytes_size(
      entry.key.as_string(),
      entry.value,
      entry.metadata.as_string(),
    )
  }
  { entries, kv_content_len }
}

///|
/// Inserts one baggage item with empty metadata.
///
/// Invalid keys or values, entry-count overflow, and total-size overflow leave
/// the baggage unchanged.
pub fn Baggage::insert(
  self : Baggage,
  key : StringView,
  value : StringView,
) -> Baggage {
  self.insert_with_metadata(key, value, Default::default())
}

///|
/// Inserts or replaces one baggage item together with explicit metadata.
///
/// Keys are trimmed before validation. Invalid data or limit violations return
/// the original baggage unchanged.
pub fn Baggage::insert_with_metadata(
  self : Baggage,
  key : StringView,
  value : StringView,
  metadata : BaggageMetadata,
) -> Baggage {
  let key = key.trim().to_string()
  let value = value.to_string()
  let metadata_text = metadata.as_string()
  if !is_key_valid(key) || !is_value_valid(value) {
    return self
  }
  let entries = self.entries.copy()
  let new_entry = KeyValueMetadata::new(key, value, metadata~)
  let previous_len = match entries.get(key) {
    Some(previous) =>
      key_value_metadata_bytes_size(
        previous.key.as_string(),
        previous.value,
        previous.metadata.as_string(),
      )
    None => 0
  }
  if entries.get(key) is None && entries.length() >= max_key_value_pairs {
    return self
  }
  let new_len = key_value_metadata_bytes_size(key, value, metadata_text)
  let total_len = self.kv_content_len - previous_len + new_len
  if total_len > max_len_of_all_pairs {
    return self
  }
  entries[key] = new_entry
  baggage_with_entries(entries)
}

///|
/// Returns a new baggage value without `key`.
///
/// Removing a missing key still returns a fresh baggage value with the same
/// contents.
pub fn Baggage::remove(self : Baggage, key : StringView) -> Baggage {
  let entries = self.entries.copy()
  ignore(entries.remove(key.to_string()))
  baggage_with_entries(entries)
}

///|
/// Looks up the string value for `key`.
pub fn Baggage::get(self : Baggage, key : StringView) -> String? {
  self.entries.get(key.to_string()).map(entry => entry.value)
}

///|
/// Looks up the value and metadata for `key`.
pub fn Baggage::get_with_metadata(
  self : Baggage,
  key : StringView,
) -> (String, BaggageMetadata)? {
  self.entries.get(key.to_string()).map(entry => (entry.value, entry.metadata))
}

///|
/// Returns all baggage entries as an array.
///
/// The returned array is detached from the internal map.
pub fn Baggage::entries(self : Baggage) -> Array[KeyValueMetadata] {
  let entries = []
  for _, entry in self.entries {
    entries.push(entry)
  }
  entries
}

///|
/// Returns the current number of baggage entries.
pub fn Baggage::len(self : Baggage) -> Int {
  self.entries.length()
}

///|
/// Returns whether the baggage contains no entries.
pub fn Baggage::is_empty(self : Baggage) -> Bool {
  self.entries.is_empty()
}

///|
pub impl Default for Baggage with default() -> Baggage {
  Baggage::new()
}
