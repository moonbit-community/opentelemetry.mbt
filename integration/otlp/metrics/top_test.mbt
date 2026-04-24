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
fn build_metric_exporter(protocol : @otlp.Protocol) -> @otlp.MetricExporter {
  let builder = @otlp.MetricExporter::builder().with_temporality(
    @sdkmetrics.Temporality::Cumulative,
  )
  let builder = match protocol {
    @otlp.Protocol::HttpBinary => builder.with_http()
    @otlp.Protocol::HttpJson => builder.with_protocol(protocol)
    @otlp.Protocol::Grpc => abort("grpc is not part of the integration suite")
  }
  guard builder.build() is Ok(exporter) else {
    abort("expected metric exporter to build")
  }
  exporter
}

///|
fn build_metric_exporter_from_env() -> @otlp.MetricExporter {
  guard @otlp.MetricExporter::builder().build() is Ok(exporter) else {
    abort("expected metric exporter to build from env")
  }
  exporter
}

///|
fn emit_metrics(scope_name : StringView) -> Unit {
  let meter = @otel.meter(
    scope_name,
    version=Some("1.0.0"),
    schema_url=Some(schema_url),
    attributes=[
      @otel.KeyValue::new("scope.attr", @otel.Value::String("integration")),
    ],
  )
  let counter = meter.u64_counter("requests").with_unit("1").build()
  counter.add(7UL, attributes=[
    @otel.KeyValue::new("route", @otel.Value::String("/checkout")),
  ])
  let histogram = meter.f64_histogram("latency.ms").with_unit("ms").build()
  histogram.record(12.5, attributes=[
    @otel.KeyValue::new("route", @otel.Value::String("/checkout")),
  ])
  histogram.record(18.0, attributes=[
    @otel.KeyValue::new("route", @otel.Value::String("/checkout")),
  ])
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
fn find_scope_metrics(
  data : @otlp_metrics.MetricsData,
  scope_name : StringView,
) -> Array[@otlp_metrics.Metric] {
  let scope_name = scope_name.to_string()
  let metrics : Array[@otlp_metrics.Metric] = []
  for resource_metrics in data.resource_metrics {
    for scope_metrics in resource_metrics.scope_metrics {
      if scope_metrics.scope.name == scope_name {
        for metric in scope_metrics.metrics {
          metrics.push(metric)
        }
      }
    }
  }
  metrics
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
fn point_has_string_attribute(
  point : @otlp_metrics.NumberDataPoint,
  key : StringView,
  expected : StringView,
) -> Bool {
  let key = key.to_string()
  let expected = expected.to_string()
  for attribute in point.attributes {
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
// Test target: Verify the root metrics APIs can periodically export protobuf metrics that match the checked-in integration snapshot.
// Test method: Install a periodic protobuf exporter, emit representative metrics through the global API, wait for collector output, and compare it to the expected fixture after normalizing timestamps.
async test "periodic metrics export over http protobuf via root API" {
  let scope_name = "integration.metrics.protobuf"
  let expected_path = "expected/metrics/http_protobuf.json"
  @global.reset_for_test()
  defer @global.reset_for_test()

  let provider = @sdk.meter_provider_builder()
    .with_resource(integration_resource("integration-metrics-protobuf"))
    .with_periodic_reader(
      build_metric_exporter(@otlp.Protocol::HttpBinary).into_periodic_reader(
        interval_millis=20,
      ),
    )
    .build()
  @sdk.set_meter_provider(provider)

  @async.with_task_group(group => {
    @sdk.spawn_background_tasks(group)
    emit_metrics(scope_name)

    let actual = match
      @support.wait_for_latest_matching_json(
        @support.metrics_actual_path,
        json => @support.metrics_json_has_scope(json, scope_name),
        "metric scope \{scope_name}",
      ) {
      Ok(actual) => actual
      Err(message) => fail(message)
    }

    match provider.shutdown() {
      Ok(_) => ()
      Err(err) =>
        fail(
          "expected meter provider shutdown to succeed: \{@debug.to_string(err)}",
        )
    }

    let expected = match @support.read_json_value_file(expected_path) {
      Ok(expected) => expected
      Err(message) => fail(message)
    }
    assert_true(
      @support.zero_metric_timestamps(actual) ==
      @support.zero_metric_timestamps(expected),
    )
  })
}

///|
// Test target: Verify force-flushed HTTP/JSON metric exports from the root API match the expected integration fixture.
// Test method: Configure an HTTP/JSON periodic reader, emit representative metrics, force flush and shut down, then compare the captured output with the fixture after timestamp normalization.
async test "force flushed metrics export over http json via root API" {
  let scope_name = "integration.metrics.json"
  let expected_path = "expected/metrics/http_json.json"
  @global.reset_for_test()
  defer @global.reset_for_test()

  let provider = @sdk.meter_provider_builder()
    .with_resource(integration_resource("integration-metrics-json"))
    .with_periodic_reader(
      build_metric_exporter(@otlp.Protocol::HttpJson).into_periodic_reader(
        interval_millis=60000,
      ),
    )
    .build()
  @sdk.set_meter_provider(provider)

  emit_metrics(scope_name)
  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected meter provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected meter provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual = match
    @support.wait_for_latest_matching_json(
      @support.metrics_actual_path,
      json => @support.metrics_json_has_scope(json, scope_name),
      "metric scope \{scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let expected = match @support.read_json_value_file(expected_path) {
    Ok(expected) => expected
    Err(message) => fail(message)
  }
  assert_true(
    @support.zero_metric_timestamps(actual) ==
    @support.zero_metric_timestamps(expected),
  )
}

///|
// Test target: Verify rich metric exports cover synchronous and observable instruments with the expected OTLP aggregation shapes.
// Test method: Emit counters, gauges, and observable instruments through the root API, force flush once, and assert the collected OTLP payload contains the expected metric kinds, values, and attributes.
async test "rich metrics export covers sync and observable instruments" {
  let scope_name = "integration.metrics.rich"
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
    @otlp.MetricExporter::builder()
    .with_http()
    .with_endpoint(@support.append_signal_path(base_endpoint, "/v1/metrics"))
    .with_timeout(2500)
    .with_headers({
      "x-integration-test": "metrics-rich",
      "x-scope": "builder-overrides",
    })
    .with_temporality(@sdkmetrics.Temporality::Cumulative)
    .build() {
    Ok(exporter) => exporter
    Err(err) =>
      fail(
        "expected metric exporter build to succeed: \{@debug.to_string(err)}",
      )
  }
  assert_true(exporter.temporality() == @sdkmetrics.Temporality::Cumulative)
  let provider = @sdk.meter_provider_builder()
    .with_resource(integration_resource("integration-metrics-rich"))
    .with_periodic_reader(
      @sdkmetrics.PeriodicMetricReader::builder(exporter.into_metric_exporter())
      .with_interval(60000)
      .with_temporality(@sdkmetrics.Temporality::Cumulative)
      .build(),
    )
    .build()
  @sdk.set_meter_provider(provider)

  let meter = @otel.meter(
    scope_name,
    version=Some("1.1.0"),
    schema_url=Some(schema_url),
    attributes=[@otel.KeyValue::new("scope.attr", @otel.Value::String("rich"))],
  )
  let depth = meter
    .i64_up_down_counter("queue.depth")
    .with_description("queue depth")
    .with_unit("1")
    .build()
  depth.add(5L, attributes=[
    @otel.KeyValue::new("state", @otel.Value::String("ready")),
  ])
  depth.add(-2L, attributes=[
    @otel.KeyValue::new("state", @otel.Value::String("ready")),
  ])

  let temperature = meter
    .f64_gauge("worker.temperature")
    .with_description("worker temperature")
    .with_unit("C")
    .build()
  temperature.record(42.5, attributes=[
    @otel.KeyValue::new("worker", @otel.Value::String("alpha")),
  ])

  let observed_jobs_calls = Ref::new(0)
  let observed_pressure_calls = Ref::new(0)
  let observed_lag_calls = Ref::new(0)
  let observed_jobs = meter
    .u64_observable_counter("jobs.processed")
    .with_description("processed jobs")
    .with_unit("1")
    .with_callback(observer => {
      observed_jobs_calls.val = observed_jobs_calls.val + 1
      observer.observe(12UL, attributes=[
        @otel.KeyValue::new("worker", @otel.Value::String("alpha")),
      ])
    })
    .build()
  let observed_pressure = meter
    .f64_observable_gauge("worker.pressure")
    .with_description("worker pressure")
    .with_unit("kPa")
    .with_callback(observer => {
      observed_pressure_calls.val = observed_pressure_calls.val + 1
      observer.observe(101.3, attributes=[
        @otel.KeyValue::new("worker", @otel.Value::String("alpha")),
      ])
    })
    .build()
  let observed_lag = meter
    .i64_observable_up_down_counter("queue.lag")
    .with_description("queue lag")
    .with_unit("1")
    .with_callback(observer => {
      observed_lag_calls.val = observed_lag_calls.val + 1
      observer.observe(-1L, attributes=[
        @otel.KeyValue::new("worker", @otel.Value::String("alpha")),
      ])
    })
    .build()
  ignore(observed_jobs)
  ignore(observed_pressure)
  ignore(observed_lag)

  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected meter provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  assert_true(observed_jobs_calls.val > 0)
  assert_true(observed_pressure_calls.val > 0)
  assert_true(observed_lag_calls.val > 0)
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected meter provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual : @otlp_metrics.MetricsData = match
    @support.wait_for_latest_matching_record(
      @support.metrics_actual_path,
      data => metrics_data_has_scope(data, scope_name),
      "metric scope \{scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let metrics = find_scope_metrics(actual, scope_name)
  assert_eq(metrics.length(), 5)

  let depth_metric = match find_metric(metrics, "queue.depth") {
    Some(metric) => metric
    None => fail("expected queue.depth metric")
  }
  let temperature_metric = match find_metric(metrics, "worker.temperature") {
    Some(metric) => metric
    None => fail("expected worker.temperature metric")
  }
  let jobs_metric = match find_metric(metrics, "jobs.processed") {
    Some(metric) => metric
    None => fail("expected jobs.processed metric")
  }
  let lag_metric = match find_metric(metrics, "queue.lag") {
    Some(metric) => metric
    None => fail("expected queue.lag metric")
  }
  let pressure_metric = match find_metric(metrics, "worker.pressure") {
    Some(metric) => metric
    None => fail("expected worker.pressure metric")
  }

  assert_eq(depth_metric.description, "queue depth")
  assert_eq(depth_metric.unit, "1")
  match depth_metric.data {
    @otlp_metrics.Metric_Data::Sum(sum) => {
      assert_true(
        sum.aggregation_temporality ==
        @otlp_metrics.AggregationTemporality::AGGREGATION_TEMPORALITY_CUMULATIVE,
      )
      assert_true(!sum.is_monotonic)
      assert_eq(sum.data_points.length(), 1)
      assert_true(
        point_has_string_attribute(sum.data_points[0], "state", "ready"),
      )
      assert_true(
        sum.data_points[0].value ==
        @otlp_metrics.NumberDataPoint_Value::AsInt(3L),
      )
    }
    _ => fail("expected queue.depth to export as a sum")
  }

  assert_eq(temperature_metric.description, "worker temperature")
  assert_eq(temperature_metric.unit, "C")
  match temperature_metric.data {
    @otlp_metrics.Metric_Data::Gauge(gauge) => {
      assert_eq(gauge.data_points.length(), 1)
      assert_true(
        point_has_string_attribute(gauge.data_points[0], "worker", "alpha"),
      )
      assert_true(
        gauge.data_points[0].value ==
        @otlp_metrics.NumberDataPoint_Value::AsDouble(42.5),
      )
    }
    _ => fail("expected worker.temperature to export as a gauge")
  }

  match jobs_metric.data {
    @otlp_metrics.Metric_Data::Sum(sum) => {
      assert_true(sum.is_monotonic)
      assert_eq(sum.data_points.length(), 1)
      assert_true(
        point_has_string_attribute(sum.data_points[0], "worker", "alpha"),
      )
      assert_true(
        sum.data_points[0].value ==
        @otlp_metrics.NumberDataPoint_Value::AsInt(12L),
      )
    }
    _ => fail("expected jobs.processed to export as a sum")
  }

  match lag_metric.data {
    @otlp_metrics.Metric_Data::Sum(sum) => {
      assert_true(!sum.is_monotonic)
      assert_eq(sum.data_points.length(), 1)
      assert_true(
        point_has_string_attribute(sum.data_points[0], "worker", "alpha"),
      )
      assert_true(
        sum.data_points[0].value ==
        @otlp_metrics.NumberDataPoint_Value::AsInt(-1L),
      )
    }
    _ => fail("expected queue.lag to export as a sum")
  }

  match pressure_metric.data {
    @otlp_metrics.Metric_Data::Gauge(gauge) => {
      assert_eq(gauge.data_points.length(), 1)
      assert_true(
        point_has_string_attribute(gauge.data_points[0], "worker", "alpha"),
      )
      assert_true(
        gauge.data_points[0].value ==
        @otlp_metrics.NumberDataPoint_Value::AsDouble(101.3),
      )
    }
    _ => fail("expected worker.pressure to export as a gauge")
  }
}

///|
// Test target: Verify metric force_flush reports an export timeout when the collector endpoint stalls.
// Test method: Point the periodic reader at a delayed local server, force flush after emitting metrics, and assert the returned error message and observed request path.
async test "metric force_flush times out against a delayed endpoint" {
  let scope_name = "integration.metrics.timeout"
  @global.reset_for_test()
  defer @global.reset_for_test()

  @async.with_task_group(group => {
    let server = @support.start_delayed_http_server(group)
    let exporter = match
      @otlp.MetricExporter::builder()
      .with_http()
      .with_endpoint(
        @support.append_signal_path(server.endpoint(), "/v1/metrics"),
      )
      .with_timeout(100)
      .with_temporality(@sdkmetrics.Temporality::Cumulative)
      .build() {
      Ok(exporter) => exporter
      Err(err) =>
        fail(
          "expected metric exporter build to succeed: \{@debug.to_string(err)}",
        )
    }
    let reader = @sdkmetrics.PeriodicMetricReader::builder(
        exporter.into_metric_exporter(),
      )
      .with_interval(60000)
      .with_temporality(@sdkmetrics.Temporality::Cumulative)
      .build()
    let provider = @sdk.meter_provider_builder()
      .with_resource(integration_resource("integration-metrics-timeout"))
      .with_periodic_reader(reader)
      .build()
    @sdk.set_meter_provider(provider)

    emit_metrics(scope_name)

    guard provider.force_flush()
      is Err(@error.OTelSdkError::ExportFailure(_, message)) else {
      fail("expected metric force_flush to fail with ExportFailure")
    }
    assert_true(message.contains("metrics export timed out after 100ms"))

    let request_path = match server.wait_until_requested() {
      Ok(request_path) => request_path
      Err(message) => fail(message)
    }
    assert_eq(request_path, "/v1/metrics")
    assert_eq(server.request_count(), 1)
    assert_eq(server.request_path(), "/v1/metrics")

    match reader.shutdown() {
      Ok(_) => ()
      Err(err) =>
        fail(
          "expected periodic metric reader shutdown to succeed: \{@debug.to_string(err)}",
        )
    }
    assert_eq(server.request_count(), 1)
  })
}

///|
// Test target: Verify the metrics-specific endpoint override takes precedence over an invalid global OTLP endpoint.
// Test method: Configure conflicting environment endpoints, export metrics through the environment-backed builder, and compare the captured output with the expected fixture.
async test "signal-specific metric endpoint overrides invalid global endpoint" {
  let scope_name = "integration.metrics.signal-endpoint"
  let expected_path = "expected/metrics/env_signal_endpoint_http_json.json"
  let original_endpoint = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_ENDPOINT)
  let original_signal_endpoint = @env.get_env_var(
    @otlp.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT,
  )
  let original_protocol = @env.get_env_var(@otlp.OTEL_EXPORTER_OTLP_PROTOCOL)
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_ENDPOINT,
    original_endpoint,
  )
  defer @support.restore_env_var(
    @otlp.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT,
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
    @otlp.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT,
    @support.append_signal_path(base_endpoint, "/v1/metrics"),
  )
  @env.set_env_var(
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL,
    @otlp.OTEL_EXPORTER_OTLP_PROTOCOL_HTTP_JSON,
  )

  let provider = @sdk.meter_provider_builder()
    .with_resource(integration_resource("integration-metrics-signal-endpoint"))
    .with_periodic_reader(
      build_metric_exporter_from_env().into_periodic_reader(
        interval_millis=60000,
      ),
    )
    .build()
  @sdk.set_meter_provider(provider)

  emit_metrics(scope_name)
  match provider.force_flush() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected meter provider force_flush to succeed: \{@debug.to_string(err)}",
      )
  }
  match provider.shutdown() {
    Ok(_) => ()
    Err(err) =>
      fail(
        "expected meter provider shutdown to succeed: \{@debug.to_string(err)}",
      )
  }

  let actual = match
    @support.wait_for_latest_matching_json(
      @support.metrics_actual_path,
      json => @support.metrics_json_has_scope(json, scope_name),
      "metric scope \{scope_name}",
    ) {
    Ok(actual) => actual
    Err(message) => fail(message)
  }
  let expected = match @support.read_json_value_file(expected_path) {
    Ok(expected) => expected
    Err(message) => fail(message)
  }
  assert_true(
    @support.zero_metric_timestamps(actual) ==
    @support.zero_metric_timestamps(expected),
  )
}
