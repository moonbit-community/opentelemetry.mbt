///|
/// Returns the current Unix time in nanoseconds.
pub fn now_unix_nano() -> Int64 {
  (@env.now() * 1_000_000UL).reinterpret_as_int64()
}

///|
/// Returns the last path segment, defaulting to `"moonbit"` when no segment is
/// present.
pub fn basename(path : StringView) -> String {
  let mut start = 0
  for i, ch in path {
    if ch is '/' || ch is '\\' {
      start = i + 1
    }
  }
  let name = path[start:].to_string()
  if name == "" {
    "moonbit"
  } else {
    name
  }
}

///|
/// Reads an environment variable from the host process.
pub fn getenv(key : StringView) -> String? {
  @env.get_env_var(key.to_string())
}
