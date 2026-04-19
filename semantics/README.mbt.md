# OpenTelemetry Semantic Conventions

This package family exposes generated semantic-convention constants imported
from upstream OpenTelemetry semantic-convention data.

## Packages

- `semantics`:
  exports only `SCHEMA_URL`, the schema URL matching the generated constants
- `semantics/attribute`:
  exports the raw attribute-key constants
- `semantics/trace`:
  exports constants commonly used with trace spans
- `semantics/resource`:
  exports constants commonly used with resources
- `semantics/metric`:
  exports metric-name constants and related signal-specific entries

## How to use them

Use these constants anywhere you would otherwise hard-code an attribute key or
metric name:

```mbt check
///|
fn _trace_attr_example() -> @sdk.KeyValue {
  @sdk.KeyValue::new(@trace.HTTP_REQUEST_METHOD, @sdk.Value::String("GET"))
}
```

## Generation model

These files are generated. Comments such as "Experimental semantic convention"
and upstream deprecation notices are preserved from the source data.
