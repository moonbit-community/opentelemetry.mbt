///|
/// Trivial logger provider that always produces no-op loggers.
pub struct NoopLoggerProvider {}

///|
/// Creates a no-op logger provider.
pub fn NoopLoggerProvider::new() -> NoopLoggerProvider {
  NoopLoggerProvider::{  }
}

///|
/// Converts the no-op provider into the public `LoggerProvider` wrapper.
pub fn NoopLoggerProvider::into_logger_provider(
  self : NoopLoggerProvider,
) -> @logs.LoggerProvider {
  ignore(self)
  @logs.LoggerProvider::noop()
}
