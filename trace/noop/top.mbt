///|
pub struct NoopTracerProvider {}

///|
pub fn NoopTracerProvider::new() -> NoopTracerProvider {
  NoopTracerProvider::{  }
}

///|
pub fn NoopTracerProvider::into_tracer_provider(
  self : NoopTracerProvider,
) -> @trace.TracerProvider {
  ignore(self)
  @trace.TracerProvider::noop()
}

///|
pub fn NoopTracerProvider::tracer(
  self : NoopTracerProvider,
  name : StringView,
) -> @trace.Tracer {
  self.into_tracer_provider().tracer(name)
}
