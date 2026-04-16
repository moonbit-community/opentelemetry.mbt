///|
pub struct NoopLoggerProvider {}

///|
pub fn NoopLoggerProvider::new() -> NoopLoggerProvider {
  NoopLoggerProvider::{  }
}

///|
pub fn NoopLoggerProvider::into_logger_provider(
  self : NoopLoggerProvider,
) -> @logs.LoggerProvider {
  ignore(self)
  @logs.LoggerProvider::noop()
}
