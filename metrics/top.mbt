///|
pub struct Counter[T] {
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
pub struct UpDownCounter[T] {
  add_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
pub struct Histogram[T] {
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
pub struct Gauge[T] {
  record_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
pub struct ObservableCounter[T] {
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
pub struct ObservableUpDownCounter[T] {
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
pub struct ObservableGauge[T] {
  observe_fn : (T, ArrayView[@common.KeyValue]) -> Unit
}

///|
pub struct CounterBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> Counter[T]
}

///|
pub struct UpDownCounterBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> UpDownCounter[T]
}

///|
pub struct HistogramBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> Histogram[T]
}

///|
pub struct GaugeBuilder[T] {
  mut description : String?
  mut unit : String?
  create_fn : (String?, String?) -> Gauge[T]
}

///|
pub struct ObservableCounterBuilder[T] {
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableCounter[T]) -> Unit]
  create_fn : (String?, String?, Array[(ObservableCounter[T]) -> Unit]) -> ObservableCounter[
    T,
  ]
}

///|
pub struct ObservableUpDownCounterBuilder[T] {
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableUpDownCounter[T]) -> Unit]
  create_fn : (String?, String?, Array[(ObservableUpDownCounter[T]) -> Unit]) -> ObservableUpDownCounter[
    T,
  ]
}

///|
pub struct ObservableGaugeBuilder[T] {
  mut description : String?
  mut unit : String?
  callbacks : Array[(ObservableGauge[T]) -> Unit]
  create_fn : (String?, String?, Array[(ObservableGauge[T]) -> Unit]) -> ObservableGauge[
    T,
  ]
}

///|
pub struct Meter {
  sdk_meter : @sdkmetrics.SdkMeter?
}

///|
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
pub fn MeterProvider::from_sdk(
  provider : @sdkmetrics.SdkMeterProvider,
) -> MeterProvider {
  { sdk_provider: Some(provider) }
}

///|
pub fn MeterProvider::noop() -> MeterProvider {
  { sdk_provider: None }
}

///|
pub fn MeterProvider::meter(self : MeterProvider, name : StringView) -> Meter {
  match self.sdk_provider {
    Some(provider) => { sdk_meter: Some(provider.meter(name)) }
    None => { sdk_meter: None }
  }
}

///|
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
pub fn MeterProvider::force_flush(self : MeterProvider) -> @error.OTelSdkResult {
  match self.sdk_provider {
    Some(provider) => provider.force_flush()
    None => @error.ok()
  }
}

///|
pub fn MeterProvider::shutdown(self : MeterProvider) -> @error.OTelSdkResult {
  match self.sdk_provider {
    Some(provider) => provider.shutdown()
    None => @error.ok()
  }
}

///|
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
pub fn[T] Counter::add(
  self : Counter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_fn)(value, attributes)
}

///|
pub fn[T] UpDownCounter::add(
  self : UpDownCounter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.add_fn)(value, attributes)
}

///|
pub fn[T] Histogram::record(
  self : Histogram[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.record_fn)(value, attributes)
}

///|
pub fn[T] Gauge::record(
  self : Gauge[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.record_fn)(value, attributes)
}

///|
pub fn[T] ObservableCounter::observe(
  self : ObservableCounter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.observe_fn)(value, attributes)
}

///|
pub fn[T] ObservableUpDownCounter::observe(
  self : ObservableUpDownCounter[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.observe_fn)(value, attributes)
}

///|
pub fn[T] ObservableGauge::observe(
  self : ObservableGauge[T],
  value : T,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> Unit {
  (self.observe_fn)(value, attributes)
}

///|
pub fn[T] CounterBuilder::with_description(
  self : CounterBuilder[T],
  description : StringView,
) -> CounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
pub fn[T] CounterBuilder::with_unit(
  self : CounterBuilder[T],
  unit : StringView,
) -> CounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn[T] CounterBuilder::build(self : CounterBuilder[T]) -> Counter[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
pub fn[T] UpDownCounterBuilder::with_description(
  self : UpDownCounterBuilder[T],
  description : StringView,
) -> UpDownCounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
pub fn[T] UpDownCounterBuilder::with_unit(
  self : UpDownCounterBuilder[T],
  unit : StringView,
) -> UpDownCounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn[T] UpDownCounterBuilder::build(
  self : UpDownCounterBuilder[T],
) -> UpDownCounter[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
pub fn[T] HistogramBuilder::with_description(
  self : HistogramBuilder[T],
  description : StringView,
) -> HistogramBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
pub fn[T] HistogramBuilder::with_unit(
  self : HistogramBuilder[T],
  unit : StringView,
) -> HistogramBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn[T] HistogramBuilder::build(self : HistogramBuilder[T]) -> Histogram[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
pub fn[T] GaugeBuilder::with_description(
  self : GaugeBuilder[T],
  description : StringView,
) -> GaugeBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
pub fn[T] GaugeBuilder::with_unit(
  self : GaugeBuilder[T],
  unit : StringView,
) -> GaugeBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn[T] GaugeBuilder::build(self : GaugeBuilder[T]) -> Gauge[T] {
  (self.create_fn)(self.description, self.unit)
}

///|
pub fn[T] ObservableCounterBuilder::with_description(
  self : ObservableCounterBuilder[T],
  description : StringView,
) -> ObservableCounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
pub fn[T] ObservableCounterBuilder::with_unit(
  self : ObservableCounterBuilder[T],
  unit : StringView,
) -> ObservableCounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn[T] ObservableCounterBuilder::with_callback(
  self : ObservableCounterBuilder[T],
  callback : (ObservableCounter[T]) -> Unit,
) -> ObservableCounterBuilder[T] {
  self.callbacks.push(callback)
  self
}

///|
pub fn[T] ObservableCounterBuilder::build(
  self : ObservableCounterBuilder[T],
) -> ObservableCounter[T] {
  (self.create_fn)(self.description, self.unit, self.callbacks.copy())
}

///|
pub fn[T] ObservableUpDownCounterBuilder::with_description(
  self : ObservableUpDownCounterBuilder[T],
  description : StringView,
) -> ObservableUpDownCounterBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
pub fn[T] ObservableUpDownCounterBuilder::with_unit(
  self : ObservableUpDownCounterBuilder[T],
  unit : StringView,
) -> ObservableUpDownCounterBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn[T] ObservableUpDownCounterBuilder::with_callback(
  self : ObservableUpDownCounterBuilder[T],
  callback : (ObservableUpDownCounter[T]) -> Unit,
) -> ObservableUpDownCounterBuilder[T] {
  self.callbacks.push(callback)
  self
}

///|
pub fn[T] ObservableUpDownCounterBuilder::build(
  self : ObservableUpDownCounterBuilder[T],
) -> ObservableUpDownCounter[T] {
  (self.create_fn)(self.description, self.unit, self.callbacks.copy())
}

///|
pub fn[T] ObservableGaugeBuilder::with_description(
  self : ObservableGaugeBuilder[T],
  description : StringView,
) -> ObservableGaugeBuilder[T] {
  self.description = Some(description.to_string())
  self
}

///|
pub fn[T] ObservableGaugeBuilder::with_unit(
  self : ObservableGaugeBuilder[T],
  unit : StringView,
) -> ObservableGaugeBuilder[T] {
  self.unit = Some(unit.to_string())
  self
}

///|
pub fn[T] ObservableGaugeBuilder::with_callback(
  self : ObservableGaugeBuilder[T],
  callback : (ObservableGauge[T]) -> Unit,
) -> ObservableGaugeBuilder[T] {
  self.callbacks.push(callback)
  self
}

///|
pub fn[T] ObservableGaugeBuilder::build(
  self : ObservableGaugeBuilder[T],
) -> ObservableGauge[T] {
  (self.create_fn)(self.description, self.unit, self.callbacks.copy())
}

///|
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
