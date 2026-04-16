///|
fn sample_resource() -> @resource.Resource {
  @resource.Resource::builder_empty()
  .with_attribute("service.name", @common.Value::String("print-test"))
  .with_schema_url("https://opentelemetry.io/schemas/1.0.0")
  .build()
}

///|
fn sample_scope() -> @common.InstrumentationScope {
  @common.InstrumentationScope::builder("print-test")
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
    "print-test",
    version=Some("1.2.3"),
    schema_url=Some("https://opentelemetry.io/schemas/1.0.0"),
    attributes=[
      @common.KeyValue::new("scope.attr", @common.Value::String("demo")),
    ],
  )
  let span = tracer.start("request", start_time_unix_nano=100L)
  span.set_attribute("http.method", @common.Value::String("GET"))
  span.add_event(
    "connected",
    attributes=[
      @common.KeyValue::new("net.transport", @common.Value::String("tcp")),
    ],
    timestamp_unix_nano=150L,
  )
  span.add_link(
    sample_span_context("4bf92f3577b34da6a3ce929d0e0e4737", "00f067aa0ba902b8"),
    attributes=[@common.KeyValue::new("linked", @common.Value::String("yes"))],
  )
  span.set_status(@sdktrace.Status::error(description=Some("boom")))
  span.end(end_time_unix_nano=200L)
  exporter.finished_spans()[0]
}

///|
fn sample_log_record() -> @sdklogs.LogRecord {
  @sdklogs.LogRecord::new(
    @common.Value::String("request failed"),
    severity_number=Some(@sdklogs.SeverityNumber::Error),
    severity_text=Some("ERROR"),
    attributes=[
      @common.KeyValue::new("http.status_code", @common.Value::Int64(500L)),
    ],
    trace_context=Some(
      sample_span_context(
        "4bf92f3577b34da6a3ce929d0e0e4736", "00f067aa0ba902b7",
      ),
    ),
    timestamp_unix_nano=300L,
    observed_timestamp_unix_nano=301L,
    resource=sample_resource(),
    instrumentation_scope=sample_scope(),
  )
}

///|
fn sample_metric_data() -> @sdkmetrics.MetricData {
  let provider = @sdkmetrics.SdkMeterProvider::builder()
    .with_resource(sample_resource())
    .build()
  let meter = provider.meter(
    "print-test",
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
  provider.manual_reader().collect()[0]
}

///|
fn counter_sum(
  metrics : Array[@sdkmetrics.MetricData],
  name : StringView,
) -> Int64? {
  for metric in metrics {
    if metric.name == name.to_string() {
      match metric.aggregation {
        @sdkmetrics.Aggregation::Sum(@sdkmetrics.Number::Int64(value)) =>
          return Some(value)
        _ => return None
      }
    }
  }
  None
}

///|
async test "render span batch includes resource scope event and link" {
  let rendered = render_span_batch([sample_span_data()], true)
  assert_true(rendered.contains("Spans"))
  assert_true(rendered.contains("Resource"))
  assert_true(rendered.contains("service.name"))
  assert_true(rendered.contains("Span #0"))
  assert_true(rendered.contains("\"request\""))
  assert_true(rendered.contains("http.method"))
  assert_true(rendered.contains("connected"))
  assert_true(rendered.contains("linked"))
  assert_true(rendered.contains("Error(\"boom\")"))
}

///|
test "render log batch includes trace context and severity" {
  let rendered = render_log_batch([sample_log_record()], true)
  assert_true(rendered.contains("Logs"))
  assert_true(rendered.contains("Log #0"))
  assert_true(rendered.contains("TraceId"))
  assert_true(rendered.contains("SeverityText"))
  assert_true(rendered.contains("SeverityNumber"))
  assert_true(rendered.contains("\"request failed\""))
  assert_true(rendered.contains("http.status_code"))
}

///|
test "render metric batch includes aggregation details" {
  let rendered = render_metric_batch([sample_metric_data()])
  assert_true(rendered.contains("Metrics"))
  assert_true(rendered.contains("Metric #0"))
  assert_true(rendered.contains("\"requests\""))
  assert_true(rendered.contains("Aggregation"))
  assert_true(rendered.contains("Sum"))
  assert_true(rendered.contains("route"))
}

///|
async test "sdk exporters reject exports after shutdown" {
  let span_exporter = SpanExporter::new().into_span_exporter()
  guard span_exporter.shutdown() is Ok(_) else {
    fail("expected span exporter shutdown to succeed")
  }
  guard span_exporter.export_batch([sample_span_data()])
    is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected span exporter to reject exports after shutdown")
  }

  let log_exporter = LogExporter::new().into_log_exporter()
  guard log_exporter.shutdown() is Ok(_) else {
    fail("expected log exporter shutdown to succeed")
  }
  guard log_exporter.export_batch([sample_log_record()])
    is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected log exporter to reject exports after shutdown")
  }

  let metric_exporter = MetricExporter::builder().build().into_metric_exporter()
  guard metric_exporter.shutdown() is Ok(_) else {
    fail("expected metric exporter shutdown to succeed")
  }
  guard metric_exporter.export_batch([sample_metric_data()])
    is Err(@error.OTelSdkError::AlreadyShutdown) else {
    fail("expected metric exporter to reject exports after shutdown")
  }
}

///|
test "metric exporter builder temporality feeds periodic reader" {
  let exporter = MetricExporter::builder()
    .with_temporality(@sdkmetrics.Temporality::Delta)
    .build()
  assert_true(exporter.temporality() == @sdkmetrics.Temporality::Delta)

  let reader = exporter.into_periodic_reader(interval_millis=1)
  let provider = @sdkmetrics.SdkMeterProvider::builder()
    .with_periodic_reader(reader)
    .build()
  let counter = provider.meter("print-metrics").counter("requests").build()

  counter.add(2)
  assert_eq(counter_sum(reader.collect(), "requests"), Some(2L))
  counter.add(3)
  assert_eq(counter_sum(reader.collect(), "requests"), Some(3L))
}
