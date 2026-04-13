///|
pub(all) enum AggregationTemporality {
  AGGREGATION_TEMPORALITY_UNSPECIFIED
  AGGREGATION_TEMPORALITY_DELTA
  AGGREGATION_TEMPORALITY_CUMULATIVE
} derive(Eq)

///|
pub fn AggregationTemporality::to_enum(
  self : AggregationTemporality,
) -> @protobuf.Enum {
  match self {
    AggregationTemporality::AGGREGATION_TEMPORALITY_UNSPECIFIED => 0
    AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA => 1
    AggregationTemporality::AGGREGATION_TEMPORALITY_CUMULATIVE => 2
  }
}

///|
pub fn AggregationTemporality::from_enum(
  i : @protobuf.Enum,
) -> AggregationTemporality {
  match i.0 {
    0 => AggregationTemporality::AGGREGATION_TEMPORALITY_UNSPECIFIED
    1 => AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA
    2 => AggregationTemporality::AGGREGATION_TEMPORALITY_CUMULATIVE
    _ => Default::default()
  }
}

///|
pub impl Default for AggregationTemporality with default() -> AggregationTemporality {
  AggregationTemporality::AGGREGATION_TEMPORALITY_UNSPECIFIED
}

///|
pub impl @protobuf.Sized for AggregationTemporality with size_of(
  self : AggregationTemporality,
) {
  @protobuf.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for AggregationTemporality with from_json(
  json : Json,
  path : @json.JsonPath,
) -> AggregationTemporality raise {
  match json {
    String("AGGREGATION_TEMPORALITY_UNSPECIFIED") =>
      AggregationTemporality::AGGREGATION_TEMPORALITY_UNSPECIFIED
    String("AGGREGATION_TEMPORALITY_DELTA") =>
      AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA
    String("AGGREGATION_TEMPORALITY_CUMULATIVE") =>
      AggregationTemporality::AGGREGATION_TEMPORALITY_CUMULATIVE
    Number(0, ..) => AggregationTemporality::AGGREGATION_TEMPORALITY_UNSPECIFIED
    Number(1, ..) => AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA
    Number(2, ..) => AggregationTemporality::AGGREGATION_TEMPORALITY_CUMULATIVE
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for AggregationTemporality with to_json(
  self : AggregationTemporality,
) -> Json {
  match self {
    AggregationTemporality::AGGREGATION_TEMPORALITY_UNSPECIFIED =>
      "AGGREGATION_TEMPORALITY_UNSPECIFIED"
    AggregationTemporality::AGGREGATION_TEMPORALITY_DELTA =>
      "AGGREGATION_TEMPORALITY_DELTA"
    AggregationTemporality::AGGREGATION_TEMPORALITY_CUMULATIVE =>
      "AGGREGATION_TEMPORALITY_CUMULATIVE"
  }
}

///|
pub(all) enum DataPointFlags {
  DATA_POINT_FLAGS_DO_NOT_USE
  DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK
} derive(Eq)

///|
pub fn DataPointFlags::to_enum(self : DataPointFlags) -> @protobuf.Enum {
  match self {
    DataPointFlags::DATA_POINT_FLAGS_DO_NOT_USE => 0
    DataPointFlags::DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK => 1
  }
}

///|
pub fn DataPointFlags::from_enum(i : @protobuf.Enum) -> DataPointFlags {
  match i.0 {
    0 => DataPointFlags::DATA_POINT_FLAGS_DO_NOT_USE
    1 => DataPointFlags::DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK
    _ => Default::default()
  }
}

///|
pub impl Default for DataPointFlags with default() -> DataPointFlags {
  DataPointFlags::DATA_POINT_FLAGS_DO_NOT_USE
}

///|
pub impl @protobuf.Sized for DataPointFlags with size_of(self : DataPointFlags) {
  @protobuf.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for DataPointFlags with from_json(
  json : Json,
  path : @json.JsonPath,
) -> DataPointFlags raise {
  match json {
    String("DATA_POINT_FLAGS_DO_NOT_USE") =>
      DataPointFlags::DATA_POINT_FLAGS_DO_NOT_USE
    String("DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK") =>
      DataPointFlags::DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK
    Number(0, ..) => DataPointFlags::DATA_POINT_FLAGS_DO_NOT_USE
    Number(1, ..) => DataPointFlags::DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for DataPointFlags with to_json(self : DataPointFlags) -> Json {
  match self {
    DataPointFlags::DATA_POINT_FLAGS_DO_NOT_USE => "DATA_POINT_FLAGS_DO_NOT_USE"
    DataPointFlags::DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK =>
      "DATA_POINT_FLAGS_NO_RECORDED_VALUE_MASK"
  }
}

///|
pub(all) struct MetricsData {
  mut resource_metrics : Array[ResourceMetrics]
} derive(Eq)

///|
pub impl @protobuf.Sized for MetricsData with size_of(self) {
  let mut size = 0U
  for s in self.resource_metrics {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for MetricsData with default() -> MetricsData {
  MetricsData::{ resource_metrics: [] }
}

///|
pub fn MetricsData::new(
  resource_metrics : Array[ResourceMetrics],
) -> MetricsData {
  MetricsData::{ resource_metrics, }
}

///|
pub impl @protobuf.Read for MetricsData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> MetricsData raise {
  let msg = MetricsData::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource_metrics.push(
            (reader |> @protobuf.read_message() : ResourceMetrics),
          )
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for MetricsData with write(
  self : MetricsData,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.resource_metrics {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for MetricsData with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource_metrics != Default::default() {
    json["resourceMetrics"] = self.resource_metrics.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for MetricsData with from_json(
  json : Json,
  path : @json.JsonPath,
) -> MetricsData raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for MetricsData"))
  }
  let message = MetricsData::default()
  for key, value in obj {
    match (key, value) {
      ("resourceMetrics", Array(value)) =>
        message.resource_metrics = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for MetricsData with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> MetricsData raise {
  let msg = MetricsData::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource_metrics.push(
            (reader |> @protobuf.async_read_message() : ResourceMetrics),
          )
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for MetricsData with write(
  self : MetricsData,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.resource_metrics {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct ResourceMetrics {
  mut resource : @v11.Resource
  mut scope_metrics : Array[ScopeMetrics]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ResourceMetrics with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.resource)
      @protobuf.size_of(size) + size
    })
  for s in self.scope_metrics {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U +
    ({
      let size = @protobuf.size_of(self.schema_url)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ResourceMetrics with default() -> ResourceMetrics {
  ResourceMetrics::{
    resource: @v11.Resource::default(),
    scope_metrics: [],
    schema_url: String::default(),
  }
}

///|
pub fn ResourceMetrics::new(
  resource : @v11.Resource,
  scope_metrics : Array[ScopeMetrics],
  schema_url : String,
) -> ResourceMetrics {
  ResourceMetrics::{ resource, scope_metrics, schema_url }
}

///|
pub impl @protobuf.Read for ResourceMetrics with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ResourceMetrics raise {
  let msg = ResourceMetrics::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.resource = (reader |> @protobuf.read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_metrics.push(
            (reader |> @protobuf.read_message() : ScopeMetrics),
          )
        (3, _) => msg.schema_url = reader |> @protobuf.read_string()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for ResourceMetrics with write(
  self : ResourceMetrics,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.resource))
  @protobuf.Write::write(self.resource, writer)
  for item in self.scope_metrics {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ResourceMetrics with to_json(self) {
  let json : Map[String, Json] = {}
  if self.resource != Default::default() {
    json["resource"] = self.resource.to_json()
  }
  if self.scope_metrics != Default::default() {
    json["scopeMetrics"] = self.scope_metrics.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ResourceMetrics with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ResourceMetrics raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ResourceMetrics"),
    )
  }
  let message = ResourceMetrics::default()
  for key, value in obj {
    match (key, value) {
      ("resource", value) => message.resource = @json.from_json(value, path~)
      ("scopeMetrics", Array(value)) =>
        message.scope_metrics = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ResourceMetrics with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ResourceMetrics raise {
  let msg = ResourceMetrics::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.resource = (
            reader |> @protobuf.async_read_message() : @v11.Resource)
        (2, _) =>
          msg.scope_metrics.push(
            (reader |> @protobuf.async_read_message() : ScopeMetrics),
          )
        (3, _) => msg.schema_url = reader |> @protobuf.async_read_string()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for ResourceMetrics with write(
  self : ResourceMetrics,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.resource))
  @protobuf.AsyncWrite::write(self.resource, writer)
  for item in self.scope_metrics {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) struct ScopeMetrics {
  mut scope : @v1_dep.InstrumentationScope
  mut metrics : Array[Metric]
  mut schema_url : String
} derive(Eq)

///|
pub impl @protobuf.Sized for ScopeMetrics with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.scope)
      @protobuf.size_of(size) + size
    })
  for s in self.metrics {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U +
    ({
      let size = @protobuf.size_of(self.schema_url)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ScopeMetrics with default() -> ScopeMetrics {
  ScopeMetrics::{
    scope: @v1_dep.InstrumentationScope::default(),
    metrics: [],
    schema_url: String::default(),
  }
}

///|
pub fn ScopeMetrics::new(
  scope : @v1_dep.InstrumentationScope,
  metrics : Array[Metric],
  schema_url : String,
) -> ScopeMetrics {
  ScopeMetrics::{ scope, metrics, schema_url }
}

///|
pub impl @protobuf.Read for ScopeMetrics with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ScopeMetrics raise {
  let msg = ScopeMetrics::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.read_message() : @v1_dep.InstrumentationScope)
        (2, _) =>
          msg.metrics.push((reader |> @protobuf.read_message() : Metric))
        (3, _) => msg.schema_url = reader |> @protobuf.read_string()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for ScopeMetrics with write(
  self : ScopeMetrics,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.scope))
  @protobuf.Write::write(self.scope, writer)
  for item in self.metrics {
    writer |> @protobuf.write_varint(18UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.schema_url)
}

///|
pub impl ToJson for ScopeMetrics with to_json(self) {
  let json : Map[String, Json] = {}
  if self.scope != Default::default() {
    json["scope"] = self.scope.to_json()
  }
  if self.metrics != Default::default() {
    json["metrics"] = self.metrics.to_json()
  }
  if self.schema_url != Default::default() {
    json["schemaUrl"] = self.schema_url.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ScopeMetrics with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ScopeMetrics raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ScopeMetrics"))
  }
  let message = ScopeMetrics::default()
  for key, value in obj {
    match (key, value) {
      ("scope", value) => message.scope = @json.from_json(value, path~)
      ("metrics", Array(value)) =>
        message.metrics = value.map(v => @json.from_json(v, path~))
      ("schemaUrl", value) => message.schema_url = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ScopeMetrics with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ScopeMetrics raise {
  let msg = ScopeMetrics::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.scope = (
            reader |> @protobuf.async_read_message() :
            @v1_dep.InstrumentationScope)
        (2, _) =>
          msg.metrics.push((reader |> @protobuf.async_read_message() : Metric))
        (3, _) => msg.schema_url = reader |> @protobuf.async_read_string()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for ScopeMetrics with write(
  self : ScopeMetrics,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.scope))
  @protobuf.AsyncWrite::write(self.scope, writer)
  for item in self.metrics {
    writer |> @protobuf.async_write_varint(18UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.schema_url)
}

///|
pub(all) struct Metric {
  mut name : String
  mut description : String
  mut unit : String
  mut metadata : Array[@v1_dep.KeyValue]
  mut data : Metric_Data
} derive(Eq)

///|
pub(all) enum Metric_Data {
  Gauge(Gauge)
  Sum(Sum)
  Histogram(Histogram)
  ExponentialHistogram(ExponentialHistogram)
  Summary(Summary)
  NotSet
} derive(Eq)

///|
pub impl Default for Metric_Data with default() -> Metric_Data {
  NotSet
}

///|
pub impl @json.FromJson for Metric_Data with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Metric_Data raise {
  try Metric_Data::Gauge(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Metric_Data::Sum(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Metric_Data::Histogram(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Metric_Data::ExponentialHistogram(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Metric_Data::Summary(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  Metric_Data::NotSet
}

///|
pub impl ToJson for Metric_Data with to_json(self : Metric_Data) -> Json {
  match self {
    Metric_Data::Gauge(v) => v.to_json()
    Metric_Data::Sum(v) => v.to_json()
    Metric_Data::Histogram(v) => v.to_json()
    Metric_Data::ExponentialHistogram(v) => v.to_json()
    Metric_Data::Summary(v) => v.to_json()
    Metric_Data::NotSet => Json::null()
  }
}

///|
pub impl @protobuf.Sized for Metric with size_of(self) {
  let mut size = 0U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.name)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.description)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.unit)
      @protobuf.size_of(size) + size
    })
  for s in self.metadata {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  match self.data {
    Gauge(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    Sum(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    Histogram(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    ExponentialHistogram(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    Summary(v) =>
      size += 1U +
        ({
          let size = @protobuf.size_of(v)
          @protobuf.size_of(size) + size
        })
    NotSet => ()
  }
  size
}

///|
pub impl Default for Metric with default() -> Metric {
  Metric::{
    name: String::default(),
    description: String::default(),
    unit: String::default(),
    metadata: [],
    data: Metric_Data::NotSet,
  }
}

///|
pub fn Metric::new(
  name : String,
  description : String,
  unit : String,
  metadata : Array[@v1_dep.KeyValue],
  data? : Metric_Data = Metric_Data::NotSet,
) -> Metric {
  Metric::{ name, description, unit, metadata, data }
}

///|
pub impl @protobuf.Read for Metric with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Metric raise {
  let msg = Metric::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.name = reader |> @protobuf.read_string()
        (2, _) => msg.description = reader |> @protobuf.read_string()
        (3, _) => msg.unit = reader |> @protobuf.read_string()
        (12, _) =>
          msg.metadata.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (5, _) =>
          msg.data = (reader |> @protobuf.read_message() : Gauge)
            |> Metric_Data::Gauge
        (7, _) =>
          msg.data = (reader |> @protobuf.read_message() : Sum)
            |> Metric_Data::Sum
        (9, _) =>
          msg.data = (reader |> @protobuf.read_message() : Histogram)
            |> Metric_Data::Histogram
        (10, _) =>
          msg.data = (reader |> @protobuf.read_message() : ExponentialHistogram)
            |> Metric_Data::ExponentialHistogram
        (11, _) =>
          msg.data = (reader |> @protobuf.read_message() : Summary)
            |> Metric_Data::Summary
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for Metric with write(
  self : Metric,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(10UL)
  writer |> @protobuf.write_string(self.name)
  writer |> @protobuf.write_varint(18UL)
  writer |> @protobuf.write_string(self.description)
  writer |> @protobuf.write_varint(26UL)
  writer |> @protobuf.write_string(self.unit)
  for item in self.metadata {
    writer |> @protobuf.write_varint(98UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  match self.data {
    Metric_Data::Gauge(v) => {
      writer |> @protobuf.write_varint(42UL)
      writer |> @protobuf.write_uint32(@protobuf.size_of(v))
      @protobuf.Write::write(v, writer)
    }
    Metric_Data::Sum(v) => {
      writer |> @protobuf.write_varint(58UL)
      writer |> @protobuf.write_uint32(@protobuf.size_of(v))
      @protobuf.Write::write(v, writer)
    }
    Metric_Data::Histogram(v) => {
      writer |> @protobuf.write_varint(74UL)
      writer |> @protobuf.write_uint32(@protobuf.size_of(v))
      @protobuf.Write::write(v, writer)
    }
    Metric_Data::ExponentialHistogram(v) => {
      writer |> @protobuf.write_varint(82UL)
      writer |> @protobuf.write_uint32(@protobuf.size_of(v))
      @protobuf.Write::write(v, writer)
    }
    Metric_Data::Summary(v) => {
      writer |> @protobuf.write_varint(90UL)
      writer |> @protobuf.write_uint32(@protobuf.size_of(v))
      @protobuf.Write::write(v, writer)
    }
    Metric_Data::NotSet => ()
  }
}

///|
pub impl ToJson for Metric with to_json(self) {
  let json : Map[String, Json] = {}
  if self.name != Default::default() {
    json["name"] = self.name.to_json()
  }
  if self.description != Default::default() {
    json["description"] = self.description.to_json()
  }
  if self.unit != Default::default() {
    json["unit"] = self.unit.to_json()
  }
  if self.metadata != Default::default() {
    json["metadata"] = self.metadata.to_json()
  }
  match self.data {
    NotSet => ()
    Gauge(v) => json["gauge"] = v.to_json()
    Sum(v) => json["sum"] = v.to_json()
    Histogram(v) => json["histogram"] = v.to_json()
    ExponentialHistogram(v) => json["exponentialHistogram"] = v.to_json()
    Summary(v) => json["summary"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Metric with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Metric raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Metric"))
  }
  let message = Metric::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("description", value) =>
        message.description = @json.from_json(value, path~)
      ("unit", value) => message.unit = @json.from_json(value, path~)
      ("metadata", Array(value)) =>
        message.metadata = value.map(v => @json.from_json(v, path~))
      ("gauge", value) => message.data = @json.from_json(value, path~)
      ("sum", value) => message.data = @json.from_json(value, path~)
      ("histogram", value) => message.data = @json.from_json(value, path~)
      ("exponentialHistogram", value) =>
        message.data = @json.from_json(value, path~)
      ("summary", value) => message.data = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Metric with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Metric raise {
  let msg = Metric::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.name = reader |> @protobuf.async_read_string()
        (2, _) => msg.description = reader |> @protobuf.async_read_string()
        (3, _) => msg.unit = reader |> @protobuf.async_read_string()
        (12, _) =>
          msg.metadata.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (5, _) =>
          msg.data = (reader |> @protobuf.async_read_message() : Gauge)
            |> Metric_Data::Gauge
        (7, _) =>
          msg.data = (reader |> @protobuf.async_read_message() : Sum)
            |> Metric_Data::Sum
        (9, _) =>
          msg.data = (reader |> @protobuf.async_read_message() : Histogram)
            |> Metric_Data::Histogram
        (10, _) =>
          msg.data = (
              reader |> @protobuf.async_read_message() : ExponentialHistogram)
            |> Metric_Data::ExponentialHistogram
        (11, _) =>
          msg.data = (reader |> @protobuf.async_read_message() : Summary)
            |> Metric_Data::Summary
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for Metric with write(
  self : Metric,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(10UL)
  writer |> @protobuf.async_write_string(self.name)
  writer |> @protobuf.async_write_varint(18UL)
  writer |> @protobuf.async_write_string(self.description)
  writer |> @protobuf.async_write_varint(26UL)
  writer |> @protobuf.async_write_string(self.unit)
  for item in self.metadata {
    writer |> @protobuf.async_write_varint(98UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  match self.data {
    Metric_Data::Gauge(v) => {
      writer |> @protobuf.async_write_varint(42UL)
      writer |> @protobuf.async_write_uint32(@protobuf.size_of(v))
      @protobuf.AsyncWrite::write(v, writer)
    }
    Metric_Data::Sum(v) => {
      writer |> @protobuf.async_write_varint(58UL)
      writer |> @protobuf.async_write_uint32(@protobuf.size_of(v))
      @protobuf.AsyncWrite::write(v, writer)
    }
    Metric_Data::Histogram(v) => {
      writer |> @protobuf.async_write_varint(74UL)
      writer |> @protobuf.async_write_uint32(@protobuf.size_of(v))
      @protobuf.AsyncWrite::write(v, writer)
    }
    Metric_Data::ExponentialHistogram(v) => {
      writer |> @protobuf.async_write_varint(82UL)
      writer |> @protobuf.async_write_uint32(@protobuf.size_of(v))
      @protobuf.AsyncWrite::write(v, writer)
    }
    Metric_Data::Summary(v) => {
      writer |> @protobuf.async_write_varint(90UL)
      writer |> @protobuf.async_write_uint32(@protobuf.size_of(v))
      @protobuf.AsyncWrite::write(v, writer)
    }
    Metric_Data::NotSet => ()
  }
}

///|
pub(all) struct Gauge {
  mut data_points : Array[NumberDataPoint]
} derive(Eq)

///|
pub impl @protobuf.Sized for Gauge with size_of(self) {
  let mut size = 0U
  for s in self.data_points {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for Gauge with default() -> Gauge {
  Gauge::{ data_points: [] }
}

///|
pub fn Gauge::new(data_points : Array[NumberDataPoint]) -> Gauge {
  Gauge::{ data_points, }
}

///|
pub impl @protobuf.Read for Gauge with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Gauge raise {
  let msg = Gauge::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.read_message() : NumberDataPoint),
          )
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for Gauge with write(
  self : Gauge,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for Gauge with to_json(self) {
  let json : Map[String, Json] = {}
  if self.data_points != Default::default() {
    json["dataPoints"] = self.data_points.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Gauge with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Gauge raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Gauge"))
  }
  let message = Gauge::default()
  for key, value in obj {
    match (key, value) {
      ("dataPoints", Array(value)) =>
        message.data_points = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Gauge with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Gauge raise {
  let msg = Gauge::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.async_read_message() : NumberDataPoint),
          )
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for Gauge with write(
  self : Gauge,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct Sum {
  mut data_points : Array[NumberDataPoint]
  mut aggregation_temporality : AggregationTemporality
  mut is_monotonic : Bool
} derive(Eq)

///|
pub impl @protobuf.Sized for Sum with size_of(self) {
  let mut size = 0U
  for s in self.data_points {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.aggregation_temporality)
  size += 1U + @protobuf.size_of(self.is_monotonic)
  size
}

///|
pub impl Default for Sum with default() -> Sum {
  Sum::{
    data_points: [],
    aggregation_temporality: AggregationTemporality::default(),
    is_monotonic: Bool::default(),
  }
}

///|
pub fn Sum::new(
  data_points : Array[NumberDataPoint],
  aggregation_temporality : AggregationTemporality,
  is_monotonic : Bool,
) -> Sum {
  Sum::{ data_points, aggregation_temporality, is_monotonic }
}

///|
pub impl @protobuf.Read for Sum with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Sum raise {
  let msg = Sum::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.read_message() : NumberDataPoint),
          )
        (2, _) =>
          msg.aggregation_temporality = reader
            |> @protobuf.read_enum()
            |> AggregationTemporality::from_enum
        (3, _) => msg.is_monotonic = reader |> @protobuf.read_bool()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for Sum with write(
  self : Sum,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_enum(self.aggregation_temporality.to_enum())
  writer |> @protobuf.write_varint(24UL)
  writer |> @protobuf.write_bool(self.is_monotonic)
}

///|
pub impl ToJson for Sum with to_json(self) {
  let json : Map[String, Json] = {}
  if self.data_points != Default::default() {
    json["dataPoints"] = self.data_points.to_json()
  }
  if self.aggregation_temporality != Default::default() {
    json["aggregationTemporality"] = self.aggregation_temporality.to_json()
  }
  if self.is_monotonic != Default::default() {
    json["isMonotonic"] = self.is_monotonic.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Sum with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Sum raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Sum"))
  }
  let message = Sum::default()
  for key, value in obj {
    match (key, value) {
      ("dataPoints", Array(value)) =>
        message.data_points = value.map(v => @json.from_json(v, path~))
      ("aggregationTemporality", value) =>
        message.aggregation_temporality = @json.from_json(value, path~)
      ("isMonotonic", value) =>
        message.is_monotonic = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Sum with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Sum raise {
  let msg = Sum::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.async_read_message() : NumberDataPoint),
          )
        (2, _) =>
          msg.aggregation_temporality = reader
            |> @protobuf.async_read_enum()
            |> AggregationTemporality::from_enum
        (3, _) => msg.is_monotonic = reader |> @protobuf.async_read_bool()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for Sum with write(
  self : Sum,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_enum(self.aggregation_temporality.to_enum())
  writer |> @protobuf.async_write_varint(24UL)
  writer |> @protobuf.async_write_bool(self.is_monotonic)
}

///|
pub(all) struct Histogram {
  mut data_points : Array[HistogramDataPoint]
  mut aggregation_temporality : AggregationTemporality
} derive(Eq)

///|
pub impl @protobuf.Sized for Histogram with size_of(self) {
  let mut size = 0U
  for s in self.data_points {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.aggregation_temporality)
  size
}

///|
pub impl Default for Histogram with default() -> Histogram {
  Histogram::{
    data_points: [],
    aggregation_temporality: AggregationTemporality::default(),
  }
}

///|
pub fn Histogram::new(
  data_points : Array[HistogramDataPoint],
  aggregation_temporality : AggregationTemporality,
) -> Histogram {
  Histogram::{ data_points, aggregation_temporality }
}

///|
pub impl @protobuf.Read for Histogram with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Histogram raise {
  let msg = Histogram::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.read_message() : HistogramDataPoint),
          )
        (2, _) =>
          msg.aggregation_temporality = reader
            |> @protobuf.read_enum()
            |> AggregationTemporality::from_enum
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for Histogram with write(
  self : Histogram,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_enum(self.aggregation_temporality.to_enum())
}

///|
pub impl ToJson for Histogram with to_json(self) {
  let json : Map[String, Json] = {}
  if self.data_points != Default::default() {
    json["dataPoints"] = self.data_points.to_json()
  }
  if self.aggregation_temporality != Default::default() {
    json["aggregationTemporality"] = self.aggregation_temporality.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Histogram with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Histogram raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Histogram"))
  }
  let message = Histogram::default()
  for key, value in obj {
    match (key, value) {
      ("dataPoints", Array(value)) =>
        message.data_points = value.map(v => @json.from_json(v, path~))
      ("aggregationTemporality", value) =>
        message.aggregation_temporality = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Histogram with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Histogram raise {
  let msg = Histogram::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.async_read_message() : HistogramDataPoint),
          )
        (2, _) =>
          msg.aggregation_temporality = reader
            |> @protobuf.async_read_enum()
            |> AggregationTemporality::from_enum
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for Histogram with write(
  self : Histogram,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_enum(self.aggregation_temporality.to_enum())
}

///|
pub(all) struct ExponentialHistogram {
  mut data_points : Array[ExponentialHistogramDataPoint]
  mut aggregation_temporality : AggregationTemporality
} derive(Eq)

///|
pub impl @protobuf.Sized for ExponentialHistogram with size_of(self) {
  let mut size = 0U
  for s in self.data_points {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.aggregation_temporality)
  size
}

///|
pub impl Default for ExponentialHistogram with default() -> ExponentialHistogram {
  ExponentialHistogram::{
    data_points: [],
    aggregation_temporality: AggregationTemporality::default(),
  }
}

///|
pub fn ExponentialHistogram::new(
  data_points : Array[ExponentialHistogramDataPoint],
  aggregation_temporality : AggregationTemporality,
) -> ExponentialHistogram {
  ExponentialHistogram::{ data_points, aggregation_temporality }
}

///|
pub impl @protobuf.Read for ExponentialHistogram with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExponentialHistogram raise {
  let msg = ExponentialHistogram::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.read_message() : ExponentialHistogramDataPoint),
          )
        (2, _) =>
          msg.aggregation_temporality = reader
            |> @protobuf.read_enum()
            |> AggregationTemporality::from_enum
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for ExponentialHistogram with write(
  self : ExponentialHistogram,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(16UL)
  writer |> @protobuf.write_enum(self.aggregation_temporality.to_enum())
}

///|
pub impl ToJson for ExponentialHistogram with to_json(self) {
  let json : Map[String, Json] = {}
  if self.data_points != Default::default() {
    json["dataPoints"] = self.data_points.to_json()
  }
  if self.aggregation_temporality != Default::default() {
    json["aggregationTemporality"] = self.aggregation_temporality.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExponentialHistogram with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExponentialHistogram raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExponentialHistogram"),
    )
  }
  let message = ExponentialHistogram::default()
  for key, value in obj {
    match (key, value) {
      ("dataPoints", Array(value)) =>
        message.data_points = value.map(v => @json.from_json(v, path~))
      ("aggregationTemporality", value) =>
        message.aggregation_temporality = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExponentialHistogram with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExponentialHistogram raise {
  let msg = ExponentialHistogram::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (
              reader |> @protobuf.async_read_message() :
              ExponentialHistogramDataPoint),
          )
        (2, _) =>
          msg.aggregation_temporality = reader
            |> @protobuf.async_read_enum()
            |> AggregationTemporality::from_enum
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for ExponentialHistogram with write(
  self : ExponentialHistogram,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(16UL)
  writer |> @protobuf.async_write_enum(self.aggregation_temporality.to_enum())
}

///|
pub(all) struct Summary {
  mut data_points : Array[SummaryDataPoint]
} derive(Eq)

///|
pub impl @protobuf.Sized for Summary with size_of(self) {
  let mut size = 0U
  for s in self.data_points {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size
}

///|
pub impl Default for Summary with default() -> Summary {
  Summary::{ data_points: [] }
}

///|
pub fn Summary::new(data_points : Array[SummaryDataPoint]) -> Summary {
  Summary::{ data_points, }
}

///|
pub impl @protobuf.Read for Summary with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Summary raise {
  let msg = Summary::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.read_message() : SummaryDataPoint),
          )
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for Summary with write(
  self : Summary,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
}

///|
pub impl ToJson for Summary with to_json(self) {
  let json : Map[String, Json] = {}
  if self.data_points != Default::default() {
    json["dataPoints"] = self.data_points.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Summary with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Summary raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Summary"))
  }
  let message = Summary::default()
  for key, value in obj {
    match (key, value) {
      ("dataPoints", Array(value)) =>
        message.data_points = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Summary with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Summary raise {
  let msg = Summary::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.data_points.push(
            (reader |> @protobuf.async_read_message() : SummaryDataPoint),
          )
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for Summary with write(
  self : Summary,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.data_points {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
}

///|
pub(all) struct NumberDataPoint {
  mut attributes : Array[@v1_dep.KeyValue]
  mut start_time_unix_nano : UInt64
  mut time_unix_nano : UInt64
  mut exemplars : Array[Exemplar]
  mut flags : UInt
  mut value : NumberDataPoint_Value
} derive(Eq)

///|
pub(all) enum NumberDataPoint_Value {
  AsDouble(Double)
  AsInt(Int64)
  NotSet
} derive(Eq)

///|
pub impl Default for NumberDataPoint_Value with default() -> NumberDataPoint_Value {
  NotSet
}

///|
pub impl @json.FromJson for NumberDataPoint_Value with from_json(
  json : Json,
  path : @json.JsonPath,
) -> NumberDataPoint_Value raise {
  try NumberDataPoint_Value::AsDouble(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try NumberDataPoint_Value::AsInt(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  NumberDataPoint_Value::NotSet
}

///|
pub impl ToJson for NumberDataPoint_Value with to_json(
  self : NumberDataPoint_Value,
) -> Json {
  match self {
    NumberDataPoint_Value::AsDouble(v) => v.to_json()
    NumberDataPoint_Value::AsInt(v) => v.to_json()
    NumberDataPoint_Value::NotSet => Json::null()
  }
}

///|
pub impl @protobuf.Sized for NumberDataPoint with size_of(self) {
  let mut size = 0U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + 8U
  size += 1U + 8U
  for s in self.exemplars {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.flags)
  match self.value {
    AsDouble(_) => size += 1U + 8U
    AsInt(_) => size += 1U + 8U
    NotSet => ()
  }
  size
}

///|
pub impl Default for NumberDataPoint with default() -> NumberDataPoint {
  NumberDataPoint::{
    attributes: [],
    start_time_unix_nano: UInt64::default(),
    time_unix_nano: UInt64::default(),
    exemplars: [],
    flags: UInt::default(),
    value: NumberDataPoint_Value::NotSet,
  }
}

///|
pub fn NumberDataPoint::new(
  attributes : Array[@v1_dep.KeyValue],
  start_time_unix_nano : UInt64,
  time_unix_nano : UInt64,
  exemplars : Array[Exemplar],
  flags : UInt,
  value? : NumberDataPoint_Value = NumberDataPoint_Value::NotSet,
) -> NumberDataPoint {
  NumberDataPoint::{
    attributes,
    start_time_unix_nano,
    time_unix_nano,
    exemplars,
    flags,
    value,
  }
}

///|
pub impl @protobuf.Read for NumberDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> NumberDataPoint raise {
  let msg = NumberDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (7, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (2, _) => msg.start_time_unix_nano = reader |> @protobuf.read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (5, _) =>
          msg.exemplars.push((reader |> @protobuf.read_message() : Exemplar))
        (8, _) => msg.flags = reader |> @protobuf.read_uint32()
        (4, _) =>
          msg.value = reader
            |> @protobuf.read_double()
            |> NumberDataPoint_Value::AsDouble
        (6, _) =>
          msg.value = reader
            |> @protobuf.read_sfixed64()
            |> NumberDataPoint_Value::AsInt
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for NumberDataPoint with write(
  self : NumberDataPoint,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.write_varint(58UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(17UL)
  writer |> @protobuf.write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.write_varint(25UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  for item in self.exemplars {
    writer |> @protobuf.write_varint(42UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(64UL)
  writer |> @protobuf.write_uint32(self.flags)
  match self.value {
    NumberDataPoint_Value::AsDouble(v) => {
      writer |> @protobuf.write_varint(33UL)
      writer |> @protobuf.write_double(v)
    }
    NumberDataPoint_Value::AsInt(v) => {
      writer |> @protobuf.write_varint(49UL)
      writer |> @protobuf.write_sfixed64(v)
    }
    NumberDataPoint_Value::NotSet => ()
  }
}

///|
pub impl ToJson for NumberDataPoint with to_json(self) {
  let json : Map[String, Json] = {}
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.start_time_unix_nano != Default::default() {
    json["startTimeUnixNano"] = self.start_time_unix_nano.to_json()
  }
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.exemplars != Default::default() {
    json["exemplars"] = self.exemplars.to_json()
  }
  if self.flags != Default::default() {
    json["flags"] = self.flags.to_json()
  }
  match self.value {
    NotSet => ()
    AsDouble(v) => json["asDouble"] = v.to_json()
    AsInt(v) => json["asInt"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for NumberDataPoint with from_json(
  json : Json,
  path : @json.JsonPath,
) -> NumberDataPoint raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for NumberDataPoint"),
    )
  }
  let message = NumberDataPoint::default()
  for key, value in obj {
    match (key, value) {
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("startTimeUnixNano", value) =>
        message.start_time_unix_nano = @json.from_json(value, path~)
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("exemplars", Array(value)) =>
        message.exemplars = value.map(v => @json.from_json(v, path~))
      ("flags", value) => message.flags = @json.from_json(value, path~)
      ("asDouble", value) => message.value = @json.from_json(value, path~)
      ("asInt", value) => message.value = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for NumberDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> NumberDataPoint raise {
  let msg = NumberDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (7, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (2, _) =>
          msg.start_time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (5, _) =>
          msg.exemplars.push(
            (reader |> @protobuf.async_read_message() : Exemplar),
          )
        (8, _) => msg.flags = reader |> @protobuf.async_read_uint32()
        (4, _) =>
          msg.value = reader
            |> @protobuf.async_read_double()
            |> NumberDataPoint_Value::AsDouble
        (6, _) =>
          msg.value = reader
            |> @protobuf.async_read_sfixed64()
            |> NumberDataPoint_Value::AsInt
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for NumberDataPoint with write(
  self : NumberDataPoint,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(58UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(17UL)
  writer |> @protobuf.async_write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.async_write_varint(25UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  for item in self.exemplars {
    writer |> @protobuf.async_write_varint(42UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(64UL)
  writer |> @protobuf.async_write_uint32(self.flags)
  match self.value {
    NumberDataPoint_Value::AsDouble(v) => {
      writer |> @protobuf.async_write_varint(33UL)
      writer |> @protobuf.async_write_double(v)
    }
    NumberDataPoint_Value::AsInt(v) => {
      writer |> @protobuf.async_write_varint(49UL)
      writer |> @protobuf.async_write_sfixed64(v)
    }
    NumberDataPoint_Value::NotSet => ()
  }
}

///|
pub(all) struct HistogramDataPoint {
  mut attributes : Array[@v1_dep.KeyValue]
  mut start_time_unix_nano : UInt64
  mut time_unix_nano : UInt64
  mut count : UInt64
  mut sum : Double?
  mut bucket_counts : Array[UInt64]
  mut explicit_bounds : Array[Double]
  mut exemplars : Array[Exemplar]
  mut flags : UInt
  mut min : Double?
  mut max : Double?
} derive(Eq)

///|
pub impl @protobuf.Sized for HistogramDataPoint with size_of(self) {
  let mut size = 0U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + 8U
  size += 1U + 8U
  size += 1U + 8U
  if self.sum is Some(_) {
    size += 1U + 8U
  }
  size += 1U +
    ({
      let size = self.bucket_counts.length().reinterpret_as_uint() * 8
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = self.explicit_bounds.length().reinterpret_as_uint() * 8
      @protobuf.size_of(size) + size
    })
  for s in self.exemplars {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.flags)
  if self.min is Some(_) {
    size += 1U + 8U
  }
  if self.max is Some(_) {
    size += 1U + 8U
  }
  size
}

///|
pub impl Default for HistogramDataPoint with default() -> HistogramDataPoint {
  HistogramDataPoint::{
    attributes: [],
    start_time_unix_nano: UInt64::default(),
    time_unix_nano: UInt64::default(),
    count: UInt64::default(),
    sum: None,
    bucket_counts: [],
    explicit_bounds: [],
    exemplars: [],
    flags: UInt::default(),
    min: None,
    max: None,
  }
}

///|
pub fn HistogramDataPoint::new(
  attributes : Array[@v1_dep.KeyValue],
  start_time_unix_nano : UInt64,
  time_unix_nano : UInt64,
  count : UInt64,
  sum? : Double,
  bucket_counts : Array[UInt64],
  explicit_bounds : Array[Double],
  exemplars : Array[Exemplar],
  flags : UInt,
  min? : Double,
  max? : Double,
) -> HistogramDataPoint {
  HistogramDataPoint::{
    attributes,
    start_time_unix_nano,
    time_unix_nano,
    count,
    sum,
    bucket_counts,
    explicit_bounds,
    exemplars,
    flags,
    min,
    max,
  }
}

///|
pub impl @protobuf.Read for HistogramDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> HistogramDataPoint raise {
  let msg = HistogramDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (9, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (2, _) => msg.start_time_unix_nano = reader |> @protobuf.read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (4, _) => msg.count = reader |> @protobuf.read_fixed64()
        (5, _) => msg.sum = reader |> @protobuf.read_double() |> Some
        (6, _) =>
          msg.bucket_counts.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_fixed64, Some(8))).iter(),
          )
        (7, _) =>
          msg.explicit_bounds.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_double, Some(8))).iter(),
          )
        (8, _) =>
          msg.exemplars.push((reader |> @protobuf.read_message() : Exemplar))
        (10, _) => msg.flags = reader |> @protobuf.read_uint32()
        (11, _) => msg.min = reader |> @protobuf.read_double() |> Some
        (12, _) => msg.max = reader |> @protobuf.read_double() |> Some
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for HistogramDataPoint with write(
  self : HistogramDataPoint,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.write_varint(74UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(17UL)
  writer |> @protobuf.write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.write_varint(25UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  writer |> @protobuf.write_varint(33UL)
  writer |> @protobuf.write_fixed64(self.count)
  if self.sum is Some(v) {
    writer |> @protobuf.write_varint(41UL)
    writer |> @protobuf.write_double(v)
  }
  writer |> @protobuf.write_varint(50UL)
  let size = self.bucket_counts.length().reinterpret_as_uint() * 8
  writer |> @protobuf.write_uint32(size)
  for item in self.bucket_counts {
    writer |> @protobuf.write_fixed64(item)
  }
  writer |> @protobuf.write_varint(58UL)
  let size = self.explicit_bounds.length().reinterpret_as_uint() * 8
  writer |> @protobuf.write_uint32(size)
  for item in self.explicit_bounds {
    writer |> @protobuf.write_double(item)
  }
  for item in self.exemplars {
    writer |> @protobuf.write_varint(66UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(80UL)
  writer |> @protobuf.write_uint32(self.flags)
  if self.min is Some(v) {
    writer |> @protobuf.write_varint(89UL)
    writer |> @protobuf.write_double(v)
  }
  if self.max is Some(v) {
    writer |> @protobuf.write_varint(97UL)
    writer |> @protobuf.write_double(v)
  }
}

///|
pub impl ToJson for HistogramDataPoint with to_json(self) {
  let json : Map[String, Json] = {}
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.start_time_unix_nano != Default::default() {
    json["startTimeUnixNano"] = self.start_time_unix_nano.to_json()
  }
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.count != Default::default() {
    json["count"] = self.count.to_json()
  }
  match self.sum {
    Some(v) => json["sum"] = v.to_json()
    _ => ()
  }
  if self.bucket_counts != Default::default() {
    json["bucketCounts"] = self.bucket_counts.to_json()
  }
  if self.explicit_bounds != Default::default() {
    json["explicitBounds"] = self.explicit_bounds.to_json()
  }
  if self.exemplars != Default::default() {
    json["exemplars"] = self.exemplars.to_json()
  }
  if self.flags != Default::default() {
    json["flags"] = self.flags.to_json()
  }
  match self.min {
    Some(v) => json["min"] = v.to_json()
    _ => ()
  }
  match self.max {
    Some(v) => json["max"] = v.to_json()
    _ => ()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for HistogramDataPoint with from_json(
  json : Json,
  path : @json.JsonPath,
) -> HistogramDataPoint raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for HistogramDataPoint"),
    )
  }
  let message = HistogramDataPoint::default()
  for key, value in obj {
    match (key, value) {
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("startTimeUnixNano", value) =>
        message.start_time_unix_nano = @json.from_json(value, path~)
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("count", value) => message.count = @json.from_json(value, path~)
      ("sum", value) => message.sum = Some(@json.from_json(value, path~))
      ("bucketCounts", Array(value)) =>
        message.bucket_counts = value.map(v => @json.from_json(v, path~))
      ("explicitBounds", Array(value)) =>
        message.explicit_bounds = value.map(v => @json.from_json(v, path~))
      ("exemplars", Array(value)) =>
        message.exemplars = value.map(v => @json.from_json(v, path~))
      ("flags", value) => message.flags = @json.from_json(value, path~)
      ("min", value) => message.min = Some(@json.from_json(value, path~))
      ("max", value) => message.max = Some(@json.from_json(value, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for HistogramDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> HistogramDataPoint raise {
  let msg = HistogramDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (9, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (2, _) =>
          msg.start_time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (4, _) => msg.count = reader |> @protobuf.async_read_fixed64()
        (5, _) => msg.sum = reader |> @protobuf.async_read_double() |> Some
        (6, _) =>
          msg.bucket_counts.push_iter(
            (reader
            |> @protobuf.async_read_packed(
              @protobuf.async_read_fixed64,
              Some(8),
            )).iter(),
          )
        (7, _) =>
          msg.explicit_bounds.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_double, Some(8))).iter(),
          )
        (8, _) =>
          msg.exemplars.push(
            (reader |> @protobuf.async_read_message() : Exemplar),
          )
        (10, _) => msg.flags = reader |> @protobuf.async_read_uint32()
        (11, _) => msg.min = reader |> @protobuf.async_read_double() |> Some
        (12, _) => msg.max = reader |> @protobuf.async_read_double() |> Some
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for HistogramDataPoint with write(
  self : HistogramDataPoint,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(74UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(17UL)
  writer |> @protobuf.async_write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.async_write_varint(25UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  writer |> @protobuf.async_write_varint(33UL)
  writer |> @protobuf.async_write_fixed64(self.count)
  if self.sum is Some(v) {
    writer |> @protobuf.async_write_varint(41UL)
    writer |> @protobuf.async_write_double(v)
  }
  writer |> @protobuf.async_write_varint(50UL)
  let size = self.bucket_counts.length().reinterpret_as_uint() * 8
  writer |> @protobuf.async_write_uint32(size)
  for item in self.bucket_counts {
    writer |> @protobuf.async_write_fixed64(item)
  }
  writer |> @protobuf.async_write_varint(58UL)
  let size = self.explicit_bounds.length().reinterpret_as_uint() * 8
  writer |> @protobuf.async_write_uint32(size)
  for item in self.explicit_bounds {
    writer |> @protobuf.async_write_double(item)
  }
  for item in self.exemplars {
    writer |> @protobuf.async_write_varint(66UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(80UL)
  writer |> @protobuf.async_write_uint32(self.flags)
  if self.min is Some(v) {
    writer |> @protobuf.async_write_varint(89UL)
    writer |> @protobuf.async_write_double(v)
  }
  if self.max is Some(v) {
    writer |> @protobuf.async_write_varint(97UL)
    writer |> @protobuf.async_write_double(v)
  }
}

///|
pub(all) struct ExponentialHistogramDataPoint_Buckets {
  mut offset : Int
  mut bucket_counts : Array[UInt64]
} derive(Eq)

///|
pub impl @protobuf.Sized for ExponentialHistogramDataPoint_Buckets with size_of(
  self,
) {
  let mut size = 0U
  size += 1U + @protobuf.size_of(self.offset)
  size += 1U +
    ({
      let size = self.bucket_counts
        .iter()
        .map(@protobuf.size_of)
        .fold(init=0U, UInt::add)
      @protobuf.size_of(size) + size
    })
  size
}

///|
pub impl Default for ExponentialHistogramDataPoint_Buckets with default() -> ExponentialHistogramDataPoint_Buckets {
  ExponentialHistogramDataPoint_Buckets::{
    offset: Int::default(),
    bucket_counts: [],
  }
}

///|
pub fn ExponentialHistogramDataPoint_Buckets::new(
  offset : Int,
  bucket_counts : Array[UInt64],
) -> ExponentialHistogramDataPoint_Buckets {
  ExponentialHistogramDataPoint_Buckets::{ offset, bucket_counts }
}

///|
pub impl @protobuf.Read for ExponentialHistogramDataPoint_Buckets with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExponentialHistogramDataPoint_Buckets raise {
  let msg = ExponentialHistogramDataPoint_Buckets::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.offset = (reader |> @protobuf.read_sint32()).0
        (2, _) =>
          msg.bucket_counts.push_iter(
            (reader |> @protobuf.read_packed(@protobuf.read_uint64, None)).iter(),
          )
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for ExponentialHistogramDataPoint_Buckets with write(
  self : ExponentialHistogramDataPoint_Buckets,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(8UL)
  writer |> @protobuf.write_sint32(self.offset)
  writer |> @protobuf.write_varint(18UL)
  let size = self.bucket_counts
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.write_uint32(size)
  for item in self.bucket_counts {
    writer |> @protobuf.write_uint64(item)
  }
}

///|
pub impl ToJson for ExponentialHistogramDataPoint_Buckets with to_json(self) {
  let json : Map[String, Json] = {}
  if self.offset != Default::default() {
    json["offset"] = self.offset.to_json()
  }
  if self.bucket_counts != Default::default() {
    json["bucketCounts"] = self.bucket_counts.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExponentialHistogramDataPoint_Buckets with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExponentialHistogramDataPoint_Buckets raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExponentialHistogramDataPoint_Buckets"),
    )
  }
  let message = ExponentialHistogramDataPoint_Buckets::default()
  for key, value in obj {
    match (key, value) {
      ("offset", value) => message.offset = @json.from_json(value, path~)
      ("bucketCounts", Array(value)) =>
        message.bucket_counts = value.map(v => @json.from_json(v, path~))
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExponentialHistogramDataPoint_Buckets with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExponentialHistogramDataPoint_Buckets raise {
  let msg = ExponentialHistogramDataPoint_Buckets::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.offset = (reader |> @protobuf.async_read_sint32()).0
        (2, _) =>
          msg.bucket_counts.push_iter(
            (reader
            |> @protobuf.async_read_packed(@protobuf.async_read_uint64, None)).iter(),
          )
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for ExponentialHistogramDataPoint_Buckets with write(
  self : ExponentialHistogramDataPoint_Buckets,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(8UL)
  writer |> @protobuf.async_write_sint32(self.offset)
  writer |> @protobuf.async_write_varint(18UL)
  let size = self.bucket_counts
    .iter()
    .map(@protobuf.size_of)
    .fold(init=0U, UInt::add)
  writer |> @protobuf.async_write_uint32(size)
  for item in self.bucket_counts {
    writer |> @protobuf.async_write_uint64(item)
  }
}

///|
pub(all) struct ExponentialHistogramDataPoint {
  mut attributes : Array[@v1_dep.KeyValue]
  mut start_time_unix_nano : UInt64
  mut time_unix_nano : UInt64
  mut count : UInt64
  mut sum : Double?
  mut scale : Int
  mut zero_count : UInt64
  mut positive : ExponentialHistogramDataPoint_Buckets
  mut negative : ExponentialHistogramDataPoint_Buckets
  mut flags : UInt
  mut exemplars : Array[Exemplar]
  mut min : Double?
  mut max : Double?
  mut zero_threshold : Double
} derive(Eq)

///|
pub impl @protobuf.Sized for ExponentialHistogramDataPoint with size_of(self) {
  let mut size = 0U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + 8U
  size += 1U + 8U
  size += 1U + 8U
  if self.sum is Some(_) {
    size += 1U + 8U
  }
  size += 1U + @protobuf.size_of(self.scale)
  size += 1U + 8U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.positive)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.negative)
      @protobuf.size_of(size) + size
    })
  size += 1U + @protobuf.size_of(self.flags)
  for s in self.exemplars {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  if self.min is Some(_) {
    size += 1U + 8U
  }
  if self.max is Some(_) {
    size += 1U + 8U
  }
  size += 1U + 8U
  size
}

///|
pub impl Default for ExponentialHistogramDataPoint with default() -> ExponentialHistogramDataPoint {
  ExponentialHistogramDataPoint::{
    attributes: [],
    start_time_unix_nano: UInt64::default(),
    time_unix_nano: UInt64::default(),
    count: UInt64::default(),
    sum: None,
    scale: Int::default(),
    zero_count: UInt64::default(),
    positive: ExponentialHistogramDataPoint_Buckets::default(),
    negative: ExponentialHistogramDataPoint_Buckets::default(),
    flags: UInt::default(),
    exemplars: [],
    min: None,
    max: None,
    zero_threshold: Double::default(),
  }
}

///|
pub fn ExponentialHistogramDataPoint::new(
  attributes : Array[@v1_dep.KeyValue],
  start_time_unix_nano : UInt64,
  time_unix_nano : UInt64,
  count : UInt64,
  sum? : Double,
  scale : Int,
  zero_count : UInt64,
  positive : ExponentialHistogramDataPoint_Buckets,
  negative : ExponentialHistogramDataPoint_Buckets,
  flags : UInt,
  exemplars : Array[Exemplar],
  min? : Double,
  max? : Double,
  zero_threshold : Double,
) -> ExponentialHistogramDataPoint {
  ExponentialHistogramDataPoint::{
    attributes,
    start_time_unix_nano,
    time_unix_nano,
    count,
    sum,
    scale,
    zero_count,
    positive,
    negative,
    flags,
    exemplars,
    min,
    max,
    zero_threshold,
  }
}

///|
pub impl @protobuf.Read for ExponentialHistogramDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> ExponentialHistogramDataPoint raise {
  let msg = ExponentialHistogramDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (2, _) => msg.start_time_unix_nano = reader |> @protobuf.read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (4, _) => msg.count = reader |> @protobuf.read_fixed64()
        (5, _) => msg.sum = reader |> @protobuf.read_double() |> Some
        (6, _) => msg.scale = (reader |> @protobuf.read_sint32()).0
        (7, _) => msg.zero_count = reader |> @protobuf.read_fixed64()
        (8, _) =>
          msg.positive = (
            reader |> @protobuf.read_message() :
            ExponentialHistogramDataPoint_Buckets)
        (9, _) =>
          msg.negative = (
            reader |> @protobuf.read_message() :
            ExponentialHistogramDataPoint_Buckets)
        (10, _) => msg.flags = reader |> @protobuf.read_uint32()
        (11, _) =>
          msg.exemplars.push((reader |> @protobuf.read_message() : Exemplar))
        (12, _) => msg.min = reader |> @protobuf.read_double() |> Some
        (13, _) => msg.max = reader |> @protobuf.read_double() |> Some
        (14, _) => msg.zero_threshold = reader |> @protobuf.read_double()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for ExponentialHistogramDataPoint with write(
  self : ExponentialHistogramDataPoint,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.write_varint(10UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(17UL)
  writer |> @protobuf.write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.write_varint(25UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  writer |> @protobuf.write_varint(33UL)
  writer |> @protobuf.write_fixed64(self.count)
  if self.sum is Some(v) {
    writer |> @protobuf.write_varint(41UL)
    writer |> @protobuf.write_double(v)
  }
  writer |> @protobuf.write_varint(48UL)
  writer |> @protobuf.write_sint32(self.scale)
  writer |> @protobuf.write_varint(57UL)
  writer |> @protobuf.write_fixed64(self.zero_count)
  writer |> @protobuf.write_varint(66UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.positive))
  @protobuf.Write::write(self.positive, writer)
  writer |> @protobuf.write_varint(74UL)
  writer |> @protobuf.write_uint32(@protobuf.size_of(self.negative))
  @protobuf.Write::write(self.negative, writer)
  writer |> @protobuf.write_varint(80UL)
  writer |> @protobuf.write_uint32(self.flags)
  for item in self.exemplars {
    writer |> @protobuf.write_varint(90UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  if self.min is Some(v) {
    writer |> @protobuf.write_varint(97UL)
    writer |> @protobuf.write_double(v)
  }
  if self.max is Some(v) {
    writer |> @protobuf.write_varint(105UL)
    writer |> @protobuf.write_double(v)
  }
  writer |> @protobuf.write_varint(113UL)
  writer |> @protobuf.write_double(self.zero_threshold)
}

///|
pub impl ToJson for ExponentialHistogramDataPoint with to_json(self) {
  let json : Map[String, Json] = {}
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.start_time_unix_nano != Default::default() {
    json["startTimeUnixNano"] = self.start_time_unix_nano.to_json()
  }
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.count != Default::default() {
    json["count"] = self.count.to_json()
  }
  match self.sum {
    Some(v) => json["sum"] = v.to_json()
    _ => ()
  }
  if self.scale != Default::default() {
    json["scale"] = self.scale.to_json()
  }
  if self.zero_count != Default::default() {
    json["zeroCount"] = self.zero_count.to_json()
  }
  if self.positive != Default::default() {
    json["positive"] = self.positive.to_json()
  }
  if self.negative != Default::default() {
    json["negative"] = self.negative.to_json()
  }
  if self.flags != Default::default() {
    json["flags"] = self.flags.to_json()
  }
  if self.exemplars != Default::default() {
    json["exemplars"] = self.exemplars.to_json()
  }
  match self.min {
    Some(v) => json["min"] = v.to_json()
    _ => ()
  }
  match self.max {
    Some(v) => json["max"] = v.to_json()
    _ => ()
  }
  if self.zero_threshold != Default::default() {
    json["zeroThreshold"] = self.zero_threshold.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ExponentialHistogramDataPoint with from_json(
  json : Json,
  path : @json.JsonPath,
) -> ExponentialHistogramDataPoint raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for ExponentialHistogramDataPoint"),
    )
  }
  let message = ExponentialHistogramDataPoint::default()
  for key, value in obj {
    match (key, value) {
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("startTimeUnixNano", value) =>
        message.start_time_unix_nano = @json.from_json(value, path~)
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("count", value) => message.count = @json.from_json(value, path~)
      ("sum", value) => message.sum = Some(@json.from_json(value, path~))
      ("scale", value) => message.scale = @json.from_json(value, path~)
      ("zeroCount", value) => message.zero_count = @json.from_json(value, path~)
      ("positive", value) => message.positive = @json.from_json(value, path~)
      ("negative", value) => message.negative = @json.from_json(value, path~)
      ("flags", value) => message.flags = @json.from_json(value, path~)
      ("exemplars", Array(value)) =>
        message.exemplars = value.map(v => @json.from_json(v, path~))
      ("min", value) => message.min = Some(@json.from_json(value, path~))
      ("max", value) => message.max = Some(@json.from_json(value, path~))
      ("zeroThreshold", value) =>
        message.zero_threshold = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for ExponentialHistogramDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> ExponentialHistogramDataPoint raise {
  let msg = ExponentialHistogramDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (2, _) =>
          msg.start_time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (4, _) => msg.count = reader |> @protobuf.async_read_fixed64()
        (5, _) => msg.sum = reader |> @protobuf.async_read_double() |> Some
        (6, _) => msg.scale = (reader |> @protobuf.async_read_sint32()).0
        (7, _) => msg.zero_count = reader |> @protobuf.async_read_fixed64()
        (8, _) =>
          msg.positive = (
            reader |> @protobuf.async_read_message() :
            ExponentialHistogramDataPoint_Buckets)
        (9, _) =>
          msg.negative = (
            reader |> @protobuf.async_read_message() :
            ExponentialHistogramDataPoint_Buckets)
        (10, _) => msg.flags = reader |> @protobuf.async_read_uint32()
        (11, _) =>
          msg.exemplars.push(
            (reader |> @protobuf.async_read_message() : Exemplar),
          )
        (12, _) => msg.min = reader |> @protobuf.async_read_double() |> Some
        (13, _) => msg.max = reader |> @protobuf.async_read_double() |> Some
        (14, _) => msg.zero_threshold = reader |> @protobuf.async_read_double()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for ExponentialHistogramDataPoint with write(
  self : ExponentialHistogramDataPoint,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(10UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(17UL)
  writer |> @protobuf.async_write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.async_write_varint(25UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  writer |> @protobuf.async_write_varint(33UL)
  writer |> @protobuf.async_write_fixed64(self.count)
  if self.sum is Some(v) {
    writer |> @protobuf.async_write_varint(41UL)
    writer |> @protobuf.async_write_double(v)
  }
  writer |> @protobuf.async_write_varint(48UL)
  writer |> @protobuf.async_write_sint32(self.scale)
  writer |> @protobuf.async_write_varint(57UL)
  writer |> @protobuf.async_write_fixed64(self.zero_count)
  writer |> @protobuf.async_write_varint(66UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.positive))
  @protobuf.AsyncWrite::write(self.positive, writer)
  writer |> @protobuf.async_write_varint(74UL)
  writer |> @protobuf.async_write_uint32(@protobuf.size_of(self.negative))
  @protobuf.AsyncWrite::write(self.negative, writer)
  writer |> @protobuf.async_write_varint(80UL)
  writer |> @protobuf.async_write_uint32(self.flags)
  for item in self.exemplars {
    writer |> @protobuf.async_write_varint(90UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  if self.min is Some(v) {
    writer |> @protobuf.async_write_varint(97UL)
    writer |> @protobuf.async_write_double(v)
  }
  if self.max is Some(v) {
    writer |> @protobuf.async_write_varint(105UL)
    writer |> @protobuf.async_write_double(v)
  }
  writer |> @protobuf.async_write_varint(113UL)
  writer |> @protobuf.async_write_double(self.zero_threshold)
}

///|
pub(all) struct SummaryDataPoint_ValueAtQuantile {
  mut quantile : Double
  mut value : Double
} derive(Eq)

///|
pub impl @protobuf.Sized for SummaryDataPoint_ValueAtQuantile with size_of(
  _self,
) {
  let mut size = 0U
  size += 1U + 8U
  size += 1U + 8U
  size
}

///|
pub impl Default for SummaryDataPoint_ValueAtQuantile with default() -> SummaryDataPoint_ValueAtQuantile {
  SummaryDataPoint_ValueAtQuantile::{
    quantile: Double::default(),
    value: Double::default(),
  }
}

///|
pub fn SummaryDataPoint_ValueAtQuantile::new(
  quantile : Double,
  value : Double,
) -> SummaryDataPoint_ValueAtQuantile {
  SummaryDataPoint_ValueAtQuantile::{ quantile, value }
}

///|
pub impl @protobuf.Read for SummaryDataPoint_ValueAtQuantile with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> SummaryDataPoint_ValueAtQuantile raise {
  let msg = SummaryDataPoint_ValueAtQuantile::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (1, _) => msg.quantile = reader |> @protobuf.read_double()
        (2, _) => msg.value = reader |> @protobuf.read_double()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for SummaryDataPoint_ValueAtQuantile with write(
  self : SummaryDataPoint_ValueAtQuantile,
  writer : &@protobuf.Writer,
) -> Unit raise {
  writer |> @protobuf.write_varint(9UL)
  writer |> @protobuf.write_double(self.quantile)
  writer |> @protobuf.write_varint(17UL)
  writer |> @protobuf.write_double(self.value)
}

///|
pub impl ToJson for SummaryDataPoint_ValueAtQuantile with to_json(self) {
  let json : Map[String, Json] = {}
  if self.quantile != Default::default() {
    json["quantile"] = self.quantile.to_json()
  }
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SummaryDataPoint_ValueAtQuantile with from_json(
  json : Json,
  path : @json.JsonPath,
) -> SummaryDataPoint_ValueAtQuantile raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for SummaryDataPoint_ValueAtQuantile"),
    )
  }
  let message = SummaryDataPoint_ValueAtQuantile::default()
  for key, value in obj {
    match (key, value) {
      ("quantile", value) => message.quantile = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for SummaryDataPoint_ValueAtQuantile with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> SummaryDataPoint_ValueAtQuantile raise {
  let msg = SummaryDataPoint_ValueAtQuantile::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (1, _) => msg.quantile = reader |> @protobuf.async_read_double()
        (2, _) => msg.value = reader |> @protobuf.async_read_double()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for SummaryDataPoint_ValueAtQuantile with write(
  self : SummaryDataPoint_ValueAtQuantile,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  writer |> @protobuf.async_write_varint(9UL)
  writer |> @protobuf.async_write_double(self.quantile)
  writer |> @protobuf.async_write_varint(17UL)
  writer |> @protobuf.async_write_double(self.value)
}

///|
pub(all) struct SummaryDataPoint {
  mut attributes : Array[@v1_dep.KeyValue]
  mut start_time_unix_nano : UInt64
  mut time_unix_nano : UInt64
  mut count : UInt64
  mut sum : Double
  mut quantile_values : Array[SummaryDataPoint_ValueAtQuantile]
  mut flags : UInt
} derive(Eq)

///|
pub impl @protobuf.Sized for SummaryDataPoint with size_of(self) {
  let mut size = 0U
  for s in self.attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + 8U
  size += 1U + 8U
  size += 1U + 8U
  size += 1U + 8U
  for s in self.quantile_values {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + @protobuf.size_of(self.flags)
  size
}

///|
pub impl Default for SummaryDataPoint with default() -> SummaryDataPoint {
  SummaryDataPoint::{
    attributes: [],
    start_time_unix_nano: UInt64::default(),
    time_unix_nano: UInt64::default(),
    count: UInt64::default(),
    sum: Double::default(),
    quantile_values: [],
    flags: UInt::default(),
  }
}

///|
pub fn SummaryDataPoint::new(
  attributes : Array[@v1_dep.KeyValue],
  start_time_unix_nano : UInt64,
  time_unix_nano : UInt64,
  count : UInt64,
  sum : Double,
  quantile_values : Array[SummaryDataPoint_ValueAtQuantile],
  flags : UInt,
) -> SummaryDataPoint {
  SummaryDataPoint::{
    attributes,
    start_time_unix_nano,
    time_unix_nano,
    count,
    sum,
    quantile_values,
    flags,
  }
}

///|
pub impl @protobuf.Read for SummaryDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> SummaryDataPoint raise {
  let msg = SummaryDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (7, _) =>
          msg.attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (2, _) => msg.start_time_unix_nano = reader |> @protobuf.read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (4, _) => msg.count = reader |> @protobuf.read_fixed64()
        (5, _) => msg.sum = reader |> @protobuf.read_double()
        (6, _) =>
          msg.quantile_values.push(
            (
              reader |> @protobuf.read_message() :
              SummaryDataPoint_ValueAtQuantile),
          )
        (8, _) => msg.flags = reader |> @protobuf.read_uint32()
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for SummaryDataPoint with write(
  self : SummaryDataPoint,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.write_varint(58UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(17UL)
  writer |> @protobuf.write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.write_varint(25UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  writer |> @protobuf.write_varint(33UL)
  writer |> @protobuf.write_fixed64(self.count)
  writer |> @protobuf.write_varint(41UL)
  writer |> @protobuf.write_double(self.sum)
  for item in self.quantile_values {
    writer |> @protobuf.write_varint(50UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(64UL)
  writer |> @protobuf.write_uint32(self.flags)
}

///|
pub impl ToJson for SummaryDataPoint with to_json(self) {
  let json : Map[String, Json] = {}
  if self.attributes != Default::default() {
    json["attributes"] = self.attributes.to_json()
  }
  if self.start_time_unix_nano != Default::default() {
    json["startTimeUnixNano"] = self.start_time_unix_nano.to_json()
  }
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.count != Default::default() {
    json["count"] = self.count.to_json()
  }
  if self.sum != Default::default() {
    json["sum"] = self.sum.to_json()
  }
  if self.quantile_values != Default::default() {
    json["quantileValues"] = self.quantile_values.to_json()
  }
  if self.flags != Default::default() {
    json["flags"] = self.flags.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for SummaryDataPoint with from_json(
  json : Json,
  path : @json.JsonPath,
) -> SummaryDataPoint raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for SummaryDataPoint"),
    )
  }
  let message = SummaryDataPoint::default()
  for key, value in obj {
    match (key, value) {
      ("attributes", Array(value)) =>
        message.attributes = value.map(v => @json.from_json(v, path~))
      ("startTimeUnixNano", value) =>
        message.start_time_unix_nano = @json.from_json(value, path~)
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("count", value) => message.count = @json.from_json(value, path~)
      ("sum", value) => message.sum = @json.from_json(value, path~)
      ("quantileValues", Array(value)) =>
        message.quantile_values = value.map(v => @json.from_json(v, path~))
      ("flags", value) => message.flags = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for SummaryDataPoint with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> SummaryDataPoint raise {
  let msg = SummaryDataPoint::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (7, _) =>
          msg.attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (2, _) =>
          msg.start_time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (3, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (4, _) => msg.count = reader |> @protobuf.async_read_fixed64()
        (5, _) => msg.sum = reader |> @protobuf.async_read_double()
        (6, _) =>
          msg.quantile_values.push(
            (
              reader |> @protobuf.async_read_message() :
              SummaryDataPoint_ValueAtQuantile),
          )
        (8, _) => msg.flags = reader |> @protobuf.async_read_uint32()
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for SummaryDataPoint with write(
  self : SummaryDataPoint,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.attributes {
    writer |> @protobuf.async_write_varint(58UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(17UL)
  writer |> @protobuf.async_write_fixed64(self.start_time_unix_nano)
  writer |> @protobuf.async_write_varint(25UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  writer |> @protobuf.async_write_varint(33UL)
  writer |> @protobuf.async_write_fixed64(self.count)
  writer |> @protobuf.async_write_varint(41UL)
  writer |> @protobuf.async_write_double(self.sum)
  for item in self.quantile_values {
    writer |> @protobuf.async_write_varint(50UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(64UL)
  writer |> @protobuf.async_write_uint32(self.flags)
}

///|
pub(all) struct Exemplar {
  mut filtered_attributes : Array[@v1_dep.KeyValue]
  mut time_unix_nano : UInt64
  mut span_id : Bytes
  mut trace_id : Bytes
  mut value : Exemplar_Value
} derive(Eq)

///|
pub(all) enum Exemplar_Value {
  AsDouble(Double)
  AsInt(Int64)
  NotSet
} derive(Eq)

///|
pub impl Default for Exemplar_Value with default() -> Exemplar_Value {
  NotSet
}

///|
pub impl @json.FromJson for Exemplar_Value with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Exemplar_Value raise {
  try Exemplar_Value::AsDouble(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Exemplar_Value::AsInt(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  Exemplar_Value::NotSet
}

///|
pub impl ToJson for Exemplar_Value with to_json(self : Exemplar_Value) -> Json {
  match self {
    Exemplar_Value::AsDouble(v) => v.to_json()
    Exemplar_Value::AsInt(v) => v.to_json()
    Exemplar_Value::NotSet => Json::null()
  }
}

///|
pub impl @protobuf.Sized for Exemplar with size_of(self) {
  let mut size = 0U
  for s in self.filtered_attributes {
    let s = @protobuf.size_of(s)
    size += 1U + @protobuf.size_of(s) + s
  }
  size += 1U + 8U
  size += 1U +
    ({
      let size = @protobuf.size_of(self.span_id)
      @protobuf.size_of(size) + size
    })
  size += 1U +
    ({
      let size = @protobuf.size_of(self.trace_id)
      @protobuf.size_of(size) + size
    })
  match self.value {
    AsDouble(_) => size += 1U + 8U
    AsInt(_) => size += 1U + 8U
    NotSet => ()
  }
  size
}

///|
pub impl Default for Exemplar with default() -> Exemplar {
  Exemplar::{
    filtered_attributes: [],
    time_unix_nano: UInt64::default(),
    span_id: Bytes::default(),
    trace_id: Bytes::default(),
    value: Exemplar_Value::NotSet,
  }
}

///|
pub fn Exemplar::new(
  filtered_attributes : Array[@v1_dep.KeyValue],
  time_unix_nano : UInt64,
  span_id : Bytes,
  trace_id : Bytes,
  value? : Exemplar_Value = Exemplar_Value::NotSet,
) -> Exemplar {
  Exemplar::{ filtered_attributes, time_unix_nano, span_id, trace_id, value }
}

///|
pub impl @protobuf.Read for Exemplar with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.Reader],
) -> Exemplar raise {
  let msg = Exemplar::default()
  try {
    for ;; {
      match (reader |> @protobuf.read_tag()) {
        (7, _) =>
          msg.filtered_attributes.push(
            (reader |> @protobuf.read_message() : @v1_dep.KeyValue),
          )
        (2, _) => msg.time_unix_nano = reader |> @protobuf.read_fixed64()
        (4, _) => msg.span_id = reader |> @protobuf.read_bytes()
        (5, _) => msg.trace_id = reader |> @protobuf.read_bytes()
        (3, _) =>
          msg.value = reader
            |> @protobuf.read_double()
            |> Exemplar_Value::AsDouble
        (6, _) =>
          msg.value = reader
            |> @protobuf.read_sfixed64()
            |> Exemplar_Value::AsInt
        (_, wire) => reader |> @protobuf.read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.Write for Exemplar with write(
  self : Exemplar,
  writer : &@protobuf.Writer,
) -> Unit raise {
  for item in self.filtered_attributes {
    writer |> @protobuf.write_varint(58UL)
    writer |> @protobuf.write_uint32(@protobuf.size_of(item))
    @protobuf.Write::write(item, writer)
  }
  writer |> @protobuf.write_varint(17UL)
  writer |> @protobuf.write_fixed64(self.time_unix_nano)
  writer |> @protobuf.write_varint(34UL)
  writer |> @protobuf.write_bytes(self.span_id)
  writer |> @protobuf.write_varint(42UL)
  writer |> @protobuf.write_bytes(self.trace_id)
  match self.value {
    Exemplar_Value::AsDouble(v) => {
      writer |> @protobuf.write_varint(25UL)
      writer |> @protobuf.write_double(v)
    }
    Exemplar_Value::AsInt(v) => {
      writer |> @protobuf.write_varint(49UL)
      writer |> @protobuf.write_sfixed64(v)
    }
    Exemplar_Value::NotSet => ()
  }
}

///|
pub impl ToJson for Exemplar with to_json(self) {
  let json : Map[String, Json] = {}
  if self.filtered_attributes != Default::default() {
    json["filteredAttributes"] = self.filtered_attributes.to_json()
  }
  if self.time_unix_nano != Default::default() {
    json["timeUnixNano"] = self.time_unix_nano.to_json()
  }
  if self.span_id != Default::default() {
    json["spanId"] = @protobuf.base64_encode(self.span_id).to_json()
  }
  if self.trace_id != Default::default() {
    json["traceId"] = @protobuf.base64_encode(self.trace_id).to_json()
  }
  match self.value {
    NotSet => ()
    AsDouble(v) => json["asDouble"] = v.to_json()
    AsInt(v) => json["asInt"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Exemplar with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Exemplar raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Exemplar"))
  }
  let message = Exemplar::default()
  for key, value in obj {
    match (key, value) {
      ("filteredAttributes", Array(value)) =>
        message.filtered_attributes = value.map(v => @json.from_json(v, path~))
      ("timeUnixNano", value) =>
        message.time_unix_nano = @json.from_json(value, path~)
      ("spanId", String(value)) =>
        message.span_id = @protobuf.base64_decode(value)
      ("traceId", String(value)) =>
        message.trace_id = @protobuf.base64_decode(value)
      ("asDouble", value) => message.value = @json.from_json(value, path~)
      ("asInt", value) => message.value = @json.from_json(value, path~)
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @protobuf.AsyncRead for Exemplar with read_with_limit(
  reader : @protobuf.LimitedReader[&@protobuf.AsyncReader],
) -> Exemplar raise {
  let msg = Exemplar::default()
  try {
    for ;; {
      match (reader |> @protobuf.async_read_tag()) {
        (7, _) =>
          msg.filtered_attributes.push(
            (reader |> @protobuf.async_read_message() : @v1_dep.KeyValue),
          )
        (2, _) => msg.time_unix_nano = reader |> @protobuf.async_read_fixed64()
        (4, _) => msg.span_id = reader |> @protobuf.async_read_bytes()
        (5, _) => msg.trace_id = reader |> @protobuf.async_read_bytes()
        (3, _) =>
          msg.value = reader
            |> @protobuf.async_read_double()
            |> Exemplar_Value::AsDouble
        (6, _) =>
          msg.value = reader
            |> @protobuf.async_read_sfixed64()
            |> Exemplar_Value::AsInt
        (_, wire) => reader |> @protobuf.async_read_unknown(wire)
      }
    }
  } catch {
    @protobuf.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @protobuf.AsyncWrite for Exemplar with write(
  self : Exemplar,
  writer : &@protobuf.AsyncWriter,
) -> Unit raise {
  for item in self.filtered_attributes {
    writer |> @protobuf.async_write_varint(58UL)
    writer |> @protobuf.async_write_uint32(@protobuf.size_of(item))
    @protobuf.AsyncWrite::write(item, writer)
  }
  writer |> @protobuf.async_write_varint(17UL)
  writer |> @protobuf.async_write_fixed64(self.time_unix_nano)
  writer |> @protobuf.async_write_varint(34UL)
  writer |> @protobuf.async_write_bytes(self.span_id)
  writer |> @protobuf.async_write_varint(42UL)
  writer |> @protobuf.async_write_bytes(self.trace_id)
  match self.value {
    Exemplar_Value::AsDouble(v) => {
      writer |> @protobuf.async_write_varint(25UL)
      writer |> @protobuf.async_write_double(v)
    }
    Exemplar_Value::AsInt(v) => {
      writer |> @protobuf.async_write_varint(49UL)
      writer |> @protobuf.async_write_sfixed64(v)
    }
    Exemplar_Value::NotSet => ()
  }
}
