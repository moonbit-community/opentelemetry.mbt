///|
// Test target: Verify baggage injection percent-encodes reserved characters and extraction reverses the encoding.
// Test method: Inject a baggage item containing reserved characters into headers, then extract it and assert the original key and value return intact.
test "baggage propagation percent-encodes reserved characters" {
  let propagator = BaggagePropagator::new()
  let context = @context.Context::empty().with_baggage_item("user,id", "a=b,c")
  let carrier : Map[String, String] = {}
  propagator.inject_context(context, carrier)

  guard carrier.get("baggage") is Some(header) else {
    fail("expected baggage header to be injected")
  }
  assert_eq(header, "user%2Cid=a%3Db%2Cc")

  let extracted = propagator.extract_with_context(Default::default(), carrier)
  assert_eq(extracted.baggage().get("user,id"), Some("a=b,c"))
}

///|
// Test target: Verify baggage extraction ignores entry metadata when only the value is part of the SDK surface.
// Test method: Parse a baggage header containing metadata and assert the extracted baggage keeps the value while discarding metadata.
test "baggage extraction ignores entry metadata" {
  let propagator = BaggagePropagator::new()
  let carrier : Map[String, String] = {}
  carrier["baggage"] = "user_id=1;env=prod"

  let extracted = propagator.extract_with_context(Default::default(), carrier)
  assert_eq(extracted.baggage().get("user_id"), Some("1"))
}

///|
// Test target: Verify baggage extraction preserves existing SDK baggage entries and overwrites matching keys from the carrier.
// Test method: Extract a baggage header into a context with preexisting baggage and assert both merge and overwrite behavior.
test "baggage extraction merges with existing sdk context baggage" {
  let propagator = BaggagePropagator::new()
  let carrier : Map[String, String] = {}
  carrier["baggage"] = "shared=new,remote=added"

  let base = @context.Context::empty()
    .with_baggage_item("existing", "keep")
    .with_baggage_item("shared", "old")
  let extracted = propagator.extract_with_context(base, carrier)
  assert_eq(extracted.baggage().get("existing"), Some("keep"))
  assert_eq(extracted.baggage().get("shared"), Some("new"))
  assert_eq(extracted.baggage().get("remote"), Some("added"))
}

///|
// Test target: Verify trace-context extraction rejects uppercase traceparent identifiers per the wire-format rules.
// Test method: Feed an uppercase traceparent header to the propagator and assert no span context is extracted.
test "trace context extraction rejects uppercase identifiers" {
  let propagator = TraceContextPropagator::new()
  let carrier : Map[String, String] = {}
  carrier["traceparent"] = "00-4BF92F3577B34DA6A3CE929D0E0E4736-00F067AA0BA902B7-01"

  let extracted = propagator.extract_with_context(Default::default(), carrier)
  guard extracted.span_context() is None else {
    fail("expected uppercase traceparent to be rejected")
  }
}

///|
// Test target: Verify future traceparent versions are accepted while unsupported flag bits are masked away.
// Test method: Extract a future-version traceparent with extra suffix data and assert the resulting remote span context keeps only supported fields.
test "trace context extraction accepts future version and masks flags" {
  let propagator = TraceContextPropagator::new()
  let carrier : Map[String, String] = {}
  carrier["traceparent"] = "02-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-09-extra"
  carrier["tracestate"] = "foo=bar"

  let extracted = propagator.extract_with_context(Default::default(), carrier)
  guard extracted.span_context() is Some(span_context) else {
    fail("expected valid span context from future version traceparent")
  }
  assert_true(span_context.is_remote())
  assert_true(span_context.is_sampled())
  assert_eq(span_context.trace_flags().to_hex(), "01")
  assert_eq(span_context.trace_state().to_header(), Some("foo=bar"))
}

///|
// Test target: Verify the map carrier accepts mixed-case inbound header names when used as an extractor.
// Test method: Populate a carrier with mixed-case HTTP header keys and assert trace-context extraction still succeeds.
test "trace context extraction accepts mixed-case header keys" {
  let propagator = TraceContextPropagator::new()
  let carrier : Map[String, String] = {}
  carrier["TraceParent"] = "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
  carrier["TraceState"] = "foo=bar"

  let extracted = propagator.extract_with_context(Default::default(), carrier)
  guard extracted.span_context() is Some(span_context) else {
    fail("expected valid span context from mixed-case header keys")
  }
  assert_true(span_context.is_remote())
  assert_eq(span_context.trace_state().to_header(), Some("foo=bar"))
}
