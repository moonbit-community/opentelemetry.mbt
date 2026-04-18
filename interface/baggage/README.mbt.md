# OpenTelemetry Baggage API

This package models the baggage values that move alongside trace context across
process boundaries.

## Main types

- `BaggageMetadata`: metadata text attached to one baggage item
- `KeyValueMetadata`: one baggage key, value, and metadata triple
- `Baggage`: immutable baggage container

## Limits and validation

The implementation enforces a few constraints when inserting entries:

- at most 64 entries
- at most 8192 bytes across the serialized key/value pairs
- key length at most 256 characters
- value length at most 256 characters

Invalid keys or values, entry-count overflow, and total-size overflow do not
raise errors. The original baggage value is returned unchanged.

## Method behavior

### `BaggageMetadata`

- `BaggageMetadata::new(metadata)`:
  trims surrounding whitespace and stores the remaining text
- `BaggageMetadata::as_string()`:
  returns the stored metadata text
- `Default::default()`:
  returns empty metadata

### `KeyValueMetadata`

- `KeyValueMetadata::new(key, value, metadata?)`:
  packages one baggage entry description; validation happens when the entry is
  inserted into a `Baggage`

### `Baggage`

- `Baggage::new()`:
  returns an empty baggage value
- `Baggage::insert(key, value)`:
  inserts or replaces one entry with empty metadata
- `Baggage::insert_with_metadata(key, value, metadata)`:
  inserts or replaces one entry with metadata; invalid input leaves the baggage
  unchanged
- `Baggage::remove(key)`:
  returns a new baggage value without `key`
- `Baggage::get(key)`:
  returns only the entry value
- `Baggage::get_with_metadata(key)`:
  returns both the value and metadata
- `Baggage::entries()`:
  returns a detached array of entries
- `Baggage::len()`:
  returns the number of entries
- `Baggage::is_empty()`:
  reports whether there are no entries

## When to use this package

Use `interface/baggage` when you need the public OpenTelemetry baggage model.
If you only need a simpler internal baggage map inside the SDK, `sdk/context`
also exposes a lighter-weight baggage representation.
