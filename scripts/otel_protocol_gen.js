#!/usr/bin/env node

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const rootDir = path.resolve(__dirname, "..");
const rootMoonModPath = path.join(rootDir, "moon.mod.json");
const rustRepoDir = path.resolve(rootDir, "..", "opentelemetry-rust");
const protoCrateDir = path.join(rustRepoDir, "opentelemetry-proto");
const protoSubmoduleDir = path.join(
  protoCrateDir,
  "src",
  "proto",
  "opentelemetry-proto",
);
const grpcBuildRsPath = path.join(protoCrateDir, "tests", "grpc_build.rs");
const protocGenMbtExePath = path.join(rootDir, "protoc-gen-mbt.exe");
const protocolDir = path.join(rootDir, "protocol");
const generatedTopLevelDirs = [
  "collector",
  "common",
  "logs",
  "metrics",
  "profiles",
  "resource",
  "trace",
  "tracez",
  "opentelemetry",
];

main();

function main() {
  const rootMoonMod = readJson(rootMoonModPath);
  const { username, projectName, moduleName } = parseModuleName(rootMoonMod);

  ensureRootModuleDependency(rootMoonMod, "moonbitlang/protobuf", "0.1.0");
  ensureProtoSources();

  const pluginExePath = ensurePluginExecutable();
  const { protoFiles, includeDirs } = parseGrpcBuildInputs();

  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "opentelemetry-protocol-"));
  try {
    const outDir = path.join(tempDir, "out");
    fs.mkdirSync(outDir, { recursive: true });

    runProtoc({
      outDir,
      pluginExePath,
      username,
      projectName,
      protoFiles,
      includeDirs,
    });

    syncGeneratedTree({
      outDir,
      projectName,
      moduleName,
    });

    console.log("Refreshing MoonBit interfaces and formatting generated code...");
    runCommand("moon", ["info"]);
    runCommand("moon", ["fmt"]);

    const packageCount = walkFiles(protocolDir).filter(
      (filePath) => path.basename(filePath) === "moon.pkg",
    ).length;
    console.log(
      `Generated ${packageCount} MoonBit packages under ${path.relative(rootDir, protocolDir)}`,
    );
  } finally {
    fs.rmSync(tempDir, { recursive: true, force: true });
  }
}

function parseModuleName(rootMoonMod) {
  const moduleName = rootMoonMod.name;
  if (typeof moduleName !== "string") {
    throw new Error(`Expected "name" in ${rootMoonModPath}`);
  }

  const [username, projectName, ...rest] = moduleName.split("/");
  if (!username || !projectName || rest.length > 0) {
    throw new Error(`Expected module name in username/project form, got ${moduleName}`);
  }

  return { username, projectName, moduleName };
}

function ensureRootModuleDependency(rootMoonMod, dependencyName, version) {
  let changed = false;

  if (!rootMoonMod.deps || typeof rootMoonMod.deps !== "object" || Array.isArray(rootMoonMod.deps)) {
    rootMoonMod.deps = {};
    changed = true;
  }

  if (rootMoonMod.deps[dependencyName] !== version) {
    rootMoonMod.deps[dependencyName] = version;
    changed = true;
  }

  if (changed) {
    writeJson(rootMoonModPath, rootMoonMod);
    console.log(
      `Updated ${path.relative(rootDir, rootMoonModPath)} with ${dependencyName}@${version}`,
    );
  }
}

function ensureProtoSources() {
  if (containsProtoFiles(protoSubmoduleDir)) {
    return;
  }

  console.log("Initializing the OpenTelemetry proto submodule...");
  runCommand("git", [
    "-C",
    rustRepoDir,
    "submodule",
    "update",
    "--init",
    "--recursive",
    "opentelemetry-proto/src/proto/opentelemetry-proto",
  ]);

  if (!containsProtoFiles(protoSubmoduleDir)) {
    throw new Error(`OpenTelemetry proto sources are still missing under ${protoSubmoduleDir}`);
  }
}

function ensurePluginExecutable() {
  if (!isFile(protocGenMbtExePath)) {
    throw new Error(
      [
        `Missing ${path.relative(rootDir, protocGenMbtExePath)}.`,
        "Install protoc-gen-mbt.exe manually from https://github.com/moonbitlang/protoc-gen-mbt",
        "and place the executable in the project root.",
      ].join(" "),
    );
  }
  return protocGenMbtExePath;
}

function parseGrpcBuildInputs() {
  const source = fs.readFileSync(grpcBuildRsPath, "utf8");
  return {
    protoFiles: parseRustStringArray(source, "TONIC_PROTO_FILES"),
    includeDirs: parseRustStringArray(source, "TONIC_INCLUDES"),
  };
}

function parseRustStringArray(source, constName) {
  const pattern = new RegExp(
    `const\\s+${constName}:\\s*&\\[&str\\]\\s*=\\s*&\\[(.*?)\\];`,
    "s",
  );
  const match = source.match(pattern);
  if (!match) {
    throw new Error(`Could not find ${constName} in ${grpcBuildRsPath}`);
  }

  return [...match[1].matchAll(/"((?:[^"\\]|\\.)*)"/g)].map((item) =>
    unescapeRustString(item[1]),
  );
}

function runProtoc({
  outDir,
  pluginExePath,
  username,
  projectName,
  protoFiles,
  includeDirs,
}) {
  const protoPaths = includeDirs.map((dirPath) => path.join(protoCrateDir, dirPath));
  const absoluteProtoFiles = protoFiles.map((filePath) => path.join(protoCrateDir, filePath));

  for (const filePath of [...protoPaths, ...absoluteProtoFiles]) {
    if (!fs.existsSync(filePath)) {
      throw new Error(`Missing expected proto input: ${filePath}`);
    }
  }

  console.log(`Generating ${absoluteProtoFiles.length} protobuf files...`);
  const args = [
    "--experimental_allow_proto3_optional",
    `--plugin=protoc-gen-mbt=${pluginExePath}`,
    ...protoPaths.map((dirPath) => `--proto_path=${dirPath}`),
    `--mbt_out=${outDir}`,
    `--mbt_opt=username=${username},project_name=${projectName},json=true,async=true,derive=Eq`,
    ...absoluteProtoFiles,
  ];
  runCommand("protoc", args);
}

function syncGeneratedTree({ outDir, projectName, moduleName }) {
  const generatedSrcDir = path.join(outDir, projectName, "src", "opentelemetry", "proto");
  if (!fs.existsSync(generatedSrcDir)) {
    throw new Error(`Expected generated OpenTelemetry code under ${generatedSrcDir}`);
  }

  fs.mkdirSync(protocolDir, { recursive: true });
  for (const dirname of generatedTopLevelDirs) {
    fs.rmSync(path.join(protocolDir, dirname), { recursive: true, force: true });
  }
  for (const entry of fs.readdirSync(generatedSrcDir, { withFileTypes: true })) {
    fs.cpSync(path.join(generatedSrcDir, entry.name), path.join(protocolDir, entry.name), {
      recursive: true,
    });
  }

  const importPrefix = `"${moduleName}/opentelemetry/proto/`;
  const rewrittenImportPrefix = `"${moduleName}/protocol/`;

  const packageDirs = walkPackageDirs(protocolDir);
  for (const packageDir of packageDirs) {
    const moonPkgPath = path.join(packageDir, "moon.pkg");
    const topMbtPath = path.join(packageDir, "top.mbt");

    let moonPkgContent = fs.readFileSync(moonPkgPath, "utf8");
    moonPkgContent = moonPkgContent.replaceAll(importPrefix, rewrittenImportPrefix);
    moonPkgContent = ensureJsonImport(moonPkgContent, moonPkgPath);

    let topMbtContent = fs.readFileSync(topMbtPath, "utf8");
    topMbtContent = rewriteTopMbt(topMbtContent);

    const aliasRewrites = findAliasRewrites(packageDir, moonPkgContent);
    for (const [oldAlias, newAlias] of aliasRewrites) {
      moonPkgContent = moonPkgContent.replaceAll(`@${oldAlias},`, `@${newAlias},`);
      topMbtContent = topMbtContent.replaceAll(`@${oldAlias}.`, `@${newAlias}.`);
    }

    fs.writeFileSync(moonPkgPath, moonPkgContent);
    fs.writeFileSync(topMbtPath, topMbtContent);
  }
}

function ensureJsonImport(content, filePath) {
  if (content.includes('"moonbitlang/core/json"')) {
    return content;
  }

  const protobufImport = '  "moonbitlang/protobuf",\n';
  if (!content.includes(protobufImport)) {
    throw new Error(`Could not locate protobuf import in ${filePath}`);
  }

  return content.replace(
    protobufImport,
    `${protobufImport}  "moonbitlang/core/json",\n`,
  );
}

function walkFiles(dirPath) {
  if (!fs.existsSync(dirPath)) {
    return [];
  }

  const files = [];
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const entryPath = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkFiles(entryPath));
    } else if (entry.isFile()) {
      files.push(entryPath);
    }
  }
  return files;
}

function walkPackageDirs(dirPath) {
  return walkFiles(dirPath)
    .filter((filePath) => path.basename(filePath) === "moon.pkg")
    .map((filePath) => path.dirname(filePath));
}

function findAliasRewrites(packageDir, moonPkgContent) {
  const currentAlias = path.basename(packageDir);
  const matches = [...moonPkgContent.matchAll(/"[^"]+"\s+@([A-Za-z0-9_]+),/g)];
  const usedAliases = new Set(matches.map((match) => match[1]));
  const aliasRewrites = [];

  for (const match of matches) {
    const importedAlias = match[1];
    if (importedAlias !== currentAlias) {
      continue;
    }

    let nextAlias = `${importedAlias}_dep`;
    while (usedAliases.has(nextAlias)) {
      nextAlias = `${nextAlias}_`;
    }
    usedAliases.add(nextAlias);
    aliasRewrites.push([importedAlias, nextAlias]);
  }

  return aliasRewrites;
}

function rewriteTopMbt(content) {
  return content
    .replaceAll("for {", "for ;; {")
    .replaceAll("DoubleValue(v) => { size += 1U + 8U }", "DoubleValue(_) => { size += 1U + 8U }")
    .replaceAll("AsDouble(v) => { size += 1U + 8U }", "AsDouble(_) => { size += 1U + 8U }")
    .replaceAll("AsInt(v) => { size += 1U + 8U }", "AsInt(_) => { size += 1U + 8U }")
    .replaceAll("if self.sum is Some(v) {\n    size += 1U + 8U\n  }", "if self.sum is Some(_) {\n    size += 1U + 8U\n  }")
    .replaceAll("if self.min is Some(v) {\n    size += 1U + 8U\n  }", "if self.min is Some(_) {\n    size += 1U + 8U\n  }")
    .replaceAll("if self.max is Some(v) {\n    size += 1U + 8U\n  }", "if self.max is Some(_) {\n    size += 1U + 8U\n  }")
    .replaceAll(
      "pub impl @protobuf.Sized for SummaryDataPoint_ValueAtQuantile with size_of(self) {",
      "pub impl @protobuf.Sized for SummaryDataPoint_ValueAtQuantile with size_of(_self) {",
    );
}

function containsProtoFiles(dirPath) {
  return walkFiles(dirPath).some((filePath) => filePath.endsWith(".proto"));
}

function isFile(filePath) {
  try {
    return fs.statSync(filePath).isFile();
  } catch {
    return false;
  }
}

function runCommand(command, args) {
  const display = [command, ...args].join(" ");
  const result = spawnSync(command, args, {
    cwd: rootDir,
    stdio: "inherit",
  });

  if (result.error) {
    throw new Error(`Failed to run ${display}: ${result.error.message}`);
  }
  if (result.status !== 0) {
    throw new Error(`Command failed (${result.status}): ${display}`);
  }
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function unescapeRustString(value) {
  return value
    .replaceAll("\\\\", "\\")
    .replaceAll('\\"', '"')
    .replaceAll("\\n", "\n")
    .replaceAll("\\r", "\r")
    .replaceAll("\\t", "\t");
}
