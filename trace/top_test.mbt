///|
test "noop tracer propagates parent span context without recording" {
  guard @common.TraceId::from_hex("4bf92f3577b34da6a3ce929d0e0e4736")
    is Some(trace_id) else {
    fail("expected trace id")
  }
  guard @common.SpanId::from_hex("00f067aa0ba902b7") is Some(span_id) else {
    fail("expected span id")
  }
  let parent_span_context = @common.SpanContext::new(trace_id, span_id)
  let tracer = TracerProvider::noop().tracer("noop")
  let span = tracer.start_with_context(
    "child",
    @context.Context::empty().with_remote_span_context(parent_span_context),
  )

  assert_false(span.is_recording())
  assert_eq(
    span.span_context().trace_id().to_hex(),
    parent_span_context.trace_id().to_hex(),
  )
}
