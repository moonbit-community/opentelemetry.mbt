///|
/// Full OpenTelemetry severity ladder used by `LogRecord`.
///
/// The 24 slots let bridges preserve finer-grained severity from existing
/// logging frameworks.
pub(all) enum SeverityNumber {
  Trace
  Trace2
  Trace3
  Trace4
  Debug
  Debug2
  Debug3
  Debug4
  Info
  Info2
  Info3
  Info4
  Warn
  Warn2
  Warn3
  Warn4
  Error
  Error2
  Error3
  Error4
  Fatal
  Fatal2
  Fatal3
  Fatal4
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Structured log value preserved by the SDK and OTLP exporter.
///
/// Use `Map` and `Array` when the backend should receive structured payloads
/// rather than preformatted strings.
pub(all) enum AnyValue {
  Bool(Bool)
  Int64(Int64)
  Double(Double)
  String(String)
  Bytes(Bytes)
  Array(Array[AnyValue])
  Map(Array[KeyValue])
} derive(Eq, ToJson, Debug)

///|
/// Structured log attribute key/value pair.
pub struct KeyValue {
  key : @common.Key
  value : AnyValue
} derive(Eq, ToJson, Debug)

///|
/// Immutable log payload exported by processors and exporters.
pub struct LogRecord {
  event_name : String?
  target : String?
  body : AnyValue
  timestamp_unix_nano : Int64
  observed_timestamp_unix_nano : Int64
  severity_number : SeverityNumber?
  severity_text : String?
  attributes : Array[KeyValue]
  trace_context : @common.SpanContext?
  resource : @resource.Resource
  instrumentation_scope : @common.InstrumentationScope
} derive(Eq, ToJson, Debug)

///|
/// Exporter callback wrapper for log batches.
pub struct LogExporter {
  export_fn : async (ArrayView[LogRecord]) -> @error.OTelSdkResult
  force_flush_fn : async () -> @error.OTelSdkResult
  shutdown_fn : async () -> @error.OTelSdkResult
  name_fn : () -> String
}

///|
/// Processing hook interface for logs.
///
/// Processors receive immutable log snapshots after the logger attaches
/// resource and instrumentation scope metadata.
pub struct LogProcessor {
  emit_fn : async (LogRecord) -> Unit
  force_flush_fn : async () -> @error.OTelSdkResult
  shutdown_fn : async () -> @error.OTelSdkResult
}

///|
/// Processor that exports each log record immediately.
///
/// Useful for tests and local debugging. Network exporters should usually be
/// wrapped by `BatchLogProcessor`.
pub struct SimpleLogProcessor {
  inner : LogProcessor
}

///|
/// Processor that buffers log records and exports them in batches.
///
/// The background loop is not started automatically. Use global/facade
/// `spawn_background_tasks()` after provider registration.
pub struct BatchLogProcessor {
  inner : LogProcessor
  state : Ref[BatchProcessorState]
}

///|
/// Configuration for batch log processing.
pub struct BatchConfig {
  max_queue_size : Int
  max_export_batch_size : Int
  scheduled_delay_millis : Int
  export_timeout_millis : Int
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
struct InMemoryLogExporterState {
  finished_logs : Array[LogRecord]
  is_shutdown : Bool
}

///|
/// Test exporter that keeps finished logs in memory.
pub struct InMemoryLogExporter {
  state : Ref[InMemoryLogExporterState]
}

///|
struct BatchProcessorState {
  exporter : LogExporter
  config : BatchConfig
  queue : Array[LogRecord]
  is_shutdown : Bool
}

///|
struct LoggerProviderState {
  resource : @resource.Resource
  processors : Array[LogProcessor]
  batch_processors : Array[BatchLogProcessor]
  is_shutdown : Bool
}

///|
/// Owns resource metadata and the processor pipeline for loggers.
///
/// Applications create one provider, configure processors/exporters, register it
/// if needed, then shut it down during application teardown.
pub struct SdkLoggerProvider {
  state : Ref[LoggerProviderState]
}

///|
/// Builder for `SdkLoggerProvider`.
pub struct SdkLoggerProviderBuilder {
  mut resource : @resource.Resource
  processors : Array[LogProcessor]
  batch_processors : Array[BatchLogProcessor]
}

///|
/// Logger scoped to one instrumentation library.
///
/// The instrumentation scope is copied onto every emitted log record.
pub struct SdkLogger {
  provider : SdkLoggerProvider
  instrumentation_scope : @common.InstrumentationScope
}

///|
/// Creates a structured log attribute.
pub fn KeyValue::new(key : StringView, value : AnyValue) -> KeyValue {
  { key: @common.Key::new(key), value }
}

///|
/// Converts a shared SDK attribute value into a log-specific structured value.
pub fn AnyValue::from_common(value : @common.Value) -> AnyValue {
  match value {
    @common.Value::Bool(value) => AnyValue::Bool(value)
    @common.Value::Int64(value) => AnyValue::Int64(value)
    @common.Value::Double(value) => AnyValue::Double(value)
    @common.Value::String(value) => AnyValue::String(value)
    @common.Value::Bytes(value) => AnyValue::Bytes(value)
    @common.Value::Array(values) => {
      let converted = []
      for value in values {
        converted.push(AnyValue::from_common(value))
      }
      AnyValue::Array(converted)
    }
  }
}

///|
/// Converts a shared SDK attribute into a log-specific structured attribute.
pub fn KeyValue::from_common(attribute : @common.KeyValue) -> KeyValue {
  { key: attribute.key, value: AnyValue::from_common(attribute.value) }
}

///|
/// Creates a log record snapshot.
///
/// This is the immutable SDK-side representation. Public API users usually
/// build `interface/logs.LogRecord` values and let `Logger::emit()` convert
/// them into this type.
pub fn LogRecord::new(
  body : AnyValue,
  timestamp_unix_nano? : Int64 = @utils.now_unix_nano(),
  observed_timestamp_unix_nano? : Int64 = @utils.now_unix_nano(),
  severity_number? : SeverityNumber? = None,
  severity_text? : String? = None,
  event_name? : String? = None,
  target? : String? = None,
  attributes? : ArrayView[KeyValue] = [],
  trace_context? : @common.SpanContext? = None,
  resource? : @resource.Resource = @resource.Resource::empty(),
  instrumentation_scope? : @common.InstrumentationScope = Default::default(),
) -> LogRecord {
  {
    event_name,
    target,
    body,
    timestamp_unix_nano,
    observed_timestamp_unix_nano,
    severity_number,
    severity_text,
    attributes: attributes.to_array(),
    trace_context,
    resource,
    instrumentation_scope,
  }
}

///|
fn parse_env_int(key : StringView) -> Int? {
  match @utils.getenv(key) {
    Some(value) => {
      let value = value.trim()
      if value == "" {
        None
      } else {
        Some(@string.parse_int(value.to_string()) catch { _ => return None })
      }
    }
    None => None
  }
}

///|
fn env_or(key : StringView, fallback : Int) -> Int {
  match parse_env_int(key) {
    Some(value) => value
    None => fallback
  }
}

///|
/// Creates normalized batch log processor configuration.
pub fn BatchConfig::new(
  max_queue_size? : Int = 2048,
  max_export_batch_size? : Int = 512,
  scheduled_delay_millis? : Int = 1000,
  export_timeout_millis? : Int = 30000,
) -> BatchConfig {
  let max_queue_size = if max_queue_size <= 0 { 1 } else { max_queue_size }
  let max_export_batch_size = if max_export_batch_size <= 0 {
    1
  } else if max_export_batch_size > max_queue_size {
    max_queue_size
  } else {
    max_export_batch_size
  }
  let scheduled_delay_millis = if scheduled_delay_millis <= 0 {
    1
  } else {
    scheduled_delay_millis
  }
  let export_timeout_millis = if export_timeout_millis <= 0 {
    1
  } else {
    export_timeout_millis
  }
  {
    max_queue_size,
    max_export_batch_size,
    scheduled_delay_millis,
    export_timeout_millis,
  }
}

///|
pub impl Default for BatchConfig with default() -> BatchConfig {
  BatchConfig::new(
    max_queue_size=env_or("OTEL_BLRP_MAX_QUEUE_SIZE", 2048),
    max_export_batch_size=env_or("OTEL_BLRP_MAX_EXPORT_BATCH_SIZE", 512),
    scheduled_delay_millis=env_or("OTEL_BLRP_SCHEDULE_DELAY", 1000),
    export_timeout_millis=env_or("OTEL_BLRP_EXPORT_TIMEOUT", 30000),
  )
}

///|
/// Builds a log exporter from callbacks.
pub fn LogExporter::new(
  export_fn : async (ArrayView[LogRecord]) -> @error.OTelSdkResult,
  force_flush_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  shutdown_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  name_fn? : () -> String = () => "custom",
) -> LogExporter {
  { export_fn, force_flush_fn, shutdown_fn, name_fn }
}

///|
/// Exports one batch of log records.
pub async fn LogExporter::export_batch(
  self : LogExporter,
  batch : ArrayView[LogRecord],
) -> @error.OTelSdkResult {
  (self.export_fn)(batch)
}

///|
/// Requests exporter flush.
pub async fn LogExporter::force_flush(
  self : LogExporter,
) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests exporter shutdown with an optional timeout budget in milliseconds.
pub async fn LogExporter::shutdown_with_timeout(
  self : LogExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  (self.shutdown_fn)()
}

///|
/// Requests exporter shutdown.
pub async fn LogExporter::shutdown(self : LogExporter) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Returns a human-readable exporter name.
pub fn LogExporter::name(self : LogExporter) -> String {
  (self.name_fn)()
}

///|
/// Builds a log processor from callbacks.
pub fn LogProcessor::new(
  emit_fn? : async (LogRecord) -> Unit = _ => (),
  force_flush_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  shutdown_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
) -> LogProcessor {
  { emit_fn, force_flush_fn, shutdown_fn }
}

///|
/// Processes one log record.
pub async fn LogProcessor::emit(
  self : LogProcessor,
  record : LogRecord,
) -> Unit {
  (self.emit_fn)(record)
}

///|
/// Requests processor flush.
pub async fn LogProcessor::force_flush(
  self : LogProcessor,
) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests processor shutdown with an optional timeout budget in milliseconds.
pub async fn LogProcessor::shutdown_with_timeout(
  self : LogProcessor,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  (self.shutdown_fn)()
}

///|
/// Requests processor shutdown.
pub async fn LogProcessor::shutdown(
  self : LogProcessor,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Creates an empty in-memory log exporter.
pub fn InMemoryLogExporter::new() -> InMemoryLogExporter {
  { state: Ref::new({ finished_logs: [], is_shutdown: false }) }
}

///|
/// Returns the finished log records accumulated so far.
pub fn InMemoryLogExporter::finished_logs(
  self : InMemoryLogExporter,
) -> Array[LogRecord] {
  self.state.val.finished_logs.copy()
}

///|
/// Clears the in-memory log buffer.
pub fn InMemoryLogExporter::reset(self : InMemoryLogExporter) -> Unit {
  self.state.val = { ..self.state.val, finished_logs: [] }
}

///|
/// Erases the concrete in-memory exporter type into `LogExporter`.
pub fn InMemoryLogExporter::into_log_exporter(
  self : InMemoryLogExporter,
) -> LogExporter {
  let state = self.state
  LogExporter::new(
    (batch : ArrayView[LogRecord]) => {
      if state.val.is_shutdown {
        return @error.already_shutdown()
      }
      let finished_logs = state.val.finished_logs.copy()
      finished_logs.append(batch)
      state.val = { ..state.val, finished_logs, }
      @error.ok()
    },
    shutdown_fn=() => {
      if state.val.is_shutdown {
        @error.already_shutdown()
      } else {
        state.val = { ..state.val, is_shutdown: true }
        @error.ok()
      }
    },
    name_fn=() => "in_memory",
  )
}

///|
/// Creates a simple processor that exports each emitted record immediately.
pub fn SimpleLogProcessor::new(exporter : LogExporter) -> SimpleLogProcessor {
  {
    inner: LogProcessor::new(
      emit_fn=(record : LogRecord) => ignore(exporter.export_batch([record])),
      force_flush_fn=() => exporter.force_flush(),
      shutdown_fn=() => exporter.shutdown(),
    ),
  }
}

///|
/// Erases the concrete simple processor type into `LogProcessor`.
pub fn SimpleLogProcessor::into_log_processor(
  self : SimpleLogProcessor,
) -> LogProcessor {
  self.inner
}

///|
/// Flushes the in-memory queue to the exporter in batch-sized chunks.
async fn flush_log_queue(
  state : Ref[BatchProcessorState],
) -> @error.OTelSdkResult {
  if state.val.is_shutdown {
    return @error.already_shutdown()
  }
  while !state.val.queue.is_empty() {
    let batch : Array[LogRecord] = []
    let batch_size = if state.val.queue.length() <
      state.val.config.max_export_batch_size {
      state.val.queue.length()
    } else {
      state.val.config.max_export_batch_size
    }
    for i = 0; i < batch_size; i = i + 1 {
      ignore(i)
      batch.push(state.val.queue.remove(0))
    }
    match state.val.exporter.export_batch(batch) {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  @error.ok()
}

///|
/// Creates a batch log processor with a bounded queue.
pub fn BatchLogProcessor::new(
  exporter : LogExporter,
  config? : BatchConfig = Default::default(),
) -> BatchLogProcessor {
  let state : Ref[BatchProcessorState] = Ref::new({
    exporter,
    config,
    queue: [],
    is_shutdown: false,
  })
  {
    inner: LogProcessor::new(
      emit_fn=(record : LogRecord) => {
        if state.val.is_shutdown {
          return
        }
        if state.val.queue.length() >= state.val.config.max_queue_size {
          // Keep the newest records under sustained pressure.
          ignore(state.val.queue.remove(0))
        }
        state.val.queue.push(record)
        if state.val.queue.length() >= state.val.config.max_export_batch_size {
          ignore(flush_log_queue(state))
        }
      },
      force_flush_fn=() => {
        match flush_log_queue(state) {
          Ok(_) => state.val.exporter.force_flush()
          Err(err) => Err(err)
        }
      },
      shutdown_fn=() => {
        if state.val.is_shutdown {
          return @error.already_shutdown()
        }
        let result = flush_log_queue(state)
        state.val = { ..state.val, is_shutdown: true }
        match result {
          Ok(_) =>
            state.val.exporter.shutdown_with_timeout(
              state.val.config.export_timeout_millis,
            )
          Err(err) => Err(err)
        }
      },
    ),
    state,
  }
}

///|
/// Erases the concrete batch processor type into `LogProcessor`.
pub fn BatchLogProcessor::into_log_processor(
  self : BatchLogProcessor,
) -> LogProcessor {
  self.inner
}

///|
/// Background loop for scheduled batch exports.
pub async fn BatchLogProcessor::run(self : BatchLogProcessor) -> Unit {
  while !self.state.val.is_shutdown {
    @async.sleep(self.state.val.config.scheduled_delay_millis)
    if self.state.val.is_shutdown {
      return
    }
    ignore(flush_log_queue(self.state))
    ignore(self.state.val.exporter.force_flush())
  }
}

///|
/// Starts building a logger provider with the default resource.
///
/// Add processors or exporters before calling `build()`. A provider with no
/// processors accepts logs but exports nothing.
pub fn SdkLoggerProvider::builder() -> SdkLoggerProviderBuilder {
  {
    resource: @resource.Resource::builder().build(),
    processors: [],
    batch_processors: [],
  }
}

///|
/// Replaces the provider resource.
pub fn SdkLoggerProviderBuilder::with_resource(
  self : SdkLoggerProviderBuilder,
  resource : @resource.Resource,
) -> SdkLoggerProviderBuilder {
  self.resource = resource
  self
}

///|
/// Appends a processor to the logger pipeline.
pub fn SdkLoggerProviderBuilder::with_log_processor(
  self : SdkLoggerProviderBuilder,
  processor : LogProcessor,
) -> SdkLoggerProviderBuilder {
  self.processors.push(processor)
  self
}

///|
/// Appends a simple processor around the exporter.
///
/// Each emitted log is exported from `SdkLogger::emit()`.
pub fn SdkLoggerProviderBuilder::with_simple_exporter(
  self : SdkLoggerProviderBuilder,
  exporter : LogExporter,
) -> SdkLoggerProviderBuilder {
  self.with_log_processor(
    SimpleLogProcessor::new(exporter).into_log_processor(),
  )
}

///|
/// Appends a batch processor around the exporter and registers it for
/// background execution.
///
/// The processor is registered with the provider, but its export loop only runs
/// after `spawn_batch_processor_tasks()` or the facade/global equivalent is
/// called.
pub fn SdkLoggerProviderBuilder::with_batch_exporter(
  self : SdkLoggerProviderBuilder,
  exporter : LogExporter,
  config? : BatchConfig = Default::default(),
) -> SdkLoggerProviderBuilder {
  let batch_processor = BatchLogProcessor::new(exporter, config~)
  self.batch_processors.push(batch_processor)
  self.with_log_processor(batch_processor.into_log_processor())
}

///|
/// Builds the logger provider.
pub fn SdkLoggerProviderBuilder::build(
  self : SdkLoggerProviderBuilder,
) -> SdkLoggerProvider {
  {
    state: Ref::new({
      resource: self.resource,
      processors: self.processors.copy(),
      batch_processors: self.batch_processors.copy(),
      is_shutdown: false,
    }),
  }
}

///|
/// Returns the provider resource.
pub fn SdkLoggerProvider::resource(
  self : SdkLoggerProvider,
) -> @resource.Resource {
  self.state.val.resource
}

///|
/// Spawns background tasks for all configured batch processors.
pub fn SdkLoggerProvider::spawn_batch_processor_tasks(
  self : SdkLoggerProvider,
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  for batch_processor in self.state.val.batch_processors {
    group.spawn_bg(no_wait=true, allow_failure~, () => batch_processor.run())
  }
}

///|
/// Creates a logger scoped to the supplied instrumentation library metadata.
pub fn SdkLoggerProvider::logger(
  self : SdkLoggerProvider,
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> SdkLogger {
  let mut scope = @common.InstrumentationScope::builder(name)
  match version {
    Some(version) => scope = scope.with_version(version)
    None => ()
  }
  match schema_url {
    Some(schema_url) => scope = scope.with_schema_url(schema_url)
    None => ()
  }
  scope = scope.with_attributes(attributes)
  { provider: self, instrumentation_scope: scope.build() }
}

///|
/// Flushes every configured processor.
pub async fn SdkLoggerProvider::force_flush(
  self : SdkLoggerProvider,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  for processor in self.state.val.processors {
    match processor.force_flush() {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  @error.ok()
}

///|
/// Shuts down every configured processor and marks the provider unusable.
pub async fn SdkLoggerProvider::shutdown_with_timeout(
  self : SdkLoggerProvider,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  let processors = self.state.val.processors.copy()
  self.state.val = { ..self.state.val, is_shutdown: true }
  for processor in processors {
    match processor.shutdown_with_timeout(timeout_millis) {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  @error.ok()
}

///|
pub async fn SdkLoggerProvider::shutdown(
  self : SdkLoggerProvider,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
fn api_sorted_keys(values : Map[String, @api.AnyValue]) -> Array[String] {
  let keys = values.keys().to_array()
  for i in 1..<keys.length() {
    let current = keys[i]
    let mut j = i
    while j > 0 && current < keys[j - 1] {
      keys[j] = keys[j - 1]
      j = j - 1
    }
    keys[j] = current
  }
  keys
}

///|
fn any_value_from_api(value : @api.AnyValue) -> AnyValue {
  match value {
    @api.AnyValue::Int(value) => AnyValue::Int64(value)
    @api.AnyValue::Double(value) => AnyValue::Double(value)
    @api.AnyValue::String(value) => AnyValue::String(value)
    @api.AnyValue::Boolean(value) => AnyValue::Bool(value)
    @api.AnyValue::Bytes(value) => AnyValue::Bytes(value)
    @api.AnyValue::ListAny(values) => {
      let converted = []
      for value in values {
        converted.push(any_value_from_api(value))
      }
      AnyValue::Array(converted)
    }
    @api.AnyValue::Map(values) => {
      let converted = []
      for key in api_sorted_keys(values) {
        guard values.get(key) is Some(value)
        converted.push(KeyValue::new(key, any_value_from_api(value)))
      }
      AnyValue::Map(converted)
    }
  }
}

///|
fn key_value_from_api(attribute : @api.KeyValue) -> KeyValue {
  { key: attribute.key, value: any_value_from_api(attribute.value) }
}

///|
fn severity_from_api(severity : @api.Severity?) -> SeverityNumber? {
  match severity {
    Some(@api.Severity::Trace) => Some(SeverityNumber::Trace)
    Some(@api.Severity::Trace2) => Some(SeverityNumber::Trace2)
    Some(@api.Severity::Trace3) => Some(SeverityNumber::Trace3)
    Some(@api.Severity::Trace4) => Some(SeverityNumber::Trace4)
    Some(@api.Severity::Debug) => Some(SeverityNumber::Debug)
    Some(@api.Severity::Debug2) => Some(SeverityNumber::Debug2)
    Some(@api.Severity::Debug3) => Some(SeverityNumber::Debug3)
    Some(@api.Severity::Debug4) => Some(SeverityNumber::Debug4)
    Some(@api.Severity::Info) => Some(SeverityNumber::Info)
    Some(@api.Severity::Info2) => Some(SeverityNumber::Info2)
    Some(@api.Severity::Info3) => Some(SeverityNumber::Info3)
    Some(@api.Severity::Info4) => Some(SeverityNumber::Info4)
    Some(@api.Severity::Warn) => Some(SeverityNumber::Warn)
    Some(@api.Severity::Warn2) => Some(SeverityNumber::Warn2)
    Some(@api.Severity::Warn3) => Some(SeverityNumber::Warn3)
    Some(@api.Severity::Warn4) => Some(SeverityNumber::Warn4)
    Some(@api.Severity::Error) => Some(SeverityNumber::Error)
    Some(@api.Severity::Error2) => Some(SeverityNumber::Error2)
    Some(@api.Severity::Error3) => Some(SeverityNumber::Error3)
    Some(@api.Severity::Error4) => Some(SeverityNumber::Error4)
    Some(@api.Severity::Fatal) => Some(SeverityNumber::Fatal)
    Some(@api.Severity::Fatal2) => Some(SeverityNumber::Fatal2)
    Some(@api.Severity::Fatal3) => Some(SeverityNumber::Fatal3)
    Some(@api.Severity::Fatal4) => Some(SeverityNumber::Fatal4)
    None => None
  }
}

///|
fn context_from_api_trace_context(
  span_context : @common.SpanContext?,
) -> @context.Context {
  match span_context {
    Some(span_context) if span_context.is_remote() =>
      @context.Context::empty().with_remote_span_context(span_context)
    Some(span_context) =>
      @context.Context::empty().with_span_context(span_context)
    None => @context.Context::empty()
  }
}

///|
fn SdkLogger::into_api_logger(self : SdkLogger) -> @api.Logger {
  @api.Logger::from_functions(
    record => {
      let severity_text = match record.severity_text {
        Some(severity_text) => Some(severity_text)
        None => record.severity_number.map(severity => severity.name())
      }
      let attributes = []
      for attribute in record.attributes {
        attributes.push(key_value_from_api(attribute))
      }
      self.emit(
        match record.body {
          Some(body) => any_value_from_api(body)
          None => AnyValue::String("")
        },
        context=context_from_api_trace_context(record.trace_context),
        severity_number=severity_from_api(record.severity_number),
        severity_text~,
        event_name=record.event_name,
        target=record.target,
        attributes~,
        timestamp_unix_nano=match record.timestamp_unix_nano {
          Some(timestamp_unix_nano) => timestamp_unix_nano
          None => @utils.now_unix_nano()
        },
        observed_timestamp_unix_nano=match record.observed_timestamp_unix_nano {
          Some(observed_timestamp_unix_nano) => observed_timestamp_unix_nano
          None => @utils.now_unix_nano()
        },
      )
    },
    event_enabled_fn=(_, _, _) => !self.provider.state.val.is_shutdown,
  )
}

///|
/// Erases this SDK provider into the public logs API provider.
pub fn SdkLoggerProvider::into_logger_provider(
  self : SdkLoggerProvider,
) -> @api.LoggerProvider {
  @api.LoggerProvider::from_functions(scope => {
    self
    .logger(
      scope.name(),
      version=scope.version(),
      schema_url=scope.schema_url(),
      attributes=scope.attributes(),
    )
    .into_api_logger()
  })
}

///|
/// Extracts a local span context from the supplied context for log correlation.
fn trace_context_from_context(
  context : @context.Context,
) -> @common.SpanContext? {
  match context.span_context() {
    Some(span_context) if span_context.is_valid() =>
      Some(span_context.with_remote(false))
    _ => None
  }
}

///|
/// Emits one log record through the provider pipeline.
///
/// The logger attaches resource and instrumentation scope metadata before
/// forwarding the record to processors.
pub async fn SdkLogger::emit(
  self : SdkLogger,
  body : AnyValue,
  context? : @context.Context = Default::default(),
  severity_number? : SeverityNumber? = None,
  severity_text? : String? = None,
  event_name? : String? = None,
  target? : String? = None,
  attributes? : ArrayView[KeyValue] = [],
  timestamp_unix_nano? : Int64 = @utils.now_unix_nano(),
  observed_timestamp_unix_nano? : Int64 = @utils.now_unix_nano(),
) -> Unit {
  if self.provider.state.val.is_shutdown {
    return
  }
  let record = LogRecord::new(
    body,
    timestamp_unix_nano~,
    observed_timestamp_unix_nano~,
    severity_number~,
    severity_text~,
    event_name~,
    target~,
    attributes~,
    trace_context=trace_context_from_context(context),
    resource=self.provider.state.val.resource,
    instrumentation_scope=self.instrumentation_scope,
  )
  for processor in self.provider.state.val.processors {
    processor.emit(record)
  }
}
