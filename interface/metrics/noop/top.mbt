///|
/// Trivial meter provider that always produces no-op instruments.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/noop/#meterprovider
pub struct NoopMeterProvider {} derive(Default)

///|
/// Creates a no-op meter provider.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/noop/#meterprovider
pub fn NoopMeterProvider::new() -> NoopMeterProvider {
  Default::default()
}

///|
/// Converts the no-op provider into the public `MeterProvider` wrapper.
/// Spec: https://opentelemetry.io/docs/specs/otel/metrics/noop/#meterprovider
pub fn NoopMeterProvider::into_meter_provider(
  self : NoopMeterProvider,
) -> @metrics.MeterProvider {
  ignore(self)
  @metrics.MeterProvider::noop()
}
