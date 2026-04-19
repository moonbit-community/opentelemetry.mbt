# Development Environment

英文版见 [DEVENV.md](./DEVENV.md)。

本仓库的 OTLP 集成测试位于 `integration/otlp`，依赖一个可接收
OTLP/HTTP 请求并将结果写入 JSON 文件的 OpenTelemetry Collector。

本文档固定两条支持路径：

1. 本地安装 `otelcol` 二进制
2. 使用 Docker 运行 collector 容器

`integration/otlp/scripts/*.mjs` 下的辅助脚本依赖 Node.js。

本文档中的 collector 版本示例统一固定为 `0.150.1`，用于减少环境漂移。

## 统一约定

### 目录

- 集成测试模块：`integration/otlp`
- collector 输出目录：`integration/otlp/actual`
- Docker collector 配置：`integration/otlp/otel-collector-config.yaml`
- 本地二进制运行脚本：`integration/otlp/scripts/test_with_binary.mjs`
- Docker 运行脚本：`integration/otlp/scripts/test_with_docker.mjs`

### 端口

- 本地二进制示例监听：`127.0.0.1:43181`
- Docker 容器内监听：`0.0.0.0:4318`
- 测试侧统一通过环境变量 `OTEL_EXPORTER_OTLP_ENDPOINT` 指向 collector

### 测试命令

从仓库根目录运行：

```bash
moon -C integration/otlp test traces
moon -C integration/otlp test logs
moon -C integration/otlp test metrics
moon -C integration/otlp test fullstack
```

如果 collector 不在默认端点，需要显式设置：

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:43181 \
  moon -C integration/otlp test traces
```

## 方案一：本地安装 `otelcol` 二进制

### 1. 安装

Linux x86_64 的固定版本安装示例：

```bash
export OTELCOL_VERSION=0.150.1
export OTELCOL_DIR="$HOME/.local/opt/otelcol/$OTELCOL_VERSION"

mkdir -p "$OTELCOL_DIR"

curl -L -o /tmp/otelcol.tar.gz \
  "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTELCOL_VERSION}/otelcol_${OTELCOL_VERSION}_linux_amd64.tar.gz"

tar -xzf /tmp/otelcol.tar.gz -C "$OTELCOL_DIR"
chmod +x "$OTELCOL_DIR/otelcol"
```

验证安装：

```bash
"$OTELCOL_DIR/otelcol" --version
```

如果平台不是 Linux x86_64，需要替换 release 产物文件名中的平台部分。

### 2. 配置

仓库中的 `integration/otlp/otel-collector-config.yaml` 是容器用配置，路径指向
容器内的 `/testresults/*.json`。本地二进制运行时需要单独准备一个本地配置文件。

建议路径：

```text
$HOME/.config/otelcol/opentelemetry-mbt.yaml
```

配置内容：

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

需要替换为实际仓库绝对路径：

```text
/absolute/path/to/opentelemetry.mbt
```

### 3. 使用

先准备输出文件：

```bash
cd /absolute/path/to/opentelemetry.mbt

mkdir -p integration/otlp/actual
: > integration/otlp/actual/traces.json
: > integration/otlp/actual/logs.json
: > integration/otlp/actual/metrics.json
```

启动 collector：

```bash
"$OTELCOL_DIR/otelcol" \
  --config "$HOME/.config/otelcol/opentelemetry-mbt.yaml"
```

在另一个终端运行集成测试：

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

仓库里也提供了一个便捷脚本，会自动启动本地 collector 二进制、等待端口就绪、
执行选定测试，并在结束后停止 collector：

```bash
integration/otlp/scripts/test_with_binary.mjs
integration/otlp/scripts/test_with_binary.mjs traces
integration/otlp/scripts/test_with_binary.mjs logs metrics fullstack
```

默认会查找：

```text
$HOME/.local/opt/otelcol/0.150.1/otelcol
```

需要时可覆盖二进制路径或端口：

```bash
OTELCOL_BIN=/custom/path/otelcol \
OTELCOL_PORT=43181 \
MOON_BIN=/custom/path/moon \
  integration/otlp/scripts/test_with_binary.mjs
```

只验证单个信号时，保留对应命令即可。

### 4. 适用场景

适用于：

- 当前环境没有 Docker
- 需要直接观察 collector 标准输出或本地配置文件
- 需要稳定复现某个固定 collector 版本

## 方案二：使用 Docker 运行 collector

### 1. 配置

Docker 路径复用仓库内已有配置文件：

```text
integration/otlp/otel-collector-config.yaml
```

该配置在容器内监听 `4318`，并将 traces、logs、metrics 分别写入挂载后的
`/testresults/*.json`。

`integration/otlp/scripts/test_with_docker.mjs` 会负责：

- 启动 collector 容器
- 将配置文件和输出文件挂载进容器
- 自动发现宿主机映射端口
- 导出 `OTEL_EXPORTER_OTLP_ENDPOINT`
- 顺序执行 `traces`、`logs`、`metrics` 测试
- 在退出时清理容器

为避免使用 `latest` 带来的行为漂移，建议显式固定镜像版本。
`integration/otlp/scripts/test_with_docker.mjs` 在未设置
`OTEL_COLLECTOR_IMAGE` 时会回退到 `latest`。

固定镜像版本示例：

```bash
export OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1
```

### 2. 使用

执行完整集成测试：

```bash
OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs
```

执行部分信号：

```bash
OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs traces

OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs logs metrics
```

如果 `docker` 或 `moon` 不在默认路径，也可以覆盖：

```bash
DOCKER_BIN=/custom/path/docker \
MOON_BIN=/custom/path/moon \
OTEL_COLLECTOR_IMAGE=ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1 \
  integration/otlp/scripts/test_with_docker.mjs
```

### 3. 适用场景

适用于：

- 本地或 CI 环境已具备 Docker
- 需要最少的手工步骤
- 需要与仓库默认集成测试脚本保持一致

## 选择建议

- 无 Docker 环境：使用“本地安装 `otelcol` 二进制”
- 常规本地开发：优先使用 Docker 路径
- CI 或自动化验证：使用 Docker 路径，并显式固定 `OTEL_COLLECTOR_IMAGE`

## 排障

### `Connection refused`

collector 未启动，或测试侧 `OTEL_EXPORTER_OTLP_ENDPOINT` 与 collector 实际监听
地址不一致。

### `HTTP 400 Bad Request`

优先检查 collector 日志和测试输出。当前仓库已经修复过 OTLP HTTP JSON 请求中的
`traceId`、`spanId`、`parentSpanId` 编码问题；如果再次出现类似报错，需要检查
`otlp/top.mbt` 是否发生回退。

### `expected/...json: No such file or directory`

对应快照缺失。新增集成测试用例时，需要同时补齐
`integration/otlp/expected/` 下的快照文件。

### Docker 端口未就绪

`integration/otlp/scripts/test_with_docker.mjs` 会等待容器映射端口可连接。如果脚本超时退出，
需要检查：

- Docker daemon 是否正常
- collector 镜像是否能被正确拉取
- 容器日志中是否存在配置错误
