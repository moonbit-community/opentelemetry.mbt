///|
struct SignalExporterState {
  is_shutdown : Bool
  resource_emitted : Bool
}

///|
struct MetricExporterState {
  is_shutdown : Bool
}

///|
/// Stdout span exporter mirroring the debugging-oriented Rust stdout exporter.
pub struct SpanExporter {
  state : Ref[SignalExporterState]
}

///|
/// Stdout log exporter mirroring the debugging-oriented Rust stdout exporter.
pub struct LogExporter {
  state : Ref[SignalExporterState]
}

///|
/// Stdout metric exporter mirroring the debugging-oriented Rust stdout
/// exporter.
pub struct MetricExporter {
  state : Ref[MetricExporterState]
  temporality : @sdkmetrics.Temporality
}

///|
/// Builder for `MetricExporter`.
pub struct MetricExporterBuilder {
  mut temporality : @sdkmetrics.Temporality
}

///|
fn push_line(builder : StringBuilder, line : String) -> Unit {
  builder.write_string(line)
  builder.write_char('\n')
}

///|
fn push_indent(builder : StringBuilder, indent : Int) -> Unit {
  for _ in 0..<indent {
    builder.write_char(' ')
  }
}

///|
fn push_field(
  builder : StringBuilder,
  indent : Int,
  label : String,
  value : String,
) -> Unit {
  push_indent(builder, indent)
  builder.write_string(label)
  builder.write_string(" : ")
  builder.write_string(value)
  builder.write_char('\n')
}

///|
fn format_value(value : @common.Value) -> String {
  value.to_json().stringify()
}

///|
fn format_log_value(value : @sdklogs.AnyValue) -> String {
  value.to_json().stringify()
}

///|
fn format_status(status : @sdktrace.Status) -> String {
  let code = match status.code {
    @sdktrace.StatusCode::Unset => "Unset"
    @sdktrace.StatusCode::Ok => "Ok"
    @sdktrace.StatusCode::Error => "Error"
  }
  match status.description {
    Some(description) => "\{code}(\{description.to_json().stringify()})"
    None => code
  }
}

///|
fn format_span_kind(kind : @sdktrace.SpanKind) -> String {
  match kind {
    @sdktrace.SpanKind::Internal => "Internal"
    @sdktrace.SpanKind::Client => "Client"
    @sdktrace.SpanKind::Server => "Server"
    @sdktrace.SpanKind::Producer => "Producer"
    @sdktrace.SpanKind::Consumer => "Consumer"
  }
}

///|
fn format_severity_number(severity : @sdklogs.SeverityNumber) -> String {
  match severity {
    @sdklogs.SeverityNumber::Trace => "Trace"
    @sdklogs.SeverityNumber::Trace2 => "Trace2"
    @sdklogs.SeverityNumber::Trace3 => "Trace3"
    @sdklogs.SeverityNumber::Trace4 => "Trace4"
    @sdklogs.SeverityNumber::Debug => "Debug"
    @sdklogs.SeverityNumber::Debug2 => "Debug2"
    @sdklogs.SeverityNumber::Debug3 => "Debug3"
    @sdklogs.SeverityNumber::Debug4 => "Debug4"
    @sdklogs.SeverityNumber::Info => "Info"
    @sdklogs.SeverityNumber::Info2 => "Info2"
    @sdklogs.SeverityNumber::Info3 => "Info3"
    @sdklogs.SeverityNumber::Info4 => "Info4"
    @sdklogs.SeverityNumber::Warn => "Warn"
    @sdklogs.SeverityNumber::Warn2 => "Warn2"
    @sdklogs.SeverityNumber::Warn3 => "Warn3"
    @sdklogs.SeverityNumber::Warn4 => "Warn4"
    @sdklogs.SeverityNumber::Error => "Error"
    @sdklogs.SeverityNumber::Error2 => "Error2"
    @sdklogs.SeverityNumber::Error3 => "Error3"
    @sdklogs.SeverityNumber::Error4 => "Error4"
    @sdklogs.SeverityNumber::Fatal => "Fatal"
    @sdklogs.SeverityNumber::Fatal2 => "Fatal2"
    @sdklogs.SeverityNumber::Fatal3 => "Fatal3"
    @sdklogs.SeverityNumber::Fatal4 => "Fatal4"
  }
}

///|
fn format_instrument_kind(kind : @sdkmetrics.InstrumentKind) -> String {
  match kind {
    @sdkmetrics.InstrumentKind::Counter => "Counter"
    @sdkmetrics.InstrumentKind::UpDownCounter => "UpDownCounter"
    @sdkmetrics.InstrumentKind::Histogram => "Histogram"
    @sdkmetrics.InstrumentKind::Gauge => "Gauge"
    @sdkmetrics.InstrumentKind::ObservableCounter => "ObservableCounter"
    @sdkmetrics.InstrumentKind::ObservableUpDownCounter =>
      "ObservableUpDownCounter"
    @sdkmetrics.InstrumentKind::ObservableGauge => "ObservableGauge"
  }
}

///|
fn format_number(number : @sdkmetrics.Number) -> String {
  match number {
    @sdkmetrics.Number::Int64(value) => value.to_string()
    @sdkmetrics.Number::UInt64(value) => value.to_string()
    @sdkmetrics.Number::Double(value) => value.to_string()
  }
}

///|
fn write_array_attributes(
  builder : StringBuilder,
  header_indent : Int,
  item_indent : Int,
  attributes : ArrayView[@common.KeyValue],
) -> Unit {
  if attributes.length() == 0 {
    return
  }
  push_indent(builder, header_indent)
  push_line(builder, "Attributes:")
  for attribute in attributes {
    push_indent(builder, item_indent)
    builder.write_string("-> ")
    builder.write_string(attribute.key.as_string())
    builder.write_string("=")
    builder.write_string(format_value(attribute.value))
    builder.write_char('\n')
  }
}

///|
fn write_log_attributes(
  builder : StringBuilder,
  header_indent : Int,
  item_indent : Int,
  attributes : ArrayView[@sdklogs.KeyValue],
) -> Unit {
  if attributes.length() == 0 {
    return
  }
  push_indent(builder, header_indent)
  push_line(builder, "Attributes:")
  for attribute in attributes {
    push_indent(builder, item_indent)
    builder.write_string("-> ")
    builder.write_string(attribute.key.as_string())
    builder.write_string("=")
    builder.write_string(format_log_value(attribute.value))
    builder.write_char('\n')
  }
}

///|
fn write_map_attributes(
  builder : StringBuilder,
  header_indent : Int,
  item_indent : Int,
  attributes : Map[String, @common.Value],
) -> Unit {
  if attributes.is_empty() {
    return
  }
  push_indent(builder, header_indent)
  push_line(builder, "Attributes:")
  for key, value in attributes {
    push_indent(builder, item_indent)
    builder.write_string("-> ")
    builder.write_string(key)
    builder.write_string("=")
    builder.write_string(format_value(value))
    builder.write_char('\n')
  }
}

///|
fn write_resource(
  builder : StringBuilder,
  resource : @resource.Resource,
) -> Unit {
  push_line(builder, "Resource")
  match resource.schema_url() {
    Some(schema_url) =>
      push_field(builder, 2, "SchemaUrl", schema_url.to_json().stringify())
    None => ()
  }
  write_map_attributes(builder, 2, 4, resource.attributes())
}

///|
fn write_scope(
  builder : StringBuilder,
  scope : @common.InstrumentationScope,
) -> Unit {
  push_line(builder, "  Instrumentation Scope")
  push_field(builder, 4, "Name", scope.name().to_json().stringify())
  match scope.version() {
    Some(version) =>
      push_field(builder, 4, "Version", version.to_json().stringify())
    None => ()
  }
  match scope.schema_url() {
    Some(schema_url) =>
      push_field(builder, 4, "SchemaUrl", schema_url.to_json().stringify())
    None => ()
  }
  write_array_attributes(builder, 4, 6, scope.attributes())
}

///|
fn render_span_batch(
  batch : ArrayView[@sdktrace.SpanData],
  include_resource : Bool,
) -> String {
  let builder = StringBuilder::new()
  push_line(builder, "Spans")
  if include_resource && batch.length() > 0 {
    write_resource(builder, batch[0].resource)
  }
  for i = 0; i < batch.length(); i = i + 1 {
    let span = batch[i]
    push_line(builder, "Span #\{i}")
    write_scope(builder, span.instrumentation_scope)
    push_field(builder, 2, "Name", span.name.to_json().stringify())
    push_field(builder, 2, "TraceId", span.span_context.trace_id().to_hex())
    push_field(builder, 2, "SpanId", span.span_context.span_id().to_hex())
    push_field(
      builder,
      2,
      "TraceFlags",
      span.span_context.trace_flags().to_hex(),
    )
    match span.parent_span_context {
      Some(parent_span_context) =>
        push_field(
          builder,
          2,
          "ParentSpanId",
          parent_span_context.span_id().to_hex(),
        )
      None => push_field(builder, 2, "ParentSpanId", "None (root span)")
    }
    push_field(builder, 2, "Kind", format_span_kind(span.kind))
    push_field(
      builder,
      2,
      "StartTimeUnixNano",
      span.start_time_unix_nano.to_string(),
    )
    match span.end_time_unix_nano {
      Some(end_time_unix_nano) =>
        push_field(
          builder,
          2,
          "EndTimeUnixNano",
          end_time_unix_nano.to_string(),
        )
      None => push_field(builder, 2, "EndTimeUnixNano", "None")
    }
    push_field(builder, 2, "Status", format_status(span.status))
    write_array_attributes(builder, 2, 4, span.attributes)
    if span.events.length() > 0 {
      push_line(builder, "  Events:")
      for index = 0; index < span.events.length(); index = index + 1 {
        let event = span.events[index]
        push_line(builder, "    Event #\{index}")
        push_field(builder, 6, "Name", event.name.to_json().stringify())
        push_field(
          builder,
          6,
          "TimestampUnixNano",
          event.timestamp_unix_nano.to_string(),
        )
        write_array_attributes(builder, 6, 8, event.attributes)
      }
    }
    if span.links.length() > 0 {
      push_line(builder, "  Links:")
      for index = 0; index < span.links.length(); index = index + 1 {
        let link = span.links[index]
        push_line(builder, "    Link #\{index}")
        push_field(builder, 6, "TraceId", link.span_context.trace_id().to_hex())
        push_field(builder, 6, "SpanId", link.span_context.span_id().to_hex())
        write_array_attributes(builder, 6, 8, link.attributes)
      }
    }
  }
  builder.to_string()
}

///|
fn render_log_batch(
  batch : ArrayView[@sdklogs.LogRecord],
  include_resource : Bool,
) -> String {
  let builder = StringBuilder::new()
  push_line(builder, "Logs")
  if include_resource && batch.length() > 0 {
    write_resource(builder, batch[0].resource)
  }
  for i = 0; i < batch.length(); i = i + 1 {
    let record = batch[i]
    push_line(builder, "Log #\{i}")
    write_scope(builder, record.instrumentation_scope)
    match record.trace_context {
      Some(trace_context) => {
        push_field(builder, 2, "TraceId", trace_context.trace_id().to_hex())
        push_field(builder, 2, "SpanId", trace_context.span_id().to_hex())
        push_field(
          builder,
          2,
          "TraceFlags",
          trace_context.trace_flags().to_hex(),
        )
      }
      None => ()
    }
    push_field(
      builder,
      2,
      "TimestampUnixNano",
      record.timestamp_unix_nano.to_string(),
    )
    push_field(
      builder,
      2,
      "ObservedTimestampUnixNano",
      record.observed_timestamp_unix_nano.to_string(),
    )
    match record.severity_text {
      Some(severity_text) =>
        push_field(
          builder,
          2,
          "SeverityText",
          severity_text.to_json().stringify(),
        )
      None => ()
    }
    match record.severity_number {
      Some(severity_number) =>
        push_field(
          builder,
          2,
          "SeverityNumber",
          format_severity_number(severity_number),
        )
      None => ()
    }
    push_field(builder, 2, "Body", format_log_value(record.body))
    write_log_attributes(builder, 2, 4, record.attributes)
  }
  builder.to_string()
}

///|
fn write_metric_aggregation(
  builder : StringBuilder,
  aggregation : @sdkmetrics.Aggregation,
) -> Unit {
  match aggregation {
    @sdkmetrics.Aggregation::Sum(number) => {
      push_field(builder, 2, "Aggregation", "Sum")
      push_field(builder, 4, "Value", format_number(number))
    }
    @sdkmetrics.Aggregation::Gauge(number) => {
      push_field(builder, 2, "Aggregation", "Gauge")
      push_field(builder, 4, "Value", format_number(number))
    }
    @sdkmetrics.Aggregation::Histogram(summary) => {
      push_field(builder, 2, "Aggregation", "Histogram")
      push_field(builder, 4, "Count", summary.count.to_string())
      push_field(builder, 4, "Sum", format_number(summary.sum))
      match summary.min {
        Some(min) => push_field(builder, 4, "Min", format_number(min))
        None => ()
      }
      match summary.max {
        Some(max) => push_field(builder, 4, "Max", format_number(max))
        None => ()
      }
    }
  }
}

///|
fn render_metric_batch(batch : ArrayView[@sdkmetrics.MetricData]) -> String {
  let builder = StringBuilder::new()
  push_line(builder, "Metrics")
  if batch.length() > 0 {
    write_resource(builder, batch[0].resource)
  }
  for i = 0; i < batch.length(); i = i + 1 {
    let metric = batch[i]
    push_line(builder, "Metric #\{i}")
    write_scope(builder, metric.instrumentation_scope)
    push_field(builder, 2, "Name", metric.name.to_json().stringify())
    match metric.description {
      Some(description) =>
        push_field(builder, 2, "Description", description.to_json().stringify())
      None => ()
    }
    match metric.unit {
      Some(unit) => push_field(builder, 2, "Unit", unit.to_json().stringify())
      None => ()
    }
    push_field(builder, 2, "Kind", format_instrument_kind(metric.kind))
    push_field(builder, 2, "TimeUnixNano", metric.time_unix_nano.to_string())
    write_array_attributes(builder, 2, 4, metric.attributes)
    write_metric_aggregation(builder, metric.aggregation)
  }
  builder.to_string()
}

///|
pub impl Default for SpanExporter with default() -> SpanExporter {
  { state: Ref::new({ is_shutdown: false, resource_emitted: false }) }
}

///|
pub impl Default for LogExporter with default() -> LogExporter {
  { state: Ref::new({ is_shutdown: false, resource_emitted: false }) }
}

///|
pub impl Default for MetricExporter with default() -> MetricExporter {
  MetricExporter::builder().build()
}

///|
/// Creates a stdout span exporter.
pub fn SpanExporter::new() -> SpanExporter {
  Default::default()
}

///|
/// Creates a stdout log exporter.
pub fn LogExporter::new() -> LogExporter {
  Default::default()
}

///|
/// Starts building a stdout metric exporter.
pub fn MetricExporter::builder() -> MetricExporterBuilder {
  { temporality: @sdkmetrics.Temporality::Cumulative }
}

///|
/// Sets the temporality that `into_periodic_reader()` should use.
pub fn MetricExporterBuilder::with_temporality(
  self : MetricExporterBuilder,
  temporality : @sdkmetrics.Temporality,
) -> MetricExporterBuilder {
  self.temporality = temporality
  self
}

///|
/// Builds a stdout metric exporter.
pub fn MetricExporterBuilder::build(
  self : MetricExporterBuilder,
) -> MetricExporter {
  { state: Ref::new({ is_shutdown: false }), temporality: self.temporality }
}

///|
/// Returns the configured temporality.
pub fn MetricExporter::temporality(
  self : MetricExporter,
) -> @sdkmetrics.Temporality {
  self.temporality
}

///|
/// Exports one batch of finished spans to stdout.
pub fn SpanExporter::export_batch(
  self : SpanExporter,
  batch : ArrayView[@sdktrace.SpanData],
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  println(render_span_batch(batch, !self.state.val.resource_emitted))
  if !self.state.val.resource_emitted && batch.length() > 0 {
    self.state.val = { ..self.state.val, resource_emitted: true }
  }
  @error.ok()
}

///|
/// Exports one batch of log records to stdout.
pub fn LogExporter::export_batch(
  self : LogExporter,
  batch : ArrayView[@sdklogs.LogRecord],
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  println(render_log_batch(batch, !self.state.val.resource_emitted))
  if !self.state.val.resource_emitted && batch.length() > 0 {
    self.state.val = { ..self.state.val, resource_emitted: true }
  }
  @error.ok()
}

///|
/// Exports one batch of metrics to stdout.
pub fn MetricExporter::export_batch(
  self : MetricExporter,
  batch : ArrayView[@sdkmetrics.MetricData],
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  println(render_metric_batch(batch))
  @error.ok()
}

///|
/// Requests span exporter flush.
pub fn SpanExporter::force_flush(self : SpanExporter) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    @error.already_shutdown()
  } else {
    @error.ok()
  }
}

///|
/// Requests log exporter flush.
pub fn LogExporter::force_flush(self : LogExporter) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    @error.already_shutdown()
  } else {
    @error.ok()
  }
}

///|
/// Requests metric exporter flush.
pub fn MetricExporter::force_flush(
  self : MetricExporter,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    @error.already_shutdown()
  } else {
    @error.ok()
  }
}

///|
/// Requests span exporter shutdown with an optional timeout budget in
/// milliseconds.
pub fn SpanExporter::shutdown_with_timeout(
  self : SpanExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = { ..self.state.val, is_shutdown: true }
  @error.ok()
}

///|
/// Requests log exporter shutdown with an optional timeout budget in
/// milliseconds.
pub fn LogExporter::shutdown_with_timeout(
  self : LogExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = { ..self.state.val, is_shutdown: true }
  @error.ok()
}

///|
/// Requests metric exporter shutdown with an optional timeout budget in
/// milliseconds.
pub fn MetricExporter::shutdown_with_timeout(
  self : MetricExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = { is_shutdown: true }
  @error.ok()
}

///|
/// Requests span exporter shutdown.
pub fn SpanExporter::shutdown(self : SpanExporter) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Requests log exporter shutdown.
pub fn LogExporter::shutdown(self : LogExporter) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Requests metric exporter shutdown.
pub fn MetricExporter::shutdown(self : MetricExporter) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Returns a human-readable exporter name.
pub fn SpanExporter::name(self : SpanExporter) -> String {
  ignore(self)
  "print"
}

///|
/// Returns a human-readable exporter name.
pub fn LogExporter::name(self : LogExporter) -> String {
  ignore(self)
  "print"
}

///|
/// Returns a human-readable exporter name.
pub fn MetricExporter::name(self : MetricExporter) -> String {
  ignore(self)
  "print"
}

///|
/// Erases the concrete span exporter type into `@sdktrace.SpanExporter`.
pub fn SpanExporter::into_span_exporter(
  self : SpanExporter,
) -> @sdktrace.SpanExporter {
  @sdktrace.SpanExporter::new(
    (batch : ArrayView[@sdktrace.SpanData]) => self.export_batch(batch),
    force_flush_fn=() => self.force_flush(),
    shutdown_fn=() => self.shutdown(),
    name_fn=() => self.name(),
  )
}

///|
/// Erases the concrete log exporter type into `@sdklogs.LogExporter`.
pub fn LogExporter::into_log_exporter(
  self : LogExporter,
) -> @sdklogs.LogExporter {
  @sdklogs.LogExporter::new(
    (batch : ArrayView[@sdklogs.LogRecord]) => self.export_batch(batch),
    force_flush_fn=() => self.force_flush(),
    shutdown_fn=() => self.shutdown(),
    name_fn=() => self.name(),
  )
}

///|
/// Erases the concrete metric exporter type into `@sdkmetrics.MetricExporter`.
pub fn MetricExporter::into_metric_exporter(
  self : MetricExporter,
) -> @sdkmetrics.MetricExporter {
  @sdkmetrics.MetricExporter::new(
    (batch : ArrayView[@sdkmetrics.MetricData]) => self.export_batch(batch),
    force_flush_fn=() => self.force_flush(),
    shutdown_fn=() => self.shutdown(),
    name_fn=() => self.name(),
  )
}

///|
/// Builds a periodic reader using this exporter's configured temporality. Use
/// this when you want the builder temporality to affect collected metric data.
pub fn MetricExporter::into_periodic_reader(
  self : MetricExporter,
  interval_millis? : Int = -1,
) -> @sdkmetrics.PeriodicMetricReader {
  let builder = @sdkmetrics.PeriodicMetricReader::builder(
    self.into_metric_exporter(),
  ).with_temporality(self.temporality)
  if interval_millis < 0 {
    builder.build()
  } else {
    builder.with_interval(interval_millis).build()
  }
}
