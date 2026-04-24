///|
let schema_url = "https://opentelemetry.io/schemas/1.25.0"

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
fn build_trace_exporter() -> @otlp.SpanExporter {
  guard @otlp.SpanExporter::builder().with_http().build() is Ok(exporter) else {
    abort("expected span exporter to build")
  }
  exporter
}

///|
fn build_log_exporter() -> @otlp.LogExporter {
  guard @otlp.LogExporter::builder()
    .with_protocol(@otlp.Protocol::HttpJson)
    .build()
    is Ok(exporter) else {
    abort("expected log exporter to build")
  }
  exporter
}

///|
fn build_metric_exporter() -> @otlp.MetricExporter {
  guard @otlp.MetricExporter::builder()
    .with_http()
    .with_temporality(@sdkmetrics.Temporality::Cumulative)
    .build()
    is Ok(exporter) else {
    abort("expected metric exporter to build")
  }
  exporter
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
fn find_trace_resource(
  data : @otlp_trace.TracesData,
  scope_name : StringView,
) -> @otlp_trace.ResourceSpans? {
  let scope_name = scope_name.to_string()
  for resource_spans in data.resource_spans {
    for scope_spans in resource_spans.scope_spans {
      if scope_spans.scope.name == scope_name {
        return Some(resource_spans)
      }
    }
  }
  None
}

///|
fn find_trace_scope(
  data : @otlp_trace.TracesData,
  scope_name : StringView,
) -> @otlp_trace.ScopeSpans? {
  let scope_name = scope_name.to_string()
  for resource_spans in data.resource_spans {
    for scope_spans in resource_spans.scope_spans {
      if scope_spans.scope.name == scope_name {
        return Some(scope_spans)
      }
    }
  }
  None
}

///|
fn find_log_resource(
  data : @otlp_logs.LogsData,
  scope_name : StringView,
) -> @otlp_logs.ResourceLogs? {
  let scope_name = scope_name.to_string()
  for resource_logs in data.resource_logs {
    for scope_logs in resource_logs.scope_logs {
      if scope_logs.scope.name == scope_name {
        return Some(resource_logs)
      }
    }
  }
  None
}

///|
fn find_log_scope(
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
fn find_metric_resource(
  data : @otlp_metrics.MetricsData,
  scope_name : StringView,
) -> @otlp_metrics.ResourceMetrics? {
  let scope_name = scope_name.to_string()
  for resource_metrics in data.resource_metrics {
    for scope_metrics in resource_metrics.scope_metrics {
      if scope_metrics.scope.name == scope_name {
        return Some(resource_metrics)
      }
    }
  }
  None
}

///|
fn find_metric_scope(
  data : @otlp_metrics.MetricsData,
  scope_name : StringView,
) -> @otlp_metrics.ScopeMetrics? {
  let scope_name = scope_name.to_string()
  for resource_metrics in data.resource_metrics {
    for scope_metrics in resource_metrics.scope_metrics {
      if scope_metrics.scope.name == scope_name {
        return Some(scope_metrics)
      }
    }
  }
  None
}

///|
fn find_metric(
  metrics : ArrayView[@otlp_metrics.Metric],
  name : StringView,
) -> @otlp_metrics.Metric? {
  let name = name.to_string()
  for metric in metrics {
    if metric.name == name {
      return Some(metric)
    }
  }
  None
}

///|
fn metrics_data_has_scope(
  data : @otlp_metrics.MetricsData,
  scope_name : StringView,
) -> Bool {
  let scope_name = scope_name.to_string()
  for resource_metrics in data.resource_metrics {
    for scope_metrics in resource_metrics.scope_metrics {
      if scope_metrics.scope.name == scope_name {
        return true
      }
    }
  }
  false
}

///|
// Test target: Verify the global trace, log, and metric APIs export correlated telemetry with shared resource and scope metadata.
// Test method: Install all three global providers, emit a span, a linked log record, and a metric, then assert the collected OTLP outputs agree on resource data and correlation identifiers.
async test "global APIs export correlated traces logs and metrics together" {
  let trace_scope_name = "integration.fullstack.traces"
  let log_scope_name = "integration.fullstack.logs"
  let metric_scope_name = "integration.fullstack.metrics"
  let service_name = "integration-fullstack"
  @global.reset_for_test()
  defer @global.reset_for_test()

  let tracer_provider = @sdk.tracer_provider_builder()
    .with_resource(integration_resource(service_name))
    .with_batch_exporter(
      build_trace_exporter().into_span_exporter(),
      config=@sdk.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  let logger_provider = @sdk.logger_provider_builder()
    .with_resource(integration_resource(service_name))
    .with_batch_exporter(
      build_log_exporter().into_log_exporter(),
      config=@sdklogs.BatchConfig::new(
        max_queue_size=8,
        max_export_batch_size=8,
        scheduled_delay_millis=60000,
      ),
    )
    .build()
  let meter_provider = @sdk.meter_provider_builder()
    .with_resource(integration_resource(service_name))
    .with_periodic_reader(
      build_metric_exporter().into_periodic_reader(interval_millis=60000),
    )
    .build()
  @sdk.set_tracer_provider(tracer_provider)
  @sdk.set_logger_provider(logger_provider)
  @sdk.set_meter_provider(meter_provider)

  let tracer = @otel.tracer(
    trace_scope_name,
    version=Some("1.0.0"),
    schema_url=Some(schema_url),
    attributes=[
      @otel.KeyValue::new("scope.attr", @otel.Value::String("fullstack")),
    ],
  )
  let logger = @otel.logger(
    log_scope_name,
    version=Some("1.0.0"),
    schema_url=Some(schema_url),
    attributes=[
      @otel.KeyValue::new("scope.attr", @otel.Value::String("fullstack")),
    ],
  )
  let meter = @otel.meter(
    metric_scope_name,
    version=Some("1.0.0"),
    schema_url=Some(schema_url),
    attributes=[
      @otel.KeyValue::new("scope.attr", @otel.Value::String("fullstack")),
    ],
  )
  let counter = meter.u64_counter("checkout.attempts").with_unit("1").build()

  let span = tracer.start("checkout.process")
  span.set_attribute(
    @otel.KeyValue::new("workflow", @otel.Value::String("checkout")),
  )
  let span_context = span.span_context()

  let record = logger.create_log_record()
  record.set_event_name("checkout.audit")
  record.set_timestamp(200L)
  record.set_observed_timestamp(205L)
  record.set_severity_number(@ilogs.Severity::Info2)
  record.set_body(@ilogs.AnyValue::String("accepted"))
  record.add_attribute("workflow", @ilogs.AnyValue::String("checkout"))
  record.add_attribute("result", @ilogs.AnyValue::String("ok"))
  record.set_trace_context(
    span_context.trace_id(),
    span_context.span_id(),
    trace_flags=Some(span_context.trace_flags()),
  )
  logger.emit(record)

  counter.add(2UL, attributes=[
    @otel.KeyValue::new("workflow", @otel.Value::String("checkout")),
  ])

  span.add_event_with_timestamp("checkout.completed", 210L)
  span.end_with_timestamp(220L)

  @async.sleep(0)
  @sdk.force_flush()
  @sdk.shutdown()

  let traces : @otlp_trace.TracesData = match
    @support.wait_for_latest_matching_record(
      @support.traces_actual_path,
      data => @support.traces_data_has_scope(data, trace_scope_name),
      "trace scope \{trace_scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let logs : @otlp_logs.LogsData = match
    @support.wait_for_latest_matching_record(
      @support.logs_actual_path,
      data => @support.logs_data_has_scope(data, log_scope_name),
      "log scope \{log_scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let metrics : @otlp_metrics.MetricsData = match
    @support.wait_for_latest_matching_record(
      @support.metrics_actual_path,
      data => metrics_data_has_scope(data, metric_scope_name),
      "metric scope \{metric_scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }

  let trace_resource = match find_trace_resource(traces, trace_scope_name) {
    Some(resource_spans) => resource_spans
    None => fail("expected trace export to contain scope \{trace_scope_name}")
  }
  let trace_scope = match find_trace_scope(traces, trace_scope_name) {
    Some(scope_spans) => scope_spans
    None => fail("expected trace scope \{trace_scope_name}")
  }
  let log_resource = match find_log_resource(logs, log_scope_name) {
    Some(resource_logs) => resource_logs
    None => fail("expected log export to contain scope \{log_scope_name}")
  }
  let log_scope = match find_log_scope(logs, log_scope_name) {
    Some(scope_logs) => scope_logs
    None => fail("expected log scope \{log_scope_name}")
  }
  let metric_resource = match find_metric_resource(metrics, metric_scope_name) {
    Some(resource_metrics) => resource_metrics
    None => fail("expected metric export to contain scope \{metric_scope_name}")
  }
  let metric_scope = match find_metric_scope(metrics, metric_scope_name) {
    Some(scope_metrics) => scope_metrics
    None => fail("expected metric scope \{metric_scope_name}")
  }

  assert_true(
    has_string_attribute(
      trace_resource.resource.attributes,
      "service.name",
      service_name,
    ),
  )
  assert_true(
    has_string_attribute(
      log_resource.resource.attributes,
      "service.name",
      service_name,
    ),
  )
  assert_true(
    has_string_attribute(
      metric_resource.resource.attributes,
      "service.name",
      service_name,
    ),
  )
  assert_true(
    has_string_attribute(
      trace_resource.resource.attributes,
      "deployment.environment.name",
      "integration",
    ),
  )
  assert_true(
    has_string_attribute(
      log_resource.resource.attributes,
      "deployment.environment.name",
      "integration",
    ),
  )
  assert_true(
    has_string_attribute(
      metric_resource.resource.attributes,
      "deployment.environment.name",
      "integration",
    ),
  )

  assert_eq(trace_scope.scope.version, "1.0.0")
  assert_eq(log_scope.scope.version, "1.0.0")
  assert_eq(metric_scope.scope.version, "1.0.0")
  assert_true(
    has_string_attribute(
      trace_scope.scope.attributes,
      "scope.attr",
      "fullstack",
    ),
  )
  assert_true(
    has_string_attribute(log_scope.scope.attributes, "scope.attr", "fullstack"),
  )
  assert_true(
    has_string_attribute(
      metric_scope.scope.attributes,
      "scope.attr",
      "fullstack",
    ),
  )

  assert_eq(trace_scope.spans.length(), 1)
  let exported_span = trace_scope.spans[0]
  assert_eq(exported_span.name, "checkout.process")
  assert_true(
    has_string_attribute(exported_span.attributes, "workflow", "checkout"),
  )
  assert_eq(exported_span.events.length(), 1)
  assert_eq(exported_span.events[0].name, "checkout.completed")

  assert_eq(log_scope.log_records.length(), 1)
  let exported_log = log_scope.log_records[0]
  assert_eq(exported_log.event_name, "checkout.audit")
  assert_eq(exported_log.severity_text, "INFO2")
  assert_true(
    has_string_attribute(exported_log.attributes, "workflow", "checkout"),
  )
  assert_true(has_string_attribute(exported_log.attributes, "result", "ok"))
  assert_true(exported_log.trace_id == exported_span.trace_id)
  assert_true(exported_log.span_id == exported_span.span_id)

  assert_eq(metric_scope.metrics.length(), 1)
  let attempts_metric = match
    find_metric(metric_scope.metrics, "checkout.attempts") {
    Some(metric) => metric
    None => fail("expected checkout.attempts metric")
  }
  assert_eq(attempts_metric.unit, "1")
  match attempts_metric.data {
    @otlp_metrics.Metric_Data::Sum(sum) => {
      assert_true(sum.is_monotonic)
      assert_eq(sum.data_points.length(), 1)
      assert_true(
        has_string_attribute(
          sum.data_points[0].attributes,
          "workflow",
          "checkout",
        ),
      )
      assert_true(
        sum.data_points[0].value ==
        @otlp_metrics.NumberDataPoint_Value::AsInt(2L),
      )
    }
    _ => fail("expected checkout.attempts to export as a sum")
  }
}
