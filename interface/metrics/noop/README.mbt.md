# No-op Metrics API

This package exposes a trivial meter provider for tests and for applications
that need an explicit no-op object.

## Method behavior

- `NoopMeterProvider::new()`:
  creates a no-op provider value
- `NoopMeterProvider::into_meter_provider()`:
  converts the value into the public `interface/metrics.MeterProvider` wrapper

Meters created from this provider return no-op instruments.
