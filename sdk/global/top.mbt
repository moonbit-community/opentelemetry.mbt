///|
/// Builds the default composite propagator used by global state.
fn default_text_map_propagator() -> @propagation.TextMapPropagator {
  @propagation.TextMapCompositePropagator::new([
    @propagation.TraceContextPropagator::new().into_text_map(),
    @propagation.BaggagePropagator::new().into_text_map(),
  ]).into_text_map()
}

///|
let tracer_provider_ref : Ref[@trace.SdkTracerProvider] = Ref::new(
  @trace.SdkTracerProvider::builder().build(),
)

///|
let logger_provider_ref : Ref[@logs.SdkLoggerProvider] = Ref::new(
  @logs.SdkLoggerProvider::builder().build(),
)

///|
let meter_provider_ref : Ref[@metrics.SdkMeterProvider] = Ref::new(
  @metrics.SdkMeterProvider::builder().build(),
)

///|
let text_map_propagator_ref : Ref[@propagation.TextMapPropagator] = Ref::new(
  default_text_map_propagator(),
)

///|
/// Returns the currently registered global tracer provider.
pub fn tracer_provider() -> @trace.SdkTracerProvider {
  tracer_provider_ref.val
}

///|
/// Replaces the global tracer provider.
pub fn set_tracer_provider(provider : @trace.SdkTracerProvider) -> Unit {
  tracer_provider_ref.val = provider
}

///|
/// Returns the currently registered global logger provider.
pub fn logger_provider() -> @logs.SdkLoggerProvider {
  logger_provider_ref.val
}

///|
/// Replaces the global logger provider.
pub fn set_logger_provider(provider : @logs.SdkLoggerProvider) -> Unit {
  logger_provider_ref.val = provider
}

///|
/// Returns the currently registered global meter provider.
pub fn meter_provider() -> @metrics.SdkMeterProvider {
  meter_provider_ref.val
}

///|
/// Replaces the global meter provider.
pub fn set_meter_provider(provider : @metrics.SdkMeterProvider) -> Unit {
  meter_provider_ref.val = provider
}

///|
/// Returns the current text map propagator.
pub fn text_map_propagator() -> @propagation.TextMapPropagator {
  text_map_propagator_ref.val
}

///|
/// Replaces the global text map propagator.
pub fn set_text_map_propagator(
  propagator : @propagation.TextMapPropagator,
) -> Unit {
  text_map_propagator_ref.val = propagator
}

///|
/// Creates a tracer from the current global tracer provider.
pub fn tracer(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @trace.SdkTracer {
  tracer_provider_ref.val.tracer(name, version~, schema_url~, attributes~)
}

///|
/// Creates a logger from the current global logger provider.
pub fn logger(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @logs.SdkLogger {
  logger_provider_ref.val.logger(name, version~, schema_url~, attributes~)
}

///|
/// Creates a meter from the current global meter provider.
pub fn meter(
  name : StringView,
  version? : String? = None,
  schema_url? : String? = None,
  attributes? : ArrayView[@common.KeyValue] = [],
) -> @metrics.SdkMeter {
  meter_provider_ref.val.meter(name, version~, schema_url~, attributes~)
}

///|
/// Spawns the background loops needed by global batch processors and periodic
/// readers.
pub fn spawn_background_tasks(
  group : @async.TaskGroup[Unit],
  allow_failure? : Bool = false,
) -> Unit {
  tracer_provider_ref.val.spawn_batch_processor_tasks(group, allow_failure~)
  logger_provider_ref.val.spawn_batch_processor_tasks(group, allow_failure~)
  meter_provider_ref.val.spawn_periodic_readers(group, allow_failure~)
}

///|
/// Flushes all globally registered providers, ignoring individual errors.
pub async fn force_flush() -> Unit {
  ignore(tracer_provider_ref.val.force_flush())
  ignore(logger_provider_ref.val.force_flush())
  ignore(meter_provider_ref.val.force_flush())
}

///|
/// Shuts down all globally registered providers, ignoring individual errors.
pub async fn shutdown() -> Unit {
  ignore(tracer_provider_ref.val.shutdown())
  ignore(logger_provider_ref.val.shutdown())
  ignore(meter_provider_ref.val.shutdown())
}

///|
/// Resets global state to defaults. Intended for tests.
pub fn reset_for_test() -> Unit {
  tracer_provider_ref.val = @trace.SdkTracerProvider::builder().build()
  logger_provider_ref.val = @logs.SdkLoggerProvider::builder().build()
  meter_provider_ref.val = @metrics.SdkMeterProvider::builder().build()
  text_map_propagator_ref.val = default_text_map_propagator()
}
