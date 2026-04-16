///|
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
