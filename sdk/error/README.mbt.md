# SDK Errors

This package defines the shared error type returned by exporters, processors,
and providers.

## Error model

- `AlreadyShutdown`: an operation was attempted after shutdown completed
- `Timeout`: a flush or shutdown path exceeded its timeout budget
- `InvalidArgument`: invalid configuration or invalid user input
- `InternalFailure`: implementation or runtime failure
- `ExportFailure`: exporter-specific failure with exporter name and message

`OTelSdkResult` is the common `Result[Unit, OTelSdkError]` alias used
throughout the SDK packages.
