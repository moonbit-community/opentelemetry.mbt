///|
// Test target: Verify the root package re-exports the common tracing, span, and baggage helpers.
// Test method: Exercise the root-level helpers directly and assert the noop span behavior plus baggage metadata round-tripping.
test "root package exposes common aliases and global helpers" {
  let tracer = @opentelemetry.tracer("root")
  let span = tracer.start("span")
  assert_false(span.is_recording())

  let baggage = @opentelemetry.Baggage::new().insert_with_metadata(
    "user_id",
    "42",
    @opentelemetry.BaggageMetadata::new("source=test"),
  )
  guard baggage.get_with_metadata("user_id") is Some((value, metadata)) else {
    fail("expected baggage entry")
  }
  @debug.assert_eq(value, "42")
  @debug.assert_eq(metadata.as_string(), "source=test")
}
