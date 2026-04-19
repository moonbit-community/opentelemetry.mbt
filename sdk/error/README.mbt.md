# SDK Errors

This package defines the shared error type returned by exporters, processors,
and providers.

## Error model

- `AlreadyShutdown`: an operation was attempted after shutdown completed
- `Timeout`: reserved for timeout-aware implementations; the built-in exporters
  and providers in this repository do not currently emit it
- `InvalidArgument`: reserved for invalid user input; the built-in exporters and
  providers in this repository do not currently emit it
- `InternalFailure`: implementation or runtime failure
- `ExportFailure`: exporter-specific failure with exporter name and message

`OTelSdkResult` is the common `Result[Unit, OTelSdkError]` alias used
throughout the SDK packages.
