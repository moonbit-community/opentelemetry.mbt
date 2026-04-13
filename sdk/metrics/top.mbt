///|
/// Supported synchronous instrument kinds.
pub(all) enum InstrumentKind {
  Counter
  UpDownCounter
  Histogram
  Gauge
} derive(Eq, Compare, Hash, ToJson, Debug)

///|
/// Numeric value stored inside metric aggregations.
pub(all) enum Number {
  Int64(Int64)
  Double(Double)
} derive(Eq, ToJson, Debug)

///|
/// Compact histogram summary emitted by the current implementation.
pub struct HistogramSummary {
  count : Int64
  sum : Double
  min : Double?
  max : Double?
} derive(Eq, ToJson, Debug)

///|
/// Aggregated metric payload for one attribute set.
pub(all) enum Aggregation {
  Sum(Number)
  Gauge(Number)
  Histogram(HistogramSummary)
} derive(Eq, ToJson, Debug)

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
/// Exporter callback wrapper for metric batches.
pub struct MetricExporter {
  export_fn : (ArrayView[MetricData]) -> @error.OTelSdkResult
  force_flush_fn : () -> @error.OTelSdkResult
  shutdown_fn : () -> @error.OTelSdkResult
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
  provider : SdkMeterProvider
}

///|
/// Push-style metric reader that exports snapshots on an interval.
pub struct PeriodicMetricReader {
  provider : SdkMeterProvider
  exporter : MetricExporter
  interval_millis : Int
}

///|
struct PeriodicMetricReaderConfig {
  exporter : MetricExporter
  interval_millis : Int
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
  descriptor : InstrumentDescriptor
  instrumentation_scope : @common.InstrumentationScope
  resource : @resource.Resource
  points : Map[String, PointState]
}

///|
priv struct MetricCollector {
  collect_fn : () -> Array[MetricData]
}

///|
struct MeterProviderState {
  resource : @resource.Resource
  collectors : Array[MetricCollector]
  exporters : Array[MetricExporter]
  periodic_readers : Array[PeriodicMetricReader]
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
  periodic_reader_configs : Array[PeriodicMetricReaderConfig]
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
/// Builder for a signed counter instrument.
pub struct UpDownCounterBuilder {
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
/// Builder for a gauge instrument.
pub struct GaugeBuilder {
  meter : SdkMeter
  name : String
  mut description : String?
  mut unit : String?
}

///|
/// Counter instrument handle.
pub struct Counter {
  state : Ref[SyncInstrumentState]
}

///|
/// Up-down counter instrument handle.
pub struct UpDownCounter {
  state : Ref[SyncInstrumentState]
}

///|
/// Histogram instrument handle.
pub struct Histogram {
  state : Ref[SyncInstrumentState]
}

///|
/// Gauge instrument handle.
pub struct Gauge {
  state : Ref[SyncInstrumentState]
}

///|
/// Builds a metric exporter from callbacks.
pub fn MetricExporter::new(
  export_fn : (ArrayView[MetricData]) -> @error.OTelSdkResult,
  force_flush_fn? : () -> @error.OTelSdkResult = @error.ok,
  shutdown_fn? : () -> @error.OTelSdkResult = @error.ok,
  name_fn? : () -> String = () => "custom",
) -> MetricExporter {
  { export_fn, force_flush_fn, shutdown_fn, name_fn }
}

///|
/// Exports one batch of metrics.
pub fn MetricExporter::export_batch(
  self : MetricExporter,
  batch : ArrayView[MetricData],
) -> @error.OTelSdkResult {
  (self.export_fn)(batch)
}

///|
/// Requests exporter flush.
pub fn MetricExporter::force_flush(
  self : MetricExporter,
) -> @error.OTelSdkResult {
  (self.force_flush_fn)()
}

///|
/// Requests exporter shutdown.
pub fn MetricExporter::shutdown(self : MetricExporter) -> @error.OTelSdkResult {
  (self.shutdown_fn)()
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
/// Materializes the current point map of one instrument into exportable metric
/// data.
fn collect_metrics(state : Ref[SyncInstrumentState]) -> Array[MetricData] {
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
/// Registers an instrument with the provider so later collections can snapshot
/// its current points.
fn register_instrument(
  meter : SdkMeter,
  descriptor : InstrumentDescriptor,
) -> Ref[SyncInstrumentState] {
  let state : Ref[SyncInstrumentState] = Ref::new({
    descriptor,
    instrumentation_scope: meter.instrumentation_scope,
    resource: meter.provider.state.val.resource,
    points: {},
  })
  if !meter.provider.state.val.is_shutdown {
    // Instruments created after shutdown still exist as handles, but they are
    // not collected by the provider anymore.
    meter.provider.state.val.collectors.push({
      collect_fn: () => collect_metrics(state),
    })
  }
  state
}

///|
fn create_builder(
  meter : SdkMeter,
  name : StringView,
) -> (SdkMeter, String, String?, String?) {
  (meter, name.to_string(), None, None)
}

///|
/// Updates a sum aggregation for the supplied attribute set.
fn update_sum(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  delta : Int64,
) -> Unit {
  let key = encode_attributes(attributes)
  let points = state.val.points.copy()
  let aggregation = match points.get(key) {
    Some(point) =>
      match point.aggregation {
        Aggregation::Sum(Number::Int64(current)) =>
          Aggregation::Sum(Number::Int64(current + delta))
        _ => Aggregation::Sum(Number::Int64(delta))
      }
    None => Aggregation::Sum(Number::Int64(delta))
  }
  points[key] = { attributes: attributes.to_array(), aggregation }
  state.val = { ..state.val, points, }
}

///|
/// Updates histogram summary statistics for the supplied attribute set.
fn update_histogram(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  value : Double,
) -> Unit {
  let key = encode_attributes(attributes)
  let points = state.val.points.copy()
  let aggregation = match points.get(key) {
    Some(point) =>
      match point.aggregation {
        Aggregation::Histogram(summary) => {
          let min = match summary.min {
            Some(current) => Some(if value < current { value } else { current })
            None => Some(value)
          }
          let max = match summary.max {
            Some(current) => Some(if value > current { value } else { current })
            None => Some(value)
          }
          Aggregation::Histogram({
            count: summary.count + 1,
            sum: summary.sum + value,
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
    None =>
      Aggregation::Histogram({
        count: 1,
        sum: value,
        min: Some(value),
        max: Some(value),
      })
  }
  points[key] = { attributes: attributes.to_array(), aggregation }
  state.val = { ..state.val, points, }
}

///|
/// Replaces the last recorded gauge value for the supplied attribute set.
fn update_gauge(
  state : Ref[SyncInstrumentState],
  attributes : ArrayView[@common.KeyValue],
  value : Double,
) -> Unit {
  let key = encode_attributes(attributes)
  let points = state.val.points.copy()
  points[key] = {
    attributes: attributes.to_array(),
    aggregation: Aggregation::Gauge(Number::Double(value)),
  }
  state.val = { ..state.val, points, }
}

///|
/// Starts building a meter provider with the default resource.
pub fn SdkMeterProvider::builder() -> SdkMeterProviderBuilder {
  {
    resource: @resource.Resource::builder().build(),
    exporters: [],
    periodic_reader_configs: [],
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
/// Registers an exporter and a periodic reader for background exports.
pub fn SdkMeterProviderBuilder::with_periodic_exporter(
  self : SdkMeterProviderBuilder,
  exporter : MetricExporter,
  interval_millis? : Int = 60000,
) -> SdkMeterProviderBuilder {
  self.exporters.push(exporter)
  self.periodic_reader_configs.push({
    exporter,
    interval_millis: if interval_millis <= 0 {
      1
    } else {
      interval_millis
    },
  })
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
    is_shutdown: false,
  })
  let provider : SdkMeterProvider = { state, }
  let periodic_readers = []
  for config in self.periodic_reader_configs {
    periodic_readers.push({
      provider,
      exporter: config.exporter,
      interval_millis: config.interval_millis,
    })
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
    metrics.append((collector.collect_fn)())
  }
  metrics
}

///|
/// Creates a pull-based reader over this provider.
pub fn SdkMeterProvider::manual_reader(self : SdkMeterProvider) -> ManualReader {
  { provider: self }
}

///|
/// Collects and exports a fresh metric snapshot through every exporter.
pub fn SdkMeterProvider::force_flush(
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
pub fn SdkMeterProvider::shutdown(
  self : SdkMeterProvider,
) -> @error.OTelSdkResult {
  if self.state.val.is_shutdown {
    return @error.already_shutdown()
  }
  match self.force_flush() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  for exporter in self.state.val.exporters {
    match exporter.shutdown() {
      Ok(_) => ()
      Err(err) => return Err(err)
    }
  }
  self.state.val = { ..self.state.val, is_shutdown: true }
  @error.ok()
}

///|
/// Pulls a metric snapshot from the provider.
pub fn ManualReader::collect(self : ManualReader) -> Array[MetricData] {
  self.provider.collect()
}

///|
/// Flushes the underlying provider.
pub fn ManualReader::force_flush(self : ManualReader) -> @error.OTelSdkResult {
  self.provider.force_flush()
}

///|
/// Shuts down the underlying provider.
pub fn ManualReader::shutdown(self : ManualReader) -> @error.OTelSdkResult {
  self.provider.shutdown()
}

///|
/// Background loop for periodic metric collection and export.
pub async fn PeriodicMetricReader::run(self : PeriodicMetricReader) -> Unit {
  while !self.provider.state.val.is_shutdown {
    @async.sleep(self.interval_millis)
    if self.provider.state.val.is_shutdown {
      return
    }
    let metrics = self.provider.collect()
    ignore(self.exporter.export_batch(metrics))
    ignore(self.exporter.force_flush())
  }
}

///|
/// Starts building a counter instrument.
pub fn SdkMeter::counter(self : SdkMeter, name : StringView) -> CounterBuilder {
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
/// Starts building a histogram instrument.
pub fn SdkMeter::histogram(
  self : SdkMeter,
  name : StringView,
) -> HistogramBuilder {
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
/// Sets the instrument unit.
pub fn CounterBuilder::with_unit(
  self : CounterBuilder,
  unit : StringView,
) -> CounterBuilder {
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
/// Sets the instrument description.
pub fn UpDownCounterBuilder::with_description(
  self : UpDownCounterBuilder,
  description : StringView,
) -> UpDownCounterBuilder {
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
/// Sets the instrument description.
pub fn HistogramBuilder::with_description(
  self : HistogramBuilder,
  description : StringView,
) -> HistogramBuilder {
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
/// Sets the instrument description.
pub fn GaugeBuilder::with_description(
  self : GaugeBuilder,
  description : StringView,
) -> GaugeBuilder {
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
/// Adds a delta to the counter for one attribute set.
pub fn Counter::add(
  self : Counter,
  value : Int64,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_sum(self.state, attributes, value)
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
/// Records one histogram sample for an attribute set.
pub fn Histogram::record(
  self : Histogram,
  value : Double,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  update_histogram(self.state, attributes, value)
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
