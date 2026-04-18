///|
/// Trivial meter provider that always produces no-op instruments.
pub struct NoopMeterProvider {}

///|
/// Creates a no-op meter provider.
pub fn NoopMeterProvider::new() -> NoopMeterProvider {
  NoopMeterProvider::{  }
}

///|
/// Converts the no-op provider into the public `MeterProvider` wrapper.
pub fn NoopMeterProvider::into_meter_provider(
  self : NoopMeterProvider,
) -> @metrics.MeterProvider {
  ignore(self)
  @metrics.MeterProvider::noop()
}
