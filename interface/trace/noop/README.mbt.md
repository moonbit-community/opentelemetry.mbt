# No-op Trace API

This package exposes a trivial tracer provider for tests and for applications
that need an explicit no-op object.

## Method behavior

- `NoopTracerProvider::new()`:
  creates a no-op provider value
- `NoopTracerProvider::into_tracer_provider()`:
  converts the value into the public `interface/trace.TracerProvider` wrapper
- `NoopTracerProvider::tracer(name)`:
  returns a tracer that creates non-recording spans

Those spans still propagate parent span context so downstream propagation logic
can continue to work.
