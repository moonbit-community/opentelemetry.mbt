///|
/// Coarse severity buckets used by `LogRecord`.
pub(all) enum SeverityNumber {
  Trace
  Debug
  Info
  Warn
  Error
  Fatal
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Immutable log payload exported by processors and exporters.
pub struct LogRecord {
  body : @common.Value
  timestamp_unix_nano : Int64
  observed_timestamp_unix_nano : Int64
  severity_number : SeverityNumber?
  severity_text : String?
  attributes : Array[@common.KeyValue]
  trace_context : @common.SpanContext?
  resource : @resource.Resource
  instrumentation_scope : @common.InstrumentationScope
} derive(Eq, ToJson, Debug)

///|
/// Exporter callback wrapper for log batches.
pub struct LogExporter {
  export_fn : (ArrayView[LogRecord]) -> @error.OTelSdkResult
  force_flush_fn : () -> @error.OTelSdkResult
  shutdown_fn : () -> @error.OTelSdkResult
  name_fn : () -> String
}

///|
/// Processing hook interface for logs.
pub struct LogProcessor {
  emit_fn : (LogRecord) -> Unit
  force_flush_fn : () -> @error.OTelSdkResult
  shutdown_fn : () -> @error.OTelSdkResult
}

///|
/// Processor that exports each log record immediately.
pub struct SimpleLogProcessor {
  inner : LogProcessor
}

///|
/// Processor that buffers log records and exports them in batches.
pub struct BatchLogProcessor {
  inner : LogProcessor
  state : Ref[BatchProcessorState]
}

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
  config : @trace.BatchConfig
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
pub struct SdkLogger {
  provider : SdkLoggerProvider
  instrumentation_scope : @common.InstrumentationScope
}

///|
/// Creates a log record snapshot.
pub fn LogRecord::new(
  body : @common.Value,
  timestamp_unix_nano? : Int64 = @common.now_unix_nano(),
  observed_timestamp_unix_nano? : Int64 = @common.now_unix_nano(),
  severity_number? : SeverityNumber? = None,
  severity_text? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
  trace_context? : @common.SpanContext? = None,
  resource? : @resource.Resource = @resource.Resource::empty(),
  instrumentation_scope? : @common.InstrumentationScope = Default::default(),
) -> LogRecord {
  {
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
/// Builds a log exporter from callbacks.
pub fn LogExporter::new(
  export_fn : (ArrayView[LogRecord]) -> @error.OTelSdkResult,
  force_flush_fn? : () -> @error.OTelSdkResult = @error.ok,
  shutdown_fn? : () -> @error.OTelSdkResult = @error.ok,
  name_fn? : () -> String = () => "custom",
) -> LogExporter {
  { export_fn, force_flush_fn, shutdown_fn, name_fn }
}

///|
/// Exports one batch of log records.
pub fn LogExporter::export_batch(
  self : LogExporter,
  batch : ArrayView[LogRecord],
) -> @error.OTelSdkResult {
  (self.export_fn)(batch)
}

///|
/// Requests exporter flush.
pub fn LogExporter::force_flush(self : LogExporter) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests exporter shutdown.
pub fn LogExporter::shutdown(self : LogExporter) -> @error.OTelSdkResult {
  (self.shutdown_fn)()
}

///|
/// Returns a human-readable exporter name.
pub fn LogExporter::name(self : LogExporter) -> String {
  (self.name_fn)()
}

///|
/// Builds a log processor from callbacks.
pub fn LogProcessor::new(
  emit_fn? : (LogRecord) -> Unit = _ => (),
  force_flush_fn? : () -> @error.OTelSdkResult = @error.ok,
  shutdown_fn? : () -> @error.OTelSdkResult = @error.ok,
) -> LogProcessor {
  { emit_fn, force_flush_fn, shutdown_fn }
}

///|
/// Processes one log record.
pub fn LogProcessor::emit(self : LogProcessor, record : LogRecord) -> Unit {
  (self.emit_fn)(record)
}

///|
/// Requests processor flush.
pub fn LogProcessor::force_flush(self : LogProcessor) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests processor shutdown.
pub fn LogProcessor::shutdown(self : LogProcessor) -> @error.OTelSdkResult {
  (self.shutdown_fn)()
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
fn flush_log_queue(state : Ref[BatchProcessorState]) -> @error.OTelSdkResult {
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
  config? : @trace.BatchConfig = Default::default(),
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
          Ok(_) => state.val.exporter.shutdown()
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
pub fn SdkLoggerProviderBuilder::with_batch_exporter(
  self : SdkLoggerProviderBuilder,
  exporter : LogExporter,
  config? : @trace.BatchConfig = Default::default(),
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
pub fn SdkLoggerProvider::force_flush(
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
pub fn SdkLoggerProvider::shutdown(
  self : SdkLoggerProvider,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  for processor in self.state.val.processors {
    match processor.shutdown() {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  self.state.val = { ..self.state.val, is_shutdown: true }
  @error.ok()
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
pub fn SdkLogger::emit(
  self : SdkLogger,
  body : @common.Value,
  context? : @context.Context = Default::default(),
  severity_number? : SeverityNumber? = None,
  severity_text? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
  timestamp_unix_nano? : Int64 = @common.now_unix_nano(),
  observed_timestamp_unix_nano? : Int64 = @common.now_unix_nano(),
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
    attributes~,
    trace_context=trace_context_from_context(context),
    resource=self.provider.state.val.resource,
    instrumentation_scope=self.instrumentation_scope,
  )
  for processor in self.provider.state.val.processors {
    processor.emit(record)
  }
}
