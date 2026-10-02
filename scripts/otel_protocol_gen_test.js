const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");

const rootDir = path.resolve(__dirname, "..");
const generatorPath = path.join(__dirname, "otel_protocol_gen.js");
const manifestPath = path.join(__dirname, "otel_protocol_manifest.json");

const expectedIncludeDirs = ["third_party/opentelemetry-proto"];
const expectedProtoFiles = [
  "third_party/opentelemetry-proto/opentelemetry/proto/common/v1/common.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/resource/v1/resource.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/trace/v1/trace.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/collector/trace/v1/trace_service.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/metrics/v1/metrics.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/collector/metrics/v1/metrics_service.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/logs/v1/logs.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/collector/logs/v1/logs_service.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/profiles/v1development/profiles.proto",
  "third_party/opentelemetry-proto/opentelemetry/proto/collector/profiles/v1development/profiles_service.proto",
];

test("proto manifest is maintained in this repository", () => {
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));

  assert.deepEqual(manifest.includeDirs, expectedIncludeDirs);
  assert.deepEqual(manifest.protoFiles, expectedProtoFiles);
});

test("generator loads proto files and include dirs from manifest", () => {
  const generator = require(generatorPath);
  const manifest = generator.loadProtoManifest(manifestPath);

  assert.deepEqual(manifest.includeDirs, expectedIncludeDirs);
  assert.deepEqual(manifest.protoFiles, expectedProtoFiles);
});

test("generator parses the current moon.mod module name", () => {
  const generator = require(generatorPath);

  assert.equal(
    generator.readModuleName(path.join(rootDir, "moon.mod")),
    "moonbit-community/opentelemetry",
  );
});

test("official opentelemetry proto source is a repository submodule", () => {
  const gitmodules = fs.readFileSync(path.join(rootDir, ".gitmodules"), "utf8");

  assert.match(gitmodules, /path = third_party\/opentelemetry-proto/);
  assert.match(gitmodules, /url = https:\/\/github\.com\/open-telemetry\/opentelemetry-proto/);
  assert.equal(
    fs.existsSync(
      path.join(rootDir, "third_party", "opentelemetry-proto", "opentelemetry", "proto", "common", "v1", "common.proto"),
    ),
    true,
  );
});

test("tracez protocol is not generated or vendored", () => {
  const manifest = fs.readFileSync(manifestPath, "utf8");
  const generator = fs.readFileSync(generatorPath, "utf8");

  assert.equal(manifest.includes("tracez"), false);
  assert.equal(generator.includes("tracez"), false);
  assert.equal(fs.existsSync(path.join(rootDir, "third_party", "otel-extra-proto", "tracez.proto")), false);
  assert.equal(fs.existsSync(path.join(rootDir, "protocol", "tracez")), false);
});

test("generator declares trait method promotion explicitly", () => {
  const generator = require(generatorPath);
  const source = [
    "pub(all) struct Foo {",
    "  x : Int",
    "} derive(Eq)",
    "",
    "pub impl @protobuf.Read for Foo with fn read_with_limit(reader, limit) {",
    "}",
    "",
    "pub impl @protobuf.AsyncRead for Foo with fn read_with_limit(reader, limit) {",
    "}",
    "",
  ].join("\n");
  const output = generator.addExplicitExtends(source);

  assert.match(output, /pub extend Foo with Eq::\{equal, not_equal\}/);
  assert.match(output, /pub extend Foo with @protobuf\.Read::\{read, read_with_limit\}/);
  assert.equal(output.includes("@protobuf.AsyncRead::"), false);
  assert.equal(generator.addExplicitExtends(output), output);
});
