///|
pub let traces_actual_path : String = "actual/traces.json"

///|
pub let logs_actual_path : String = "actual/logs.json"

///|
pub let metrics_actual_path : String = "actual/metrics.json"

///|
pub struct DelayedHttpServer {
  endpoint : String
  request_count : Ref[Int]
  request_path : Ref[String]
}

///|
pub fn DelayedHttpServer::endpoint(self : DelayedHttpServer) -> String {
  self.endpoint
}

///|
pub fn DelayedHttpServer::request_count(self : DelayedHttpServer) -> Int {
  self.request_count.val
}

///|
pub fn DelayedHttpServer::request_path(self : DelayedHttpServer) -> String {
  self.request_path.val
}

///|
pub async fn DelayedHttpServer::wait_until_requested(
  self : DelayedHttpServer,
  attempts? : Int = 40,
  sleep_millis? : Int = 10,
) -> Result[String, String] {
  let attempts = if attempts <= 0 { 1 } else { attempts }
  for _ in 0..<attempts {
    if self.request_count.val > 0 {
      return Ok(self.request_path.val)
    }
    @async.sleep(sleep_millis)
  }
  Err("delayed http server did not receive a request in time")
}

///|
/// TODO: Replace this mock timeout helper with a delay proxy in front of a
/// real otelcol once the integration runner can manage both processes.
pub async fn start_delayed_http_server(
  group : @async.TaskGroup[Unit],
  response_delay_millis? : Int = 300,
) -> DelayedHttpServer {
  let server = @http.Server(
    @socket.Addr::parse("127.0.0.1:0") catch {
      _ => abort("expected loopback socket address to parse")
    },
  ) catch {
    _ => abort("expected delayed http server to start")
  }
  let request_count = Ref::new(0)
  let request_path = Ref::new("")
  group.spawn_bg(no_wait=true, () => {
    server.run_forever(
      (request, body, _conn) => {
        request_count.val = request_count.val + 1
        request_path.val = request.path
        ignore(body.read_all())
        @async.sleep(response_delay_millis)
      },
      max_connections=1,
    )
  })
  {
    endpoint: "http://127.0.0.1:\{server.addr.port()}",
    request_count,
    request_path,
  }
}

///|
pub fn restore_env_var(key : String, value : String?) -> Unit {
  match value {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
}

///|
fn strip_trailing_slashes(value : StringView) -> String {
  let mut end = value.length()
  while end > 0 && value[end - 1:end] == "/" {
    end = end - 1
  }
  value[:end].to_string()
}

///|
fn strip_leading_slashes(value : StringView) -> String {
  let mut start = 0
  while start < value.length() && value[start:start + 1] == "/" {
    start = start + 1
  }
  value[start:].to_string()
}

///|
pub fn collector_base_endpoint() -> String {
  match @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT) {
    Some(endpoint) => endpoint.to_string()
    None => @otlp.OTEL_EXPORTER_OTLP_ENDPOINT_DEFAULT
  }
}

///|
pub fn append_signal_path(
  base : StringView,
  signal_path : StringView,
) -> String {
  let base = strip_trailing_slashes(base)
  let signal_path = strip_leading_slashes(signal_path)
  if signal_path == "" {
    base
  } else {
    "\{base}/\{signal_path}"
  }
}

///|
fn[T : @json.FromJson] decode_json_text(text : String) -> Result[T, String] {
  let json = @json.parse(text) catch { _ => return Err("invalid json text") }
  try {
    let value : T = @json.from_json(json)
    Ok(value)
  } catch {
    _ => Err("json did not match the expected schema")
  }
}

///|
fn non_empty_lines(text : String) -> Array[String] {
  let lines = []
  for line in text.split("\n") {
    let builder = StringBuilder::new()
    for _, ch in line {
      if ch != '\u{0000}' {
        builder.write_char(ch)
      }
    }
    let trimmed = builder.to_string().trim()
    if !trimmed.is_empty() {
      lines.push(trimmed.to_string())
    }
  }
  lines
}

///|
pub async fn[T : @json.FromJson] read_json_file(
  path : StringView,
) -> Result[T, String] {
  decode_json_text(@fs.read_file(path).text())
}

///|
pub async fn read_json_value_file(path : StringView) -> Result[Json, String] {
  let text = @fs.read_file(path).text()
  let json = @json.parse(text) catch { _ => return Err("invalid json file") }
  Ok(json)
}

///|
fn[T : @json.FromJson] read_latest_matching_record(
  text : String,
  matches : (T) -> Bool,
  description : String,
) -> Result[T, String] {
  let lines = non_empty_lines(text)
  let mut index = lines.length()
  while index > 0 {
    index = index - 1
    match decode_json_text(lines[index]) {
      Ok(value) if matches(value) => return Ok(value)
      _ => ()
    }
  }
  Err("no matching record found for \{description}")
}

///|
fn read_latest_matching_json(
  text : String,
  matches : (Json) -> Bool,
  description : String,
) -> Result[Json, String] {
  let lines = non_empty_lines(text)
  let mut index = lines.length()
  while index > 0 {
    index = index - 1
    let json = @json.parse(lines[index]) catch { _ => continue }
    if matches(json) {
      return Ok(json)
    }
  }
  Err("no matching json record found for \{description}")
}

///|
pub async fn[T : @json.FromJson] wait_for_latest_matching_record(
  path : StringView,
  matches : (T) -> Bool,
  description : StringView,
  attempts? : Int = 40,
  sleep_millis? : Int = 50,
) -> Result[T, String] {
  let attempts = if attempts <= 0 { 1 } else { attempts }
  let mut last_error = "no matching record found for \{description}"
  for _ in 0..<attempts {
    let text = @fs.read_file(path).text() catch {
      err => {
        last_error = @debug.to_string(err)
        @async.sleep(sleep_millis)
        continue
      }
    }
    match read_latest_matching_record(text, matches, description.to_string()) {
      Ok(value) => return Ok(value)
      Err(err) => last_error = err
    }
    @async.sleep(sleep_millis)
  }
  Err(last_error)
}

///|
pub async fn wait_for_latest_matching_json(
  path : StringView,
  matches : (Json) -> Bool,
  description : StringView,
  attempts? : Int = 40,
  sleep_millis? : Int = 50,
) -> Result[Json, String] {
  let attempts = if attempts <= 0 { 1 } else { attempts }
  let mut last_error = "no matching json record found for \{description}"
  for _ in 0..<attempts {
    let text = @fs.read_file(path).text() catch {
      err => {
        last_error = @debug.to_string(err)
        @async.sleep(sleep_millis)
        continue
      }
    }
    match read_latest_matching_json(text, matches, description.to_string()) {
      Ok(value) => return Ok(value)
      Err(err) => last_error = err
    }
    @async.sleep(sleep_millis)
  }
  Err(last_error)
}

///|
pub fn traces_data_has_scope(
  data : @otlp_trace.TracesData,
  scope_name : StringView,
) -> Bool {
  let scope_name = scope_name.to_string()
  for resource_spans in data.resource_spans {
    for scope_spans in resource_spans.scope_spans {
      if scope_spans.scope.name == scope_name {
        return true
      }
    }
  }
  false
}

///|
pub fn logs_data_has_scope(
  data : @otlp_logs.LogsData,
  scope_name : StringView,
) -> Bool {
  let scope_name = scope_name.to_string()
  for resource_logs in data.resource_logs {
    for scope_logs in resource_logs.scope_logs {
      if scope_logs.scope.name == scope_name {
        return true
      }
    }
  }
  false
}

///|
fn json_scope_matches(
  json : Json,
  resource_key : String,
  scope_key : String,
  scope_name : String,
) -> Bool {
  guard json is Object(obj) else { return false }
  guard obj.get(resource_key) is Some(Array(resources)) else { return false }
  for resource in resources {
    guard resource is Object(resource_obj) else { continue }
    guard resource_obj.get(scope_key) is Some(Array(scopes)) else { continue }
    for scope in scopes {
      guard scope is Object(scope_obj) else { continue }
      guard scope_obj.get("scope") is Some(Object(scope_value)) else {
        continue
      }
      guard scope_value.get("name") is Some(String(name)) else { continue }
      if name == scope_name {
        return true
      }
    }
  }
  false
}

///|
pub fn metrics_json_has_scope(json : Json, scope_name : StringView) -> Bool {
  json_scope_matches(
    json,
    "resourceMetrics",
    "scopeMetrics",
    scope_name.to_string(),
  )
}

///|
pub fn zero_metric_timestamps(json : Json) -> Json {
  match json {
    Object(obj) => {
      let normalized : Map[String, Json] = {}
      for key, value in obj {
        if key == "startTimeUnixNano" || key == "timeUnixNano" {
          normalized[key] = Json::string("0")
        } else {
          normalized[key] = zero_metric_timestamps(value)
        }
      }
      Json::object(normalized)
    }
    Array(values) =>
      Json::array(values.map(value => zero_metric_timestamps(value)))
    _ => json
  }
}
