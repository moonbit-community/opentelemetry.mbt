# Development Environment

Chinese version: [DEVENV_CN.md](./DEVENV_CN.md).

The OTLP integration tests for this repository live in `integration/otlp`.
They require an OpenTelemetry Collector that can receive OTLP/HTTP traffic and
write the received payloads to JSON files.

This document defines two supported workflows:

1. Install a local `otelcol` binary
2. Run the collector with Docker

The helper scripts under `integration/otlp/scripts/*.mjs` require Node.js.

All examples pin the collector to version `0.150.1` to reduce environment
drift.

## Shared Conventions

### Paths

- Integration test module: `integration/otlp`
- Collector output directory: `integration/otlp/actual`
- Docker collector config: `integration/otlp/otel-collector-config.yaml`
- Local binary runner script: `integration/otlp/scripts/test_with_binary.mjs`
- Docker runner script: `integration/otlp/scripts/test_with_docker.mjs`

### Ports

- Local binary example listener: `127.0.0.1:43181`
- Docker container listener: `0.0.0.0:4318`
- Tests point to the collector through `OTEL_EXPORTER_OTLP_ENDPOINT`

### Test Commands

Run from the repository root:

```bash
moon -C integration/otlp test traces
moon -C integration/otlp test logs
moon -C integration/otlp test metrics
moon -C integration/otlp test fullstack
```

If the collector is not running on the default endpoint, set it explicitly:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:43181 \
  moon -C integration/otlp test traces
```

## Option 1: Local `otelcol` Binary

### 1. Installation

Pinned install example for Linux x86_64:

```bash
export OTELCOL_VERSION=0.150.1
export OTELCOL_DIR="$HOME/.local/opt/otelcol/$OTELCOL_VERSION"

mkdir -p "$OTELCOL_DIR"

curl -L -o /tmp/otelcol.tar.gz \
  "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTELCOL_VERSION}/otelcol_${OTELCOL_VERSION}_linux_amd64.tar.gz"

tar -xzf /tmp/otelcol.tar.gz -C "$OTELCOL_DIR"
chmod +x "$OTELCOL_DIR/otelcol"
```

Verify the installation:

```bash
"$OTELCOL_DIR/otelcol" --version
```

For non-Linux x86_64 environments, replace the release artifact name with the
matching platform build.

### 2. Configuration

The repository file `integration/otlp/otel-collector-config.yaml` is intended
for containers and writes to `/testresults/*.json` inside the container.
Running the collector as a local binary requires a separate config file.

Recommended location:

```text
$HOME/.config/otelcol/opentelemetry-mbt.yaml
```

Example config:

```yaml
receivers:
  otlp:
    protocols:
      http:
        endpoint: 127.0.0.1:43181

exporters:
  file/traces:
    path: /absolute/path/to/opentelemetry.mbt/integration/otlp/actual/traces.json
  file/logs:
    path: /absolute/path/to/opentelemetry.mbt/integration/otlp/actual/logs.json
    rotation:
  file/metrics:
    path: /absolute/path/to/opentelemetry.mbt/integration/otlp/actual/metrics.json

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [file/traces]
    logs:
      receivers: [otlp]
      exporters: [file/logs]
    metrics:
      receivers: [otlp]
      exporters: [file/metrics]
```

Replace this placeholder with the actual repository path:

```text
/absolute/path/to/opentelemetry.mbt
```

### 3. Usage

Prepare the output files first:

```bash
cd /absolute/path/to/opentelemetry.mbt

mkdir -p integration/otlp/actual
: > integration/otlp/actual/traces.json
: > integration/otlp/actual/logs.json
: > integration/otlp/actual/metrics.json
```

Start the collector:

```bash
"$OTELCOL_DIR/otelcol" \
  --config "$HOME/.config/otelcol/opentelemetry-mbt.yaml"
```

Run the integration tests from another terminal:

```bash
cd /absolute/path/to/opentelemetry.mbt

OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:43181 \
  moon -C integration/otlp test traces

OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:43181 \
  moon -C integration/otlp test logs

OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:43181 \
  moon -C integration/otlp test metrics

OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:43181 \
  moon -C integration/otlp test fullstack
```

The repository also provides a convenience runner that starts the local binary,
waits for the OTLP HTTP port, runs the selected packages, and then stops the
collector:

```bash
integration/otlp/scripts/test_with_binary.mjs
integration/otlp/scripts/test_with_binary.mjs traces
integration/otlp/scripts/test_with_binary.mjs logs metrics fullstack
```

By default it looks for:

```text
$HOME/.local/opt/otelcol/0.150.1/otelcol
```

Override the binary or port when needed:

```bash
OTELCOL_BIN=/custom/path/otelcol \
OTELCOL_PORT=43181 \
MOON_BIN=/custom/path/moon \
  integration/otlp/scripts/test_with_binary.mjs
```

For single-signal validation, run only the relevant command.

### 4. When to Use This Path

Use this workflow when:

- Docker is not available
- direct access to collector logs or local config files is needed
- reproducing behavior against a pinned collector binary is important

## Option 2: Docker-Based Collector

### 1. Configuration

The Docker workflow reuses the repository config file:

```text
integration/otlp/otel-collector-config.yaml
```

This config listens on `4318` inside the container and writes traces, logs, and
metrics to mounted `/testresults/*.json` files.

`integration/otlp/scripts/test_with_docker.mjs` is responsible for:

- starting the collector container
- mounting the config file and output files into the container
- discovering the mapped host port automatically
- exporting `OTEL_EXPORTER_OTLP_ENDPOINT`
- running `traces`, `logs`, and `metrics` sequentially
- cleaning up the container on exit

To avoid drift from `latest`, pin the image explicitly.
`integration/otlp/scripts/test_with_docker.mjs` falls back to `latest` when
`OTEL_COLLECTOR_IMAGE` is unset.

Example:

```bash
export OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1
```

### 2. Usage

Run the full integration suite:

```bash
OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs
```

Run a subset:

```bash
OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs traces

OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs logs metrics
```

If `docker` or `moon` is not on the default path, override them:

```bash
DOCKER_BIN=/custom/path/docker \
MOON_BIN=/custom/path/moon \
OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs
```

### 3. When to Use This Path

Use this workflow when:

- Docker is already available locally or in CI
- the fewest manual steps are preferred
- the execution path should match the repository-provided runner script

## Selection Guidance

- No Docker environment: use the local `otelcol` binary workflow
- Typical local development: prefer the Docker workflow
- CI or automated verification: use the Docker workflow and pin
  `OTEL_COLLECTOR_IMAGE`

## Troubleshooting

### `Connection refused`

The collector is not running, or `OTEL_EXPORTER_OTLP_ENDPOINT` does not match
the actual listener address.

### `HTTP 400 Bad Request`

Check collector logs and test output first. This repository already includes a
fix for OTLP HTTP JSON encoding of `traceId`, `spanId`, and `parentSpanId`. If
similar failures appear again, inspect `otlp/top.mbt` for regressions.

### `expected/...json: No such file or directory`

The corresponding snapshot is missing. New integration tests must add matching
files under `integration/otlp/expected/`.

### Docker Port Never Becomes Ready

`integration/otlp/scripts/test_with_docker.mjs` waits for the mapped container port to become
reachable. If the script times out, check:

- whether the Docker daemon is healthy
- whether the collector image can be pulled successfully
- whether the container logs show configuration errors
