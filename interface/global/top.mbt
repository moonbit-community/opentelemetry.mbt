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
/// Returns the currently registered global tracer provider.
pub fn tracer_provider() -> @trace.TracerProvider {
  tracer_provider_ref.val
}

///|
/// Replaces the current global tracer provider.
pub fn set_tracer_provider(provider : @trace.TracerProvider) -> Unit {
  tracer_provider_ref.val = provider
}

///|
/// Returns the currently registered global logger provider.
pub fn logger_provider() -> @logs.LoggerProvider {
  logger_provider_ref.val
}

///|
/// Replaces the current global logger provider.
pub fn set_logger_provider(provider : @logs.LoggerProvider) -> Unit {
  logger_provider_ref.val = provider
}

///|
/// Returns the currently registered global meter provider.
pub fn meter_provider() -> @metrics.MeterProvider {
  meter_provider_ref.val
}

///|
/// Replaces the current global meter provider.
pub fn set_meter_provider(provider : @metrics.MeterProvider) -> Unit {
  meter_provider_ref.val = provider
}

///|
/// Replaces the current global text-map propagator.
pub fn set_text_map_propagator(
  propagator : @propagation.TextMapPropagator,
) -> Unit {
  text_map_propagator_ref.val = propagator
}

///|
/// Calls `f` with the current global text-map propagator.
pub fn[T] get_text_map_propagator(
  f : (@propagation.TextMapPropagator) -> T,
) -> T {
  f(text_map_propagator_ref.val)
}

///|
/// Returns a tracer from the current global tracer provider.
///
/// The scope is built from `name`, `version`, `schema_url`, and `attributes`.
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
/// Returns a tracer for an already constructed instrumentation scope.
pub fn tracer_with_scope(scope : @common.InstrumentationScope) -> @trace.Tracer {
  tracer_provider_ref.val.tracer_with_scope(scope)
}

///|
/// Returns a logger from the current global logger provider.
///
/// The scope is built from `name`, `version`, `schema_url`, and `attributes`.
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
/// Returns a logger for an already constructed instrumentation scope.
pub fn logger_with_scope(scope : @common.InstrumentationScope) -> @logs.Logger {
  logger_provider_ref.val.logger_with_scope(scope)
}

///|
/// Returns a meter from the current global meter provider.
///
/// The scope is built from `name`, `version`, `schema_url`, and `attributes`.
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
/// Returns a meter for an already constructed instrumentation scope.
pub fn meter_with_scope(scope : @common.InstrumentationScope) -> @metrics.Meter {
  meter_provider_ref.val.meter_with_scope(scope)
}

///|
/// Spawns background loops for the currently registered global providers.
///
/// This activates batch span/log processors and periodic metric readers. No-op
/// providers simply do nothing.
pub fn spawn_background_tasks(
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  tracer_provider_ref.val.spawn_batch_processor_tasks(group, allow_failure~)
  logger_provider_ref.val.spawn_batch_processor_tasks(group, allow_failure~)
  meter_provider_ref.val.spawn_periodic_readers(group, allow_failure~)
}

///|
/// Flushes all currently registered providers.
///
/// Individual provider errors are intentionally ignored so the call always
/// completes with `Unit`.
pub async fn force_flush() -> Unit {
  ignore(tracer_provider_ref.val.force_flush())
  ignore(logger_provider_ref.val.force_flush())
  ignore(meter_provider_ref.val.force_flush())
}

///|
/// Shuts down all currently registered providers.
///
/// Individual provider errors are intentionally ignored so the call always
/// completes with `Unit`.
pub async fn shutdown() -> Unit {
  ignore(tracer_provider_ref.val.shutdown())
  ignore(logger_provider_ref.val.shutdown())
  ignore(meter_provider_ref.val.shutdown())
}

///|
/// Resets all global state back to the default no-op providers and default
/// propagator.
///
/// This helper exists for tests.
pub fn reset_for_test() -> Unit {
  tracer_provider_ref.val = @trace.TracerProvider::noop()
  logger_provider_ref.val = @logs.LoggerProvider::noop()
  meter_provider_ref.val = @metrics.MeterProvider::noop()
  text_map_propagator_ref.val = default_text_map_propagator()
}
