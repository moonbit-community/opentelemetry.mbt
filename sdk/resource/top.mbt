///|
/// Immutable description of the entity producing telemetry.
pub struct Resource {
  attributes : Map[String, @common.Value]
  schema_url : String?
} derive(Eq, ToJson, Debug)

///|
/// Detector callback used to discover resource attributes from the runtime or
/// environment.
pub struct ResourceDetector {
  detect_fn : () -> Resource
}

///|
/// Builder that combines explicit attributes with detector output.
pub struct ResourceBuilder {
  mut resource : Resource
  detectors : Array[ResourceDetector]
}

///|
fn resource_from_attributes(
  attributes : ArrayView[@common.KeyValue],
  schema_url? : String? = None,
) -> Resource {
  let map : Map[String, @common.Value] = {}
  for attribute in attributes {
    map[attribute.key.as_string()] = attribute.value
  }
  { attributes: map, schema_url }
}

///|
/// Returns an empty resource.
pub fn Resource::empty() -> Resource {
  { attributes: {}, schema_url: None }
}

///|
/// Starts building a resource with the SDK-provided, telemetry, and environment
/// detectors enabled by default.
pub fn Resource::builder() -> ResourceBuilder {
  {
    resource: Resource::empty(),
    detectors: [
      sdk_provided_resource_detector(),
      telemetry_resource_detector(),
      env_resource_detector(),
    ],
  }
}

///|
/// Starts building a resource without any default detectors.
pub fn Resource::builder_empty() -> ResourceBuilder {
  { resource: Resource::empty(), detectors: [] }
}

///|
/// Creates a resource from explicit attributes. Later duplicate keys win.
pub fn Resource::new(attributes : ArrayView[@common.KeyValue]) -> Resource {
  resource_from_attributes(attributes)
}

///|
/// Returns the optional schema URL attached to this resource.
pub fn Resource::schema_url(self : Resource) -> String? {
  self.schema_url
}

///|
/// Returns the number of attributes stored in the resource.
pub fn Resource::len(self : Resource) -> Int {
  self.attributes.length()
}

///|
/// Returns whether the resource carries no attributes.
pub fn Resource::is_empty(self : Resource) -> Bool {
  self.attributes.is_empty()
}

///|
/// Looks up one resource attribute.
pub fn Resource::get(self : Resource, key : StringView) -> @common.Value? {
  self.attributes.get_from_string(key)
}

///|
/// Returns a copy of all resource attributes.
pub fn Resource::attributes(self : Resource) -> Map[String, @common.Value] {
  self.attributes.copy()
}

///|
/// Merges two resources, preferring attributes from `other`. Conflicting schema
/// URLs clear the merged schema URL.
pub fn Resource::merge(self : Resource, other : Resource) -> Resource {
  if self.is_empty() && self.schema_url is None {
    return other
  }
  if other.is_empty() && other.schema_url is None {
    return self
  }
  let attributes = self.attributes.copy()
  for key, value in other.attributes {
    attributes[key] = value
  }
  let schema_url = match (self.schema_url, other.schema_url) {
    (Some(left), Some(right)) if left == right => Some(left)
    (Some(_), Some(_)) => None
    (Some(left), None) => Some(left)
    (None, Some(right)) => Some(right)
    (None, None) => None
  }
  { attributes, schema_url }
}

///|
pub impl Default for Resource with default() -> Resource {
  Resource::empty()
}

///|
/// Creates a detector from a callback.
pub fn ResourceDetector::new(detect_fn : () -> Resource) -> ResourceDetector {
  { detect_fn, }
}

///|
/// Runs the detector and returns the discovered resource.
pub fn ResourceDetector::detect(self : ResourceDetector) -> Resource {
  (self.detect_fn)()
}

///|
fn default_service_name() -> String {
  let args = @env.args()
  let process_name = if args.length() > 0 {
    @common.basename(args[0])
  } else {
    "moonbit"
  }
  "unknown_service:\{process_name}"
}

///|
/// Detects the fallback `service.name` derived from the current executable or
/// script name.
pub fn sdk_provided_resource_detector() -> ResourceDetector {
  ResourceDetector::new(() => {
    Resource::new([
      @common.KeyValue::new(
        "service.name",
        @common.Value::String(default_service_name()),
      ),
    ])
  })
}

///|
/// Detects the standard `telemetry.sdk.*` attributes for this MoonBit SDK.
pub fn telemetry_resource_detector() -> ResourceDetector {
  ResourceDetector::new(() => {
    Resource::new([
      @common.KeyValue::new(
        "telemetry.sdk.name",
        @common.Value::String("opentelemetry"),
      ),
      @common.KeyValue::new(
        "telemetry.sdk.language",
        @common.Value::String("moonbit"),
      ),
      @common.KeyValue::new(
        "telemetry.sdk.version",
        @common.Value::String("0.1.0"),
      ),
    ])
  })
}

///|
fn parse_resource_attributes(
  attributes : StringView,
) -> Array[@common.KeyValue] {
  let parsed = []
  for item in attributes.split(",") {
    let item = item.trim()
    if item.is_empty() {
      continue
    }
    guard item.find("=") is Some(index)
    let key = item[:index].trim()
    let value = item[index + 1:].trim()
    if key != "" {
      parsed.push(
        @common.KeyValue::new(key, @common.Value::String(value.to_string())),
      )
    }
  }
  parsed
}

///|
/// Detects resources from `OTEL_RESOURCE_ATTRIBUTES` and `OTEL_SERVICE_NAME`.
/// `OTEL_SERVICE_NAME` is merged last so it wins over `service.name` from the
/// generic attribute list.
pub fn env_resource_detector() -> ResourceDetector {
  ResourceDetector::new(() => {
    let mut resource = Resource::empty()
    if @common.getenv("OTEL_RESOURCE_ATTRIBUTES") is Some(attributes) {
      let detected = Resource::new(parse_resource_attributes(attributes))
      resource = resource.merge(detected)
    }
    if @common.getenv("OTEL_SERVICE_NAME") is Some(service_name) {
      let service_resource = Resource::new([
        @common.KeyValue::new(
          "service.name",
          @common.Value::String(service_name),
        ),
      ])
      resource = resource.merge(service_resource)
    }
    resource
  })
}

///|
/// Adds or replaces one attribute.
pub fn ResourceBuilder::with_attribute(
  self : ResourceBuilder,
  key : StringView,
  value : @common.Value,
) -> ResourceBuilder {
  self.resource = self.resource.merge(
    Resource::new([@common.KeyValue::new(key, value)]),
  )
  self
}

///|
/// Adds or replaces multiple attributes.
pub fn ResourceBuilder::with_attributes(
  self : ResourceBuilder,
  attributes : ArrayView[@common.KeyValue],
) -> ResourceBuilder {
  self.resource = self.resource.merge(Resource::new(attributes))
  self
}

///|
/// Sets `service.name` on the resource being built.
pub fn ResourceBuilder::with_service_name(
  self : ResourceBuilder,
  service_name : StringView,
) -> ResourceBuilder {
  self.with_attribute(
    "service.name",
    @common.Value::String(service_name.to_string()),
  )
}

///|
/// Sets the schema URL on the resource being built.
pub fn ResourceBuilder::with_schema_url(
  self : ResourceBuilder,
  schema_url : StringView,
) -> ResourceBuilder {
  self.resource = {
    attributes: self.resource.attributes,
    schema_url: Some(schema_url.to_string()),
  }
  self
}

///|
/// Appends an additional detector that will run before explicit builder
/// attributes are merged in.
pub fn ResourceBuilder::with_detector(
  self : ResourceBuilder,
  detector : ResourceDetector,
) -> ResourceBuilder {
  self.detectors.push(detector)
  self
}

///|
/// Runs detectors in order and then merges in explicit builder attributes so
/// direct configuration takes precedence.
pub fn ResourceBuilder::build(self : ResourceBuilder) -> Resource {
  let mut resource = Resource::empty()
  for detector in self.detectors {
    resource = resource.merge(detector.detect())
  }
  resource.merge(self.resource)
}
