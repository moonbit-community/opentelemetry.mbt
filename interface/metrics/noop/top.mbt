///|
pub struct NoopMeterProvider {}

///|
pub fn NoopMeterProvider::new() -> NoopMeterProvider {
  NoopMeterProvider::{  }
}

///|
pub fn NoopMeterProvider::into_meter_provider(
  self : NoopMeterProvider,
) -> @metrics.MeterProvider {
  ignore(self)
  @metrics.MeterProvider::noop()
}
