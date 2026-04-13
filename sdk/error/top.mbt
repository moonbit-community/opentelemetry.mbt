///|
/// Error type shared by SDK providers, processors, and exporters.
pub(all) enum OTelSdkError {
  AlreadyShutdown
  Timeout(Int)
  InvalidArgument(String)
  InternalFailure(String)
  ExportFailure(String, String)
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
/// Common result type for operations that succeed with `Unit`.
pub type OTelSdkResult = Result[Unit, OTelSdkError]

///|
/// Convenience helper returning `Ok(())`.
pub fn ok() -> OTelSdkResult {
  Ok(())
}

///|
/// Convenience helper returning `AlreadyShutdown`.
pub fn already_shutdown() -> OTelSdkResult {
  Err(OTelSdkError::AlreadyShutdown)
}

///|
/// Convenience helper returning `Timeout`.
pub fn timeout(timeout_millis : Int) -> OTelSdkResult {
  Err(OTelSdkError::Timeout(timeout_millis))
}

///|
/// Convenience helper returning `InvalidArgument`.
pub fn invalid_argument(message : String) -> OTelSdkResult {
  Err(OTelSdkError::InvalidArgument(message))
}

///|
/// Convenience helper returning `InternalFailure`.
pub fn internal_failure(message : String) -> OTelSdkResult {
  Err(OTelSdkError::InternalFailure(message))
}

///|
/// Convenience helper returning `ExportFailure`.
pub fn export_failure(
  exporter_name : String,
  message : String,
) -> OTelSdkResult {
  Err(OTelSdkError::ExportFailure(exporter_name, message))
}
