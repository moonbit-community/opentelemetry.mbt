# OpenTelemetry Resource SDK

This package represents the entity producing telemetry and the detectors used to
discover that information.

## Default detectors

`Resource::builder()` starts with three detectors, following the same broad
shape as the Rust SDK:

- `sdk_provided_resource_detector()`
- `telemetry_resource_detector()`
- `env_resource_detector()`

The default output always includes SDK metadata and a fallback
`service.name=unknown_service:<process_name>` when the application does not
provide one.

## Merge semantics

`Resource::merge()` prefers attributes from the right-hand resource. Schema URL
handling follows OpenTelemetry resource merge rules:

- same schema URL: keep it
- only one schema URL present: keep the present one
- conflicting schema URLs: clear it

## Environment variables

`env_resource_detector()` currently reads:

- `OTEL_RESOURCE_ATTRIBUTES`
- `OTEL_SERVICE_NAME`

`OTEL_SERVICE_NAME` takes precedence because its detected resource is merged
after the generic resource attributes.
