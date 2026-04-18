///|
/// Supported metric instrument kinds.
pub(all) enum InstrumentKind {
  Counter
  UpDownCounter
  Histogram
  Gauge
  ObservableCounter
  ObservableUpDownCounter
  ObservableGauge
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Numeric value stored inside metric aggregations.
pub(all) enum Number {
  Int64(Int64)
  UInt64(UInt64)
  Double(Double)
} derive(Eq, ToJson, Debug)

///|
/// Compact histogram summary emitted by the current implementation.
pub struct HistogramSummary {
  count : Int64
  sum : Number
  min : Number?
  max : Number?
} derive(Eq, ToJson, Debug)

///|
/// Aggregated metric payload for one attribute set.
pub(all) enum Aggregation {
  Sum(Number)
  Gauge(Number)
  Histogram(HistogramSummary)
} derive(Eq, ToJson, Debug)

///|
/// Aggregation selection used by metric views.
pub(all) enum StreamAggregation {
  Default
  Drop
  Sum
  LastValue
  Histogram
} derive(Eq, ToJson, Debug)

///|
/// Defines the time window used when readers report aggregated measurements.
pub(all) enum Temporality {
  Cumulative
  Delta
  LowMemory
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Immutable metric data item exported from a meter provider.
pub struct MetricData {
  name : String
  description : String?
  unit : String?
  kind : InstrumentKind
  attributes : Array[@common.KeyValue]
  aggregation : Aggregation
  time_unix_nano : Int64
  resource : @resource.Resource
  instrumentation_scope : @common.InstrumentationScope
} derive(Eq, ToJson, Debug)

///|
/// Instrument metadata used by views to match and transform streams.
pub struct Instrument {
  name : String
  description : String?
  unit : String?
  kind : InstrumentKind
  instrumentation_scope : @common.InstrumentationScope
} derive(Eq, ToJson, Debug)

///|
/// Stream configuration returned by a view.
pub struct Stream {
  name : String?
  description : String?
  unit : String?
  aggregation : StreamAggregation?
  allowed_attribute_keys : Array[String]?
  cardinality_limit : Int?
} derive(Eq, ToJson, Debug)

///|
/// Builder for stream transformations.
pub struct StreamBuilder {
  mut name : String?
  mut description : String?
  mut unit : String?
  mut aggregation : StreamAggregation?
  mut allowed_attribute_keys : Array[String]?
  mut cardinality_limit : Int?
}

///|
/// Exporter callback wrapper for metric batches.
pub struct MetricExporter {
  export_fn : async (ArrayView[MetricData]) -> @error.OTelSdkResult
  force_flush_fn : async () -> @error.OTelSdkResult
  shutdown_fn : async () -> @error.OTelSdkResult
  name_fn : () -> String
}

///|
struct InMemoryMetricExporterState {
  finished_metrics : Array[MetricData]
  is_shutdown : Bool
}

///|
/// Test exporter that keeps finished metrics in memory.
pub struct InMemoryMetricExporter {
  state : Ref[InMemoryMetricExporterState]
}

///|
/// Pull-based metric reader that snapshots the provider on demand.
pub struct ManualReader {
  state : Ref[ManualReaderState]
}

///|
struct ManualReaderState {
  provider : SdkMeterProvider?
  temporality : Temporality
  last_metrics : Map[String, Aggregation]
  is_shutdown : Bool
}

///|
/// Builder for `ManualReader`.
pub struct ManualReaderBuilder {
  mut temporality : Temporality
}

///|
/// View callback used to transform metric streams during instrument creation.
pub type View = (Instrument) -> Stream?

///|
/// Push-style metric reader that exports snapshots on an interval.
pub struct PeriodicMetricReader {
  state : Ref[PeriodicMetricReaderState]
}

///|
struct PeriodicMetricReaderState {
  provider : SdkMeterProvider?
  exporter : MetricExporter
  interval_millis : Int
  temporality : Temporality
  last_metrics : Map[String, Aggregation]
  is_shutdown : Bool
}

///|
priv struct MetricStreamState {
  descriptor : InstrumentDescriptor
  instrumentation_scope : @common.InstrumentationScope
  resource : @resource.Resource
  aggregation : StreamAggregation
  allowed_attribute_keys : Array[String]?
  cardinality_limit : Int
  points : Map[String, PointState]
}

///|
pub struct PeriodicMetricReaderBuilder {
  exporter : MetricExporter
  mut interval_millis : Int
  mut temporality : Temporality
}

///|
priv struct InstrumentDescriptor {
  name : String
  description : String?
  unit : String?
  kind : InstrumentKind
}

///|
priv struct PointState {
  attributes : Array[@common.KeyValue]
  aggregation : Aggregation
}

///|
struct SyncInstrumentState {
  streams : Array[Ref[MetricStreamState]]
}

///|
priv struct MetricCollector {
  prepare_fn : () -> Unit
  collect_fn : () -> Array[MetricData]
}

///|
struct MeterProviderState {
  resource : @resource.Resource
  collectors : Array[MetricCollector]
  exporters : Array[MetricExporter]
  periodic_readers : Array[PeriodicMetricReader]
  views : Array[View]
  is_shutdown : Bool
}

///|
/// Owns resource metadata, registered instruments, exporters, and readers.
pub struct SdkMeterProvider {
  state : Ref[MeterProviderState]
}

///|
/// Builder for `SdkMeterProvider`.
pub struct SdkMeterProviderBuilder {
  mut resource : @resource.Resource
  exporters : Array[MetricExporter]
  manual_readers : Array[ManualReader]
  periodic_readers : Array[PeriodicMetricReader]
  views : Array[View]
}

///|
/// Meter scoped to one instrumentation library.
pub struct SdkMeter {
  provider : SdkMeterProvider
  instrumentation_scope : @common.InstrumentationScope
}

///|
/// Builder for a monotonic counter instrument.
pub struct CounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for a monotonic floating-point counter instrument.
pub struct DoubleCounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for an unsigned monotonic counter instrument.
pub struct UInt64CounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for a signed counter instrument.
pub struct UpDownCounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for a signed floating-point counter instrument.
pub struct DoubleUpDownCounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for a histogram instrument.
pub struct HistogramBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for an unsigned histogram instrument.
pub struct UInt64HistogramBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for a gauge instrument.
pub struct GaugeBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for an unsigned gauge instrument.
pub struct UInt64GaugeBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Builder for an observable monotonic counter instrument.
pub struct ObservableCounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableCounter) -> Unit]
}

///|
/// Builder for an observable monotonic floating-point counter instrument.
pub struct ObservableDoubleCounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableDoubleCounter) -> Unit]
}

///|
/// Builder for an unsigned observable monotonic counter instrument.
pub struct ObservableUInt64CounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableUInt64Counter) -> Unit]
}

///|
/// Builder for an observable signed counter instrument.
pub struct ObservableUpDownCounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableUpDownCounter) -> Unit]
}

///|
/// Builder for an observable signed floating-point counter instrument.
pub struct ObservableDoubleUpDownCounterBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableDoubleUpDownCounter) -> Unit]
}

///|
/// Builder for an observable gauge instrument.
pub struct ObservableGaugeBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableGauge) -> Unit]
}

///|
/// Builder for an unsigned observable gauge instrument.
pub struct ObservableUInt64GaugeBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableUInt64Gauge) -> Unit]
}

///|
/// Counter instrument handle.
pub struct Counter {
  state : Ref[SyncInstrumentState]
}

///|
/// Floating-point counter instrument handle.
pub struct DoubleCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Unsigned counter instrument handle.
pub struct UInt64Counter {
  state : Ref[SyncInstrumentState]
}

///|
/// Up-down counter instrument handle.
pub struct UpDownCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Floating-point up-down counter instrument handle.
pub struct DoubleUpDownCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Histogram instrument handle.
pub struct Histogram {
  state : Ref[SyncInstrumentState]
}

///|
/// Unsigned histogram instrument handle.
pub struct UInt64Histogram {
  state : Ref[SyncInstrumentState]
}

///|
/// Gauge instrument handle.
pub struct Gauge {
  state : Ref[SyncInstrumentState]
}

///|
/// Unsigned gauge instrument handle.
pub struct UInt64Gauge {
  state : Ref[SyncInstrumentState]
}

///|
/// Observable counter instrument handle passed to callbacks.
pub struct ObservableCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Observable floating-point counter instrument handle passed to callbacks.
pub struct ObservableDoubleCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Unsigned observable counter instrument handle passed to callbacks.
pub struct ObservableUInt64Counter {
  state : Ref[SyncInstrumentState]
}

///|
/// Observable up-down counter instrument handle passed to callbacks.
pub struct ObservableUpDownCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Observable floating-point up-down counter instrument handle passed to callbacks.
pub struct ObservableDoubleUpDownCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Observable gauge instrument handle passed to callbacks.
pub struct ObservableGauge {
  state : Ref[SyncInstrumentState]
}

///|
/// Unsigned observable gauge instrument handle passed to callbacks.
pub struct ObservableUInt64Gauge {
  state : Ref[SyncInstrumentState]
}

///|
/// Builds a metric exporter from callbacks.
pub fn MetricExporter::new(
  export_fn : async (ArrayView[MetricData]) -> @error.OTelSdkResult,
  force_flush_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  shutdown_fn? : async () -> @error.OTelSdkResult = () => @error.ok(),
  name_fn? : () -> String = () => "custom",
) -> MetricExporter {
  { export_fn, force_flush_fn, shutdown_fn, name_fn }
}

///|
/// Exports one batch of metrics.
pub async fn MetricExporter::export_batch(
  self : MetricExporter,
  batch : ArrayView[MetricData],
) -> @error.OTelSdkResult {
  (self.export_fn)(batch)
}

///|
/// Requests exporter flush.
pub async fn MetricExporter::force_flush(
  self : MetricExporter,
) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests exporter shutdown with an optional timeout budget in milliseconds.
pub async fn MetricExporter::shutdown_with_timeout(
  self : MetricExporter,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  (self.shutdown_fn)()
}

///|
/// Requests exporter shutdown.
pub async fn MetricExporter::shutdown(
  self : MetricExporter,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Returns a human-readable exporter name.
pub fn MetricExporter::name(self : MetricExporter) -> String {
  (self.name_fn)()
}

///|
/// Creates an empty in-memory metric exporter.
pub fn InMemoryMetricExporter::new() -> InMemoryMetricExporter {
  { state: Ref::new({ finished_metrics: [], is_shutdown: false }) }
}

///|
/// Returns the finished metrics accumulated so far.
pub fn InMemoryMetricExporter::finished_metrics(
  self : InMemoryMetricExporter,
) -> Array[MetricData] {
  self.state.val.finished_metrics.copy()
}

///|
/// Clears the in-memory metric buffer.
pub fn InMemoryMetricExporter::reset(self : InMemoryMetricExporter) -> Unit {
  self.state.val = { ..self.state.val, finished_metrics: [] }
}

///|
fn parse_env_int(key : StringView) -> Int? {
  match @common.getenv(key) {
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
fn default_metric_export_interval_millis() -> Int {
  match parse_env_int("OTEL_METRIC_EXPORT_INTERVAL") {
    Some(value) if value > 0 => value
    _ => 60000
  }
}

///|
/// Creates an empty stream builder.
pub fn Stream::builder() -> StreamBuilder {
  {
    name: None,
    description: None,
    unit: None,
    aggregation: None,
    allowed_attribute_keys: None,
    cardinality_limit: None,
  }
}

///|
pub fn StreamBuilder::with_name(
  self : StreamBuilder,
  name : StringView,
) -> StreamBuilder {
  self.name = Some(name.to_string())
  self
}

///|
pub fn StreamBuilder::with_description(
  self : StreamBuilder,
  description : StringView,
) -> StreamBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn StreamBuilder::with_unit(
  self : StreamBuilder,
  unit : StringView,
) -> StreamBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn StreamBuilder::with_aggregation(
  self : StreamBuilder,
  aggregation : StreamAggregation,
) -> StreamBuilder {
  self.aggregation = Some(aggregation)
  self
}

///|
pub fn StreamBuilder::with_allowed_attribute_keys(
  self : StreamBuilder,
  keys : ArrayView[StringView],
) -> StreamBuilder {
  let allowed_attribute_keys = []
  for key in keys {
    allowed_attribute_keys.push(key.to_string())
  }
  self.allowed_attribute_keys = Some(allowed_attribute_keys)
  self
}

///|
pub fn StreamBuilder::with_cardinality_limit(
  self : StreamBuilder,
  limit : Int,
) -> StreamBuilder {
  self.cardinality_limit = Some(limit)
  self
}

///|
pub fn StreamBuilder::build(self : StreamBuilder) -> Stream {
  let cardinality_limit = match self.cardinality_limit {
    Some(limit) if limit <= 0 => Some(1)
    _ => self.cardinality_limit
  }
  {
    name: self.name,
    description: self.description,
    unit: self.unit,
    aggregation: self.aggregation,
    allowed_attribute_keys: self.allowed_attribute_keys,
    cardinality_limit,
  }
}

///|
/// Creates a detached manual reader that can later be registered with a
/// provider using `SdkMeterProviderBuilder::with_reader()`.
pub fn ManualReader::builder() -> ManualReaderBuilder {
  { temporality: Temporality::Cumulative }
}

///|
pub fn ManualReaderBuilder::with_temporality(
  self : ManualReaderBuilder,
  temporality : Temporality,
) -> ManualReaderBuilder {
  self.temporality = temporality
  self
}

///|
pub fn ManualReaderBuilder::build(self : ManualReaderBuilder) -> ManualReader {
  {
    state: Ref::new({
      provider: None,
      temporality: self.temporality,
      last_metrics: {},
      is_shutdown: false,
    }),
  }
}

///|
/// Creates a detached periodic reader around the supplied exporter.
pub fn PeriodicMetricReader::builder(
  exporter : MetricExporter,
) -> PeriodicMetricReaderBuilder {
  {
    exporter,
    interval_millis: default_metric_export_interval_millis(),
    temporality: Temporality::Cumulative,
  }
}

///|
pub fn PeriodicMetricReaderBuilder::with_interval(
  self : PeriodicMetricReaderBuilder,
  interval_millis : Int,
) -> PeriodicMetricReaderBuilder {
  self.interval_millis = if interval_millis <= 0 { 1 } else { interval_millis }
  self
}

///|
pub fn PeriodicMetricReaderBuilder::with_temporality(
  self : PeriodicMetricReaderBuilder,
  temporality : Temporality,
) -> PeriodicMetricReaderBuilder {
  self.temporality = temporality
  self
}

///|
pub fn PeriodicMetricReaderBuilder::build(
  self : PeriodicMetricReaderBuilder,
) -> PeriodicMetricReader {
  {
    state: Ref::new({
      provider: None,
      exporter: self.exporter,
      interval_millis: self.interval_millis,
      temporality: self.temporality,
      last_metrics: {},
      is_shutdown: false,
    }),
  }
}

///|
/// Erases the concrete in-memory exporter type into `MetricExporter`.
pub fn InMemoryMetricExporter::into_metric_exporter(
  self : InMemoryMetricExporter,
) -> MetricExporter {
  let state = self.state
  MetricExporter::new(
    (batch : ArrayView[MetricData]) => {
      if state.val.is_shutdown {
        return @error.already_shutdown()
      }
      let finished_metrics = state.val.finished_metrics.copy()
      finished_metrics.append(batch)
      state.val = { ..state.val, finished_metrics, }
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
/// Encodes attributes into a stable map key for point storage.
fn encode_attributes(attributes : ArrayView[@common.KeyValue]) -> String {
  let builder = StringBuilder::new()
  let mut is_first = true
  for attribute in attributes {
    if !is_first {
      builder.write_char(',')
    }
    is_first = false
    builder.write_string(attribute.key.as_string())
    builder.write_char('=')
    match attribute.value {
      @common.Value::String(value) => builder.write_string(value)
      _ => builder.write_string(attribute.value.to_json().stringify())
    }
  }
  builder.to_string()
}

///|
fn normalize_cardinality_limit(limit : Int?) -> Int {
  match limit {
    Some(limit) if limit <= 0 => 1
    Some(limit) => limit
    None => 2000
  }
}

///|
fn default_stream_aggregation(kind : InstrumentKind) -> StreamAggregation {
  match kind {
    InstrumentKind::Counter => StreamAggregation::Sum
    InstrumentKind::UpDownCounter => StreamAggregation::Sum
    InstrumentKind::Histogram => StreamAggregation::Histogram
    InstrumentKind::Gauge => StreamAggregation::LastValue
    InstrumentKind::ObservableCounter => StreamAggregation::Sum
    InstrumentKind::ObservableUpDownCounter => StreamAggregation::Sum
    InstrumentKind::ObservableGauge => StreamAggregation::LastValue
  }
}

///|
priv struct TemporalityResult {
  last_metrics : Map[String, Aggregation]
  metrics : Array[MetricData]
}

///|
fn use_delta_temporality(
  kind : InstrumentKind,
  temporality : Temporality,
) -> Bool {
  match temporality {
    Temporality::Cumulative => false
    Temporality::Delta =>
      match kind {
        InstrumentKind::Counter => true
        InstrumentKind::Histogram => true
        InstrumentKind::ObservableCounter => true
        InstrumentKind::Gauge => true
        InstrumentKind::ObservableGauge => true
        _ => false
      }
    Temporality::LowMemory =>
      match kind {
        InstrumentKind::Counter => true
        InstrumentKind::Histogram => true
        _ => false
      }
  }
}

///|
fn metric_identity(metric : MetricData) -> String {
  let builder = StringBuilder::new()
  builder.write_string(metric.name)
  builder.write_char('|')
  builder.write_string(metric.kind.to_json().stringify())
  builder.write_char('|')
  builder.write_string(metric.instrumentation_scope.to_json().stringify())
  builder.write_char('|')
  builder.write_string(encode_attributes(metric.attributes))
  builder.to_string()
}

///|
fn zero_number(number : Number) -> Number {
  match number {
    Number::Int64(_) => Number::Int64(0)
    Number::UInt64(_) => Number::UInt64(0UL)
    Number::Double(_) => Number::Double(0.0)
  }
}

///|
fn add_numbers(lhs : Number, rhs : Number) -> Number {
  match (lhs, rhs) {
    (Number::Int64(lhs), Number::Int64(rhs)) => Number::Int64(lhs + rhs)
    (Number::UInt64(lhs), Number::UInt64(rhs)) => Number::UInt64(lhs + rhs)
    (Number::Double(lhs), Number::Double(rhs)) => Number::Double(lhs + rhs)
    (_, _) => rhs
  }
}

///|
fn min_number(lhs : Number, rhs : Number) -> Number {
  match (lhs, rhs) {
    (Number::Int64(lhs), Number::Int64(rhs)) =>
      Number::Int64(if lhs < rhs { lhs } else { rhs })
    (Number::UInt64(lhs), Number::UInt64(rhs)) =>
      Number::UInt64(if lhs < rhs { lhs } else { rhs })
    (Number::Double(lhs), Number::Double(rhs)) =>
      Number::Double(if lhs < rhs { lhs } else { rhs })
    (_, _) => rhs
  }
}

///|
fn max_number(lhs : Number, rhs : Number) -> Number {
  match (lhs, rhs) {
    (Number::Int64(lhs), Number::Int64(rhs)) =>
      Number::Int64(if lhs > rhs { lhs } else { rhs })
    (Number::UInt64(lhs), Number::UInt64(rhs)) =>
      Number::UInt64(if lhs > rhs { lhs } else { rhs })
    (Number::Double(lhs), Number::Double(rhs)) =>
      Number::Double(if lhs > rhs { lhs } else { rhs })
    (_, _) => rhs
  }
}

///|
fn subtract_numbers(current : Number, previous : Number) -> Number {
  match (current, previous) {
    (Number::Int64(current), Number::Int64(previous)) =>
      Number::Int64(current - previous)
    (Number::UInt64(current), Number::UInt64(previous)) =>
      Number::UInt64(if current > previous { current - previous } else { 0UL })
    (Number::Double(current), Number::Double(previous)) =>
      Number::Double(current - previous)
    (_, _) => current
  }
}

///|
fn delta_histogram(
  current : HistogramSummary,
  previous : HistogramSummary?,
) -> HistogramSummary {
  match previous {
    Some(previous) => {
      let count = current.count - previous.count
      let sum = subtract_numbers(current.sum, previous.sum)
      if count <= 0 {
        { count: 0, sum: zero_number(current.sum), min: None, max: None }
      } else {
        { count, sum, min: current.min, max: current.max }
      }
    }
    None => current
  }
}

///|
fn delta_aggregation(
  metric : MetricData,
  previous : Aggregation?,
) -> Aggregation {
  if !use_delta_temporality(metric.kind, Temporality::Delta) {
    return metric.aggregation
  }
  match metric.aggregation {
    Aggregation::Sum(Number::Int64(value)) =>
      match previous {
        Some(Aggregation::Sum(Number::Int64(previous_value))) =>
          Aggregation::Sum(Number::Int64(value - previous_value))
        _ => metric.aggregation
      }
    Aggregation::Sum(Number::UInt64(value)) =>
      match previous {
        Some(Aggregation::Sum(Number::UInt64(previous_value))) =>
          Aggregation::Sum(
            Number::UInt64(
              if value > previous_value {
                value - previous_value
              } else {
                0UL
              },
            ),
          )
        _ => metric.aggregation
      }
    Aggregation::Sum(Number::Double(value)) =>
      match previous {
        Some(Aggregation::Sum(Number::Double(previous_value))) =>
          Aggregation::Sum(Number::Double(value - previous_value))
        _ => metric.aggregation
      }
    Aggregation::Histogram(summary) =>
      match previous {
        Some(Aggregation::Histogram(previous_summary)) =>
          Aggregation::Histogram(
            delta_histogram(summary, Some(previous_summary)),
          )
        _ => metric.aggregation
      }
    _ => metric.aggregation
  }
}

///|
fn apply_temporality(
  temporality : Temporality,
  previous : Map[String, Aggregation],
  metrics : Array[MetricData],
) -> TemporalityResult {
  if temporality == Temporality::Cumulative {
    let last_metrics = {}
    for metric in metrics {
      last_metrics[metric_identity(metric)] = metric.aggregation
    }
    return { last_metrics, metrics }
  }

  let last_metrics = {}
  let transformed = []
  for metric in metrics {
    let identity = metric_identity(metric)
    let aggregation = if use_delta_temporality(metric.kind, temporality) {
      delta_aggregation(metric, previous.get(identity))
    } else {
      metric.aggregation
    }
    transformed.push({ ..metric, aggregation, })
    last_metrics[identity] = metric.aggregation
  }
  { last_metrics, metrics: transformed }
}

///|
fn resolve_stream_aggregation(
  configured : StreamAggregation?,
  kind : InstrumentKind,
) -> StreamAggregation {
  match configured {
    Some(StreamAggregation::Default) => default_stream_aggregation(kind)
    Some(aggregation) => aggregation
    None => default_stream_aggregation(kind)
  }
}

///|
fn matches_allowed_attribute_key(
  allowed_attribute_keys : Array[String],
  key : StringView,
) -> Bool {
  let key = key.to_string()
  for allowed_key in allowed_attribute_keys {
    if allowed_key == key {
      return true
    }
  }
  false
}

///|
fn filter_attributes(
  allowed_attribute_keys : Array[String]?,
  attributes : ArrayView[@common.KeyValue],
) -> Array[@common.KeyValue] {
  match allowed_attribute_keys {
    None => attributes.to_array()
    Some(allowed_attribute_keys) => {
      let filtered = []
      for attribute in attributes {
        if matches_allowed_attribute_key(
            allowed_attribute_keys,
            attribute.key.as_string(),
          ) {
          filtered.push(attribute)
        }
      }
      filtered
    }
  }
}

///|
fn collect_stream_metrics(state : Ref[MetricStreamState]) -> Array[MetricData] {
  let metrics = []
  for _, point in state.val.points {
    metrics.push({
      name: state.val.descriptor.name,
      description: state.val.descriptor.description,
      unit: state.val.descriptor.unit,
      kind: state.val.descriptor.kind,
      attributes: point.attributes.copy(),
      aggregation: point.aggregation,
      time_unix_nano: @common.now_unix_nano(),
      resource: state.val.resource,
      instrumentation_scope: state.val.instrumentation_scope,
    })
  }
  metrics
}

///|
/// Materializes the current point map of one instrument into exportable metric
/// data.
fn collect_metrics(state : Ref[SyncInstrumentState]) -> Array[MetricData] {
  let metrics = []
  for stream in state.val.streams {
    metrics.append(collect_stream_metrics(stream))
  }
  metrics
}

///|
fn resolve_stream_state(
  meter : SdkMeter,
  descriptor : InstrumentDescriptor,
) -> Array[Ref[MetricStreamState]] {
  let instrument = {
    name: descriptor.name,
    description: descriptor.description,
    unit: descriptor.unit,
    kind: descriptor.kind,
    instrumentation_scope: meter.instrumentation_scope,
  }
  let streams = []
  let mut matched_view = false
  for view in meter.provider.state.val.views {
    match view(instrument) {
      Some(stream) => {
        matched_view = true
        let aggregation = resolve_stream_aggregation(
          stream.aggregation,
          descriptor.kind,
        )
        if aggregation == StreamAggregation::Drop {
          continue
        }
        let resolved_descriptor = {
          name: match stream.name {
            Some(name) => name
            None => descriptor.name
          },
          description: match stream.description {
            Some(description) => Some(description)
            None => descriptor.description
          },
          unit: match stream.unit {
            Some(unit) => Some(unit)
            None => descriptor.unit
          },
          kind: descriptor.kind,
        }
        streams.push(
          Ref::new({
            descriptor: resolved_descriptor,
            instrumentation_scope: meter.instrumentation_scope,
            resource: meter.provider.state.val.resource,
            aggregation,
            allowed_attribute_keys: stream.allowed_attribute_keys,
            cardinality_limit: normalize_cardinality_limit(
              stream.cardinality_limit,
            ),
            points: {},
          }),
        )
      }
      None => ()
    }
  }
  if !matched_view {
    streams.push(
      Ref::new({
        descriptor,
        instrumentation_scope: meter.instrumentation_scope,
        resource: meter.provider.state.val.resource,
        aggregation: default_stream_aggregation(descriptor.kind),
        allowed_attribute_keys: None,
        cardinality_limit: 2000,
        points: {},
      }),
    )
  }
  streams
}

///|
fn clear_metrics(state : Ref[SyncInstrumentState]) -> Unit {
  for stream in state.val.streams {
    stream.val = { ..stream.val, points: {} }
  }
}

///|
fn register_manual_reader(
  reader : ManualReader,
  provider : SdkMeterProvider,
) -> Unit {
  if reader.state.val.is_shutdown {
    return
  }
  match reader.state.val.provider {
    Some(_) => ()
    None => reader.state.val = { ..reader.state.val, provider: Some(provider) }
  }
}

///|
fn register_periodic_reader(
  reader : PeriodicMetricReader,
  provider : SdkMeterProvider,
) -> Unit {
  if reader.state.val.is_shutdown {
    return
  }
  match reader.state.val.provider {
    Some(_) => ()
    None => reader.state.val = { ..reader.state.val, provider: Some(provider) }
  }
}

///|
fn collect_with_temporality(
  provider : SdkMeterProvider,
  temporality : Temporality,
  previous : Map[String, Aggregation],
) -> TemporalityResult {
  apply_temporality(temporality, previous, provider.collect())
}

///|
/// Registers an instrument with the provider so later collections can snapshot
/// its current points.
fn register_instrument(
  meter : SdkMeter,
  descriptor : InstrumentDescriptor,
) -> Ref[SyncInstrumentState] {
  let state : Ref[SyncInstrumentState] = Ref::new({
    streams: resolve_stream_state(meter, descriptor),
  })
  if !meter.provider.state.val.is_shutdown {
    meter.provider.state.val.collectors.push({
      prepare_fn: () => (),
      collect_fn: () => collect_metrics(state),
    })
  }
  state
}

///|
fn register_observable_instrument(
  meter : SdkMeter,
  descriptor : InstrumentDescriptor,
  state : Ref[SyncInstrumentState],
  callbacks : Array[() -> Unit],
) -> Unit {
  state.val = { streams: resolve_stream_state(meter, descriptor) }
  if !meter.provider.state.val.is_shutdown {
    meter.provider.state.val.collectors.push({
      prepare_fn: () => {
        clear_metrics(state)
        for callback in callbacks {
          callback()
        }
      },
      collect_fn: () => collect_metrics(state),
    })
  }
}

///|
fn create_builder(
  meter : SdkMeter,
  name : StringView,
) -> (SdkMeter, String, String?, String?) {
  (meter, name.to_string(), None, None)
}

///|
fn histogram_aggregation(current : Aggregation?, value : Number) -> Aggregation {
  match current {
    Some(Aggregation::Histogram(summary)) => {
      let min = match summary.min {
        Some(current) => Some(min_number(current, value))
        None => Some(value)
      }
      let max = match summary.max {
        Some(current) => Some(max_number(current, value))
        None => Some(value)
      }
      Aggregation::Histogram({
        count: summary.count + 1,
        sum: add_numbers(summary.sum, value),
        min,
        max,
      })
    }
    _ =>
      Aggregation::Histogram({
        count: 1,
        sum: value,
        min: Some(value),
        max: Some(value),
      })
  }
}

///|
fn update_sum_stream(
  state : Ref[MetricStreamState],
  attributes : ArrayView[@common.KeyValue],
  delta : Int64,
) -> Unit {
  let attributes = filter_attributes(
    state.val.allowed_attribute_keys,
    attributes,
  )
  let key = encode_attributes(attributes)
  let points = state.val.points.copy()
  let current = points.get(key).map(fn(point) { point.aggregation })
  if current is None && points.length() >= state.val.cardinality_limit {
    return
  }
  let aggregation = match state.val.aggregation {
    StreamAggregation::Sum =>
      match current {
        Some(Aggregation::Sum(Number::Int64(current))) =>
          Aggregation::Sum(Number::Int64(current + delta))
        _ => Aggregation::Sum(Number::Int64(delta))
      }
    StreamAggregation::LastValue => Aggregation::Gauge(Number::Int64(delta))
    StreamAggregation::Histogram =>
      histogram_aggregation(current, Number::Int64(delta))
    _ => Aggregation::Sum(Number::Int64(delta))
  }
  points[key] = { attributes, aggregation }
  state.val = { ..state.val, points, }
}

///|
fn update_double_stream(
  state : Ref[MetricStreamState],
  attributes : ArrayView[@common.KeyValue],
  value : Double,
) -> Unit {
  let attributes = filter_attributes(
    state.val.allowed_attribute_keys,
    attributes,
  )
  let key = encode_attributes(attributes)
  let points = state.val.points.copy()
  let current = points.get(key).map(fn(point) { point.aggregation })
  if current is None && points.length() >= state.val.cardinality_limit {
    return
  }
  let aggregation = match state.val.aggregation {
    StreamAggregation::Sum =>
      match current {
        Some(Aggregation::Sum(Number::Double(current))) =>
          Aggregation::Sum(Number::Double(current + value))
        _ => Aggregation::Sum(Number::Double(value))
      }
    StreamAggregation::LastValue => Aggregation::Gauge(Number::Double(value))
    StreamAggregation::Histogram =>
      histogram_aggregation(current, Number::Double(value))
    _ => Aggregation::Gauge(Number::Double(value))
  }
  points[key] = { attributes, aggregation }
  state.val = { ..state.val, points, }
}

///|
fn update_u64_stream(
  state : Ref[MetricStreamState],
  attributes : ArrayView[@common.KeyValue],
  value : UInt64,
) -> Unit {
  let attributes = filter_attributes(
    state.val.allowed_attribute_keys,
    attributes,
  )
  let key = encode_attributes(attributes)
  let points = state.val.points.copy()
  let current = points.get(key).map(fn(point) { point.aggregation })
  if current is None && points.length() >= state.val.cardinality_limit {
    return
  }
  let aggregation = match state.val.aggregation {
    StreamAggregation::Sum =>
      match current {
        Some(Aggregation::Sum(Number::UInt64(current))) =>
          Aggregation::Sum(Number::UInt64(current + value))
        _ => Aggregation::Sum(Number::UInt64(value))
      }
    StreamAggregation::LastValue => Aggregation::Gauge(Number::UInt64(value))
    StreamAggregation::Histogram =>
      histogram_aggregation(current, Number::UInt64(value))
    _ => Aggregation::Gauge(Number::UInt64(value))
  }
  points[key] = { attributes, aggregation }
  state.val = { ..state.val, points, }
}

///|
/// Updates a sum aggregation for the supplied attribute set.
fn update_sum(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  delta : Int64,
) -> Unit {
  for stream in state.val.streams {
    update_sum_stream(stream, attributes, delta)
  }
}

///|
/// Updates a floating-point sum aggregation for the supplied attribute set.
fn update_double_sum(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  delta : Double,
) -> Unit {
  for stream in state.val.streams {
    update_double_stream(stream, attributes, delta)
  }
}

///|
/// Updates an unsigned sum aggregation for the supplied attribute set.
fn update_u64_sum(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  delta : UInt64,
) -> Unit {
  for stream in state.val.streams {
    update_u64_stream(stream, attributes, delta)
  }
}

///|
/// Updates histogram summary statistics for the supplied attribute set.
fn update_histogram(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  value : Double,
) -> Unit {
  for stream in state.val.streams {
    update_double_stream(stream, attributes, value)
  }
}

///|
/// Updates unsigned histogram summary statistics for the supplied attribute set.
fn update_u64_histogram(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  value : UInt64,
) -> Unit {
  for stream in state.val.streams {
    update_u64_stream(stream, attributes, value)
  }
}

///|
/// Replaces the last recorded gauge value for the supplied attribute set.
fn update_gauge(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  value : Double,
) -> Unit {
  for stream in state.val.streams {
    update_double_stream(stream, attributes, value)
  }
}

///|
/// Replaces the last recorded unsigned gauge value for the supplied attribute set.
fn update_u64_gauge(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  value : UInt64,
) -> Unit {
  for stream in state.val.streams {
    update_u64_stream(stream, attributes, value)
  }
}

///|
/// Starts building a meter provider with the default resource.
pub fn SdkMeterProvider::builder() -> SdkMeterProviderBuilder {
  {
    resource: @resource.Resource::builder().build(),
    exporters: [],
    manual_readers: [],
    periodic_readers: [],
    views: [],
  }
}

///|
/// Replaces the provider resource.
pub fn SdkMeterProviderBuilder::with_resource(
  self : SdkMeterProviderBuilder,
  resource : @resource.Resource,
) -> SdkMeterProviderBuilder {
  self.resource = resource
  self
}

///|
/// Registers an exporter used during `force_flush()` and `shutdown()`.
pub fn SdkMeterProviderBuilder::with_exporter(
  self : SdkMeterProviderBuilder,
  exporter : MetricExporter,
) -> SdkMeterProviderBuilder {
  self.exporters.push(exporter)
  self
}

///|
/// Registers a manual reader with the provider.
pub fn SdkMeterProviderBuilder::with_reader(
  self : SdkMeterProviderBuilder,
  reader : ManualReader,
) -> SdkMeterProviderBuilder {
  self.manual_readers.push(reader)
  self
}

///|
/// Registers a periodic reader with the provider.
pub fn SdkMeterProviderBuilder::with_periodic_reader(
  self : SdkMeterProviderBuilder,
  reader : PeriodicMetricReader,
) -> SdkMeterProviderBuilder {
  self.periodic_readers.push(reader)
  self
}

///|
/// Adds a view that can rename or reshape future metric streams.
pub fn SdkMeterProviderBuilder::with_view(
  self : SdkMeterProviderBuilder,
  view : View,
) -> SdkMeterProviderBuilder {
  self.views.push(view)
  self
}

///|
/// Registers an exporter and a periodic reader for background exports.
pub fn SdkMeterProviderBuilder::with_periodic_exporter(
  self : SdkMeterProviderBuilder,
  exporter : MetricExporter,
  interval_millis? : Int = -1,
) -> SdkMeterProviderBuilder {
  let interval_millis = if interval_millis < 0 {
    default_metric_export_interval_millis()
  } else if interval_millis == 0 {
    1
  } else {
    interval_millis
  }
  self.periodic_readers.push(
    PeriodicMetricReader::builder(exporter)
    .with_interval(interval_millis)
    .build(),
  )
  self
}

///|
/// Builds the meter provider and wires up periodic readers.
pub fn SdkMeterProviderBuilder::build(
  self : SdkMeterProviderBuilder,
) -> SdkMeterProvider {
  let state = Ref::new({
    resource: self.resource,
    collectors: [],
    exporters: self.exporters.copy(),
    periodic_readers: [],
    views: self.views.copy(),
    is_shutdown: false,
  })
  let provider : SdkMeterProvider = { state, }
  for reader in self.manual_readers {
    register_manual_reader(reader, provider)
  }
  let periodic_readers = []
  for reader in self.periodic_readers {
    register_periodic_reader(reader, provider)
    periodic_readers.push(reader)
  }
  state.val = { ..state.val, periodic_readers, }
  provider
}

///|
/// Returns the provider resource.
pub fn SdkMeterProvider::resource(
  self : SdkMeterProvider,
) -> @resource.Resource {
  self.state.val.resource
}

///|
/// Creates a meter scoped to the supplied instrumentation library metadata.
pub fn SdkMeterProvider::meter(
  self : SdkMeterProvider,
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> SdkMeter {
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
/// Collects a fresh snapshot from every registered synchronous instrument.
pub fn SdkMeterProvider::collect(self : SdkMeterProvider) -> Array[MetricData] {
  let metrics = []
  if self.state.val.is_shutdown {
    return metrics
  }
  for collector in self.state.val.collectors {
    (collector.prepare_fn)()
    metrics.append((collector.collect_fn)())
  }
  metrics
}

///|
/// Creates a pull-based reader over this provider.
pub fn SdkMeterProvider::manual_reader(self : SdkMeterProvider) -> ManualReader {
  let reader = ManualReader::builder().build()
  register_manual_reader(reader, self)
  reader
}

///|
/// Collects and exports a fresh metric snapshot through every exporter.
pub async fn SdkMeterProvider::force_flush(
  self : SdkMeterProvider,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  let metrics = self.collect()
  for exporter in self.state.val.exporters {
    match exporter.export_batch(metrics) {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  for exporter in self.state.val.exporters {
    match exporter.force_flush() {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  for reader in self.state.val.periodic_readers {
    match reader.force_flush() {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  @error.ok()
}

///|
/// Spawns all configured periodic readers into the provided task group.
pub fn SdkMeterProvider::spawn_periodic_readers(
  self : SdkMeterProvider,
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  for reader in self.state.val.periodic_readers {
    group.spawn_bg(no_wait=true, allow_failure~, () => reader.run())
  }
}

///|
/// Flushes exporters, then shuts them down and marks the provider unusable.
pub async fn SdkMeterProvider::shutdown_with_timeout(
  self : SdkMeterProvider,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  let exporters = self.state.val.exporters.copy()
  let metrics = self.collect()
  for exporter in exporters {
    match exporter.export_batch(metrics) {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  for exporter in exporters {
    match exporter.force_flush() {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  for reader in self.state.val.periodic_readers {
    match reader.force_flush() {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  self.state.val = { ..self.state.val, is_shutdown: true }
  for exporter in exporters {
    match exporter.shutdown_with_timeout(timeout_millis) {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  for reader in self.state.val.periodic_readers {
    match reader.shutdown_with_timeout(timeout_millis) {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  @error.ok()
}

///|
pub async fn SdkMeterProvider::shutdown(
  self : SdkMeterProvider,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
fn manual_reader_collect_result(
  reader : ManualReader,
) -> Result[Array[MetricData], @error.OTelSdkError] {
  if reader.state.val.is_shutdown {
    return Err(@error.OTelSdkError::AlreadyShutdown)
  }
  match reader.state.val.provider {
    Some(provider) => {
      let result = collect_with_temporality(
        provider,
        reader.state.val.temporality,
        reader.state.val.last_metrics,
      )
      reader.state.val = {
        ..reader.state.val,
        last_metrics: result.last_metrics,
      }
      Ok(result.metrics)
    }
    None =>
      Err(
        @error.OTelSdkError::InternalFailure(
          "reader is not registered".to_string(),
        ),
      )
  }
}

///|
/// Pulls a metric snapshot from the provider and returns lifecycle failures.
pub fn ManualReader::collect_result(
  self : ManualReader,
) -> Result[Array[MetricData], @error.OTelSdkError] {
  manual_reader_collect_result(self)
}

///|
/// Pulls a metric snapshot from the provider.
pub fn ManualReader::collect(self : ManualReader) -> Array[MetricData] {
  match self.collect_result() {
    Ok(metrics) => metrics
    Err(_) => []
  }
}

///|
/// Manual readers do not own exporters, so force_flush is a no-op.
#warnings("-unused_async")
pub async fn ManualReader::force_flush(
  self : ManualReader,
) -> @error.OTelSdkResult {
  ignore(self)
  @error.ok()
}

///|
/// Detaches the reader from the provider.
#warnings("-unused_async")
pub async fn ManualReader::shutdown_with_timeout(
  self : ManualReader,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  ignore(timeout_millis)
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = {
    provider: None,
    temporality: self.state.val.temporality,
    last_metrics: {},
    is_shutdown: true,
  }
  @error.ok()
}

///|
pub async fn ManualReader::shutdown(
  self : ManualReader,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Collects one snapshot for this reader and applies its temporality policy.
pub fn PeriodicMetricReader::collect(
  self : PeriodicMetricReader,
) -> Array[MetricData] {
  if self.state.val.is_shutdown {
    return []
  }
  match self.state.val.provider {
    Some(provider) => {
      let result = collect_with_temporality(
        provider,
        self.state.val.temporality,
        self.state.val.last_metrics,
      )
      self.state.val = { ..self.state.val, last_metrics: result.last_metrics }
      result.metrics
    }
    None => []
  }
}

///|
/// Exports one temporality-adjusted snapshot immediately.
pub async fn PeriodicMetricReader::force_flush(
  self : PeriodicMetricReader,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  if self.state.val.provider is None {
    return @error.internal_failure("reader is not registered".to_string())
  }
  let metrics = self.collect()
  match self.state.val.exporter.export_batch(metrics) {
    Ok(_) => self.state.val.exporter.force_flush()
    Err(err) => Err(err)
  }
}

///|
/// Shuts down the periodic reader and its exporter.
pub async fn PeriodicMetricReader::shutdown_with_timeout(
  self : PeriodicMetricReader,
  timeout_millis : Int,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  self.state.val = {
    ..self.state.val,
    provider: None,
    last_metrics: {},
    is_shutdown: true,
  }
  self.state.val.exporter.shutdown_with_timeout(timeout_millis)
}

///|
pub async fn PeriodicMetricReader::shutdown(
  self : PeriodicMetricReader,
) -> @error.OTelSdkResult {
  self.shutdown_with_timeout(5000)
}

///|
/// Background loop for periodic metric collection and export.
pub async fn PeriodicMetricReader::run(self : PeriodicMetricReader) -> Unit {
  while !self.state.val.is_shutdown {
    @async.sleep(self.state.val.interval_millis)
    if self.state.val.is_shutdown {
      return
    }
    match self.state.val.provider {
      Some(provider) if provider.state.val.is_shutdown => return
      Some(_) => ignore(self.force_flush())
      None => return
    }
  }
}

///|
/// Starts building a counter instrument.
pub fn SdkMeter::counter(self : SdkMeter, name : StringView) -> CounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building a floating-point counter instrument.
pub fn SdkMeter::f64_counter(
  self : SdkMeter,
  name : StringView,
) -> DoubleCounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building an unsigned counter instrument.
pub fn SdkMeter::u64_counter(
  self : SdkMeter,
  name : StringView,
) -> UInt64CounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building an up-down counter instrument.
pub fn SdkMeter::up_down_counter(
  self : SdkMeter,
  name : StringView,
) -> UpDownCounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building a floating-point up-down counter instrument.
pub fn SdkMeter::f64_up_down_counter(
  self : SdkMeter,
  name : StringView,
) -> DoubleUpDownCounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building a histogram instrument.
pub fn SdkMeter::histogram(
  self : SdkMeter,
  name : StringView,
) -> HistogramBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building an unsigned histogram instrument.
pub fn SdkMeter::u64_histogram(
  self : SdkMeter,
  name : StringView,
) -> UInt64HistogramBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building a gauge instrument.
pub fn SdkMeter::gauge(self : SdkMeter, name : StringView) -> GaugeBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building an unsigned gauge instrument.
pub fn SdkMeter::u64_gauge(
  self : SdkMeter,
  name : StringView,
) -> UInt64GaugeBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit }
}

///|
/// Starts building an observable counter instrument.
pub fn SdkMeter::observable_counter(
  self : SdkMeter,
  name : StringView,
) -> ObservableCounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit, callbacks: [] }
}

///|
/// Starts building an observable floating-point counter instrument.
pub fn SdkMeter::f64_observable_counter(
  self : SdkMeter,
  name : StringView,
) -> ObservableDoubleCounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit, callbacks: [] }
}

///|
/// Starts building an unsigned observable counter instrument.
pub fn SdkMeter::u64_observable_counter(
  self : SdkMeter,
  name : StringView,
) -> ObservableUInt64CounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit, callbacks: [] }
}

///|
/// Starts building an observable up-down counter instrument.
pub fn SdkMeter::observable_up_down_counter(
  self : SdkMeter,
  name : StringView,
) -> ObservableUpDownCounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit, callbacks: [] }
}

///|
/// Starts building an observable floating-point up-down counter instrument.
pub fn SdkMeter::f64_observable_up_down_counter(
  self : SdkMeter,
  name : StringView,
) -> ObservableDoubleUpDownCounterBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit, callbacks: [] }
}

///|
/// Starts building an observable gauge instrument.
pub fn SdkMeter::observable_gauge(
  self : SdkMeter,
  name : StringView,
) -> ObservableGaugeBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit, callbacks: [] }
}

///|
/// Starts building an unsigned observable gauge instrument.
pub fn SdkMeter::u64_observable_gauge(
  self : SdkMeter,
  name : StringView,
) -> ObservableUInt64GaugeBuilder {
  let (meter, name, description, unit) = create_builder(self, name)
  { meter, name, description, unit, callbacks: [] }
}

///|
fn descriptor(
  name : String,
  description : String?,
  unit : String?,
  kind : InstrumentKind,
) -> InstrumentDescriptor {
  { name, description, unit, kind }
}

///|
/// Sets the instrument description.
pub fn CounterBuilder::with_description(
  self : CounterBuilder,
  description : StringView,
) -> CounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument description.
pub fn DoubleCounterBuilder::with_description(
  self : DoubleCounterBuilder,
  description : StringView,
) -> DoubleCounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument description.
pub fn UInt64CounterBuilder::with_description(
  self : UInt64CounterBuilder,
  description : StringView,
) -> UInt64CounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn CounterBuilder::with_unit(
  self : CounterBuilder,
  unit : StringView,
) -> CounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn DoubleCounterBuilder::with_unit(
  self : DoubleCounterBuilder,
  unit : StringView,
) -> DoubleCounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn UInt64CounterBuilder::with_unit(
  self : UInt64CounterBuilder,
  unit : StringView,
) -> UInt64CounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the counter instrument and registers it with the provider.
pub fn CounterBuilder::build(self : CounterBuilder) -> Counter {
  {
    state: register_instrument(
      self.meter,
      descriptor(
        self.name,
        self.description,
        self.unit,
        InstrumentKind::Counter,
      ),
    ),
  }
}

///|
/// Builds the floating-point counter instrument and registers it with the provider.
pub fn DoubleCounterBuilder::build(
  self : DoubleCounterBuilder,
) -> DoubleCounter {
  {
    state: register_instrument(
      self.meter,
      descriptor(
        self.name,
        self.description,
        self.unit,
        InstrumentKind::Counter,
      ),
    ),
  }
}

///|
/// Builds the unsigned counter instrument and registers it with the provider.
pub fn UInt64CounterBuilder::build(
  self : UInt64CounterBuilder,
) -> UInt64Counter {
  {
    state: register_instrument(
      self.meter,
      descriptor(
        self.name,
        self.description,
        self.unit,
        InstrumentKind::Counter,
      ),
    ),
  }
}

///|
/// Sets the instrument description.
pub fn UpDownCounterBuilder::with_description(
  self : UpDownCounterBuilder,
  description : StringView,
) -> UpDownCounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument description.
pub fn DoubleUpDownCounterBuilder::with_description(
  self : DoubleUpDownCounterBuilder,
  description : StringView,
) -> DoubleUpDownCounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn UpDownCounterBuilder::with_unit(
  self : UpDownCounterBuilder,
  unit : StringView,
) -> UpDownCounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn DoubleUpDownCounterBuilder::with_unit(
  self : DoubleUpDownCounterBuilder,
  unit : StringView,
) -> DoubleUpDownCounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the up-down counter instrument and registers it with the provider.
pub fn UpDownCounterBuilder::build(
  self : UpDownCounterBuilder,
) -> UpDownCounter {
  {
    state: register_instrument(
      self.meter,
      descriptor(
        self.name,
        self.description,
        self.unit,
        InstrumentKind::UpDownCounter,
      ),
    ),
  }
}

///|
/// Builds the floating-point up-down counter instrument and registers it with the provider.
pub fn DoubleUpDownCounterBuilder::build(
  self : DoubleUpDownCounterBuilder,
) -> DoubleUpDownCounter {
  {
    state: register_instrument(
      self.meter,
      descriptor(
        self.name,
        self.description,
        self.unit,
        InstrumentKind::UpDownCounter,
      ),
    ),
  }
}

///|
/// Sets the instrument description.
pub fn HistogramBuilder::with_description(
  self : HistogramBuilder,
  description : StringView,
) -> HistogramBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument description.
pub fn UInt64HistogramBuilder::with_description(
  self : UInt64HistogramBuilder,
  description : StringView,
) -> UInt64HistogramBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn HistogramBuilder::with_unit(
  self : HistogramBuilder,
  unit : StringView,
) -> HistogramBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn UInt64HistogramBuilder::with_unit(
  self : UInt64HistogramBuilder,
  unit : StringView,
) -> UInt64HistogramBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the histogram instrument and registers it with the provider.
pub fn HistogramBuilder::build(self : HistogramBuilder) -> Histogram {
  {
    state: register_instrument(
      self.meter,
      descriptor(
        self.name,
        self.description,
        self.unit,
        InstrumentKind::Histogram,
      ),
    ),
  }
}

///|
/// Builds the unsigned histogram instrument and registers it with the provider.
pub fn UInt64HistogramBuilder::build(
  self : UInt64HistogramBuilder,
) -> UInt64Histogram {
  {
    state: register_instrument(
      self.meter,
      descriptor(
        self.name,
        self.description,
        self.unit,
        InstrumentKind::Histogram,
      ),
    ),
  }
}

///|
/// Sets the instrument description.
pub fn GaugeBuilder::with_description(
  self : GaugeBuilder,
  description : StringView,
) -> GaugeBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument description.
pub fn UInt64GaugeBuilder::with_description(
  self : UInt64GaugeBuilder,
  description : StringView,
) -> UInt64GaugeBuilder {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn GaugeBuilder::with_unit(
  self : GaugeBuilder,
  unit : StringView,
) -> GaugeBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Sets the instrument unit.
pub fn UInt64GaugeBuilder::with_unit(
  self : UInt64GaugeBuilder,
  unit : StringView,
) -> UInt64GaugeBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the gauge instrument and registers it with the provider.
pub fn GaugeBuilder::build(self : GaugeBuilder) -> Gauge {
  {
    state: register_instrument(
      self.meter,
      descriptor(self.name, self.description, self.unit, InstrumentKind::Gauge),
    ),
  }
}

///|
/// Builds the unsigned gauge instrument and registers it with the provider.
pub fn UInt64GaugeBuilder::build(self : UInt64GaugeBuilder) -> UInt64Gauge {
  {
    state: register_instrument(
      self.meter,
      descriptor(self.name, self.description, self.unit, InstrumentKind::Gauge),
    ),
  }
}

///|
pub fn ObservableCounterBuilder::with_description(
  self : ObservableCounterBuilder,
  description : StringView,
) -> ObservableCounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn ObservableCounterBuilder::with_unit(
  self : ObservableCounterBuilder,
  unit : StringView,
) -> ObservableCounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn ObservableCounterBuilder::with_callback(
  self : ObservableCounterBuilder,
  callback : (ObservableCounter) -> Unit,
) -> ObservableCounterBuilder {
  self.callbacks.push(callback)
  self
}

///|
pub fn ObservableDoubleCounterBuilder::with_description(
  self : ObservableDoubleCounterBuilder,
  description : StringView,
) -> ObservableDoubleCounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn ObservableUInt64CounterBuilder::with_description(
  self : ObservableUInt64CounterBuilder,
  description : StringView,
) -> ObservableUInt64CounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn ObservableDoubleCounterBuilder::with_unit(
  self : ObservableDoubleCounterBuilder,
  unit : StringView,
) -> ObservableDoubleCounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn ObservableUInt64CounterBuilder::with_unit(
  self : ObservableUInt64CounterBuilder,
  unit : StringView,
) -> ObservableUInt64CounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn ObservableDoubleCounterBuilder::with_callback(
  self : ObservableDoubleCounterBuilder,
  callback : (ObservableDoubleCounter) -> Unit,
) -> ObservableDoubleCounterBuilder {
  self.callbacks.push(callback)
  self
}

///|
pub fn ObservableUInt64CounterBuilder::with_callback(
  self : ObservableUInt64CounterBuilder,
  callback : (ObservableUInt64Counter) -> Unit,
) -> ObservableUInt64CounterBuilder {
  self.callbacks.push(callback)
  self
}

///|
pub fn ObservableCounterBuilder::build(
  self : ObservableCounterBuilder,
) -> ObservableCounter {
  let state : Ref[SyncInstrumentState] = Ref::new({ streams: [] })
  let instrument : ObservableCounter = { state, }
  let callbacks = []
  for callback in self.callbacks {
    callbacks.push(() => callback(instrument))
  }
  register_observable_instrument(
    self.meter,
    descriptor(
      self.name,
      self.description,
      self.unit,
      InstrumentKind::ObservableCounter,
    ),
    state,
    callbacks,
  )
  instrument
}

///|
pub fn ObservableDoubleCounterBuilder::build(
  self : ObservableDoubleCounterBuilder,
) -> ObservableDoubleCounter {
  let state : Ref[SyncInstrumentState] = Ref::new({ streams: [] })
  let instrument : ObservableDoubleCounter = { state, }
  let callbacks = []
  for callback in self.callbacks {
    callbacks.push(() => callback(instrument))
  }
  register_observable_instrument(
    self.meter,
    descriptor(
      self.name,
      self.description,
      self.unit,
      InstrumentKind::ObservableCounter,
    ),
    state,
    callbacks,
  )
  instrument
}

///|
pub fn ObservableUInt64CounterBuilder::build(
  self : ObservableUInt64CounterBuilder,
) -> ObservableUInt64Counter {
  let state : Ref[SyncInstrumentState] = Ref::new({ streams: [] })
  let instrument : ObservableUInt64Counter = { state, }
  let callbacks = []
  for callback in self.callbacks {
    callbacks.push(() => callback(instrument))
  }
  register_observable_instrument(
    self.meter,
    descriptor(
      self.name,
      self.description,
      self.unit,
      InstrumentKind::ObservableCounter,
    ),
    state,
    callbacks,
  )
  instrument
}

///|
pub fn ObservableUpDownCounterBuilder::with_description(
  self : ObservableUpDownCounterBuilder,
  description : StringView,
) -> ObservableUpDownCounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn ObservableDoubleUpDownCounterBuilder::with_description(
  self : ObservableDoubleUpDownCounterBuilder,
  description : StringView,
) -> ObservableDoubleUpDownCounterBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn ObservableUpDownCounterBuilder::with_unit(
  self : ObservableUpDownCounterBuilder,
  unit : StringView,
) -> ObservableUpDownCounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn ObservableDoubleUpDownCounterBuilder::with_unit(
  self : ObservableDoubleUpDownCounterBuilder,
  unit : StringView,
) -> ObservableDoubleUpDownCounterBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn ObservableUpDownCounterBuilder::with_callback(
  self : ObservableUpDownCounterBuilder,
  callback : (ObservableUpDownCounter) -> Unit,
) -> ObservableUpDownCounterBuilder {
  self.callbacks.push(callback)
  self
}

///|
pub fn ObservableDoubleUpDownCounterBuilder::with_callback(
  self : ObservableDoubleUpDownCounterBuilder,
  callback : (ObservableDoubleUpDownCounter) -> Unit,
) -> ObservableDoubleUpDownCounterBuilder {
  self.callbacks.push(callback)
  self
}

///|
pub fn ObservableUpDownCounterBuilder::build(
  self : ObservableUpDownCounterBuilder,
) -> ObservableUpDownCounter {
  let state : Ref[SyncInstrumentState] = Ref::new({ streams: [] })
  let instrument : ObservableUpDownCounter = { state, }
  let callbacks = []
  for callback in self.callbacks {
    callbacks.push(() => callback(instrument))
  }
  register_observable_instrument(
    self.meter,
    descriptor(
      self.name,
      self.description,
      self.unit,
      InstrumentKind::ObservableUpDownCounter,
    ),
    state,
    callbacks,
  )
  instrument
}

///|
pub fn ObservableDoubleUpDownCounterBuilder::build(
  self : ObservableDoubleUpDownCounterBuilder,
) -> ObservableDoubleUpDownCounter {
  let state : Ref[SyncInstrumentState] = Ref::new({ streams: [] })
  let instrument : ObservableDoubleUpDownCounter = { state, }
  let callbacks = []
  for callback in self.callbacks {
    callbacks.push(() => callback(instrument))
  }
  register_observable_instrument(
    self.meter,
    descriptor(
      self.name,
      self.description,
      self.unit,
      InstrumentKind::ObservableUpDownCounter,
    ),
    state,
    callbacks,
  )
  instrument
}

///|
pub fn ObservableGaugeBuilder::with_description(
  self : ObservableGaugeBuilder,
  description : StringView,
) -> ObservableGaugeBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn ObservableUInt64GaugeBuilder::with_description(
  self : ObservableUInt64GaugeBuilder,
  description : StringView,
) -> ObservableUInt64GaugeBuilder {
  self.description = Some(description.to_string())
  self
}

///|
pub fn ObservableGaugeBuilder::with_unit(
  self : ObservableGaugeBuilder,
  unit : StringView,
) -> ObservableGaugeBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn ObservableUInt64GaugeBuilder::with_unit(
  self : ObservableUInt64GaugeBuilder,
  unit : StringView,
) -> ObservableUInt64GaugeBuilder {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn ObservableGaugeBuilder::with_callback(
  self : ObservableGaugeBuilder,
  callback : (ObservableGauge) -> Unit,
) -> ObservableGaugeBuilder {
  self.callbacks.push(callback)
  self
}

///|
pub fn ObservableUInt64GaugeBuilder::with_callback(
  self : ObservableUInt64GaugeBuilder,
  callback : (ObservableUInt64Gauge) -> Unit,
) -> ObservableUInt64GaugeBuilder {
  self.callbacks.push(callback)
  self
}

///|
pub fn ObservableGaugeBuilder::build(
  self : ObservableGaugeBuilder,
) -> ObservableGauge {
  let state : Ref[SyncInstrumentState] = Ref::new({ streams: [] })
  let instrument : ObservableGauge = { state, }
  let callbacks = []
  for callback in self.callbacks {
    callbacks.push(() => callback(instrument))
  }
  register_observable_instrument(
    self.meter,
    descriptor(
      self.name,
      self.description,
      self.unit,
      InstrumentKind::ObservableGauge,
    ),
    state,
    callbacks,
  )
  instrument
}

///|
pub fn ObservableUInt64GaugeBuilder::build(
  self : ObservableUInt64GaugeBuilder,
) -> ObservableUInt64Gauge {
  let state : Ref[SyncInstrumentState] = Ref::new({ streams: [] })
  let instrument : ObservableUInt64Gauge = { state, }
  let callbacks = []
  for callback in self.callbacks {
    callbacks.push(() => callback(instrument))
  }
  register_observable_instrument(
    self.meter,
    descriptor(
      self.name,
      self.description,
      self.unit,
      InstrumentKind::ObservableGauge,
    ),
    state,
    callbacks,
  )
  instrument
}

///|
/// Adds a delta to the counter for one attribute set.
pub fn Counter::add(
  self : Counter,
  value : Int64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  if value < 0 {
    return
  }
  update_sum(self.state, attributes, value)
}

///|
/// Adds a floating-point delta to the counter for one attribute set.
pub fn DoubleCounter::add(
  self : DoubleCounter,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  if value < 0.0 {
    return
  }
  update_double_sum(self.state, attributes, value)
}

///|
/// Adds a delta to the unsigned counter for one attribute set.
pub fn UInt64Counter::add(
  self : UInt64Counter,
  value : UInt64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_u64_sum(self.state, attributes, value)
}

///|
/// Adds a delta to the up-down counter for one attribute set.
pub fn UpDownCounter::add(
  self : UpDownCounter,
  value : Int64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_sum(self.state, attributes, value)
}

///|
/// Adds a floating-point delta to the up-down counter for one attribute set.
pub fn DoubleUpDownCounter::add(
  self : DoubleUpDownCounter,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_double_sum(self.state, attributes, value)
}

///|
/// Records one histogram sample for an attribute set.
pub fn Histogram::record(
  self : Histogram,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_histogram(self.state, attributes, value)
}

///|
/// Records one unsigned histogram sample for an attribute set.
pub fn UInt64Histogram::record(
  self : UInt64Histogram,
  value : UInt64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_u64_histogram(self.state, attributes, value)
}

///|
/// Records the latest gauge value for an attribute set.
pub fn Gauge::record(
  self : Gauge,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_gauge(self.state, attributes, value)
}

///|
/// Records the latest unsigned gauge value for an attribute set.
pub fn UInt64Gauge::record(
  self : UInt64Gauge,
  value : UInt64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_u64_gauge(self.state, attributes, value)
}

///|
/// Observes one value for an observable counter during callback execution.
pub fn ObservableCounter::observe(
  self : ObservableCounter,
  value : Int64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  if value < 0 {
    return
  }
  update_sum(self.state, attributes, value)
}

///|
/// Observes one floating-point value for an observable counter during callback execution.
pub fn ObservableDoubleCounter::observe(
  self : ObservableDoubleCounter,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  if value < 0.0 {
    return
  }
  update_double_sum(self.state, attributes, value)
}

///|
/// Observes one unsigned value for an observable counter during callback execution.
pub fn ObservableUInt64Counter::observe(
  self : ObservableUInt64Counter,
  value : UInt64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_u64_sum(self.state, attributes, value)
}

///|
/// Observes one value for an observable up-down counter during callback
/// execution.
pub fn ObservableUpDownCounter::observe(
  self : ObservableUpDownCounter,
  value : Int64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_sum(self.state, attributes, value)
}

///|
/// Observes one floating-point value for an observable up-down counter during
/// callback execution.
pub fn ObservableDoubleUpDownCounter::observe(
  self : ObservableDoubleUpDownCounter,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_double_sum(self.state, attributes, value)
}

///|
/// Observes one value for an observable gauge during callback execution.
pub fn ObservableGauge::observe(
  self : ObservableGauge,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_gauge(self.state, attributes, value)
}

///|
/// Observes one unsigned value for an observable gauge during callback execution.
pub fn ObservableUInt64Gauge::observe(
  self : ObservableUInt64Gauge,
  value : UInt64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_u64_gauge(self.state, attributes, value)
}
