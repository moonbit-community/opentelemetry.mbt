///|
let schema_url = "https://opentelemetry.io/schemas/1.25.0"

///|
fn parse_trace_id(hex : StringView) -> @otel.TraceId {
  match @otel.TraceId::from_hex(hex) {
    Some(trace_id) => trace_id
    None => abort("invalid trace id: \{hex}")
  }
}

///|
fn parse_span_id(hex : StringView) -> @otel.SpanId {
  match @otel.SpanId::from_hex(hex) {
    Some(span_id) => span_id
    None => abort("invalid span id: \{hex}")
  }
}

///|
fn sampled_trace_flags() -> @otel.TraceFlags {
  let trace_flags : @otel.TraceFlags = Default::default()
  trace_flags.with_sampled(true)
}

///|
fn fixed_id_generator() -> @sdktrace.IdGenerator {
  let span_ids = Ref::new([
    parse_span_id("1111111111111111"),
    parse_span_id("2222222222222222"),
    parse_span_id("3333333333333333"),
    parse_span_id("4444444444444444"),
  ])
  @sdktrace.IdGenerator::new(
    () => parse_trace_id("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
    () => {
      if span_ids.val.is_empty() {
        abort("out of fixed span ids")
      }
      let span_id = span_ids.val[0]
      ignore(span_ids.val.remove(0))
      span_id
    },
  )
}

///|
fn integration_resource(service_name : StringView) -> @resource.Resource {
  @resource.Resource::builder_empty()
  .with_service_name(service_name)
  .with_attribute(
    "deployment.environment.name",
    @otel.Value::String("integration"),
  )
  .with_schema_url(schema_url)
  .build()
}

///|
fn remote_link_context() -> @sdk.SpanContext {
  @sdk.SpanContext::new(
    parse_trace_id("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"),
    parse_span_id("9999999999999999"),
    trace_flags=sampled_trace_flags(),
    is_remote=true,
    trace_state=@otel.TraceState::from_header("tenant=blue"),
  )
}

///|
fn build_trace_exporter(protocol : @otlp.Protocol) -> @otlp.SpanExporter {
  let builder = @otlp.SpanExporter::builder()
  let builder = match protocol {
    @otlp.Protocol::HttpBinary => builder.with_http()
    @otlp.Protocol::HttpJson => builder.with_protocol(protocol)
    @otlp.Protocol::Grpc => abort("grpc is not part of the integration suite")
  }
  guard builder.build() is Ok(exporter) else {
    abort("expected span exporter to build")
  }
  exporter
}

///|
fn build_trace_exporter_from_env() -> @otlp.SpanExporter {
  guard @otlp.SpanExporter::builder().build() is Ok(exporter) else {
    abort("expected span exporter to build from env")
  }
  exporter
}

///|
fn find_scope_spans(
  data : @otlp_trace.TracesData,
  scope_name : StringView,
) -> Array[@otlp_trace.ScopeSpans] {
  let scope_name = scope_name.to_string()
  let matches : Array[@otlp_trace.ScopeSpans] = []
  for resource_spans in data.resource_spans {
    for scope_spans in resource_spans.scope_spans {
      if scope_spans.scope.name == scope_name {
        matches.push(scope_spans)
      }
    }
  }
  matches
}

///|
fn find_span(
  spans : ArrayView[@otlp_trace.Span],
  name : StringView,
) -> @otlp_trace.Span? {
  let name = name.to_string()
  for span in spans {
    if span.name == name {
      return Some(span)
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
fn has_bool_attribute(
  attributes : ArrayView[@otlp_common.KeyValue],
  key : StringView,
  expected : Bool,
) -> Bool {
  let key = key.to_string()
  for attribute in attributes {
    if attribute.key == key {
      match attribute.value.value {
        @otlp_common.AnyValue_Value::BoolValue(value) =>
          return value == expected
        _ => return false
      }
    }
  }
  false
}

///|
fn find_event(
  events : ArrayView[@otlp_trace.Span_Event],
  name : StringView,
) -> @otlp_trace.Span_Event? {
  let name = name.to_string()
  for event in events {
    if event.name == name {
      return Some(event)
    }
  }
  None
}

///|
// Test target: Verify the root tracing APIs can batch-export protobuf traces that match the checked-in integration snapshot.
// Test method: Install a batch exporter, emit nested spans through the global API, wait for the collector output, and compare it to the expected JSON fixture.
async test "batch traces export over http protobuf via root API" {
  let scope_name = "integration.traces.protobuf"
  let expected_path = "expected/traces/http_protobuf.json"
  @global.reset_for_test()
  defer @global.reset_for_test()

  let provider = @sdk.tracer_provider_builder()
    .with_resource(integration_resource("integration-traces-protobuf"))
    .with_id_generator(fixed_id_generator())
    .with_batch_exporter(
      build_trace_exporter(@otlp.Protocol::HttpBinary).into_span_exporter(),
      config=@sdk.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=20,
      ),
    )
    .build()
  @sdk.set_tracer_provider(provider)

  @async.with_task_group(group => {
    @sdk.spawn_background_tasks(group)

    let tracer = @otel.tracer(
      scope_name,
      version=Some("1.0.0"),
      schema_url=Some(schema_url),
      attributes=[
        @otel.KeyValue::new("scope.attr", @otel.Value::String("batch")),
      ],
    )
    let root = tracer.build(
      tracer
      .span_builder("http.request")
      .with_kind(@trace.SpanKind::Server)
      .with_start_time(100L)
      .with_attributes([
        @otel.KeyValue::new("http.method", @otel.Value::String("GET")),
      ])
      .with_events([
        @trace.Event::new("connected", timestamp_unix_nano=150L, attributes=[
          @otel.KeyValue::new("net.transport", @otel.Value::String("tcp")),
        ]),
      ])
      .with_links([
        @trace.Link::new(remote_link_context(), attributes=[
          @otel.KeyValue::new("linked", @otel.Value::String("true")),
        ]),
      ]),
    )
    let child = tracer.build_with_context(
      tracer
      .span_builder("db.query")
      .with_kind(@trace.SpanKind::Client)
      .with_start_time(170L)
      .with_attributes([
        @otel.KeyValue::new("db.system", @otel.Value::String("postgresql")),
      ]),
      root.context(),
    )
    child.add_event_with_timestamp("db.rows", 180L, attributes=[
      @otel.KeyValue::new("db.rows", @otel.Value::Int64(3L)),
    ])
    child.end_with_timestamp(190L)

    root.set_status(@trace.Status::error(description=Some("timeout")))
    root.end_with_timestamp(200L)

    let actual = match
      @support.wait_for_latest_matching_record(
        @support.traces_actual_path,
        data => @support.traces_data_has_scope(data, scope_name),
        "trace scope \{scope_name}",
      ) {
      Ok(actual) => actual
      Err(message) => fail(message)
    }
    let expected : @otlp_trace.TracesData = match
      @support.read_json_file(expected_path) {
      Ok(expected) => expected
      Err(message) => fail(message)
    }
    assert_true(actual == expected)

    match provider.shutdown() {
      Ok(_) => ()
      Err(err) =>
        fail(
          "expected tracer provider shutdown to succeed: \{@debug.to_string(err)}",
        )
    }
  })
}

///|
// Test target: Verify force-flushed HTTP/JSON trace exports from the root API match the expected integration fixture.
// Test method: Configure an HTTP/JSON exporter, emit one span, force flush and shut down, then compare the collected output with the fixture.
async test "force flushed traces export over http json via root API" {
  let scope_name = "integration.traces.json"
  let expected_path = "expected/traces/http_json.json"
  @global.reset_for_test()
  defer @global.reset_for_test()

  let provider = @sdk.tracer_provider_builder()
    .with_resource(integration_resource("integration-traces-json"))
    .with_id_generator(fixed_id_generator())
    .with_batch_exporter(
      build_trace_exporter(@otlp.Protocol::HttpJson).into_span_exporter(),
      config=@sdk.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  @sdk.set_tracer_provider(provider)

  let tracer = @otel.tracer(
    scope_name,
    version=Some("1.0.0"),
    schema_url=Some(schema_url),
    attributes=[@otel.KeyValue::new("scope.attr", @otel.Value::String("json"))],
  )
  let span = tracer.build(
    tracer
    .span_builder("cache.lookup")
    .with_kind(@trace.SpanKind::Internal)
    .with_start_time(300L)
    .with_attributes([@otel.KeyValue::new("cache.hit", @otel.Value::Bool(true))]),
  )
  span.add_event_with_timestamp("lookup.complete", 320L)
  span.end_with_timestamp(330L)

  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected tracer provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected tracer provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual = match
    @support.wait_for_latest_matching_record(
      @support.traces_actual_path,
      data => @support.traces_data_has_scope(data, scope_name),
      "trace scope \{scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let expected : @otlp_trace.TracesData = match
    @support.read_json_file(expected_path) {
    Ok(expected) => expected
    Err(message) => fail(message)
  }
  assert_true(actual == expected)
}

///|
// Test target: Verify explicit builder settings override invalid environment defaults and preserve rich nested span structure in exported traces.
// Test method: Build an exporter with explicit endpoint and headers, emit nested spans plus links and errors, then assert the collected OTLP payload contains the expected relationships and attributes.
async test "trace builder overrides env and exports nested spans through root APIs" {
  let scope_name = "integration.traces.builder-overrides"
  let original_endpoint = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT)
  let original_protocol = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_PROTOCOL)
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_ENDPOINT,
    original_endpoint,
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
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL,
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_JSON,
  )

  let exporter = match
    @otlp.SpanExporter::builder()
    .with_http()
    .with_endpoint(@support.append_signal_path(base_endpoint, "/v1/traces"))
    .with_timeout(2500)
    .with_headers({
      "x-integration-test": "traces-builder",
      "x-scope": "builder-overrides",
    })
    .build() {
    Ok(exporter) => exporter
    Err(err) =>
      fail("expected trace exporter build to succeed: \{@debug.to_string(err)}")
  }
  let provider = @sdk.tracer_provider_builder()
    .with_resource(integration_resource("integration-traces-builder-overrides"))
    .with_id_generator(fixed_id_generator())
    .with_batch_exporter(
      exporter.into_span_exporter(),
      config=@sdk.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  @sdk.set_tracer_provider(provider)

  let tracer = @otel.tracer(
    scope_name,
    version=Some("1.1.0"),
    schema_url=Some(schema_url),
    attributes=[
      @otel.KeyValue::new("scope.attr", @otel.Value::String("builder")),
    ],
  )
  let root = tracer.start("queue.receive")
  assert_true(root.is_recording())
  assert_true(!root.has_ended())
  root.update_name("queue.receive.process")
  root.set_attribute(
    @otel.KeyValue::new("messaging.system", @otel.Value::String("rabbitmq")),
  )
  root.set_attributes([
    @otel.KeyValue::new("messaging.batch.message_count", @otel.Value::Int64(2L)),
    @otel.KeyValue::new("component", @otel.Value::String("worker")),
  ])
  root.record_error("decode failed")
  root.add_link(remote_link_context(), attributes=[
    @otel.KeyValue::new("retry", @otel.Value::Bool(false)),
  ])

  let worker = tracer.start_with_context("job.handle", root.context())
  worker.add_event_with_timestamp("job.started", 820L)
  worker.end_with_timestamp(830L)

  ignore(
    tracer.in_span_with_builder(
      tracer
      .span_builder("job.persist")
      .with_kind(@trace.SpanKind::Client)
      .with_start_time(831L)
      .with_attributes([
        @otel.KeyValue::new("db.system", @otel.Value::String("sqlite")),
      ]),
      root.context(),
      persist_context => {
        let cache = tracer.build_with_context(
          tracer
          .span_builder("job.cache")
          .with_kind(@trace.SpanKind::Internal)
          .with_start_time(832L),
          persist_context,
        )
        cache.end_with_timestamp(833L)
      },
    ),
  )

  root.set_status(@trace.Status::error(description=Some("root failed")))
  root.end_with_timestamp(840L)
  assert_true(root.has_ended())

  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected tracer provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected tracer provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual : @otlp_trace.TracesData = match
    @support.wait_for_latest_matching_record(
      @support.traces_actual_path,
      data => @support.traces_data_has_scope(data, scope_name),
      "trace scope \{scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let scope_spans = find_scope_spans(actual, scope_name)
  if scope_spans.is_empty() {
    fail("expected trace export to contain scope \{scope_name}")
  }
  assert_eq(scope_spans[0].scope.version, "1.1.0")
  assert_true(
    has_string_attribute(
      scope_spans[0].scope.attributes,
      "scope.attr",
      "builder",
    ),
  )
  let spans : Array[@otlp_trace.Span] = []
  for item in scope_spans {
    for span in item.spans {
      spans.push(span)
    }
  }
  assert_eq(spans.length(), 4)

  let root_span : @otlp_trace.Span = match
    find_span(spans, "queue.receive.process") {
    Some(span) => span
    None => fail("expected exported root span")
  }
  let worker_span : @otlp_trace.Span = match find_span(spans, "job.handle") {
    Some(span) => span
    None => fail("expected exported worker span")
  }
  let persist_span : @otlp_trace.Span = match find_span(spans, "job.persist") {
    Some(span) => span
    None => fail("expected exported persist span")
  }
  let cache_span : @otlp_trace.Span = match find_span(spans, "job.cache") {
    Some(span) => span
    None => fail("expected exported cache span")
  }

  assert_true(
    has_string_attribute(root_span.attributes, "messaging.system", "rabbitmq"),
  )
  assert_true(
    has_int_attribute(root_span.attributes, "messaging.batch.message_count", 2L),
  )
  assert_true(has_string_attribute(root_span.attributes, "component", "worker"))
  assert_eq(root_span.links.length(), 1)
  assert_true(has_bool_attribute(root_span.links[0].attributes, "retry", false))
  assert_true(
    root_span.status.code == @otlp_trace.Status_StatusCode::STATUS_CODE_ERROR,
  )
  assert_eq(root_span.status.message, "root failed")

  let exception_event : @otlp_trace.Span_Event = match
    find_event(root_span.events, "exception") {
    Some(event) => event
    None => fail("expected root span exception event")
  }
  assert_true(
    has_string_attribute(
      exception_event.attributes,
      "exception.message",
      "decode failed",
    ),
  )

  assert_true(worker_span.parent_span_id == root_span.span_id)
  assert_eq(worker_span.events.length(), 1)
  assert_eq(worker_span.events[0].name, "job.started")
  assert_true(persist_span.parent_span_id == root_span.span_id)
  assert_true(cache_span.parent_span_id == persist_span.span_id)
  assert_true(
    has_string_attribute(persist_span.attributes, "db.system", "sqlite"),
  )
}

///|
// Test target: Verify trace force_flush reports an export timeout when the collector endpoint does not respond in time.
// Test method: Point the exporter at a delayed local server, force flush one span, and assert the returned error message and observed request path.
async test "trace force_flush times out against a delayed endpoint" {
  let scope_name = "integration.traces.timeout"
  @global.reset_for_test()
  defer @global.reset_for_test()

  @async.with_task_group(group => {
    let server = @support.start_delayed_http_server(group)
    let exporter = match
      @otlp.SpanExporter::builder()
      .with_http()
      .with_endpoint(
        @support.append_signal_path(server.endpoint(), "/v1/traces"),
      )
      .with_timeout(100)
      .build() {
      Ok(exporter) => exporter
      Err(err) =>
        fail(
          "expected trace exporter build to succeed: \{@debug.to_string(err)}",
        )
    }
    let batch_processor = @sdktrace.BatchSpanProcessor::new(
      exporter.into_span_exporter(),
      config=@sdk.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    let span_processor = batch_processor.into_span_processor()
    let provider = @sdk.tracer_provider_builder()
      .with_resource(integration_resource("integration-traces-timeout"))
      .with_span_processor(span_processor)
      .build()
    @sdk.set_tracer_provider(provider)

    let tracer = @otel.tracer(scope_name)
    let span = tracer.start("checkout.timeout")
    span.end()

    guard provider.force_flush()
      is Err(@error.OTelSdkError::ExportFailure(_, message)) else {
      fail("expected trace force_flush to fail with ExportFailure")
    }
    assert_true(message.contains("traces export timed out after 100ms"))

    let request_path = match server.wait_until_requested() {
      Ok(request_path) => request_path
      Err(message) => fail(message)
    }
    assert_eq(request_path, "/v1/traces")
    assert_eq(server.request_count(), 1)
    assert_eq(server.request_path(), "/v1/traces")

    match span_processor.shutdown() {
      Ok(_) => ()
      Err(err) =>
        fail(
          "expected trace span processor shutdown to succeed: \{@debug.to_string(err)}",
        )
    }
    assert_eq(server.request_count(), 1)
  })
}

///|
// Test target: Verify the signal-specific trace endpoint overrides an invalid global endpoint from the environment.
// Test method: Configure conflicting global and traces-specific endpoints, export one span through the environment-backed builder, and compare the captured output with the fixture.
async test "signal-specific trace endpoint overrides invalid global endpoint" {
  let scope_name = "integration.traces.signal-endpoint"
  let expected_path = "expected/traces/env_signal_endpoint_http_json.json"
  let original_endpoint = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT)
  let original_signal_endpoint = @env.get_env_var(
    @otlp.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
  )
  let original_protocol = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_PROTOCOL)
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_ENDPOINT,
    original_endpoint,
  )
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
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
    @otlp.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
    @support.append_signal_path(base_endpoint, "/v1/traces"),
  )
  @env.set_env_var(
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL,
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_JSON,
  )

  let provider = @sdk.tracer_provider_builder()
    .with_resource(integration_resource("integration-traces-signal-endpoint"))
    .with_id_generator(fixed_id_generator())
    .with_batch_exporter(
      build_trace_exporter_from_env().into_span_exporter(),
      config=@sdk.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  @sdk.set_tracer_provider(provider)

  let tracer = @otel.tracer(
    scope_name,
    version=Some("1.0.1"),
    schema_url=Some(schema_url),
    attributes=[
      @otel.KeyValue::new("scope.attr", @otel.Value::String("env-endpoint")),
    ],
  )
  let span = tracer.build(
    tracer
    .span_builder("queue.publish")
    .with_kind(@trace.SpanKind::Producer)
    .with_start_time(610L)
    .with_attributes([
      @otel.KeyValue::new("messaging.system", @otel.Value::String("kafka")),
    ]),
  )
  span.add_event_with_timestamp("publish.acked", 620L, attributes=[
    @otel.KeyValue::new("partition", @otel.Value::Int64(7L)),
  ])
  span.end_with_timestamp(630L)

  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected tracer provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected tracer provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual = match
    @support.wait_for_latest_matching_record(
      @support.traces_actual_path,
      data => @support.traces_data_has_scope(data, scope_name),
      "trace scope \{scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let expected : @otlp_trace.TracesData = match
    @support.read_json_file(expected_path) {
    Ok(expected) => expected
    Err(message) => fail(message)
  }
  assert_true(actual == expected)
}
