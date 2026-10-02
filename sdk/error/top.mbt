///|
/// Error type shared by SDK providers, processors, and exporters.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub(all) enum OTelSdkError {
  AlreadyShutdown
  Timeout(Int)
  InvalidArgument(String)
  InternalFailure(String)
  ExportFailure(String, String)
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub extend OTelSdkError with Debug::{to_repr}

///|
pub extend OTelSdkError with Eq::{not_equal, equal}

///|
pub extend OTelSdkError with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend OTelSdkError with Hash::{hash, hash_combine}

///|
pub extend OTelSdkError with ToJson::{to_json}

///|
/// Common result type for operations that succeed with `Unit`.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub type OTelSdkResult = Result[Unit, OTelSdkError]

///|
/// Convenience helper returning `Ok(())`.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub fn ok() -> OTelSdkResult {
  Ok(())
}

///|
/// Convenience helper returning `AlreadyShutdown`.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub fn already_shutdown() -> OTelSdkResult {
  Err(AlreadyShutdown)
}

///|
/// Convenience helper returning `Timeout`.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub fn timeout(timeout_millis : Int) -> OTelSdkResult {
  Err(Timeout(timeout_millis))
}

///|
/// Convenience helper returning `InvalidArgument`.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub fn invalid_argument(message : String) -> OTelSdkResult {
  Err(InvalidArgument(message))
}

///|
/// Convenience helper returning `InternalFailure`.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub fn internal_failure(message : String) -> OTelSdkResult {
  Err(InternalFailure(message))
}

///|
/// Convenience helper returning `ExportFailure`.
/// Spec: https://opentelemetry.io/docs/specs/otel/error-handling/#basic-error-handling-principles
pub fn export_failure(
  exporter_name : String,
  message : String,
) -> OTelSdkResult {
  Err(ExportFailure(exporter_name, message))
}
