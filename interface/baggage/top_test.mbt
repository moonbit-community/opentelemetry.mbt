///|
// Test target: Verify baggage keeps valid entries with metadata and drops invalid keys.
// Test method: Insert one valid key and one invalid key, then assert only the valid entry remains and its metadata round-trips.
test "baggage stores metadata and enforces key validity" {
  let baggage = Baggage::new()
    .insert_with_metadata("user_id", "42", BaggageMetadata::new("env=test"))
    .insert("invalid,key", "ignored")

  assert_eq(baggage.len(), 1)
  guard baggage.get_with_metadata("user_id") is Some((value, metadata)) else {
    fail("expected baggage entry")
  }
  assert_eq(value, "42")
  assert_eq(metadata.as_string(), "env=test")
}
