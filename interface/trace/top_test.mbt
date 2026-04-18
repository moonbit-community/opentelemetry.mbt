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

///|
async test "builder events and links preserve dropped attribute counts" {
  let exporter = @sdktrace.InMemorySpanExporter::new()
  let provider = TracerProvider::from_sdk(
    @sdktrace.SdkTracerProvider::builder()
    .with_span_limits(
      @sdktrace.SpanLimits::new(
        max_attributes_per_event=1,
        max_attributes_per_link=1,
      ),
    )
    .with_simple_exporter(exporter.into_span_exporter())
    .build(),
  )
  guard @common.TraceId::from_hex("4bf92f3577b34da6a3ce929d0e0e4736")
    is Some(trace_id) else {
    fail("expected trace id")
  }
  guard @common.SpanId::from_hex("00f067aa0ba902b7") is Some(span_id) else {
    fail("expected span id")
  }
  let span = provider
    .tracer("trace-builder")
    .build(
      SpanBuilder::from_name("root")
      .with_events([
        Event::new("db.query", attributes=[
          @common.KeyValue::new("kept", @common.Value::String("one")),
          @common.KeyValue::new("dropped", @common.Value::String("two")),
        ]),
      ])
      .with_links([
        Link::new(@common.SpanContext::new(trace_id, span_id), attributes=[
          @common.KeyValue::new("kept", @common.Value::String("one")),
          @common.KeyValue::new("dropped", @common.Value::String("two")),
        ]),
      ]),
    )
  span.end_with_timestamp(200L)

  let exported = exporter.finished_spans()
  assert_eq(exported.length(), 1)
  assert_eq(exported[0].events[0].attributes.length(), 1)
  assert_eq(exported[0].events[0].dropped_attributes_count, 1)
  assert_eq(exported[0].links[0].attributes.length(), 1)
  assert_eq(exported[0].links[0].dropped_attributes_count, 1)
}
