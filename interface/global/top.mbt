///|
fn default_text_map_propagator() -> @propagation.TextMapPropagator {
  @propagation.TextMapCompositePropagator::new([
    @propagation.TraceContextPropagator::new().into_text_map(),
    @propagation.BaggagePropagator::new().into_text_map(),
  ]).into_text_map()
}

///|
let tracer_provider_ref : Ref[@trace.TracerProvider] = Ref::new(
  @trace.TracerProvider::noop(),
)

///|
let logger_provider_ref : Ref[@logs.LoggerProvider] = Ref::new(
  @logs.LoggerProvider::noop(),
)

///|
let meter_provider_ref : Ref[@metrics.MeterProvider] = Ref::new(
  @metrics.MeterProvider::noop(),
)

///|
let text_map_propagator_ref : Ref[@propagation.TextMapPropagator] = Ref::new(
  default_text_map_propagator(),
)

///|
fn build_scope(
  name : StringView,
  version : String?,
  schema_url : String?,
  attributes : ArrayView[@common.KeyValue],
) -> @common.InstrumentationScope {
  let mut builder = @common.InstrumentationScope::builder(name)
  match version {
    Some(version) => builder = builder.with_version(version)
    None => ()
  }
  match schema_url {
    Some(schema_url) => builder = builder.with_schema_url(schema_url)
    None => ()
  }
  builder.with_attributes(attributes).build()
}

///|
pub fn tracer_provider() -> @trace.TracerProvider {
  tracer_provider_ref.val
}

///|
pub fn set_tracer_provider(provider : @trace.TracerProvider) -> Unit {
  tracer_provider_ref.val = provider
}

///|
pub fn logger_provider() -> @logs.LoggerProvider {
  logger_provider_ref.val
}

///|
pub fn set_logger_provider(provider : @logs.LoggerProvider) -> Unit {
  logger_provider_ref.val = provider
}

///|
pub fn meter_provider() -> @metrics.MeterProvider {
  meter_provider_ref.val
}

///|
pub fn set_meter_provider(provider : @metrics.MeterProvider) -> Unit {
  meter_provider_ref.val = provider
}

///|
pub fn set_text_map_propagator(
  propagator : @propagation.TextMapPropagator,
) -> Unit {
  text_map_propagator_ref.val = propagator
}

///|
pub fn[T] get_text_map_propagator(
  f : (@propagation.TextMapPropagator) -> T,
) -> T {
  f(text_map_propagator_ref.val)
}

///|
pub fn tracer(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @trace.Tracer {
  tracer_provider_ref.val.tracer_with_scope(
    build_scope(name, version, schema_url, attributes),
  )
}

///|
pub fn tracer_with_scope(scope : @common.InstrumentationScope) -> @trace.Tracer {
  tracer_provider_ref.val.tracer_with_scope(scope)
}

///|
pub fn logger(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @logs.Logger {
  logger_provider_ref.val.logger_with_scope(
    build_scope(name, version, schema_url, attributes),
  )
}

///|
pub fn logger_with_scope(scope : @common.InstrumentationScope) -> @logs.Logger {
  logger_provider_ref.val.logger_with_scope(scope)
}

///|
pub fn meter(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @metrics.Meter {
  meter_provider_ref.val.meter_with_scope(
    build_scope(name, version, schema_url, attributes),
  )
}

///|
pub fn meter_with_scope(scope : @common.InstrumentationScope) -> @metrics.Meter {
  meter_provider_ref.val.meter_with_scope(scope)
}

///|
pub fn spawn_background_tasks(
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  tracer_provider_ref.val.spawn_batch_processor_tasks(group, allow_failure~)
  logger_provider_ref.val.spawn_batch_processor_tasks(group, allow_failure~)
  meter_provider_ref.val.spawn_periodic_readers(group, allow_failure~)
}

///|
pub async fn force_flush() -> Unit {
  ignore(tracer_provider_ref.val.force_flush())
  ignore(logger_provider_ref.val.force_flush())
  ignore(meter_provider_ref.val.force_flush())
}

///|
pub async fn shutdown() -> Unit {
  ignore(tracer_provider_ref.val.shutdown())
  ignore(logger_provider_ref.val.shutdown())
  ignore(meter_provider_ref.val.shutdown())
}

///|
pub fn reset_for_test() -> Unit {
  tracer_provider_ref.val = @trace.TracerProvider::noop()
  logger_provider_ref.val = @logs.LoggerProvider::noop()
  meter_provider_ref.val = @metrics.MeterProvider::noop()
  text_map_propagator_ref.val = default_text_map_propagator()
}
