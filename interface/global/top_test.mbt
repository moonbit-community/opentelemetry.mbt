///|
// Test target: Verify the interface-level global wrapper can replace the active tracer provider with an SDK-backed implementation.
// Test method: Install an in-memory SDK provider, create a span through the global API, and assert the exporter receives it.
async test "global tracer provider can be replaced from sdk-backed wrapper" {
  reset_for_test()

  let exporter = @sdktrace.InMemorySpanExporter::new()
  let provider = @trace.TracerProvider::from_sdk(
    @sdktrace.SdkTracerProvider::builder()
    .with_simple_exporter(exporter.into_span_exporter())
    .build(),
  )
  set_tracer_provider(provider)

  let span = tracer("global-root").start("root-span")
  span.end()

  assert_eq(exporter.finished_spans().length(), 1)
  reset_for_test()
}
