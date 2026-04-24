///|
/// Monotonic synchronous counter handle.
///
/// Use counters for values that only increase, such as requests served, errors
/// observed, or bytes sent. Negative deltas are ignored by the SDK.
pub struct Counter[T] {
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Additive synchronous counter that accepts positive and negative deltas.
///
/// Use up-down counters for state that can increase and decrease, such as
/// active requests, queue depth, or open connections.
pub struct UpDownCounter[T] {
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Synchronous histogram handle.
///
/// Use histograms for distributions such as request latency, payload size, or
/// retry count.
pub struct Histogram[T] {
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Synchronous gauge handle recording the latest value for one attribute set.
///
/// Use gauges for current-state measurements such as memory usage or
/// temperature.
pub struct Gauge[T] {
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Observable monotonic counter handle used inside callbacks.
///
/// Observable instruments report values during SDK collection instead of at the
/// point where application work happens.
pub struct ObservableCounter[T] {
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Observable additive counter handle used inside callbacks.
pub struct ObservableUpDownCounter[T] {
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Observable gauge handle used inside callbacks.
pub struct ObservableGauge[T] {
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Builder for `Counter`.
pub struct CounterBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> Counter[T]
}

///|
/// Builder for `UpDownCounter`.
pub struct UpDownCounterBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> UpDownCounter[T]
}

///|
/// Builder for `Histogram`.
pub struct HistogramBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> Histogram[T]
}

///|
/// Builder for `Gauge`.
pub struct GaugeBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> Gauge[T]
}

///|
/// Builder for `ObservableCounter`.
pub struct ObservableCounterBuilder[T] {
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableCounter[T]) -> Unit]
  create_fn : (String?, String?, Array[(ObservableCounter[T]) -> Unit]) -> ObservableCounter[
    T,
  ]
}

///|
/// Builder for `ObservableUpDownCounter`.
pub struct ObservableUpDownCounterBuilder[T] {
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableUpDownCounter[T]) -> Unit]
  create_fn : (String?, String?, Array[(ObservableUpDownCounter[T]) -> Unit]) -> ObservableUpDownCounter[
    T,
  ]
}

///|
/// Builder for `ObservableGauge`.
pub struct ObservableGaugeBuilder[T] {
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableGauge[T]) -> Unit]
  create_fn : (String?, String?, Array[(ObservableGauge[T]) -> Unit]) -> ObservableGauge[
    T,
  ]
}

///|
/// Public meter handle.
///
/// A meter creates reusable instruments for one instrumentation scope. Create
/// instruments once and reuse them on hot paths.
pub struct Meter {
  u64_counter_fn : (String) -> CounterBuilder[UInt64]
  f64_counter_fn : (String) -> CounterBuilder[Double]
  i64_up_down_counter_fn : (String) -> UpDownCounterBuilder[Int64]
  f64_up_down_counter_fn : (String) -> UpDownCounterBuilder[Double]
  u64_histogram_fn : (String) -> HistogramBuilder[UInt64]
  f64_histogram_fn : (String) -> HistogramBuilder[Double]
  u64_gauge_fn : (String) -> GaugeBuilder[UInt64]
  i64_gauge_fn : (String) -> GaugeBuilder[Int64]
  f64_gauge_fn : (String) -> GaugeBuilder[Double]
  u64_observable_counter_fn : (String) -> ObservableCounterBuilder[UInt64]
  f64_observable_counter_fn : (String) -> ObservableCounterBuilder[Double]
  i64_observable_up_down_counter_fn : (String) -> ObservableUpDownCounterBuilder[
    Int64,
  ]
  f64_observable_up_down_counter_fn : (String) -> ObservableUpDownCounterBuilder[
    Double,
  ]
  u64_observable_gauge_fn : (String) -> ObservableGaugeBuilder[UInt64]
  i64_observable_gauge_fn : (String) -> ObservableGaugeBuilder[Int64]
  f64_observable_gauge_fn : (String) -> ObservableGaugeBuilder[Double]
}

///|
/// Public meter provider.
///
/// The default provider is no-op. Applications install SDK-backed providers
/// through the SDK facade while library code depends only on this API type.
pub struct MeterProvider {
  meter_with_scope_fn : (@common.InstrumentationScope) -> Meter
}

///|
/// Builds a counter handle from an add callback.
pub fn[T] Counter::from_functions(
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit,
) -> Counter[T] {
  { add_fn, }
}

///|
/// Builds an up-down counter handle from an add callback.
pub fn[T] UpDownCounter::from_functions(
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit,
) -> UpDownCounter[T] {
  { add_fn, }
}

///|
/// Builds a histogram handle from a record callback.
pub fn[T] Histogram::from_functions(
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit,
) -> Histogram[T] {
  { record_fn, }
}

///|
/// Builds a gauge handle from a record callback.
pub fn[T] Gauge::from_functions(
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit,
) -> Gauge[T] {
  { record_fn, }
}

///|
/// Builds an observable counter handle from an observe callback.
pub fn[T] ObservableCounter::from_functions(
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit,
) -> ObservableCounter[T] {
  { observe_fn, }
}

///|
/// Builds an observable up-down counter handle from an observe callback.
pub fn[T] ObservableUpDownCounter::from_functions(
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit,
) -> ObservableUpDownCounter[T] {
  { observe_fn, }
}

///|
/// Builds an observable gauge handle from an observe callback.
pub fn[T] ObservableGauge::from_functions(
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit,
) -> ObservableGauge[T] {
  { observe_fn, }
}

///|
/// Builds a counter builder from a creation callback.
pub fn[T] CounterBuilder::from_functions(
  create_fn : (String?, String?) -> Counter[T],
) -> CounterBuilder[T] {
  { description: None, unit: None, create_fn }
}

///|
/// Builds an up-down counter builder from a creation callback.
pub fn[T] UpDownCounterBuilder::from_functions(
  create_fn : (String?, String?) -> UpDownCounter[T],
) -> UpDownCounterBuilder[T] {
  { description: None, unit: None, create_fn }
}

///|
/// Builds a histogram builder from a creation callback.
pub fn[T] HistogramBuilder::from_functions(
  create_fn : (String?, String?) -> Histogram[T],
) -> HistogramBuilder[T] {
  { description: None, unit: None, create_fn }
}

///|
/// Builds a gauge builder from a creation callback.
pub fn[T] GaugeBuilder::from_functions(
  create_fn : (String?, String?) -> Gauge[T],
) -> GaugeBuilder[T] {
  { description: None, unit: None, create_fn }
}

///|
/// Builds an observable counter builder from a creation callback.
pub fn[T] ObservableCounterBuilder::from_functions(
  create_fn : (String?, String?, Array[(ObservableCounter[T]) -> Unit]) -> ObservableCounter[
    T,
  ],
) -> ObservableCounterBuilder[T] {
  { description: None, unit: None, callbacks: [], create_fn }
}

///|
/// Builds an observable up-down counter builder from a creation callback.
pub fn[T] ObservableUpDownCounterBuilder::from_functions(
  create_fn : (String?, String?, Array[(ObservableUpDownCounter[T]) -> Unit]) -> ObservableUpDownCounter[
    T,
  ],
) -> ObservableUpDownCounterBuilder[T] {
  { description: None, unit: None, callbacks: [], create_fn }
}

///|
/// Builds an observable gauge builder from a creation callback.
pub fn[T] ObservableGaugeBuilder::from_functions(
  create_fn : (String?, String?, Array[(ObservableGauge[T]) -> Unit]) -> ObservableGauge[
    T,
  ],
) -> ObservableGaugeBuilder[T] {
  { description: None, unit: None, callbacks: [], create_fn }
}

///|
fn[T] noop_counter() -> Counter[T] {
  Counter::from_functions((_, _) => ())
}

///|
fn[T] noop_up_down_counter() -> UpDownCounter[T] {
  UpDownCounter::from_functions((_, _) => ())
}

///|
fn[T] noop_histogram() -> Histogram[T] {
  Histogram::from_functions((_, _) => ())
}

///|
fn[T] noop_gauge() -> Gauge[T] {
  Gauge::from_functions((_, _) => ())
}

///|
fn[T] noop_observable_counter() -> ObservableCounter[T] {
  ObservableCounter::from_functions((_, _) => ())
}

///|
fn[T] noop_observable_up_down_counter() -> ObservableUpDownCounter[T] {
  ObservableUpDownCounter::from_functions((_, _) => ())
}

///|
fn[T] noop_observable_gauge() -> ObservableGauge[T] {
  ObservableGauge::from_functions((_, _) => ())
}

///|
fn[T] noop_counter_builder() -> CounterBuilder[T] {
  CounterBuilder::from_functions((_, _) => noop_counter())
}

///|
fn[T] noop_up_down_counter_builder() -> UpDownCounterBuilder[T] {
  UpDownCounterBuilder::from_functions((_, _) => noop_up_down_counter())
}

///|
fn[T] noop_histogram_builder() -> HistogramBuilder[T] {
  HistogramBuilder::from_functions((_, _) => noop_histogram())
}

///|
fn[T] noop_gauge_builder() -> GaugeBuilder[T] {
  GaugeBuilder::from_functions((_, _) => noop_gauge())
}

///|
fn[T] noop_observable_counter_builder() -> ObservableCounterBuilder[T] {
  ObservableCounterBuilder::from_functions((_, _, _) => {
    noop_observable_counter()
  })
}

///|
fn[T] noop_observable_up_down_counter_builder() -> ObservableUpDownCounterBuilder[
  T,
] {
  ObservableUpDownCounterBuilder::from_functions((_, _, _) => {
    noop_observable_up_down_counter()
  })
}

///|
fn[T] noop_observable_gauge_builder() -> ObservableGaugeBuilder[T] {
  ObservableGaugeBuilder::from_functions((_, _, _) => noop_observable_gauge())
}

///|
fn noop_meter() -> Meter {
  Meter::from_functions(
    _ => noop_counter_builder(),
    _ => noop_counter_builder(),
    _ => noop_up_down_counter_builder(),
    _ => noop_up_down_counter_builder(),
    _ => noop_histogram_builder(),
    _ => noop_histogram_builder(),
    _ => noop_gauge_builder(),
    _ => noop_gauge_builder(),
    _ => noop_gauge_builder(),
    _ => noop_observable_counter_builder(),
    _ => noop_observable_counter_builder(),
    _ => noop_observable_up_down_counter_builder(),
    _ => noop_observable_up_down_counter_builder(),
    _ => noop_observable_gauge_builder(),
    _ => noop_observable_gauge_builder(),
    _ => noop_observable_gauge_builder(),
  )
}

///|
/// Builds a meter from instrument-builder callbacks.
///
/// SDK implementations use this to erase concrete meter types into the public
/// API without making the API package depend on the SDK.
pub fn Meter::from_functions(
  u64_counter_fn : (String) -> CounterBuilder[UInt64],
  f64_counter_fn : (String) -> CounterBuilder[Double],
  i64_up_down_counter_fn : (String) -> UpDownCounterBuilder[Int64],
  f64_up_down_counter_fn : (String) -> UpDownCounterBuilder[Double],
  u64_histogram_fn : (String) -> HistogramBuilder[UInt64],
  f64_histogram_fn : (String) -> HistogramBuilder[Double],
  u64_gauge_fn : (String) -> GaugeBuilder[UInt64],
  i64_gauge_fn : (String) -> GaugeBuilder[Int64],
  f64_gauge_fn : (String) -> GaugeBuilder[Double],
  u64_observable_counter_fn : (String) -> ObservableCounterBuilder[UInt64],
  f64_observable_counter_fn : (String) -> ObservableCounterBuilder[Double],
  i64_observable_up_down_counter_fn : (String) -> ObservableUpDownCounterBuilder[
    Int64,
  ],
  f64_observable_up_down_counter_fn : (String) -> ObservableUpDownCounterBuilder[
    Double,
  ],
  u64_observable_gauge_fn : (String) -> ObservableGaugeBuilder[UInt64],
  i64_observable_gauge_fn : (String) -> ObservableGaugeBuilder[Int64],
  f64_observable_gauge_fn : (String) -> ObservableGaugeBuilder[Double],
) -> Meter {
  {
    u64_counter_fn,
    f64_counter_fn,
    i64_up_down_counter_fn,
    f64_up_down_counter_fn,
    u64_histogram_fn,
    f64_histogram_fn,
    u64_gauge_fn,
    i64_gauge_fn,
    f64_gauge_fn,
    u64_observable_counter_fn,
    f64_observable_counter_fn,
    i64_observable_up_down_counter_fn,
    f64_observable_up_down_counter_fn,
    u64_observable_gauge_fn,
    i64_observable_gauge_fn,
    f64_observable_gauge_fn,
  }
}

///|
/// Builds a meter provider from a scope-to-meter callback.
pub fn MeterProvider::from_functions(
  meter_with_scope_fn : (@common.InstrumentationScope) -> Meter,
) -> MeterProvider {
  { meter_with_scope_fn, }
}

///|
/// Returns a no-op meter provider.
///
/// Meters from this provider create instruments that silently discard all
/// measurements and never run observable callbacks.
pub fn MeterProvider::noop() -> MeterProvider {
  MeterProvider::from_functions(_ => noop_meter())
}

///|
/// Returns a meter for one instrumentation name.
///
/// If the provider is no-op, the returned meter creates no-op instruments.
pub fn MeterProvider::meter(self : MeterProvider, name : StringView) -> Meter {
  self.meter_with_scope(@common.InstrumentationScope::builder(name).build())
}

///|
/// Returns a meter for a fully constructed instrumentation scope.
pub fn MeterProvider::meter_with_scope(
  self : MeterProvider,
  scope : @common.InstrumentationScope,
) -> Meter {
  (self.meter_with_scope_fn)(scope)
}

///|
/// Adds one measurement to a monotonic counter.
///
/// The underlying SDK ignores negative deltas. Attributes should be
/// low-cardinality because they form metric series identity.
pub fn[T] Counter::add(
  self : Counter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_fn)(value, attributes)
}

///|
/// Adds one measurement to an up-down counter.
///
/// Use this for state that can go up and down. For monotonically increasing
/// totals, prefer `Counter`.
pub fn[T] UpDownCounter::add(
  self : UpDownCounter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_fn)(value, attributes)
}

///|
/// Records one histogram sample.
///
/// Histograms aggregate distributions and are usually the right choice for
/// latency and size measurements.
pub fn[T] Histogram::record(
  self : Histogram[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.record_fn)(value, attributes)
}

///|
/// Records the latest gauge value for one attribute set.
///
/// The latest value replaces the previous value for the same attribute set.
pub fn[T] Gauge::record(
  self : Gauge[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.record_fn)(value, attributes)
}

///|
/// Reports one observable counter value from a callback.
pub fn[T] ObservableCounter::observe(
  self : ObservableCounter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.observe_fn)(value, attributes)
}

///|
/// Reports one observable up-down counter value from a callback.
pub fn[T] ObservableUpDownCounter::observe(
  self : ObservableUpDownCounter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.observe_fn)(value, attributes)
}

///|
/// Reports one observable gauge value from a callback.
pub fn[T] ObservableGauge::observe(
  self : ObservableGauge[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.observe_fn)(value, attributes)
}

///|
/// Sets the instrument description on the counter builder.
pub fn[T] CounterBuilder::with_description(
  self : CounterBuilder[T],
  description : StringView,
) -> CounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit on the counter builder.
pub fn[T] CounterBuilder::with_unit(
  self : CounterBuilder[T],
  unit : StringView,
) -> CounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the counter with the current builder options.
pub fn[T] CounterBuilder::build(self : CounterBuilder[T]) -> Counter[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
/// Sets the instrument description on the up-down counter builder.
pub fn[T] UpDownCounterBuilder::with_description(
  self : UpDownCounterBuilder[T],
  description : StringView,
) -> UpDownCounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit on the up-down counter builder.
pub fn[T] UpDownCounterBuilder::with_unit(
  self : UpDownCounterBuilder[T],
  unit : StringView,
) -> UpDownCounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the up-down counter with the current builder options.
pub fn[T] UpDownCounterBuilder::build(
  self : UpDownCounterBuilder[T],
) -> UpDownCounter[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
/// Sets the instrument description on the histogram builder.
pub fn[T] HistogramBuilder::with_description(
  self : HistogramBuilder[T],
  description : StringView,
) -> HistogramBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit on the histogram builder.
pub fn[T] HistogramBuilder::with_unit(
  self : HistogramBuilder[T],
  unit : StringView,
) -> HistogramBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the histogram with the current builder options.
pub fn[T] HistogramBuilder::build(self : HistogramBuilder[T]) -> Histogram[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
/// Sets the instrument description on the gauge builder.
pub fn[T] GaugeBuilder::with_description(
  self : GaugeBuilder[T],
  description : StringView,
) -> GaugeBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit on the gauge builder.
pub fn[T] GaugeBuilder::with_unit(
  self : GaugeBuilder[T],
  unit : StringView,
) -> GaugeBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Builds the gauge with the current builder options.
pub fn[T] GaugeBuilder::build(self : GaugeBuilder[T]) -> Gauge[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
/// Sets the instrument description on the observable counter builder.
pub fn[T] ObservableCounterBuilder::with_description(
  self : ObservableCounterBuilder[T],
  description : StringView,
) -> ObservableCounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit on the observable counter builder.
pub fn[T] ObservableCounterBuilder::with_unit(
  self : ObservableCounterBuilder[T],
  unit : StringView,
) -> ObservableCounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Registers one callback to run during metric collection.
///
/// Keep callbacks fast and side-effect-light. They run on collection/export
/// paths, not when the observable instrument is created.
pub fn[T] ObservableCounterBuilder::with_callback(
  self : ObservableCounterBuilder[T],
  callback : (ObservableCounter[T]) -> Unit,
) -> ObservableCounterBuilder[T] {
  self.callbacks.push(callback)
  self
}

///|
/// Builds the observable counter and freezes the currently registered
/// callbacks.
pub fn[T] ObservableCounterBuilder::build(
  self : ObservableCounterBuilder[T],
) -> ObservableCounter[T] {
  (self.create_fn)(self.description, self.unit, self.callbacks.copy())
}

///|
/// Sets the instrument description on the observable up-down counter builder.
pub fn[T] ObservableUpDownCounterBuilder::with_description(
  self : ObservableUpDownCounterBuilder[T],
  description : StringView,
) -> ObservableUpDownCounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit on the observable up-down counter builder.
pub fn[T] ObservableUpDownCounterBuilder::with_unit(
  self : ObservableUpDownCounterBuilder[T],
  unit : StringView,
) -> ObservableUpDownCounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Registers one callback to run during metric collection.
///
/// Keep callbacks fast and side-effect-light. They run on collection/export
/// paths, not when the observable instrument is created.
pub fn[T] ObservableUpDownCounterBuilder::with_callback(
  self : ObservableUpDownCounterBuilder[T],
  callback : (ObservableUpDownCounter[T]) -> Unit,
) -> ObservableUpDownCounterBuilder[T] {
  self.callbacks.push(callback)
  self
}

///|
/// Builds the observable up-down counter and freezes the currently registered
/// callbacks.
pub fn[T] ObservableUpDownCounterBuilder::build(
  self : ObservableUpDownCounterBuilder[T],
) -> ObservableUpDownCounter[T] {
  (self.create_fn)(self.description, self.unit, self.callbacks.copy())
}

///|
/// Sets the instrument description on the observable gauge builder.
pub fn[T] ObservableGaugeBuilder::with_description(
  self : ObservableGaugeBuilder[T],
  description : StringView,
) -> ObservableGaugeBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
/// Sets the instrument unit on the observable gauge builder.
pub fn[T] ObservableGaugeBuilder::with_unit(
  self : ObservableGaugeBuilder[T],
  unit : StringView,
) -> ObservableGaugeBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
/// Registers one callback to run during metric collection.
///
/// Keep callbacks fast and side-effect-light. They run on collection/export
/// paths, not when the observable instrument is created.
pub fn[T] ObservableGaugeBuilder::with_callback(
  self : ObservableGaugeBuilder[T],
  callback : (ObservableGauge[T]) -> Unit,
) -> ObservableGaugeBuilder[T] {
  self.callbacks.push(callback)
  self
}

///|
/// Builds the observable gauge and freezes the currently registered callbacks.
pub fn[T] ObservableGaugeBuilder::build(
  self : ObservableGaugeBuilder[T],
) -> ObservableGauge[T] {
  (self.create_fn)(self.description, self.unit, self.callbacks.copy())
}

///|
/// Starts building a `UInt64` monotonic counter.
///
/// Instrument names should be stable and low-cardinality. The same named
/// instrument should be built once and reused.
pub fn Meter::u64_counter(
  self : Meter,
  name : StringView,
) -> CounterBuilder[UInt64] {
  (self.u64_counter_fn)(name.to_string())
}

///|
/// Starts building a `Double` monotonic counter.
///
/// The underlying SDK ignores negative deltas.
pub fn Meter::f64_counter(
  self : Meter,
  name : StringView,
) -> CounterBuilder[Double] {
  (self.f64_counter_fn)(name.to_string())
}

///|
/// Starts building an `Int64` up-down counter.
pub fn Meter::i64_up_down_counter(
  self : Meter,
  name : StringView,
) -> UpDownCounterBuilder[Int64] {
  (self.i64_up_down_counter_fn)(name.to_string())
}

///|
/// Starts building a `Double` up-down counter.
pub fn Meter::f64_up_down_counter(
  self : Meter,
  name : StringView,
) -> UpDownCounterBuilder[Double] {
  (self.f64_up_down_counter_fn)(name.to_string())
}

///|
/// Starts building a `UInt64` histogram.
pub fn Meter::u64_histogram(
  self : Meter,
  name : StringView,
) -> HistogramBuilder[UInt64] {
  (self.u64_histogram_fn)(name.to_string())
}

///|
/// Starts building a `Double` histogram.
pub fn Meter::f64_histogram(
  self : Meter,
  name : StringView,
) -> HistogramBuilder[Double] {
  (self.f64_histogram_fn)(name.to_string())
}

///|
/// Starts building a `UInt64` gauge.
pub fn Meter::u64_gauge(
  self : Meter,
  name : StringView,
) -> GaugeBuilder[UInt64] {
  (self.u64_gauge_fn)(name.to_string())
}

///|
/// Starts building an `Int64` gauge.
///
/// Values are converted to `Double` before they are forwarded to the SDK.
pub fn Meter::i64_gauge(self : Meter, name : StringView) -> GaugeBuilder[Int64] {
  (self.i64_gauge_fn)(name.to_string())
}

///|
/// Starts building a `Double` gauge.
pub fn Meter::f64_gauge(
  self : Meter,
  name : StringView,
) -> GaugeBuilder[Double] {
  (self.f64_gauge_fn)(name.to_string())
}

///|
/// Starts building a `UInt64` observable counter.
pub fn Meter::u64_observable_counter(
  self : Meter,
  name : StringView,
) -> ObservableCounterBuilder[UInt64] {
  (self.u64_observable_counter_fn)(name.to_string())
}

///|
/// Starts building a `Double` observable counter.
pub fn Meter::f64_observable_counter(
  self : Meter,
  name : StringView,
) -> ObservableCounterBuilder[Double] {
  (self.f64_observable_counter_fn)(name.to_string())
}

///|
/// Starts building an `Int64` observable up-down counter.
pub fn Meter::i64_observable_up_down_counter(
  self : Meter,
  name : StringView,
) -> ObservableUpDownCounterBuilder[Int64] {
  (self.i64_observable_up_down_counter_fn)(name.to_string())
}

///|
/// Starts building a `Double` observable up-down counter.
pub fn Meter::f64_observable_up_down_counter(
  self : Meter,
  name : StringView,
) -> ObservableUpDownCounterBuilder[Double] {
  (self.f64_observable_up_down_counter_fn)(name.to_string())
}

///|
/// Starts building a `UInt64` observable gauge.
pub fn Meter::u64_observable_gauge(
  self : Meter,
  name : StringView,
) -> ObservableGaugeBuilder[UInt64] {
  (self.u64_observable_gauge_fn)(name.to_string())
}

///|
/// Starts building an `Int64` observable gauge.
///
/// Callback observations are converted to `Double` before they are forwarded to
/// the SDK.
pub fn Meter::i64_observable_gauge(
  self : Meter,
  name : StringView,
) -> ObservableGaugeBuilder[Int64] {
  (self.i64_observable_gauge_fn)(name.to_string())
}

///|
/// Starts building a `Double` observable gauge.
pub fn Meter::f64_observable_gauge(
  self : Meter,
  name : StringView,
) -> ObservableGaugeBuilder[Double] {
  (self.f64_observable_gauge_fn)(name.to_string())
}
