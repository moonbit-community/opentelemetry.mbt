///|
/// Trivial logger provider that always produces no-op loggers.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/noop/#loggerprovider
pub struct NoopLoggerProvider {} derive(Default)

///|
pub extend NoopLoggerProvider with Default::{default}

///|
/// Creates a no-op logger provider.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/noop/#loggerprovider
pub fn NoopLoggerProvider::new() -> NoopLoggerProvider {
  Default::default()
}

///|
/// Converts the no-op provider into the public `LoggerProvider` wrapper.
/// Spec: https://opentelemetry.io/docs/specs/otel/logs/noop/#loggerprovider
pub fn NoopLoggerProvider::into_logger_provider(
  self : NoopLoggerProvider,
) -> @logs.LoggerProvider {
  ignore(self)
  @logs.LoggerProvider::noop()
}
