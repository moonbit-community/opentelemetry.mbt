# No-op Logs API

This package exposes a trivial logger provider for tests and for applications
that need an explicit no-op object.

## Method behavior

- `NoopLoggerProvider::new()`:
  creates a no-op provider value
- `NoopLoggerProvider::into_logger_provider()`:
  converts the value into the public `interface/logs.LoggerProvider` wrapper

Loggers created from this provider never emit records.
