///|
let schema_url = "https://opentelemetry.io/schemas/1.25.0"

///|
fn parse_trace_id(hex : StringView) -> @sdk.TraceId {
  match @sdk.TraceId::from_hex(hex) {
    Some(trace_id) => trace_id
    None => abort("invalid trace id: \{hex}")
  }
}

///|
fn parse_span_id(hex : StringView) -> @sdk.SpanId {
  match @sdk.SpanId::from_hex(hex) {
    Some(span_id) => span_id
    None => abort("invalid span id: \{hex}")
  }
}

///|
fn sampled_trace_flags() -> @sdk.TraceFlags {
  let trace_flags : @sdk.TraceFlags = Default::default()
  trace_flags.with_sampled(true)
}

///|
fn integration_resource(service_name : StringView) -> @resource.Resource {
  @resource.Resource::builder_empty()
  .with_service_name(service_name)
  .with_attribute(
    "deployment.environment.name",
    @sdk.Value::String("integration"),
  )
  .with_schema_url(schema_url)
  .build()
}

///|
fn build_log_exporter(protocol : @otlp.Protocol) -> @otlp.LogExporter {
  let builder = @otlp.LogExporter::builder()
  let builder = match protocol {
    @otlp.Protocol::HttpBinary => builder.with_http()
    @otlp.Protocol::HttpJson => builder.with_protocol(protocol)
    @otlp.Protocol::Grpc => abort("grpc is not part of the integration suite")
  }
  guard builder.build() is Ok(exporter) else {
    abort("expected log exporter to build")
  }
  exporter
}

///|
fn build_log_exporter_from_env() -> @otlp.LogExporter {
  guard @otlp.LogExporter::builder().build() is Ok(exporter) else {
    abort("expected log exporter to build from env")
  }
  exporter
}

///|
fn find_scope_logs(
  data : @otlp_logs.LogsData,
  scope_name : StringView,
) -> @otlp_logs.ScopeLogs? {
  let scope_name = scope_name.to_string()
  for resource_logs in data.resource_logs {
    for scope_logs in resource_logs.scope_logs {
      if scope_logs.scope.name == scope_name {
        return Some(scope_logs)
      }
    }
  }
  None
}

///|
fn find_log_record(
  records : ArrayView[@otlp_logs.LogRecord],
  event_name : StringView,
) -> @otlp_logs.LogRecord? {
  let event_name = event_name.to_string()
  for record in records {
    if record.event_name == event_name {
      return Some(record)
    }
  }
  None
}

///|
fn has_string_attribute(
  attributes : ArrayView[@otlp_common.KeyValue],
  key : StringView,
  expected : StringView,
) -> Bool {
  let key = key.to_string()
  let expected = expected.to_string()
  for attribute in attributes {
    if attribute.key == key {
      match attribute.value.value {
        @otlp_common.AnyValue_Value::StringValue(value) =>
          return value == expected
        _ => return false
      }
    }
  }
  false
}

///|
fn has_int_attribute(
  attributes : ArrayView[@otlp_common.KeyValue],
  key : StringView,
  expected : Int64,
) -> Bool {
  let key = key.to_string()
  let expected_text = expected.to_string()
  for attribute in attributes {
    if attribute.key == key {
      match attribute.value.value {
        @otlp_common.AnyValue_Value::IntValue(value) => return value == expected
        @otlp_common.AnyValue_Value::StringValue(value) =>
          return value == expected_text
        _ => return false
      }
    }
  }
  false
}

///|
fn log_body_is_empty_string(record : @otlp_logs.LogRecord) -> Bool {
  match record.body.value {
    @otlp_common.AnyValue_Value::StringValue(value) => value == ""
    _ => false
  }
}

///|
fn log_body_is_array(record : @otlp_logs.LogRecord, expected_len : Int) -> Bool {
  match record.body.value {
    @otlp_common.AnyValue_Value::ArrayValue(values) =>
      values.values.length() == expected_len
    _ => false
  }
}

///|
fn build_record(target : StringView) -> @ilogs.LogRecord {
  let record = @ilogs.LoggerProvider::noop()
    .logger("unused")
    .create_log_record()
  record.set_target(target)
  record.set_event_name("checkout.failed")
  record.set_timestamp(400L)
  record.set_observed_timestamp(405L)
  record.set_severity_number(@ilogs.Severity::Error3)
  record.set_body(
    @ilogs.AnyValue::Map({
      "message": @ilogs.AnyValue::String("request failed"),
      "retries": @ilogs.AnyValue::Int(2L),
    }),
  )
  record.add_attribute("http.status_code", @ilogs.AnyValue::Int(500L))
  record.add_attribute("feature.flag", @ilogs.AnyValue::Boolean(true))
  record.set_trace_context(
    parse_trace_id("cccccccccccccccccccccccccccccccc"),
    parse_span_id("dddddddddddddddd"),
    trace_flags=Some(sampled_trace_flags()),
  )
  record
}

///|
// Test target: Verify the root logging APIs can batch-export protobuf logs that match the checked-in integration snapshot.
// Test method: Install a batch log exporter, emit a representative log record through the global API, wait for collector output, and compare it to the expected fixture.
async test "batch logs export over http protobuf via root API" {
  let target_name = "integration.logs.protobuf"
  let expected_path = "expected/logs/http_protobuf.json"
  @global.reset_for_test()
  defer @global.reset_for_test()

  let provider = @sdk.logger_provider_builder()
    .with_resource(integration_resource("integration-logs-protobuf"))
    .with_batch_exporter(
      build_log_exporter(@otlp.Protocol::HttpBinary).into_log_exporter(),
      config=@sdklogs.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=20,
      ),
    )
    .build()
  @global.set_logger_provider(@ilogs.LoggerProvider::from_sdk(provider))

  @async.with_task_group(group => {
    @global.spawn_background_tasks(group)

    let logger = @global.logger_provider().logger_with_scope(
      @sdk.InstrumentationScope::builder("integration.logs.logger")
      .with_version("1.0.0")
      .with_schema_url(schema_url)
      .with_attributes([
        @sdk.KeyValue::new("scope.attr", @sdk.Value::String("batch")),
      ])
      .build(),
    )
    logger.emit(build_record(target_name))

    let actual = match
      @support.wait_for_latest_matching_record(
        @support.logs_actual_path,
        data => @support.logs_data_has_scope(data, target_name),
        "log scope \{target_name}",
      ) {
      Ok(actual) => actual
      Err(message) => fail(message)
    }
    let expected : @otlp_logs.LogsData = match
      @support.read_json_file(expected_path) {
      Ok(expected) => expected
      Err(message) => fail(message)
    }
    assert_true(actual == expected)

    match provider.shutdown() {
      Ok(_) => ()
      Err(err) =>
        fail(
          "expected logger provider shutdown to succeed: \{@debug.to_string(err)}",
        )
    }
  })
}

///|
// Test target: Verify force-flushed HTTP/JSON log exports from the root API match the expected integration fixture.
// Test method: Configure an HTTP/JSON log exporter, emit one record with modified severity and body, force flush, and compare the captured output with the fixture.
async test "force flushed logs export over http json via root API" {
  let target_name = "integration.logs.json"
  let expected_path = "expected/logs/http_json.json"
  @global.reset_for_test()
  defer @global.reset_for_test()

  let provider = @sdk.logger_provider_builder()
    .with_resource(integration_resource("integration-logs-json"))
    .with_batch_exporter(
      build_log_exporter(@otlp.Protocol::HttpJson).into_log_exporter(),
      config=@sdklogs.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  @global.set_logger_provider(@ilogs.LoggerProvider::from_sdk(provider))

  let logger = @global.logger_provider().logger_with_scope(
    @sdk.InstrumentationScope::builder("integration.logs.logger")
    .with_version("1.0.0")
    .with_schema_url(schema_url)
    .with_attributes([
      @sdk.KeyValue::new("scope.attr", @sdk.Value::String("json")),
    ])
    .build(),
  )
  let record = build_record(target_name)
  record.set_severity_number(@ilogs.Severity::Warn)
  record.set_severity_text("WARN")
  record.set_body(@ilogs.AnyValue::String("cache warning"))
  record.set_timestamp(500L)
  record.set_observed_timestamp(505L)
  logger.emit(record)

  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected logger provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected logger provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual = match
    @support.wait_for_latest_matching_record(
      @support.logs_actual_path,
      data => @support.logs_data_has_scope(data, target_name),
      "log scope \{target_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let expected : @otlp_logs.LogsData = match
    @support.read_json_file(expected_path) {
    Ok(expected) => expected
    Err(message) => fail(message)
  }
  assert_true(actual == expected)
}

///|
// Test target: Verify the root logger API exports both explicitly populated and defaulted log-record fields with the expected OTLP shape.
// Test method: Emit one fully populated log record and one fallback record, then assert the collected OTLP payload preserves the expected event names, bodies, attributes, and trace linkage.
async test "root logger API exports explicit and default log record fields" {
  let target_name = "integration.logs.root-api"
  let original_endpoint = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT)
  let original_signal_endpoint = @env.get_env_var(
    @otlp.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT,
  )
  let original_protocol = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_PROTOCOL)
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_ENDPOINT,
    original_endpoint,
  )
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT,
    original_signal_endpoint,
  )
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL,
    original_protocol,
  )
  @global.reset_for_test()
  defer @global.reset_for_test()

  let base_endpoint = @support.collector_base_endpoint()
  @env.set_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT, "http://127.0.0.1:1")
  @env.set_env_var(
    @otlp.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT,
    @support.append_signal_path(base_endpoint, "/v1/logs"),
  )
  @env.set_env_var(
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL,
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_JSON,
  )

  let exporter = match @otlp.LogExporter::new() {
    Ok(exporter) => exporter
    Err(err) =>
      fail("expected log exporter new() to succeed: \{@debug.to_string(err)}")
  }
  let provider = @sdk.logger_provider_builder()
    .with_resource(integration_resource("integration-logs-root-api"))
    .with_batch_exporter(
      exporter.into_log_exporter(),
      config=@sdklogs.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  @global.set_logger_provider(@ilogs.LoggerProvider::from_sdk(provider))

  let logger = @otel.logger(
    "integration.logs.root",
    version=Some("1.2.0"),
    schema_url=Some(schema_url),
    attributes=[@sdk.KeyValue::new("scope.attr", @sdk.Value::String("root"))],
  )
  assert_true(
    logger.event_enabled(
      @ilogs.Severity::Info2,
      target_name,
      name=Some("checkout.audit"),
    ),
  )

  let audit = logger.create_log_record()
  audit.set_target(target_name)
  audit.set_event_name("checkout.audit")
  audit.set_timestamp(880L)
  audit.set_observed_timestamp(885L)
  audit.set_severity_number(@ilogs.Severity::Info2)
  audit.set_body(
    @ilogs.AnyValue::ListAny([
      @ilogs.AnyValue::String("accepted"),
      @ilogs.AnyValue::Int(2L),
    ]),
  )
  audit.add_attribute("payment.method", @ilogs.AnyValue::String("card"))
  audit.add_attributes([
    @sdk.KeyValue::new("tenant", @sdk.Value::String("blue")),
    @sdk.KeyValue::new("items", @sdk.Value::Int64(3L)),
  ])
  audit.set_trace_context(
    parse_trace_id("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"),
    parse_span_id("ffffffffffffffff"),
    trace_flags=Some(sampled_trace_flags()),
  )
  logger.emit(audit)

  let fallback = logger.create_log_record()
  fallback.set_target(target_name)
  fallback.set_event_name("checkout.empty")
  fallback.set_timestamp(890L)
  fallback.set_observed_timestamp(891L)
  fallback.set_severity_number(@ilogs.Severity::Error)
  logger.emit(fallback)

  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected logger provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected logger provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual = match
    @support.wait_for_latest_matching_record(
      @support.logs_actual_path,
      data => @support.logs_data_has_scope(data, target_name),
      "log scope \{target_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let scope_logs = match find_scope_logs(actual, target_name) {
    Some(scope_logs) => scope_logs
    None => fail("expected log export to contain scope \{target_name}")
  }
  assert_eq(scope_logs.log_records.length(), 2)

  let audit_record = match
    find_log_record(scope_logs.log_records, "checkout.audit") {
    Some(record) => record
    None => fail("expected checkout.audit log record")
  }
  let fallback_record = match
    find_log_record(scope_logs.log_records, "checkout.empty") {
    Some(record) => record
    None => fail("expected checkout.empty log record")
  }

  assert_eq(audit_record.severity_text, "INFO2")
  assert_true(log_body_is_array(audit_record, 2))
  assert_true(
    has_string_attribute(audit_record.attributes, "payment.method", "card"),
  )
  assert_true(has_string_attribute(audit_record.attributes, "tenant", "blue"))
  assert_true(has_int_attribute(audit_record.attributes, "items", 3L))
  assert_true(audit_record.trace_id.length() > 0)
  assert_true(audit_record.span_id.length() > 0)

  assert_eq(fallback_record.severity_text, "ERROR")
  assert_true(log_body_is_empty_string(fallback_record))
  assert_eq(fallback_record.attributes.length(), 0)
  assert_eq(fallback_record.trace_id.length(), 0)
  assert_eq(fallback_record.span_id.length(), 0)
}

///|
// Test target: Verify log force_flush reports an export timeout when the collector endpoint is delayed.
// Test method: Point the exporter at a delayed local server, force flush one log record, and assert the returned error message and observed request path.
async test "log force_flush times out against a delayed endpoint" {
  let target_name = "integration.logs.timeout"
  @global.reset_for_test()
  defer @global.reset_for_test()

  @async.with_task_group(group => {
    let server = @support.start_delayed_http_server(group)
    let exporter = match
      @otlp.LogExporter::builder()
      .with_http()
      .with_endpoint(@support.append_signal_path(server.endpoint(), "/v1/logs"))
      .with_timeout(100)
      .build() {
      Ok(exporter) => exporter
      Err(err) =>
        fail("expected log exporter build to succeed: \{@debug.to_string(err)}")
    }
    let batch_processor = @sdklogs.BatchLogProcessor::new(
      exporter.into_log_exporter(),
      config=@sdklogs.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    let log_processor = batch_processor.into_log_processor()
    let provider = @sdk.logger_provider_builder()
      .with_resource(integration_resource("integration-logs-timeout"))
      .with_log_processor(log_processor)
      .build()
    @global.set_logger_provider(@ilogs.LoggerProvider::from_sdk(provider))

    let logger = @global.logger_provider().logger("integration.logs.timeout")
    logger.emit(build_record(target_name))

    guard provider.force_flush()
      is Err(@error.OTelSdkError::ExportFailure(_, message)) else {
      fail("expected log force_flush to fail with ExportFailure")
    }
    assert_true(message.contains("logs export timed out after 100ms"))

    let request_path = match server.wait_until_requested() {
      Ok(request_path) => request_path
      Err(message) => fail(message)
    }
    assert_eq(request_path, "/v1/logs")
    assert_eq(server.request_count(), 1)
    assert_eq(server.request_path(), "/v1/logs")

    match log_processor.shutdown() {
      Ok(_) => ()
      Err(err) =>
        fail(
          "expected log processor shutdown to succeed: \{@debug.to_string(err)}",
        )
    }
    assert_eq(server.request_count(), 1)
  })
}

///|
// Test target: Verify the logs-specific endpoint override takes precedence over an invalid global OTLP endpoint.
// Test method: Configure conflicting environment endpoints, export one log record through the environment-backed builder, and compare the captured output with the fixture.
async test "signal-specific log endpoint overrides invalid global endpoint" {
  let target_name = "integration.logs.signal-endpoint"
  let expected_path = "expected/logs/env_signal_endpoint_http_protobuf.json"
  let original_endpoint = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT)
  let original_signal_endpoint = @env.get_env_var(
    @otlp.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT,
  )
  let original_protocol = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_PROTOCOL)
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_ENDPOINT,
    original_endpoint,
  )
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT,
    original_signal_endpoint,
  )
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL,
    original_protocol,
  )
  @global.reset_for_test()
  defer @global.reset_for_test()

  let base_endpoint = @support.collector_base_endpoint()
  @env.set_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT, "http://127.0.0.1:1")
  @env.set_env_var(
    @otlp.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT,
    @support.append_signal_path(base_endpoint, "/v1/logs"),
  )
  @env.set_env_var(
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL,
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_PROTOBUF,
  )

  let provider = @sdk.logger_provider_builder()
    .with_resource(integration_resource("integration-logs-signal-endpoint"))
    .with_batch_exporter(
      build_log_exporter_from_env().into_log_exporter(),
      config=@sdklogs.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  @global.set_logger_provider(@ilogs.LoggerProvider::from_sdk(provider))

  let logger = @global.logger_provider().logger_with_scope(
    @sdk.InstrumentationScope::builder("integration.logs.env")
    .with_version("1.0.1")
    .with_schema_url(schema_url)
    .with_attributes([
      @sdk.KeyValue::new("scope.attr", @sdk.Value::String("env-endpoint")),
    ])
    .build(),
  )
  let record = build_record(target_name)
  record.set_severity_number(@ilogs.Severity::Info2)
  record.set_severity_text("INFO2")
  record.set_body(
    @ilogs.AnyValue::Map({
      "message": @ilogs.AnyValue::String("job accepted"),
      "queue": @ilogs.AnyValue::String("checkout"),
    }),
  )
  record.set_timestamp(710L)
  record.set_observed_timestamp(715L)
  logger.emit(record)

  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected logger provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected logger provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual = match
    @support.wait_for_latest_matching_record(
      @support.logs_actual_path,
      data => @support.logs_data_has_scope(data, target_name),
      "log scope \{target_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let expected : @otlp_logs.LogsData = match
    @support.read_json_file(expected_path) {
    Ok(expected) => expected
    Err(message) => fail(message)
  }
  assert_true(actual == expected)
}
