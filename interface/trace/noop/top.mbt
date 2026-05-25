///|
/// Trivial tracer provider that always produces non-recording spans.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#behavior-of-the-api-in-the-absence-of-an-installed-sdk
pub struct NoopTracerProvider {} derive(Default)

///|
/// Creates a no-op tracer provider.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#behavior-of-the-api-in-the-absence-of-an-installed-sdk
pub fn NoopTracerProvider::new() -> NoopTracerProvider {
  Default::default()
}

///|
/// Converts the no-op provider into the public `TracerProvider` wrapper.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#behavior-of-the-api-in-the-absence-of-an-installed-sdk
pub fn NoopTracerProvider::into_tracer_provider(
  self : NoopTracerProvider,
) -> @trace.TracerProvider {
  ignore(self)
  @trace.TracerProvider::noop()
}

///|
/// Returns a no-op tracer from this no-op provider.
/// Spec: https://opentelemetry.io/docs/specs/otel/trace/api/#behavior-of-the-api-in-the-absence-of-an-installed-sdk
pub fn NoopTracerProvider::tracer(
  self : NoopTracerProvider,
  name : StringView,
) -> @trace.Tracer {
  self.into_tracer_provider().tracer(name)
}
