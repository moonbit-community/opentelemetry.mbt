///|
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
