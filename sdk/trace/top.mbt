///|
/// OpenTelemetry span kinds.
///
/// Span kind describes the relationship between this operation and remote
/// systems. It affects how backends render service maps and client/server
/// relationships.
pub(all) enum SpanKind {
  Internal
  Client
  Server
  Producer
  Consumer
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// OpenTelemetry status code attached to a completed span.
pub(all) enum StatusCode {
  Unset
  Ok
  Error
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Span status consisting of a code and optional description.
pub struct Status {
  code : StatusCode
  description : String?
} derive(Eq, ToJson, Debug)

///|
/// Event recorded on a span timeline.
pub struct SpanEvent {
  name : String
  timestamp_unix_nano : Int64
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
} derive(Eq, ToJson, Debug)

///|
/// Link from one span to another span context.
pub struct SpanLink {
  span_context : @common.SpanContext
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
} derive(Eq, ToJson, Debug)

///|
/// Per-span limits for attributes, events, and links.
pub struct SpanLimits {
  max_attributes_per_span : Int
  max_events_per_span : Int
  max_links_per_span : Int
  max_attributes_per_event : Int
  max_attributes_per_link : Int
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Result of a sampler decision.
///
/// `Drop` creates a non-recording span context, `RecordOnly` records locally
/// without setting the sampled flag, and `RecordAndSample` records and marks the
/// context as sampled for downstream services.
pub(all) enum SamplingDecision {
  Drop
  RecordOnly
  RecordAndSample
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Full sampler output, including attributes and trace state to apply to the
/// started span.
pub struct SamplingResult {
  decision : SamplingDecision
  attributes : Array[@common.KeyValue]
  trace_state : @common.TraceState
} derive(Eq, ToJson, Debug)

///|
/// Inputs provided to a sampler when a span is started.
pub struct SamplingParameters {
  parent_context : @context.Context
  trace_id : @common.TraceId
  name : String
  kind : SpanKind
  attributes : Array[@common.KeyValue]
  links : Array[SpanLink]
} derive(Eq, ToJson, Debug)

///|
/// Sampling policy wrapper.
pub struct Sampler {
  should_sample_fn : (SamplingParameters) -> SamplingResult
  description_fn : () -> String
}

///|
/// Strategy object for generating trace and span identifiers.
pub struct IdGenerator {
  new_trace_id_fn : () -> @common.TraceId
  new_span_id_fn : () -> @common.SpanId
}

///|
/// Default random ID generator.
pub struct RandomIdGenerator {
  inner : IdGenerator
}

///|
/// Configuration for batch span processing.
pub struct BatchConfig {
  max_queue_size : Int
  max_export_batch_size : Int
  scheduled_delay_millis : Int
  export_timeout_millis : Int
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Provider-wide trace configuration.
///
/// Configuration is read when a span starts. Builder methods override defaults
/// derived from environment variables.
pub struct Config {
  sampler : Sampler
  id_generator : IdGenerator
  span_limits : SpanLimits
  resource : @resource.Resource
}

///|
/// Immutable snapshot of a completed or in-flight span.
pub struct SpanData {
  name : String
  span_context : @common.SpanContext
  parent_span_context : @common.SpanContext?
  kind : SpanKind
  start_time_unix_nano : Int64
  end_time_unix_nano : Int64?
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
  events : Array[SpanEvent]
  dropped_events_count : Int
  links : Array[SpanLink]
  dropped_links_count : Int
  status : Status
  resource : @resource.Resource
  instrumentation_scope : @common.InstrumentationScope
} derive(Eq, ToJson, Debug)

///|
/// Exporter callback wrapper for finished span batches.
pub struct SpanExporter {
  export_fn : async (ArrayView[SpanData]) -> @error.OTelSdkResult
  force_flush_fn : async () -> @error.OTelSdkResult
  shutdown_fn : async () -> @error.OTelSdkResult
  name_fn : () -> String
}

///|
/// Processing hook interface around span start and end.
///
/// Processors should avoid expensive work on `on_start`. Exporters usually run
/// from `on_end` through simple or batch processor implementations.
pub struct SpanProcessor {
  on_start_fn : (@context.Context, SpanData) -> Unit
  on_end_fn : async (SpanData) -> Unit
  force_flush_fn : async () -> @error.OTelSdkResult
  shutdown_fn : async () -> @error.OTelSdkResult
}

///|
/// Processor that exports spans immediately when `Span::end()` is awaited.
///
/// This is useful for tests and local debugging. For network exporters, prefer
/// `BatchSpanProcessor` to reduce request-path latency.
pub struct SimpleSpanProcessor {
  inner : SpanProcessor
}

///|
/// Processor that buffers ended spans and exports them in batches.
///
/// The background loop is not started automatically. Register the provider
/// globally and call `spawn_background_tasks()` from the application runtime.
pub struct BatchSpanProcessor {
  inner : SpanProcessor
  state : Ref[BatchProcessorState]
}

///|
struct InMemorySpanExporterState {
  finished_spans : Array[SpanData]
  is_shutdown : Bool
}

///|
/// Test exporter that keeps finished spans in memory.
pub struct InMemorySpanExporter {
  state : Ref[InMemorySpanExporterState]
}

///|
struct SpanState {
  name : String
  span_context : @common.SpanContext
  parent_span_context : @common.SpanContext?
  kind : SpanKind
  start_time_unix_nano : Int64
  end_time_unix_nano : Int64?
  attributes : Array[@common.KeyValue]
  dropped_attributes_count : Int
  events : Array[SpanEvent]
  dropped_events_count : Int
  links : Array[SpanLink]
  dropped_links_count : Int
  status : Status
  resource : @resource.Resource
  instrumentation_scope : @common.InstrumentationScope
  processors : Array[SpanProcessor]
  limits : SpanLimits
  is_recording : Bool
  has_ended : Bool
}

///|
/// Mutable span handle used while an operation is in flight.
pub struct Span {
  state : Ref[SpanState]
}

///|
struct ProviderState {
  config : Config
  processors : Array[SpanProcessor]
  batch_processors : Array[BatchSpanProcessor]
  is_shutdown : Bool
}

///|
/// Owns trace configuration, processors, and resource metadata.
///
/// Applications create one provider, configure processors/exporters, and shut it
/// down during application teardown.
pub struct SdkTracerProvider {
  state : Ref[ProviderState]
}

///|
/// Builder for `SdkTracerProvider`.
pub struct SdkTracerProviderBuilder {
  mut config : Config
  processors : Array[SpanProcessor]
  batch_processors : Array[BatchSpanProcessor]
}

///|
/// Tracer scoped to one instrumentation library.
///
/// Tracers are lightweight handles. The instrumentation scope is attached to
/// every span they create.
pub struct SdkTracer {
  provider : SdkTracerProvider
  instrumentation_scope : @common.InstrumentationScope
}

///|
/// Creates a span status.
pub fn Status::new(code : StatusCode, description? : String? = None) -> Status {
  { code, description }
}

///|
/// Returns the default unset status.
pub fn Status::unset() -> Status {
  Status::new(StatusCode::Unset)
}

///|
/// Returns an ok status.
pub fn Status::ok() -> Status {
  Status::new(StatusCode::Ok)
}

///|
/// Returns an error status with an optional description.
pub fn Status::error(description? : String? = None) -> Status {
  Status::new(StatusCode::Error, description~)
}

///|
pub impl Default for Status with default() -> Status {
  Status::unset()
}

///|
/// Creates a span event.
pub fn SpanEvent::new(
  name : StringView,
  attributes? : ArrayView[@common.KeyValue] = [],
  timestamp_unix_nano? : Int64 = @utils.now_unix_nano(),
  dropped_attributes_count? : Int = 0,
) -> SpanEvent {
  {
    name: name.to_string(),
    timestamp_unix_nano,
    attributes: attributes.to_array(),
    dropped_attributes_count,
  }
}

///|
/// Creates a span link.
pub fn SpanLink::new(
  span_context : @common.SpanContext,
  attributes? : ArrayView[@common.KeyValue] = [],
  dropped_attributes_count? : Int = 0,
) -> SpanLink {
  { span_context, attributes: attributes.to_array(), dropped_attributes_count }
}

///|
/// Creates bounded span limits.
pub fn SpanLimits::new(
  max_attributes_per_span? : Int = 128,
  max_events_per_span? : Int = 128,
  max_links_per_span? : Int = 128,
  max_attributes_per_event? : Int = 128,
  max_attributes_per_link? : Int = 128,
) -> SpanLimits {
  {
    max_attributes_per_span,
    max_events_per_span,
    max_links_per_span,
    max_attributes_per_event,
    max_attributes_per_link,
  }
}

///|
pub impl Default for SpanLimits with default() -> SpanLimits {
  SpanLimits::new()
}

///|
/// Creates a sampling result.
pub fn SamplingResult::new(
  decision : SamplingDecision,
  attributes? : ArrayView[@common.KeyValue] = [],
  trace_state? : @common.TraceState = Default::default(),
) -> SamplingResult {
  { decision, attributes: attributes.to_array(), trace_state }
}

///|
/// Converts a sampling decision into trace flags for the created span context.
fn sampled_trace_flags(decision : SamplingDecision) -> @common.TraceFlags {
  let trace_flags : @common.TraceFlags = Default::default()
  trace_flags.with_sampled(decision == SamplingDecision::RecordAndSample)
}

///|
fn sampling_description(name : String) -> () -> String {
  () => name
}

///|
/// Builds a sampler from callbacks.
pub fn Sampler::new(
  should_sample_fn : (SamplingParameters) -> SamplingResult,
  description_fn : () -> String,
) -> Sampler {
  { should_sample_fn, description_fn }
}

///|
/// Evaluates the sampling policy.
pub fn Sampler::should_sample(
  self : Sampler,
  parameters : SamplingParameters,
) -> SamplingResult {
  (self.should_sample_fn)(parameters)
}

///|
/// Returns a human-readable description of the sampler.
pub fn Sampler::description(self : Sampler) -> String {
  (self.description_fn)()
}

///|
/// Sampler that records and samples every span.
///
/// This is useful for development but can be expensive in high-throughput
/// production services.
pub fn Sampler::always_on() -> Sampler {
  Sampler::new(
    _ => SamplingResult::new(SamplingDecision::RecordAndSample),
    sampling_description("always_on"),
  )
}

///|
/// Sampler that drops every span.
///
/// Dropped spans still carry a valid context for propagation, but they do not
/// record events, attributes, or processor callbacks.
pub fn Sampler::always_off() -> Sampler {
  Sampler::new(
    _ => SamplingResult::new(SamplingDecision::Drop),
    sampling_description("always_off"),
  )
}

///|
fn clamp_ratio(ratio : Double) -> Double {
  if ratio <= 0.0 {
    0.0
  } else if ratio >= 1.0 {
    1.0
  } else {
    ratio
  }
}

///|
fn trace_id_prefix(trace_id : @common.TraceId) -> Int {
  @string.parse_int(trace_id.to_hex()[:8].to_string(), base=16) catch {
    _ => 0
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
fn parse_decimal(value : StringView) -> Double? {
  let value = value.trim()
  if value == "" {
    return None
  }
  let mut whole = 0.0
  let mut fraction = 0.0
  let mut divisor = 1.0
  let mut seen_digit = false
  let mut seen_dot = false
  for _, ch in value {
    if ch == '.' {
      if seen_dot {
        return None
      }
      seen_dot = true
      continue
    }
    if ch < '0' || ch > '9' {
      return None
    }
    seen_digit = true
    let digit = Double::from_int(ch.to_int() - '0'.to_int())
    if seen_dot {
      divisor = divisor * 10.0
      fraction = fraction + digit / divisor
    } else {
      whole = whole * 10.0 + digit
    }
  }
  if !seen_digit {
    None
  } else {
    Some(whole + fraction)
  }
}

///|
fn parse_env_ratio(key : StringView) -> Double? {
  match @utils.getenv(key) {
    Some(value) => parse_decimal(value)
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
fn ratio_arg_or_default() -> Double {
  match parse_env_ratio("OTEL_TRACES_SAMPLER_ARG") {
    Some(ratio) => ratio
    None => 1.0
  }
}

///|
fn sampler_from_env() -> Sampler {
  let default_sampler = Sampler::parent_based(Sampler::always_on())
  match @utils.getenv("OTEL_TRACES_SAMPLER") {
    Some(value) => {
      let value = value.trim()
      if value == "always_on" {
        Sampler::always_on()
      } else if value == "always_off" {
        Sampler::always_off()
      } else if value == "traceidratio" {
        Sampler::trace_id_ratio(ratio_arg_or_default())
      } else if value == "parentbased_always_on" {
        Sampler::parent_based(Sampler::always_on())
      } else if value == "parentbased_always_off" {
        Sampler::parent_based(Sampler::always_off())
      } else if value == "parentbased_traceidratio" {
        Sampler::parent_based(Sampler::trace_id_ratio(ratio_arg_or_default()))
      } else {
        default_sampler
      }
    }
    None => default_sampler
  }
}

///|
fn span_limits_from_env() -> SpanLimits {
  SpanLimits::new(
    max_attributes_per_span=env_or("OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT", 128),
    max_events_per_span=env_or("OTEL_SPAN_EVENT_COUNT_LIMIT", 128),
    max_links_per_span=env_or("OTEL_SPAN_LINK_COUNT_LIMIT", 128),
  )
}

///|
/// Sampler that records and samples according to a trace ID ratio.
pub fn Sampler::trace_id_ratio(ratio : Double) -> Sampler {
  let ratio = clamp_ratio(ratio)
  Sampler::new(
    (parameters : SamplingParameters) => {
      if ratio <= 0.0 {
        SamplingResult::new(SamplingDecision::Drop)
      } else if ratio >= 1.0 {
        SamplingResult::new(SamplingDecision::RecordAndSample)
      } else {
        // Match the common OpenTelemetry approach of using the high 32 bits of
        // the trace ID as a deterministic sampling source.
        let threshold = (ratio * 4294967295.0).to_int()
        if trace_id_prefix(parameters.trace_id) <= threshold {
          SamplingResult::new(SamplingDecision::RecordAndSample)
        } else {
          SamplingResult::new(SamplingDecision::Drop)
        }
      }
    },
    () => "trace_id_ratio(\{ratio})",
  )
}

///|
/// Sampler that honors a valid parent sampling decision and otherwise delegates
/// to the supplied root sampler.
pub fn Sampler::parent_based(root : Sampler) -> Sampler {
  let description = root.description()
  Sampler::new(
    (parameters : SamplingParameters) => {
      match parameters.parent_context.span_context() {
        Some(parent_span_context) if parent_span_context.is_valid() =>
          if parent_span_context.is_sampled() {
            SamplingResult::new(
              SamplingDecision::RecordAndSample,
              trace_state=parent_span_context.trace_state(),
            )
          } else {
            SamplingResult::new(
              SamplingDecision::Drop,
              trace_state=parent_span_context.trace_state(),
            )
          }
        _ => root.should_sample(parameters)
      }
    },
    () => "parent_based(\{description})",
  )
}

///|
pub impl Default for Sampler with default() -> Sampler {
  Sampler::parent_based(Sampler::always_on())
}

///|
/// Builds an ID generator from callbacks.
pub fn IdGenerator::new(
  new_trace_id_fn : () -> @common.TraceId,
  new_span_id_fn : () -> @common.SpanId,
) -> IdGenerator {
  { new_trace_id_fn, new_span_id_fn }
}

///|
/// Returns a new trace ID.
pub fn IdGenerator::new_trace_id(self : IdGenerator) -> @common.TraceId {
  (self.new_trace_id_fn)()
}

///|
/// Returns a new span ID.
pub fn IdGenerator::new_span_id(self : IdGenerator) -> @common.SpanId {
  (self.new_span_id_fn)()
}

///|
fn random_hex_16(random : @random.Rand) -> String {
  random.uint64().to_string(radix=16).pad_start(16, '0')
}

///|
/// Creates the default random ID generator.
pub fn RandomIdGenerator::new() -> RandomIdGenerator {
  let random = Ref::new(@random.Rand::new())
  {
    inner: IdGenerator::new(
      () => {
        let hex = random_hex_16(random.val) + random_hex_16(random.val)
        match @common.TraceId::from_hex(hex) {
          Some(trace_id) => trace_id
          None => @common.TraceId::invalid()
        }
      },
      () => {
        let hex = random_hex_16(random.val)
        match @common.SpanId::from_hex(hex) {
          Some(span_id) => span_id
          None => @common.SpanId::invalid()
        }
      },
    ),
  }
}

///|
/// Erases the concrete random generator type into `IdGenerator`.
pub fn RandomIdGenerator::into_id_generator(
  self : RandomIdGenerator,
) -> IdGenerator {
  self.inner
}

///|
/// Creates normalized batch processor configuration.
pub fn BatchConfig::new(
  max_queue_size? : Int = 2048,
  max_export_batch_size? : Int = 512,
  scheduled_delay_millis? : Int = 5000,
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
    max_queue_size=env_or("OTEL_BSP_MAX_QUEUE_SIZE", 2048),
    max_export_batch_size=env_or("OTEL_BSP_MAX_EXPORT_BATCH_SIZE", 512),
    scheduled_delay_millis=env_or("OTEL_BSP_SCHEDULE_DELAY", 5000),
    export_timeout_millis=env_or("OTEL_BSP_EXPORT_TIMEOUT", 30000),
  )
}

///|
/// Creates trace provider configuration.
///
/// Omitted arguments use default sampler, ID generator, span limits, and
/// resource. Environment variables are applied through `Default`.
pub fn Config::new(
  sampler? : Sampler = Default::default(),
  id_generator? : IdGenerator = RandomIdGenerator::new().into_id_generator(),
  span_limits? : SpanLimits = Default::default(),
  resource? : @resource.Resource = @resource.Resource::builder().build(),
) -> Config {
  { sampler, id_generator, span_limits, resource }
}

///|
pub impl Default for Config with default() -> Config {
  Config::new(sampler=sampler_from_env(), span_limits=span_limits_from_env())
}

///|
/// Builds a span exporter from callbacks.
pub fn SpanExporter::new(
  export_fn : async (ArrayView[SpanData]) -> @error.OTelSdkResult,
  force_flush_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  shutdown_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  name_fn? : () -> String = () => "custom",
) -> SpanExporter {
  { export_fn, force_flush_fn, shutdown_fn, name_fn }
}

///|
/// Exports one batch of finished spans.
pub async fn SpanExporter::export_batch(
  self : SpanExporter,
  batch : ArrayView[SpanData],
) -> @error.OTelSdkResult {
  (self.export_fn)(batch)
}

///|
/// Requests exporter flush.
pub async fn SpanExporter::force_flush(
  self : SpanExporter,
) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests exporter shutdown with an optional timeout budget in milliseconds.
pub async fn SpanExporter::shutdown_with_timeout(
  self : SpanExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  (self.shutdown_fn)()
}

///|
/// Requests exporter shutdown.
pub async fn SpanExporter::shutdown(
  self : SpanExporter,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Returns a human-readable exporter name.
pub fn SpanExporter::name(self : SpanExporter) -> String {
  (self.name_fn)()
}

///|
/// Builds a span processor from callbacks.
pub fn SpanProcessor::new(
  on_start_fn? : (@context.Context, SpanData) -> Unit = (_, _) => (),
  on_end_fn? : async (SpanData) -> Unit = _ => (),
  force_flush_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  shutdown_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
) -> SpanProcessor {
  { on_start_fn, on_end_fn, force_flush_fn, shutdown_fn }
}

///|
/// Invokes the processor start hook.
pub fn SpanProcessor::on_start(
  self : SpanProcessor,
  parent_context : @context.Context,
  span_data : SpanData,
) -> Unit {
  (self.on_start_fn)(parent_context, span_data)
}

///|
/// Invokes the processor end hook.
pub async fn SpanProcessor::on_end(
  self : SpanProcessor,
  span_data : SpanData,
) -> Unit {
  (self.on_end_fn)(span_data)
}

///|
/// Requests processor flush.
pub async fn SpanProcessor::force_flush(
  self : SpanProcessor,
) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests processor shutdown with an optional timeout budget in milliseconds.
pub async fn SpanProcessor::shutdown_with_timeout(
  self : SpanProcessor,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  (self.shutdown_fn)()
}

///|
/// Requests processor shutdown.
pub async fn SpanProcessor::shutdown(
  self : SpanProcessor,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Creates an empty in-memory span exporter.
pub fn InMemorySpanExporter::new() -> InMemorySpanExporter {
  { state: Ref::new({ finished_spans: [], is_shutdown: false }) }
}

///|
/// Returns the finished spans accumulated so far.
pub fn InMemorySpanExporter::finished_spans(
  self : InMemorySpanExporter,
) -> Array[SpanData] {
  self.state.val.finished_spans.copy()
}

///|
/// Clears the in-memory span buffer.
pub fn InMemorySpanExporter::reset(self : InMemorySpanExporter) -> Unit {
  self.state.val = { ..self.state.val, finished_spans: [] }
}

///|
/// Returns whether the exporter has been shut down.
pub fn InMemorySpanExporter::is_shutdown(self : InMemorySpanExporter) -> Bool {
  self.state.val.is_shutdown
}

///|
/// Erases the concrete in-memory exporter type into `SpanExporter`.
pub fn InMemorySpanExporter::into_span_exporter(
  self : InMemorySpanExporter,
) -> SpanExporter {
  let state = self.state
  SpanExporter::new(
    (batch : ArrayView[SpanData]) => {
      if state.val.is_shutdown {
        return @error.already_shutdown()
      }
      let finished_spans = state.val.finished_spans.copy()
      finished_spans.append(batch)
      state.val = { ..state.val, finished_spans, }
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
/// Creates a simple processor that exports each ended span immediately.
pub fn SimpleSpanProcessor::new(exporter : SpanExporter) -> SimpleSpanProcessor {
  {
    inner: SpanProcessor::new(
      on_end_fn=(span_data : SpanData) => {
        ignore(exporter.export_batch([span_data]))
      },
      force_flush_fn=() => exporter.force_flush(),
      shutdown_fn=() => exporter.shutdown(),
    ),
  }
}

///|
/// Erases the concrete simple processor type into `SpanProcessor`.
pub fn SimpleSpanProcessor::into_span_processor(
  self : SimpleSpanProcessor,
) -> SpanProcessor {
  self.inner
}

///|
struct BatchProcessorState {
  exporter : SpanExporter
  config : BatchConfig
  queue : Array[SpanData]
  is_shutdown : Bool
}

///|
/// Flushes queued spans to the exporter in batch-sized chunks.
async fn flush_span_queue(
  state : Ref[BatchProcessorState],
) -> @error.OTelSdkResult {
  if state.val.is_shutdown {
    return @error.already_shutdown()
  }
  while !state.val.queue.is_empty() {
    let batch : Array[SpanData] = []
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
/// Creates a batch span processor with a bounded in-memory queue.
pub fn BatchSpanProcessor::new(
  exporter : SpanExporter,
  config? : BatchConfig = Default::default(),
) -> BatchSpanProcessor {
  let state : Ref[BatchProcessorState] = Ref::new({
    exporter,
    config,
    queue: [],
    is_shutdown: false,
  })
  {
    inner: SpanProcessor::new(
      on_end_fn=(span_data : SpanData) => {
        if state.val.is_shutdown {
          return
        }
        if state.val.queue.length() >= state.val.config.max_queue_size {
          // Keep the newest spans under sustained pressure.
          ignore(state.val.queue.remove(0))
        }
        state.val.queue.push(span_data)
        if state.val.queue.length() >= state.val.config.max_export_batch_size {
          ignore(flush_span_queue(state))
        }
      },
      force_flush_fn=() => {
        match flush_span_queue(state) {
          Ok(_) => state.val.exporter.force_flush()
          Err(err) => Err(err)
        }
      },
      shutdown_fn=() => {
        if state.val.is_shutdown {
          return @error.already_shutdown()
        }
        let result = flush_span_queue(state)
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
/// Erases the concrete batch processor type into `SpanProcessor`.
pub fn BatchSpanProcessor::into_span_processor(
  self : BatchSpanProcessor,
) -> SpanProcessor {
  self.inner
}

///|
/// Background loop for scheduled batch exports.
pub async fn BatchSpanProcessor::run(self : BatchSpanProcessor) -> Unit {
  while !self.state.val.is_shutdown {
    @async.sleep(self.state.val.config.scheduled_delay_millis)
    if self.state.val.is_shutdown {
      return
    }
    ignore(flush_span_queue(self.state))
    ignore(self.state.val.exporter.force_flush())
  }
}

///|
fn span_data_from_state(state : SpanState) -> SpanData {
  {
    name: state.name,
    span_context: state.span_context,
    parent_span_context: state.parent_span_context,
    kind: state.kind,
    start_time_unix_nano: state.start_time_unix_nano,
    end_time_unix_nano: state.end_time_unix_nano,
    attributes: state.attributes.copy(),
    dropped_attributes_count: state.dropped_attributes_count,
    events: state.events.copy(),
    dropped_events_count: state.dropped_events_count,
    links: state.links.copy(),
    dropped_links_count: state.dropped_links_count,
    status: state.status,
    resource: state.resource,
    instrumentation_scope: state.instrumentation_scope,
  }
}

///|
/// Pushes a value into a bounded array, returning the copied array and the
/// number of dropped values.
fn[T] push_bounded(
  values : Array[T],
  value : T,
  limit : Int,
) -> (Array[T], Int) {
  if limit <= 0 {
    return (values, 1)
  }
  if values.length() >= limit {
    return (values, 1)
  }
  let copied = values.copy()
  copied.push(value)
  (copied, 0)
}

///|
fn truncate_attributes(
  attributes : ArrayView[@common.KeyValue],
  limit : Int,
  dropped_attributes_count? : Int = 0,
) -> (Array[@common.KeyValue], Int) {
  let copied = attributes.to_array()
  if limit <= 0 {
    return ([], copied.length() + dropped_attributes_count)
  }
  if copied.length() <= limit {
    return (copied, dropped_attributes_count)
  }
  (
    copied[:limit].to_array(),
    copied.length() - limit + dropped_attributes_count,
  )
}

///|
fn status_priority(code : StatusCode) -> Int {
  match code {
    StatusCode::Unset => 0
    StatusCode::Error => 1
    StatusCode::Ok => 2
  }
}

///|
fn recording_from_decision(decision : SamplingDecision) -> Bool {
  match decision {
    SamplingDecision::Drop => false
    _ => true
  }
}

///|
/// Returns the immutable span context.
pub fn Span::span_context(self : Span) -> @common.SpanContext {
  self.state.val.span_context
}

///|
/// Returns a context carrying this span as the active local span.
pub fn Span::context(self : Span) -> @context.Context {
  @context.Context::empty().with_span_context(self.span_context())
}

///|
/// Returns whether the span is still recording mutations.
pub fn Span::is_recording(self : Span) -> Bool {
  self.state.val.is_recording && !self.state.val.has_ended
}

///|
/// Returns whether `end()` has already been called.
pub fn Span::has_ended(self : Span) -> Bool {
  self.state.val.has_ended
}

///|
/// Adds one attribute if the span is still recording.
pub fn Span::set_attribute(
  self : Span,
  key : StringView,
  value : @common.Value,
) -> Unit {
  if !self.is_recording() {
    return
  }
  let (attributes, dropped) = push_bounded(
    self.state.val.attributes,
    @common.KeyValue::new(key, value),
    self.state.val.limits.max_attributes_per_span,
  )
  self.state.val = {
    ..self.state.val,
    attributes,
    dropped_attributes_count: self.state.val.dropped_attributes_count + dropped,
  }
}

///|
/// Adds one event if the span is still recording.
pub fn Span::add_event(
  self : Span,
  name : StringView,
  attributes? : ArrayView[@common.KeyValue] = [],
  timestamp_unix_nano? : Int64 = @utils.now_unix_nano(),
  dropped_attributes_count? : Int = 0,
) -> Unit {
  if !self.is_recording() {
    return
  }
  let (attributes, dropped_attributes_count) = truncate_attributes(
    attributes,
    self.state.val.limits.max_attributes_per_event,
    dropped_attributes_count~,
  )
  let (events, dropped) = push_bounded(
    self.state.val.events,
    SpanEvent::new(
      name,
      attributes~,
      timestamp_unix_nano~,
      dropped_attributes_count~,
    ),
    self.state.val.limits.max_events_per_span,
  )
  self.state.val = {
    ..self.state.val,
    events,
    dropped_events_count: self.state.val.dropped_events_count + dropped,
  }
}

///|
/// Adds one link if the span is still recording.
pub fn Span::add_link(
  self : Span,
  span_context : @common.SpanContext,
  attributes? : ArrayView[@common.KeyValue] = [],
  dropped_attributes_count? : Int = 0,
) -> Unit {
  if !self.is_recording() {
    return
  }
  let (attributes, dropped_attributes_count) = truncate_attributes(
    attributes,
    self.state.val.limits.max_attributes_per_link,
    dropped_attributes_count~,
  )
  let (links, dropped) = push_bounded(
    self.state.val.links,
    SpanLink::new(span_context, attributes~, dropped_attributes_count~),
    self.state.val.limits.max_links_per_span,
  )
  self.state.val = {
    ..self.state.val,
    links,
    dropped_links_count: self.state.val.dropped_links_count + dropped,
  }
}

///|
/// Sets the span status if the span is still recording.
pub fn Span::set_status(self : Span, status : Status) -> Unit {
  if !self.is_recording() {
    return
  }
  let current = self.state.val.status
  if status.code == current.code ||
    status_priority(status.code) > status_priority(current.code) {
    self.state.val = { ..self.state.val, status, }
  }
}

///|
/// Updates the span name.
pub fn Span::update_name(self : Span, name : StringView) -> Unit {
  self.state.val = { ..self.state.val, name: name.to_string() }
}

///|
/// Returns an immutable snapshot of the current span state.
pub fn Span::snapshot(self : Span) -> SpanData {
  span_data_from_state(self.state.val)
}

///|
/// Ends the span once and forwards the final snapshot to processors when the
/// span is recording.
pub async fn Span::end(
  self : Span,
  end_time_unix_nano? : Int64 = @utils.now_unix_nano(),
) -> Unit {
  if self.state.val.has_ended {
    return
  }
  self.state.val = {
    ..self.state.val,
    end_time_unix_nano: Some(end_time_unix_nano),
    has_ended: true,
  }
  if !self.state.val.is_recording {
    return
  }
  let span_data = self.snapshot()
  for processor in self.state.val.processors {
    processor.on_end(span_data)
  }
}

///|
/// Starts building a tracer provider.
///
/// Add processors or exporters before calling `build()`. A provider with no
/// processors records spans in memory only long enough to return span handles;
/// no telemetry is exported.
pub fn SdkTracerProvider::builder() -> SdkTracerProviderBuilder {
  { config: Default::default(), processors: [], batch_processors: [] }
}

///|
/// Replaces the entire trace provider configuration.
pub fn SdkTracerProviderBuilder::with_config(
  self : SdkTracerProviderBuilder,
  config : Config,
) -> SdkTracerProviderBuilder {
  self.config = config
  self
}

///|
/// Replaces the provider resource.
pub fn SdkTracerProviderBuilder::with_resource(
  self : SdkTracerProviderBuilder,
  resource : @resource.Resource,
) -> SdkTracerProviderBuilder {
  self.config = { ..self.config, resource, }
  self
}

///|
/// Replaces the sampler.
pub fn SdkTracerProviderBuilder::with_sampler(
  self : SdkTracerProviderBuilder,
  sampler : Sampler,
) -> SdkTracerProviderBuilder {
  self.config = { ..self.config, sampler, }
  self
}

///|
/// Replaces the ID generator.
pub fn SdkTracerProviderBuilder::with_id_generator(
  self : SdkTracerProviderBuilder,
  id_generator : IdGenerator,
) -> SdkTracerProviderBuilder {
  self.config = { ..self.config, id_generator, }
  self
}

///|
/// Replaces the span limits.
pub fn SdkTracerProviderBuilder::with_span_limits(
  self : SdkTracerProviderBuilder,
  span_limits : SpanLimits,
) -> SdkTracerProviderBuilder {
  self.config = { ..self.config, span_limits, }
  self
}

///|
/// Appends a span processor to the provider pipeline.
pub fn SdkTracerProviderBuilder::with_span_processor(
  self : SdkTracerProviderBuilder,
  processor : SpanProcessor,
) -> SdkTracerProviderBuilder {
  self.processors.push(processor)
  self
}

///|
/// Appends a simple processor around the exporter.
///
/// Finished spans are exported from `Span::end()`.
pub fn SdkTracerProviderBuilder::with_simple_exporter(
  self : SdkTracerProviderBuilder,
  exporter : SpanExporter,
) -> SdkTracerProviderBuilder {
  self.with_span_processor(
    SimpleSpanProcessor::new(exporter).into_span_processor(),
  )
}

///|
/// Appends a batch processor around the exporter and registers it for
/// background execution.
///
/// The processor is registered with the provider, but its export loop only runs
/// after `spawn_batch_processor_tasks()` or the facade/global equivalent is
/// called.
pub fn SdkTracerProviderBuilder::with_batch_exporter(
  self : SdkTracerProviderBuilder,
  exporter : SpanExporter,
  config? : BatchConfig = Default::default(),
) -> SdkTracerProviderBuilder {
  let batch_processor = BatchSpanProcessor::new(exporter, config~)
  self.batch_processors.push(batch_processor)
  self.with_span_processor(batch_processor.into_span_processor())
}

///|
/// Builds the tracer provider.
pub fn SdkTracerProviderBuilder::build(
  self : SdkTracerProviderBuilder,
) -> SdkTracerProvider {
  {
    state: Ref::new({
      config: self.config,
      processors: self.processors.copy(),
      batch_processors: self.batch_processors.copy(),
      is_shutdown: false,
    }),
  }
}

///|
/// Returns the provider resource.
pub fn SdkTracerProvider::resource(
  self : SdkTracerProvider,
) -> @resource.Resource {
  self.state.val.config.resource
}

///|
/// Spawns background tasks for all configured batch processors.
pub fn SdkTracerProvider::spawn_batch_processor_tasks(
  self : SdkTracerProvider,
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  for batch_processor in self.state.val.batch_processors {
    group.spawn_bg(no_wait=true, allow_failure~, () => batch_processor.run())
  }
}

///|
/// Creates a tracer scoped to the supplied instrumentation library metadata.
pub fn SdkTracerProvider::tracer(
  self : SdkTracerProvider,
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> SdkTracer {
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
/// Flushes every configured span processor.
pub async fn SdkTracerProvider::force_flush(
  self : SdkTracerProvider,
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
/// Shuts down every configured span processor and marks the provider unusable.
pub async fn SdkTracerProvider::shutdown_with_timeout(
  self : SdkTracerProvider,
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
pub async fn SdkTracerProvider::shutdown(
  self : SdkTracerProvider,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
fn span_context_from_parent(
  parent_context : @context.Context,
) -> @common.SpanContext? {
  match parent_context.span_context() {
    Some(span_context) if span_context.is_valid() => Some(span_context)
    _ => None
  }
}

///|
fn span_state(
  name : String,
  span_context : @common.SpanContext,
  parent_span_context : @common.SpanContext?,
  kind : SpanKind,
  start_time_unix_nano : Int64,
  attributes : Array[@common.KeyValue],
  links : Array[SpanLink],
  resource : @resource.Resource,
  instrumentation_scope : @common.InstrumentationScope,
  processors : Array[SpanProcessor],
  limits : SpanLimits,
  is_recording : Bool,
) -> SpanState {
  {
    name,
    span_context,
    parent_span_context,
    kind,
    start_time_unix_nano,
    end_time_unix_nano: None,
    attributes,
    dropped_attributes_count: 0,
    events: [],
    dropped_events_count: 0,
    links,
    dropped_links_count: 0,
    status: Default::default(),
    resource,
    instrumentation_scope,
    processors,
    limits,
    is_recording,
    has_ended: false,
  }
}

///|
/// Starts a span using the provider configuration, sampler, and resource.
///
/// This evaluates the sampler, generates IDs, applies limits, and notifies
/// processors when the span is recording.
pub fn SdkTracer::start(
  self : SdkTracer,
  name : StringView,
  parent_context? : @context.Context = Default::default(),
  kind? : SpanKind = SpanKind::Internal,
  attributes? : ArrayView[@common.KeyValue] = [],
  links? : ArrayView[SpanLink] = [],
  start_time_unix_nano? : Int64 = @utils.now_unix_nano(),
) -> Span {
  let provider_state = self.provider.state.val
  if provider_state.is_shutdown {
    return {
      state: Ref::new(
        span_state(
          name.to_string(),
          Default::default(),
          None,
          kind,
          start_time_unix_nano,
          [],
          [],
          provider_state.config.resource,
          self.instrumentation_scope,
          [],
          provider_state.config.span_limits,
          false,
        ),
      ),
    }
  }
  let parent_span_context = span_context_from_parent(parent_context)
  let trace_id = match parent_span_context {
    Some(parent_span_context) => parent_span_context.trace_id()
    None => provider_state.config.id_generator.new_trace_id()
  }
  let sampling_parameters : SamplingParameters = {
    parent_context,
    trace_id,
    name: name.to_string(),
    kind,
    attributes: attributes.to_array(),
    links: links.to_array(),
  }
  let sampling_result = provider_state.config.sampler.should_sample(
    sampling_parameters,
  )
  let trace_state = sampling_result.trace_state
  // Sampling controls both recording and the sampled bit stored in the created
  // span context.
  let span_context = @common.SpanContext::new(
    trace_id,
    provider_state.config.id_generator.new_span_id(),
    trace_flags=sampled_trace_flags(sampling_result.decision),
    trace_state~,
  )
  let is_recording = recording_from_decision(sampling_result.decision)
  let mut span_attributes = sampling_result.attributes.copy()
  span_attributes.append(attributes)
  let mut dropped_attributes_count = 0
  if span_attributes.length() >
    provider_state.config.span_limits.max_attributes_per_span {
    dropped_attributes_count = span_attributes.length() -
      provider_state.config.span_limits.max_attributes_per_span
    span_attributes = span_attributes[:provider_state.config.span_limits.max_attributes_per_span].to_array()
  }
  let mut dropped_links_count = 0
  let span_links = []
  for link in links {
    if span_links.length() >=
      provider_state.config.span_limits.max_links_per_span {
      dropped_links_count += 1
      continue
    }
    let (attributes, dropped_attributes_count) = truncate_attributes(
      link.attributes,
      provider_state.config.span_limits.max_attributes_per_link,
      dropped_attributes_count=link.dropped_attributes_count,
    )
    span_links.push({
      span_context: link.span_context,
      attributes,
      dropped_attributes_count,
    })
  }
  let span : Span = {
    state: Ref::new({
      ..span_state(
        name.to_string(),
        span_context,
        parent_span_context,
        kind,
        start_time_unix_nano,
        span_attributes,
        span_links,
        provider_state.config.resource,
        self.instrumentation_scope,
        provider_state.processors.copy(),
        provider_state.config.span_limits,
        is_recording,
      ),
      dropped_attributes_count,
      dropped_links_count,
    }),
  }
  if is_recording {
    // Processors observe a started span through a context that carries the new
    // local span context, matching how downstream log correlation would see it.
    let started_context = @context.Context::empty().with_span_context(
      span_context,
    )
    let span_data = span.snapshot()
    for processor in provider_state.processors {
      processor.on_start(started_context, span_data)
    }
  }
  span
}
