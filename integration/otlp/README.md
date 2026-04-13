# OTLP Integration Tests

This module contains collector-backed integration tests for
`moonbit-community/opentelemetry`.

It is intentionally isolated from the repository root so the default
`moon test` for the main module stays fast and does not require Docker.

## Coverage

The suite exercises the public MoonBit API over the OTLP HTTP exporters:

- traces over `http/protobuf` and `http/json`
- logs over `http/protobuf` and `http/json`
- metrics over `http/protobuf` and `http/json`
- a cross-signal `fullstack` flow that correlates traces, logs, and metrics in
  one request path
- signal-specific OTLP endpoint environment variables overriding an invalid
  global OTLP endpoint

Each test drives the public API end to end:

1. build an SDK provider with an OTLP exporter
2. register it with `sdk.set_*_provider()`, which also updates
   `interface/global`
3. emit telemetry through the root package API or `interface/global`
4. send data to a real OpenTelemetry Collector
5. compare the collector file output against checked-in snapshots

## Prerequisites

- Node.js
- MoonBit toolchain with `moon`
- either Docker or a local `otelcol` binary installed as described in `DEVENV.md`

## Run

From the repository root with Docker and the default pinned collector image:

```bash
integration/otlp/scripts/test_with_docker.mjs
```

With a local `otelcol` binary installed in the standard path from `DEVENV.md`:

```bash
integration/otlp/scripts/test_with_binary.mjs
```

To run a subset:

```bash
integration/otlp/scripts/test_with_docker.mjs traces
integration/otlp/scripts/test_with_docker.mjs logs metrics fullstack
integration/otlp/scripts/test_with_binary.mjs traces
integration/otlp/scripts/test_with_binary.mjs logs metrics fullstack
```

The Docker runner starts one collector container with random host port mapping,
exports `OTEL_EXPORTER_OTLP_ENDPOINT`, runs the selected packages
sequentially, and then cleans the container up. If `OTEL_COLLECTOR_IMAGE` is
unset it uses the script's pinned default collector image. Set
`OTEL_COLLECTOR_IMAGE` only when you need to override that version.
