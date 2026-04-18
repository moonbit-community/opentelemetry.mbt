///|
/// Trivial tracer provider that always produces non-recording spans.
pub struct NoopTracerProvider {}

///|
/// Creates a no-op tracer provider.
pub fn NoopTracerProvider::new() -> NoopTracerProvider {
  NoopTracerProvider::{  }
}

///|
/// Converts the no-op provider into the public `TracerProvider` wrapper.
pub fn NoopTracerProvider::into_tracer_provider(
  self : NoopTracerProvider,
) -> @trace.TracerProvider {
  ignore(self)
  @trace.TracerProvider::noop()
}

///|
/// Returns a no-op tracer from this no-op provider.
pub fn NoopTracerProvider::tracer(
  self : NoopTracerProvider,
  name : StringView,
) -> @trace.Tracer {
  self.into_tracer_provider().tracer(name)
}
