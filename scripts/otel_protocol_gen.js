#!/usr/bin/env node

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const rootDir = path.resolve(__dirname, "..");
const rootMoonModPath = path.join(rootDir, "moon.mod");
const protoManifestPath = path.join(__dirname, "otel_protocol_manifest.json");
const protoSubmoduleDir = path.join(rootDir, "third_party", "opentelemetry-proto");
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
  "opentelemetry",
];

if (require.main === module) {
  main();
}

function main() {
  const moduleName = readModuleName(rootMoonModPath);
  const { username, projectName } = parseModuleName(moduleName);

  ensureProtoSources();

  const pluginExePath = ensurePluginExecutable();
  const { protoFiles, includeDirs } = loadProtoManifest();

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

function readModuleName(filePath) {
  const source = fs.readFileSync(filePath, "utf8");
  const match = source.match(/^\s*name\s*=\s*"([^"]+)"\s*$/m);
  if (!match) {
    throw new Error(`Expected "name" in ${filePath}`);
  }
  return match[1];
}

function parseModuleName(moduleName) {
  const [username, projectName, ...rest] = moduleName.split("/");
  if (!username || !projectName || rest.length > 0) {
    throw new Error(`Expected module name in username/project form, got ${moduleName}`);
  }

  return { username, projectName, moduleName };
}

function ensureProtoSources() {
  if (containsProtoFiles(protoSubmoduleDir)) {
    return;
  }

  console.log("Initializing the OpenTelemetry proto submodule...");
  runCommand("git", [
    "submodule",
    "update",
    "--init",
    "--recursive",
    "third_party/opentelemetry-proto",
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

function loadProtoManifest(filePath = protoManifestPath) {
  const manifest = readJson(filePath);
  return {
    includeDirs: readManifestStringArray(manifest, "includeDirs", filePath),
    protoFiles: readManifestStringArray(manifest, "protoFiles", filePath),
  };
}

function readManifestStringArray(manifest, fieldName, filePath) {
  const value = manifest[fieldName];
  if (!Array.isArray(value) || value.length === 0) {
    throw new Error(`Expected non-empty "${fieldName}" array in ${filePath}`);
  }

  for (const item of value) {
    if (typeof item !== "string" || item.length === 0) {
      throw new Error(`Expected "${fieldName}" in ${filePath} to contain only non-empty strings`);
    }
    if (path.isAbsolute(item) || item.split(/[\\/]+/).includes("..")) {
      throw new Error(`Expected "${fieldName}" entry to be relative and stay inside repository: ${item}`);
    }
  }

  return [...value];
}

function runProtoc({
  outDir,
  pluginExePath,
  username,
  projectName,
  protoFiles,
  includeDirs,
}) {
  const protoPaths = includeDirs.map((dirPath) => path.join(rootDir, dirPath));
  const absoluteProtoFiles = protoFiles.map((filePath) => path.join(rootDir, filePath));

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

module.exports = {
  loadProtoManifest,
  parseModuleName,
  readModuleName,
};
