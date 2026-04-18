///|
/// Monotonic synchronous counter handle.
pub struct Counter[T] {
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Additive synchronous counter that accepts positive and negative deltas.
pub struct UpDownCounter[T] {
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Synchronous histogram handle.
pub struct Histogram[T] {
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Synchronous gauge handle recording the latest value for one attribute set.
pub struct Gauge[T] {
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
/// Observable monotonic counter handle used inside callbacks.
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
pub struct Meter {
  sdk_meter : @sdkmetrics.SdkMeter?
}

///|
/// Public meter provider wrapper around the SDK provider.
pub struct MeterProvider {
  sdk_provider : @sdkmetrics.SdkMeterProvider?
}

///|
fn[T] noop_counter() -> Counter[T] {
  { add_fn: (_, _) => () }
}

///|
fn[T] noop_up_down_counter() -> UpDownCounter[T] {
  { add_fn: (_, _) => () }
}

///|
fn[T] noop_histogram() -> Histogram[T] {
  { record_fn: (_, _) => () }
}

///|
fn[T] noop_gauge() -> Gauge[T] {
  { record_fn: (_, _) => () }
}

///|
fn[T] noop_observable_counter() -> ObservableCounter[T] {
  { observe_fn: (_, _) => () }
}

///|
fn[T] noop_observable_up_down_counter() -> ObservableUpDownCounter[T] {
  { observe_fn: (_, _) => () }
}

///|
fn[T] noop_observable_gauge() -> ObservableGauge[T] {
  { observe_fn: (_, _) => () }
}

///|
fn uint64_to_int64(value : UInt64) -> Int64? {
  if value > 9223372036854775807UL {
    None
  } else {
    Some(value.reinterpret_as_int64())
  }
}

///|
fn with_counter_options(
  builder : @sdkmetrics.CounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.CounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_double_counter_options(
  builder : @sdkmetrics.DoubleCounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.DoubleCounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_up_down_counter_options(
  builder : @sdkmetrics.UpDownCounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.UpDownCounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_double_up_down_counter_options(
  builder : @sdkmetrics.DoubleUpDownCounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.DoubleUpDownCounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_histogram_options(
  builder : @sdkmetrics.HistogramBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.HistogramBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_gauge_options(
  builder : @sdkmetrics.GaugeBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.GaugeBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_observable_counter_options(
  builder : @sdkmetrics.ObservableCounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.ObservableCounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_observable_double_counter_options(
  builder : @sdkmetrics.ObservableDoubleCounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.ObservableDoubleCounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_observable_up_down_counter_options(
  builder : @sdkmetrics.ObservableUpDownCounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.ObservableUpDownCounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_observable_double_up_down_counter_options(
  builder : @sdkmetrics.ObservableDoubleUpDownCounterBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.ObservableDoubleUpDownCounterBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
fn with_observable_gauge_options(
  builder : @sdkmetrics.ObservableGaugeBuilder,
  description : String?,
  unit : String?,
) -> @sdkmetrics.ObservableGaugeBuilder {
  let mut builder = builder
  match description {
    Some(description) => builder = builder.with_description(description)
    None => ()
  }
  match unit {
    Some(unit) => builder = builder.with_unit(unit)
    None => ()
  }
  builder
}

///|
/// Wraps an SDK meter provider in the public API type.
pub fn MeterProvider::from_sdk(
  provider : @sdkmetrics.SdkMeterProvider,
) -> MeterProvider {
  { sdk_provider: Some(provider) }
}

///|
/// Returns a no-op meter provider.
pub fn MeterProvider::noop() -> MeterProvider {
  { sdk_provider: None }
}

///|
/// Returns a meter for one instrumentation name.
///
/// If the provider is no-op, the returned meter creates no-op instruments.
pub fn MeterProvider::meter(self : MeterProvider, name : StringView) -> Meter {
  match self.sdk_provider {
    Some(provider) => { sdk_meter: Some(provider.meter(name)) }
    None => { sdk_meter: None }
  }
}

///|
/// Returns a meter for a fully constructed instrumentation scope.
pub fn MeterProvider::meter_with_scope(
  self : MeterProvider,
  scope : @common.InstrumentationScope,
) -> Meter {
  match self.sdk_provider {
    Some(provider) => {
      let meter = provider.meter(
        scope.name(),
        version=scope.version(),
        schema_url=scope.schema_url(),
        attributes=scope.attributes(),
      )
      { sdk_meter: Some(meter) }
    }
    None => { sdk_meter: None }
  }
}

///|
/// Flushes the underlying SDK provider.
///
/// No-op providers report success.
pub async fn MeterProvider::force_flush(
  self : MeterProvider,
) -> @error.OTelSdkResult {
  match self.sdk_provider {
    Some(provider) => provider.force_flush()
    None => @error.ok()
  }
}

///|
/// Shuts down the underlying SDK provider.
///
/// No-op providers report success.
pub async fn MeterProvider::shutdown(
  self : MeterProvider,
) -> @error.OTelSdkResult {
  match self.sdk_provider {
    Some(provider) => provider.shutdown()
    None => @error.ok()
  }
}

///|
/// Spawns background loops for periodic metric readers owned by this provider.
///
/// No-op providers do nothing.
pub fn MeterProvider::spawn_periodic_readers(
  self : MeterProvider,
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  match self.sdk_provider {
    Some(provider) => provider.spawn_periodic_readers(group, allow_failure~)
    None => ()
  }
}

///|
/// Adds one measurement to a monotonic counter.
///
/// The underlying SDK ignores negative deltas.
pub fn[T] Counter::add(
  self : Counter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_fn)(value, attributes)
}

///|
/// Adds one measurement to an up-down counter.
pub fn[T] UpDownCounter::add(
  self : UpDownCounter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_fn)(value, attributes)
}

///|
/// Records one histogram sample.
pub fn[T] Histogram::record(
  self : Histogram[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.record_fn)(value, attributes)
}

///|
/// Records the latest gauge value for one attribute set.
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
/// Values are bridged through the SDK's signed 64-bit counter. Measurements
/// larger than `Int64::max` are dropped.
pub fn Meter::u64_counter(
  self : Meter,
  name : StringView,
) -> CounterBuilder[UInt64] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let counter = with_counter_options(
            meter.counter(name),
            description,
            unit,
          ).build()
          {
            add_fn: (value, attributes) => {
              match uint64_to_int64(value) {
                Some(value) => counter.add(value, attributes~)
                None => ()
              }
            },
          }
        }
        None => noop_counter()
      }
    },
  }
}

///|
/// Starts building a `Double` monotonic counter.
///
/// The underlying SDK ignores negative deltas.
pub fn Meter::f64_counter(
  self : Meter,
  name : StringView,
) -> CounterBuilder[Double] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let counter = with_double_counter_options(
            meter.f64_counter(name),
            description,
            unit,
          ).build()
          { add_fn: (value, attributes) => counter.add(value, attributes~) }
        }
        None => noop_counter()
      }
    },
  }
}

///|
/// Starts building an `Int64` up-down counter.
pub fn Meter::i64_up_down_counter(
  self : Meter,
  name : StringView,
) -> UpDownCounterBuilder[Int64] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let counter = with_up_down_counter_options(
            meter.up_down_counter(name),
            description,
            unit,
          ).build()
          { add_fn: (value, attributes) => counter.add(value, attributes~) }
        }
        None => noop_up_down_counter()
      }
    },
  }
}

///|
/// Starts building a `Double` up-down counter.
pub fn Meter::f64_up_down_counter(
  self : Meter,
  name : StringView,
) -> UpDownCounterBuilder[Double] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let counter = with_double_up_down_counter_options(
            meter.f64_up_down_counter(name),
            description,
            unit,
          ).build()
          { add_fn: (value, attributes) => counter.add(value, attributes~) }
        }
        None => noop_up_down_counter()
      }
    },
  }
}

///|
/// Starts building a `UInt64` histogram.
///
/// Values are converted to `Double` before they are forwarded to the SDK.
pub fn Meter::u64_histogram(
  self : Meter,
  name : StringView,
) -> HistogramBuilder[UInt64] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let histogram = with_histogram_options(
            meter.histogram(name),
            description,
            unit,
          ).build()
          {
            record_fn: (value, attributes) => {
              histogram.record(value.to_double(), attributes~)
            },
          }
        }
        None => noop_histogram()
      }
    },
  }
}

///|
/// Starts building a `Double` histogram.
pub fn Meter::f64_histogram(
  self : Meter,
  name : StringView,
) -> HistogramBuilder[Double] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let histogram = with_histogram_options(
            meter.histogram(name),
            description,
            unit,
          ).build()
          {
            record_fn: (value, attributes) => {
              histogram.record(value, attributes~)
            },
          }
        }
        None => noop_histogram()
      }
    },
  }
}

///|
/// Starts building a `UInt64` gauge.
///
/// Values are converted to `Double` before they are forwarded to the SDK.
pub fn Meter::u64_gauge(
  self : Meter,
  name : StringView,
) -> GaugeBuilder[UInt64] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let gauge = with_gauge_options(meter.gauge(name), description, unit).build()
          {
            record_fn: (value, attributes) => {
              gauge.record(value.to_double(), attributes~)
            },
          }
        }
        None => noop_gauge()
      }
    },
  }
}

///|
/// Starts building an `Int64` gauge.
///
/// Values are converted to `Double` before they are forwarded to the SDK.
pub fn Meter::i64_gauge(self : Meter, name : StringView) -> GaugeBuilder[Int64] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let gauge = with_gauge_options(meter.gauge(name), description, unit).build()
          {
            record_fn: (value, attributes) => {
              gauge.record(value.to_double(), attributes~)
            },
          }
        }
        None => noop_gauge()
      }
    },
  }
}

///|
/// Starts building a `Double` gauge.
pub fn Meter::f64_gauge(
  self : Meter,
  name : StringView,
) -> GaugeBuilder[Double] {
  {
    description: None,
    unit: None,
    create_fn: (description, unit) => {
      match self.sdk_meter {
        Some(meter) => {
          let gauge = with_gauge_options(meter.gauge(name), description, unit).build()
          { record_fn: (value, attributes) => gauge.record(value, attributes~) }
        }
        None => noop_gauge()
      }
    },
  }
}

///|
/// Starts building a `UInt64` observable counter.
///
/// Callback observations are bridged through the SDK's signed 64-bit counter.
/// Values larger than `Int64::max` are dropped.
pub fn Meter::u64_observable_counter(
  self : Meter,
  name : StringView,
) -> ObservableCounterBuilder[UInt64] {
  {
    description: None,
    unit: None,
    callbacks: [],
    create_fn: (description, unit, callbacks) => {
      match self.sdk_meter {
        Some(meter) => {
          let mut builder = with_observable_counter_options(
            meter.observable_counter(name),
            description,
            unit,
          )
          for callback in callbacks {
            builder = builder.with_callback(observer => {
              let wrapped : ObservableCounter[UInt64] = {
                observe_fn: (value, attributes) => {
                  match uint64_to_int64(value) {
                    Some(value) => observer.observe(value, attributes~)
                    None => ()
                  }
                },
              }
              callback(wrapped)
            })
          }
          let observer = builder.build()
          {
            observe_fn: (value, attributes) => {
              match uint64_to_int64(value) {
                Some(value) => observer.observe(value, attributes~)
                None => ()
              }
            },
          }
        }
        None => noop_observable_counter()
      }
    },
  }
}

///|
/// Starts building a `Double` observable counter.
pub fn Meter::f64_observable_counter(
  self : Meter,
  name : StringView,
) -> ObservableCounterBuilder[Double] {
  {
    description: None,
    unit: None,
    callbacks: [],
    create_fn: (description, unit, callbacks) => {
      match self.sdk_meter {
        Some(meter) => {
          let mut builder = with_observable_double_counter_options(
            meter.f64_observable_counter(name),
            description,
            unit,
          )
          for callback in callbacks {
            builder = builder.with_callback(observer => {
              let wrapped : ObservableCounter[Double] = {
                observe_fn: (value, attributes) => {
                  observer.observe(value, attributes~)
                },
              }
              callback(wrapped)
            })
          }
          let observer = builder.build()
          {
            observe_fn: (value, attributes) => {
              observer.observe(value, attributes~)
            },
          }
        }
        None => noop_observable_counter()
      }
    },
  }
}

///|
/// Starts building an `Int64` observable up-down counter.
pub fn Meter::i64_observable_up_down_counter(
  self : Meter,
  name : StringView,
) -> ObservableUpDownCounterBuilder[Int64] {
  {
    description: None,
    unit: None,
    callbacks: [],
    create_fn: (description, unit, callbacks) => {
      match self.sdk_meter {
        Some(meter) => {
          let mut builder = with_observable_up_down_counter_options(
            meter.observable_up_down_counter(name),
            description,
            unit,
          )
          for callback in callbacks {
            builder = builder.with_callback(observer => {
              let wrapped : ObservableUpDownCounter[Int64] = {
                observe_fn: (value, attributes) => {
                  observer.observe(value, attributes~)
                },
              }
              callback(wrapped)
            })
          }
          let observer = builder.build()
          {
            observe_fn: (value, attributes) => {
              observer.observe(value, attributes~)
            },
          }
        }
        None => noop_observable_up_down_counter()
      }
    },
  }
}

///|
/// Starts building a `Double` observable up-down counter.
pub fn Meter::f64_observable_up_down_counter(
  self : Meter,
  name : StringView,
) -> ObservableUpDownCounterBuilder[Double] {
  {
    description: None,
    unit: None,
    callbacks: [],
    create_fn: (description, unit, callbacks) => {
      match self.sdk_meter {
        Some(meter) => {
          let mut builder = with_observable_double_up_down_counter_options(
            meter.f64_observable_up_down_counter(name),
            description,
            unit,
          )
          for callback in callbacks {
            builder = builder.with_callback(observer => {
              let wrapped : ObservableUpDownCounter[Double] = {
                observe_fn: (value, attributes) => {
                  observer.observe(value, attributes~)
                },
              }
              callback(wrapped)
            })
          }
          let observer = builder.build()
          {
            observe_fn: (value, attributes) => {
              observer.observe(value, attributes~)
            },
          }
        }
        None => noop_observable_up_down_counter()
      }
    },
  }
}

///|
/// Starts building a `UInt64` observable gauge.
///
/// Callback observations are converted to `Double` before they are forwarded to
/// the SDK.
pub fn Meter::u64_observable_gauge(
  self : Meter,
  name : StringView,
) -> ObservableGaugeBuilder[UInt64] {
  {
    description: None,
    unit: None,
    callbacks: [],
    create_fn: (description, unit, callbacks) => {
      match self.sdk_meter {
        Some(meter) => {
          let mut builder = with_observable_gauge_options(
            meter.observable_gauge(name),
            description,
            unit,
          )
          for callback in callbacks {
            builder = builder.with_callback(observer => {
              let wrapped : ObservableGauge[UInt64] = {
                observe_fn: (value, attributes) => {
                  observer.observe(value.to_double(), attributes~)
                },
              }
              callback(wrapped)
            })
          }
          let observer = builder.build()
          {
            observe_fn: (value, attributes) => {
              observer.observe(value.to_double(), attributes~)
            },
          }
        }
        None => noop_observable_gauge()
      }
    },
  }
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
  {
    description: None,
    unit: None,
    callbacks: [],
    create_fn: (description, unit, callbacks) => {
      match self.sdk_meter {
        Some(meter) => {
          let mut builder = with_observable_gauge_options(
            meter.observable_gauge(name),
            description,
            unit,
          )
          for callback in callbacks {
            builder = builder.with_callback(observer => {
              let wrapped : ObservableGauge[Int64] = {
                observe_fn: (value, attributes) => {
                  observer.observe(value.to_double(), attributes~)
                },
              }
              callback(wrapped)
            })
          }
          let observer = builder.build()
          {
            observe_fn: (value, attributes) => {
              observer.observe(value.to_double(), attributes~)
            },
          }
        }
        None => noop_observable_gauge()
      }
    },
  }
}

///|
/// Starts building a `Double` observable gauge.
pub fn Meter::f64_observable_gauge(
  self : Meter,
  name : StringView,
) -> ObservableGaugeBuilder[Double] {
  {
    description: None,
    unit: None,
    callbacks: [],
    create_fn: (description, unit, callbacks) => {
      match self.sdk_meter {
        Some(meter) => {
          let mut builder = with_observable_gauge_options(
            meter.observable_gauge(name),
            description,
            unit,
          )
          for callback in callbacks {
            builder = builder.with_callback(observer => {
              let wrapped : ObservableGauge[Double] = {
                observe_fn: (value, attributes) => {
                  observer.observe(value, attributes~)
                },
              }
              callback(wrapped)
            })
          }
          let observer = builder.build()
          {
            observe_fn: (value, attributes) => {
              observer.observe(value, attributes~)
            },
          }
        }
        None => noop_observable_gauge()
      }
    },
  }
}
