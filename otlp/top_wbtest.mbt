///|
fn restore_env_var(key : String, value : String?) -> Unit {
  match value {
    Some(value) => @env.set_env_var(key, value)
    None => @env.unset_env_var(key)
  }
}

///|
fn sample_resource() -> @resource.Resource {
  @resource.Resource::builder_empty()
  .with_service_name("otlp-test")
  .with_attribute("deployment.environment", @common.Value::String("test"))
  .with_schema_url("https://opentelemetry.io/schemas/1.0.0")
  .build()
}

///|
fn sample_scope() -> @common.InstrumentationScope {
  @common.InstrumentationScope::builder("otlp-test")
  .with_version("1.2.3")
  .with_schema_url("https://opentelemetry.io/schemas/1.0.0")
  .with_attributes([
    @common.KeyValue::new("scope.attr", @common.Value::String("demo")),
  ])
  .build()
}

///|
fn sample_span_context(
  trace_id_hex : String,
  span_id_hex : String,
  is_remote? : Bool = false,
) -> @common.SpanContext {
  let trace_id = match @common.TraceId::from_hex(trace_id_hex) {
    Some(trace_id) => trace_id
    None => @common.TraceId::invalid()
  }
  let span_id = match @common.SpanId::from_hex(span_id_hex) {
    Some(span_id) => span_id
    None => @common.SpanId::invalid()
  }
  let trace_flags : @common.TraceFlags = Default::default()
  @common.SpanContext::new(
    trace_id,
    span_id,
    trace_flags=trace_flags.with_sampled(true),
    is_remote~,
    trace_state=@common.TraceState::from_header("tenant=blue"),
  )
}

///|
async fn sample_span_data() -> @sdktrace.SpanData {
  let exporter = @sdktrace.InMemorySpanExporter::new()
  let provider = @sdktrace.SdkTracerProvider::builder()
    .with_resource(sample_resource())
    .with_simple_exporter(exporter.into_span_exporter())
    .build()
  let tracer = provider.tracer(
    "otlp-test",
    version=Some("1.2.3"),
    schema_url=Some("https://opentelemetry.io/schemas/1.0.0"),
    attributes=[
      @common.KeyValue::new("scope.attr", @common.Value::String("demo")),
    ],
  )
  let span = tracer.start(
    "request",
    kind=@sdktrace.SpanKind::Server,
    start_time_unix_nano=100L,
  )
  span.set_attribute("http.method", @common.Value::String("GET"))
  span.add_event(
    "connected",
    attributes=[
      @common.KeyValue::new("net.transport", @common.Value::String("tcp")),
    ],
    timestamp_unix_nano=150L,
  )
  span.add_link(
    sample_span_context(
      "4bf92f3577b34da6a3ce929d0e0e4737",
      "00f067aa0ba902b8",
      is_remote=true,
    ),
    attributes=[@common.KeyValue::new("linked", @common.Value::String("yes"))],
  )
  span.set_status(@sdktrace.Status::error(description=Some("boom")))
  span.end(end_time_unix_nano=200L)
  exporter.finished_spans()[0]
}

///|
fn sample_log_record() -> @sdklogs.LogRecord {
  sample_log_record_with_timestamp(300L, 301L)
}

///|
fn sample_log_record_with_timestamp(
  timestamp_unix_nano : Int64,
  observed_timestamp_unix_nano : Int64,
) -> @sdklogs.LogRecord {
  @sdklogs.LogRecord::new(
    @sdklogs.AnyValue::Map([
      @sdklogs.KeyValue::new(
        "message",
        @sdklogs.AnyValue::String("request failed"),
      ),
      @sdklogs.KeyValue::new(
        "codes",
        @sdklogs.AnyValue::Array([
          @sdklogs.AnyValue::Int64(7L),
          @sdklogs.AnyValue::Int64(9L),
        ]),
      ),
    ]),
    severity_number=Some(@sdklogs.SeverityNumber::Error3),
    severity_text=Some("ERROR3"),
    event_name=Some("checkout.failed"),
    target=Some("my-target"),
    attributes=[
      @sdklogs.KeyValue::new("http.status_code", @sdklogs.AnyValue::Int64(500L)),
    ],
    trace_context=Some(
      sample_span_context(
        "4bf92f3577b34da6a3ce929d0e0e4736", "00f067aa0ba902b7",
      ),
    ),
    timestamp_unix_nano~,
    observed_timestamp_unix_nano~,
    resource=sample_resource(),
    instrumentation_scope=sample_scope(),
  )
}

///|
fn sample_counter_metric() -> @sdkmetrics.MetricData {
  let metrics = sample_metrics()
  for metric in metrics {
    if metric.name == "requests" {
      return metric
    }
  }
  metrics[0]
}

///|
fn sample_histogram_metric() -> @sdkmetrics.MetricData {
  let metrics = sample_metrics()
  for metric in metrics {
    if metric.name == "latency" {
      return metric
    }
  }
  metrics[0]
}

///|
fn sample_metrics() -> Array[@sdkmetrics.MetricData] {
  let provider = @sdkmetrics.SdkMeterProvider::builder()
    .with_resource(sample_resource())
    .build()
  let meter = provider.meter(
    "otlp-test",
    version=Some("1.2.3"),
    schema_url=Some("https://opentelemetry.io/schemas/1.0.0"),
    attributes=[
      @common.KeyValue::new("scope.attr", @common.Value::String("demo")),
    ],
  )
  let counter = meter
    .counter("requests")
    .with_description("request count")
    .with_unit("1")
    .build()
  counter.add(5, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/health")),
  ])
  let histogram = meter
    .histogram("latency")
    .with_description("request latency")
    .with_unit("ms")
    .build()
  histogram.record(1.0, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/health")),
  ])
  histogram.record(3.5, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/health")),
  ])
  histogram.record(8.0, attributes=[
    @common.KeyValue::new("route", @common.Value::String("/health")),
  ])
  provider.manual_reader().collect()
}

///|
fn decode_trace_request(
  bytes : Bytes,
) -> Result[@collectortrace.ExportTraceServiceRequest, String] {
  try {
    let reader = @protobuf.BytesReader::from_bytes(bytes)
    let request : @collectortrace.ExportTraceServiceRequest = @protobuf.Read::read(
      reader,
    )
    Ok(request)
  } catch {
    err => Err(@debug.to_string(err))
  }
}

///|
test "span exporter builder resolves env precedence" {
  let original_endpoint = @env.get_env_var(OTEL_EXPORTER_OTLP_ENDPOINT)
  let original_signal_endpoint = @env.get_env_var(
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
  )
  let original_headers = @env.get_env_var(OTEL_EXPORTER_OTLP_HEADERS)
  let original_signal_headers = @env.get_env_var(
    OTEL_EXPORTER_OTLP_TRACES_HEADERS,
  )
  defer {
    restore_env_var(OTEL_EXPORTER_OTLP_ENDPOINT, original_endpoint)
    restore_env_var(
      OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
      original_signal_endpoint,
    )
    restore_env_var(OTEL_EXPORTER_OTLP_HEADERS, original_headers)
    restore_env_var(OTEL_EXPORTER_OTLP_TRACES_HEADERS, original_signal_headers)
  }

  @env.set_env_var(OTEL_EXPORTER_OTLP_ENDPOINT, "http://collector:4318/root/")
  @env.set_env_var(OTEL_EXPORTER_OTLP_HEADERS, "authorization=Basic%20abc")
  @env.set_env_var(OTEL_EXPORTER_OTLP_TRACES_HEADERS, "x-trace=1")
  guard SpanExporter::builder().build() is Ok(exporter) else {
    fail("expected span exporter build to succeed")
  }
  assert_eq(exporter.config.endpoint, "http://collector:4318/root/v1/traces")
  assert_eq(
    exporter.config.headers.get_from_string("authorization"),
    Some("Basic abc"),
  )
  assert_eq(exporter.config.headers.get_from_string("x-trace"), Some("1"))

  @env.set_env_var(
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT,
    "http://collector:4318/custom",
  )
  guard SpanExporter::builder().build() is Ok(signal_exporter) else {
    fail("expected signal-specific endpoint to build")
  }
  assert_eq(signal_exporter.config.endpoint, "http://collector:4318/custom")
}

///|
test "metric exporter resolves temporality preference" {
  let original = @env.get_env_var(
    OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE,
  )
  defer restore_env_var(
    OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE,
    original,
  )
  @env.set_env_var(
    OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE,
    "lowmemory",
  )
  guard MetricExporter::builder().build() is Ok(exporter) else {
    fail("expected metric exporter build to succeed")
  }
  assert_true(exporter.temporality() == @sdkmetrics.Temporality::LowMemory)
}

///|
test "span exporter builder resolves http json protocol" {
  let original = @env.get_env_var(OTEL_EXPORTER_OTLP_PROTOCOL)
  defer restore_env_var(OTEL_EXPORTER_OTLP_PROTOCOL, original)

  @env.set_env_var(OTEL_EXPORTER_OTLP_PROTOCOL, "http/json")
  guard SpanExporter::builder().build() is Ok(env_exporter) else {
    fail("expected http/json env protocol to build")
  }
  assert_true(env_exporter.config.protocol == Protocol::HttpJson)

  guard SpanExporter::builder().with_http().build() is Ok(binary_exporter) else {
    fail("expected with_http to force binary protocol")
  }
  assert_true(binary_exporter.config.protocol == Protocol::HttpBinary)

  guard SpanExporter::builder().with_protocol(Protocol::HttpJson).build()
    is Ok(json_exporter) else {
    fail("expected explicit http/json protocol to build")
  }
  assert_true(json_exporter.config.protocol == Protocol::HttpJson)
}

///|
async test "trace request encodes span data" {
  let request = build_trace_request([sample_span_data()])
  assert_eq(request.resource_spans.length(), 1)
  let resource_spans = request.resource_spans[0]
  assert_eq(resource_spans.schema_url, "https://opentelemetry.io/schemas/1.0.0")
  assert_eq(resource_spans.scope_spans.length(), 1)
  let scope_spans = resource_spans.scope_spans[0]
  assert_eq(scope_spans.schema_url, "https://opentelemetry.io/schemas/1.0.0")
  let span = scope_spans.spans[0]
  assert_eq(span.name, "request")
  assert_eq(span.trace_state, "")
  assert_eq(span.attributes.length(), 1)
  assert_eq(span.events.length(), 1)
  assert_eq(span.links.length(), 1)
  assert_eq(span.dropped_attributes_count, 0U)
  assert_eq(span.dropped_events_count, 0U)
  assert_eq(span.dropped_links_count, 0U)
  assert_eq(span.links[0].trace_state, "tenant=blue")
  assert_true((span.flags & 0x1U) == 0x1U)
  assert_true((span.flags & 0x100U) == 0x100U)
  assert_true(
    span.status.code == @otlptrace.Status_StatusCode::STATUS_CODE_ERROR,
  )
}

///|
async test "trace request json roundtrips" {
  let encoded = encode_json_message(build_trace_request([sample_span_data()]))
  let request : @collectortrace.ExportTraceServiceRequest = match
    decode_json_message(encoded) {
    Ok(request) => request
    Err(message) => fail("expected valid trace json payload: \{message}")
  }
  assert_eq(request.resource_spans.length(), 1)
  assert_eq(request.resource_spans[0].scope_spans[0].spans[0].name, "request")
}

///|
test "logs request encodes severity and trace context" {
  let request = build_logs_request([sample_log_record()])
  assert_eq(request.resource_logs.length(), 1)
  assert_eq(request.resource_logs[0].scope_logs[0].scope.name, "my-target")
  let record = request.resource_logs[0].scope_logs[0].log_records[0]
  assert_true(
    record.severity_number == @otlplogs.SeverityNumber::SEVERITY_NUMBER_ERROR3,
  )
  assert_eq(record.severity_text, "ERROR3")
  assert_eq(record.event_name, "checkout.failed")
  assert_eq(record.attributes.length(), 1)
  assert_true(record.trace_id.length() == 16)
  assert_true(record.span_id.length() == 8)
  assert_true((record.flags & 0x1U) == 0x1U)
  guard record.body.value is @otlpcommon.AnyValue_Value::KvlistValue(body) else {
    fail("expected log body to be encoded as a structured map")
  }
  assert_eq(body.values.length(), 2)
}

///|
test "logs request json roundtrips" {
  let encoded = encode_json_message(build_logs_request([sample_log_record()]))
  let request : @collectorlogs.ExportLogsServiceRequest = match
    decode_json_message(encoded) {
    Ok(request) => request
    Err(message) => fail("expected valid logs json payload: \{message}")
  }
  let record = request.resource_logs[0].scope_logs[0].log_records[0]
  assert_eq(record.severity_text, "ERROR3")
  assert_eq(record.event_name, "checkout.failed")
  assert_eq(record.attributes.length(), 1)
}

///|
test "logs request groups identical target and resource into one scope" {
  let first = sample_log_record()
  let second = sample_log_record_with_timestamp(302L, 303L)
  let request = build_logs_request([first, second])
  assert_eq(request.resource_logs.length(), 1)
  assert_eq(request.resource_logs[0].scope_logs.length(), 1)
  assert_eq(request.resource_logs[0].scope_logs[0].log_records.length(), 2)
  assert_eq(request.resource_logs[0].scope_logs[0].scope.name, "my-target")
}

///|
test "metrics request encodes sums and histograms" {
  let request = build_metrics_request(
    [sample_counter_metric(), sample_histogram_metric()],
    @sdkmetrics.Temporality::LowMemory,
  )
  assert_eq(request.resource_metrics.length(), 2)

  let counter_metric = request.resource_metrics[0].scope_metrics[0].metrics[0]
  guard counter_metric.data is @otlpmetrics.Metric_Data::Sum(sum) else {
    fail("expected counter metric to encode as sum")
  }
  assert_true(
    sum.aggregation_temporality ==
    @otlpmetrics.AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA,
  )
  assert_true(sum.is_monotonic)
  guard sum.data_points[0].value
    is @otlpmetrics.NumberDataPoint_Value::AsInt(value) else {
    fail("expected counter datapoint to encode as int")
  }
  assert_eq(value, 5L)

  let histogram_metric = request.resource_metrics[1].scope_metrics[0].metrics[0]
  guard histogram_metric.data is @otlpmetrics.Metric_Data::Histogram(histogram) else {
    fail("expected histogram metric to encode as histogram")
  }
  assert_true(
    histogram.aggregation_temporality ==
    @otlpmetrics.AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA,
  )
  assert_eq(histogram.data_points[0].bucket_counts, [3UL])
  assert_eq(histogram.data_points[0].sum, Some(12.5))
  assert_eq(histogram.data_points[0].min, Some(1.0))
  assert_eq(histogram.data_points[0].max, Some(8.0))
}

///|
test "metrics request json roundtrips" {
  let encoded = encode_json_message(
    build_metrics_request(
      [sample_counter_metric(), sample_histogram_metric()],
      @sdkmetrics.Temporality::LowMemory,
    ),
  )
  let request : @collectormetrics.ExportMetricsServiceRequest = match
    decode_json_message(encoded) {
    Ok(request) => request
    Err(message) => fail("expected valid metrics json payload: \{message}")
  }
  assert_eq(request.resource_metrics.length(), 2)
  assert_eq(
    request.resource_metrics[0].scope_metrics[0].metrics[0].name,
    "requests",
  )
}

///|
test "json response validation handles success and partial success" {
  guard validate_trace_response(
      Protocol::HttpJson,
      encode_json_message(@collectortrace.ExportTraceServiceResponse::default()),
    )
    is Ok(_) else {
    fail("expected empty trace json response to validate")
  }
  guard validate_logs_response(
      Protocol::HttpJson,
      encode_json_message(@collectorlogs.ExportLogsServiceResponse::default()),
    )
    is Ok(_) else {
    fail("expected empty logs json response to validate")
  }
  guard validate_metrics_response(
      Protocol::HttpJson,
      encode_json_message(
        @collectormetrics.ExportMetricsServiceResponse::default(),
      ),
    )
    is Ok(_) else {
    fail("expected empty metrics json response to validate")
  }

  guard validate_trace_response(
      Protocol::HttpJson,
      encode_json_message(
        @collectortrace.ExportTraceServiceResponse::new(
          @collectortrace.ExportTracePartialSuccess::new(1L, "trace failed"),
        ),
      ),
    )
    is Err(trace_message) else {
    fail("expected trace partial success to fail validation")
  }
  assert_true(trace_message.contains("rejected_spans=1"))

  guard validate_logs_response(
      Protocol::HttpJson,
      encode_json_message(
        @collectorlogs.ExportLogsServiceResponse::new(
          @collectorlogs.ExportLogsPartialSuccess::new(2L, "logs failed"),
        ),
      ),
    )
    is Err(logs_message) else {
    fail("expected logs partial success to fail validation")
  }
  assert_true(logs_message.contains("rejected_log_records=2"))

  guard validate_metrics_response(
      Protocol::HttpJson,
      encode_json_message(
        @collectormetrics.ExportMetricsServiceResponse::new(
          @collectormetrics.ExportMetricsPartialSuccess::new(
            3L, "metrics failed",
          ),
        ),
      ),
    )
    is Err(metrics_message) else {
    fail("expected metrics partial success to fail validation")
  }
  assert_true(metrics_message.contains("rejected_data_points=3"))
}

///|
async test "async span exporter posts protobuf to collector" {
  let received_path = Ref::new("")
  let received_content_type = Ref::new("")
  let received_body = Ref::new(b"")

  @async.with_task_group(group => {
    let server = @http.Server(@socket.Addr::parse("127.0.0.1:0"))
    let port = server.addr.port()
    group.spawn_bg(no_wait=true, () => {
      server.run_forever(
        (request, body, conn) => {
          received_path.val = request.path
          for key, value in request.headers {
            if normalize_ascii_lower(key) == "content-type" {
              received_content_type.val = value
            }
          }
          received_body.val = body.read_all().binary()
          conn..send_response(200, "OK").end_response()
        },
        max_connections=1,
      )
    })

    guard SpanExporter::builder()
      .with_endpoint("http://127.0.0.1:\{port}/custom/traces")
      .build()
      is Ok(exporter) else {
      fail("expected exporter build to succeed")
    }
    guard exporter.export_batch([sample_span_data()]) is Ok(_) else {
      fail("expected export to succeed")
    }
  })

  assert_eq(received_path.val, "/custom/traces")
  assert_eq(received_content_type.val, "application/x-protobuf")
  let request : @collectortrace.ExportTraceServiceRequest = match
    decode_trace_request(received_body.val) {
    Ok(request) => request
    Err(message) => fail("expected valid protobuf body: \{message}")
  }
  assert_eq(request.resource_spans.length(), 1)
}

///|
async test "async span exporter posts json to collector" {
  let received_path = Ref::new("")
  let received_content_type = Ref::new("")
  let received_body = Ref::new(b"")

  @async.with_task_group(group => {
    let server = @http.Server(@socket.Addr::parse("127.0.0.1:0"))
    let port = server.addr.port()
    group.spawn_bg(no_wait=true, () => {
      server.run_forever(
        (request, body, conn) => {
          received_path.val = request.path
          for key, value in request.headers {
            if normalize_ascii_lower(key) == "content-type" {
              received_content_type.val = value
            }
          }
          received_body.val = body.read_all().binary()
          conn.send_response(200, "OK", extra_headers={
            "content-type": "application/json",
          })
          conn.write("{}" |> @utf8.encode)
          conn.end_response()
        },
        max_connections=1,
      )
    })

    guard SpanExporter::builder()
      .with_endpoint("http://127.0.0.1:\{port}/custom/traces")
      .with_protocol(Protocol::HttpJson)
      .build()
      is Ok(exporter) else {
      fail("expected json exporter build to succeed")
    }
    guard exporter.export_batch([sample_span_data()]) is Ok(_) else {
      fail("expected json export to succeed")
    }
  })

  assert_eq(received_path.val, "/custom/traces")
  assert_eq(received_content_type.val, "application/json")
  let request : @collectortrace.ExportTraceServiceRequest = match
    decode_json_message(received_body.val) {
    Ok(request) => request
    Err(message) => fail("expected valid json body: \{message}")
  }
  assert_eq(request.resource_spans.length(), 1)
}

///|
async test "sdk exporters reject export after shutdown" {
  guard SpanExporter::builder().build() is Ok(span_exporter) else {
    fail("expected span exporter build to succeed")
  }
  guard span_exporter.shutdown() is Ok(_) else {
    fail("expected span exporter shutdown to succeed")
  }
  guard span_exporter.export_batch([sample_span_data()])
    is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected span exporter to reject export after shutdown")
  }

  guard LogExporter::builder().build() is Ok(log_exporter) else {
    fail("expected log exporter build to succeed")
  }
  guard log_exporter.shutdown() is Ok(_) else {
    fail("expected log exporter shutdown to succeed")
  }
  guard log_exporter.export_batch([sample_log_record()])
    is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected log exporter to reject export after shutdown")
  }

  guard MetricExporter::builder().build() is Ok(metric_exporter) else {
    fail("expected metric exporter build to succeed")
  }
  guard metric_exporter.shutdown() is Ok(_) else {
    fail("expected metric exporter shutdown to succeed")
  }
  guard metric_exporter.export_batch([sample_counter_metric()])
    is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected metric exporter to reject export after shutdown")
  }
}
