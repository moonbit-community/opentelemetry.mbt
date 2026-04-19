///|
// Test target: Verify the baggage propagator preserves baggage metadata through inject and extract operations.
// Test method: Inject a baggage entry with metadata into a carrier, extract it back, and assert both value and metadata survive.
test "baggage propagator preserves metadata" {
  let context = @context.Context::empty().with_baggage_item(
    "user_id",
    "42",
    metadata=@baggage.BaggageMetadata::new("source=test"),
  )
  let carrier : Map[String, String] = {}
  BaggagePropagator::new().inject_context(context, carrier)

  guard carrier.get("baggage") is Some(header) else {
    fail("expected baggage header")
  }
  assert_true(header.contains("source=test"))

  let extracted = BaggagePropagator::new().extract_with_context(
    Default::default(),
    carrier,
  )
  guard extracted.baggage().get_with_metadata("user_id")
    is Some((value, metadata)) else {
    fail("expected extracted baggage")
  }
  assert_eq(value, "42")
  assert_eq(metadata.as_string(), "source=test")
}

///|
// Test target: Verify baggage extraction preserves existing entries and lets extracted entries override matching keys.
// Test method: Start from a context that already carries baggage, extract a header into it, and assert unmatched entries survive while matching keys are replaced.
test "baggage propagator merges into existing context baggage" {
  let base = @context.Context::empty()
    .with_baggage_item("existing", "keep")
    .with_baggage_item("shared", "old")
  let carrier : Map[String, String] = {}
  carrier["baggage"] = "shared=new,remote=added"

  let extracted = BaggagePropagator::new().extract_with_context(base, carrier)
  assert_eq(extracted.baggage().get("existing"), Some("keep"))
  assert_eq(extracted.baggage().get("shared"), Some("new"))
  assert_eq(extracted.baggage().get("remote"), Some("added"))
}

///|
// Test target: Verify the trace-context propagator round-trips a sampled span context through carriers.
// Test method: Inject a known span context into headers, extract it again, and compare the recovered trace and span identifiers.
test "trace context propagator round trips span context" {
  guard @common.TraceId::from_hex("4bf92f3577b34da6a3ce929d0e0e4736")
    is Some(trace_id) else {
    fail("expected trace id")
  }
  guard @common.SpanId::from_hex("00f067aa0ba902b7") is Some(span_id) else {
    fail("expected span id")
  }
  let trace_flags : @common.TraceFlags = Default::default()
  let span_context = @common.SpanContext::new(
    trace_id,
    span_id,
    trace_flags=trace_flags.with_sampled(true),
  )
  let context = @context.Context::empty().with_span_context(span_context)
  let carrier : Map[String, String] = {}

  TraceContextPropagator::new().inject_context(context, carrier)
  let extracted = TraceContextPropagator::new().extract_with_context(
    Default::default(),
    carrier,
  )

  guard extracted.span_context() is Some(round_tripped) else {
    fail("expected round-tripped span context")
  }
  assert_eq(round_tripped.trace_id().to_hex(), span_context.trace_id().to_hex())
  assert_eq(round_tripped.span_id().to_hex(), span_context.span_id().to_hex())
}

///|
// Test target: Verify the built-in map carrier accepts mixed-case inbound header names.
// Test method: Populate a carrier with HTTP-style mixed-case keys and assert trace context extraction still succeeds.
test "trace context propagator reads mixed-case map keys" {
  let carrier : Map[String, String] = {
    "TraceParent": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01",
    "TraceState": "foo=bar",
  }

  let extracted = TraceContextPropagator::new().extract_with_context(
    Default::default(),
    carrier,
  )
  guard extracted.span_context() is Some(span_context) else {
    fail("expected span context from mixed-case keys")
  }
  assert_true(span_context.is_remote())
  assert_eq(span_context.trace_state().to_header(), Some("foo=bar"))
}
