///|
// Test target: Verify the root package re-exports the common tracing, span, and baggage helpers.
// Test method: Exercise the root-level helpers directly and assert the noop span behavior plus baggage metadata round-tripping.
test "root package exposes common aliases and global helpers" {
  let tracer = tracer("root")
  let span = tracer.start("span")
  assert_false(span.is_recording())

  let baggage = Baggage::new().insert_with_metadata(
    "user_id",
    "42",
    BaggageMetadata::new("source=test"),
  )
  guard baggage.get_with_metadata("user_id") is Some((value, metadata)) else {
    fail("expected baggage entry")
  }
  assert_eq(value, "42")
  assert_eq(metadata.as_string(), "source=test")
}
