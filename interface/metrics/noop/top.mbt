///|
/// Trivial meter provider that always produces no-op instruments.
pub struct NoopMeterProvider {} derive(Default)

///|
/// Creates a no-op meter provider.
pub fn NoopMeterProvider::new() -> NoopMeterProvider {
  Default::default()
}

///|
/// Converts the no-op provider into the public `MeterProvider` wrapper.
pub fn NoopMeterProvider::into_meter_provider(
  self : NoopMeterProvider,
) -> @metrics.MeterProvider {
  ignore(self)
  @metrics.MeterProvider::noop()
}
