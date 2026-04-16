///|
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
test "baggage extraction ignores entry metadata" {
  let propagator = BaggagePropagator::new()
  let carrier : Map[String, String] = {}
  carrier["baggage"] = "user_id=1;env=prod"

  let extracted = propagator.extract_with_context(Default::default(), carrier)
  assert_eq(extracted.baggage().get("user_id"), Some("1"))
}

///|
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
