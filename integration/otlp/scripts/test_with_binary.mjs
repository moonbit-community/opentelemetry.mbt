#!/usr/bin/env node

import fs from "node:fs";
import net from "node:net";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { spawn, spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { once } from "node:events";

/**
 * Runs the OTLP integration packages against a locally installed `otelcol`.
 *
 * The script generates a temporary collector config that points file exporters
 * at `integration/otlp/actual`, waits for the local collector to start, runs
 * the selected MoonBit packages sequentially, and then shuts everything down.
 */

/**
 * @typedef {object} RunCheckedOptions
 * @property {boolean} [captureOutput] When true, collect stdout/stderr for the caller.
 * @property {string} [cwd] Working directory for the child process.
 * @property {NodeJS.ProcessEnv} [env] Environment variables for the child process.
 */

// Resolve script-local paths so the runner works no matter where it is invoked from.
const __filename = fileURLToPath(import.meta.url);
const scriptDir = path.dirname(__filename);
const moduleRoot = path.resolve(scriptDir, "..");

const validPackages = new Set(["traces", "logs", "metrics", "fullstack"]);
const packages = process.argv.slice(2);
const selectedPackages =
  packages.length === 0 ? ["traces", "logs", "metrics", "fullstack"] : packages;

for (const pkg of selectedPackages) {
  if (!validPackages.has(pkg)) {
    console.error(`unknown package: ${pkg}`);
    process.exit(1);
  }
}

const moonBin = process.env.MOON_BIN ?? "moon";
const otelcolVersion = process.env.OTELCOL_VERSION ?? "0.150.1";
const otelcolDir =
  process.env.OTELCOL_DIR ??
  path.join(process.env.HOME ?? "", ".local", "opt", "otelcol", otelcolVersion);
const otelcolBin = process.env.OTELCOL_BIN ?? path.join(otelcolDir, "otelcol");
const collectorHost = process.env.OTELCOL_HOST ?? "127.0.0.1";
const collectorPort = Number.parseInt(process.env.OTELCOL_PORT ?? "43181", 10);

if (!Number.isInteger(collectorPort) || collectorPort <= 0) {
  console.error(
    `invalid OTELCOL_PORT: ${process.env.OTELCOL_PORT ?? "<unset>"}`,
  );
  process.exit(1);
}

// The collector writes one file per signal; truncate them before each package.
const actualDir = path.join(moduleRoot, "actual");
const tracesFile = path.join(actualDir, "traces.json");
const logsFile = path.join(actualDir, "logs.json");
const metricsFile = path.join(actualDir, "metrics.json");

fs.mkdirSync(actualDir, { recursive: true });
for (const filePath of [tracesFile, logsFile, metricsFile]) {
  fs.writeFileSync(filePath, "");
  fs.chmodSync(filePath, 0o666);
}

// A temporary config keeps the local runner self-contained and host-specific.
const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "otelcol-mbt-"));
const configPath = path.join(tempDir, "otelcol-local.yaml");

fs.writeFileSync(
  configPath,
  [
    "receivers:",
    "  otlp:",
    "    protocols:",
    "      http:",
    `        endpoint: ${collectorHost}:${collectorPort}`,
    "",
    "exporters:",
    "  file/traces:",
    `    path: ${tracesFile}`,
    "  file/logs:",
    `    path: ${logsFile}`,
    "    rotation:",
    "  file/metrics:",
    `    path: ${metricsFile}`,
    "",
    "service:",
    "  pipelines:",
    "    traces:",
    "      receivers: [otlp]",
    "      exporters: [file/traces]",
    "    logs:",
    "      receivers: [otlp]",
    "      exporters: [file/logs]",
    "    metrics:",
    "      receivers: [otlp]",
    "      exporters: [file/metrics]",
    "",
  ].join("\n"),
);

let collector = null;
let collectorExited = null;
let collectorLogs = "";
let cleanedUp = false;

/**
 * Runs a child process and throws when it exits unsuccessfully.
 *
 * @param {string} command
 * @param {string[]} args
 * @param {RunCheckedOptions} [options]
 * @returns {import("node:child_process").SpawnSyncReturns<string>}
 */
function runChecked(command, args, options = {}) {
  const result = spawnSync(command, args, {
    stdio: options.captureOutput ? ["inherit", "pipe", "pipe"] : "inherit",
    cwd: options.cwd,
    env: options.env,
    encoding: "utf8",
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    const error = new Error(`${command} exited with code ${result.status}`);
    error.status = result.status;
    error.stdout = result.stdout ?? "";
    error.stderr = result.stderr ?? "";
    throw error;
  }
  return result;
}

/**
 * Appends collector stdout/stderr into one buffer so failures can print the whole trace.
 *
 * @param {"stdout" | "stderr"} prefix
 * @param {Buffer | string} chunk
 */
function appendCollectorLog(prefix, chunk) {
  collectorLogs += `[${prefix}] ${chunk.toString()}`;
}

/**
 * Clears only the output files that the next package is expected to touch.
 *
 * @param {"traces" | "logs" | "metrics" | "fullstack"} pkg
 */
function resetOutputForPackage(pkg) {
  switch (pkg) {
    case "traces":
      fs.writeFileSync(tracesFile, "");
      break;
    case "logs":
      fs.writeFileSync(logsFile, "");
      break;
    case "metrics":
      fs.writeFileSync(metricsFile, "");
      break;
    case "fullstack":
      fs.writeFileSync(tracesFile, "");
      fs.writeFileSync(logsFile, "");
      fs.writeFileSync(metricsFile, "");
      break;
    default:
      throw new Error(`unknown package: ${pkg}`);
  }
}

/**
 * @param {number} millis
 * @returns {Promise<void>}
 */
async function sleep(millis) {
  await new Promise(resolve => setTimeout(resolve, millis));
}

/**
 * Polls until the collector's OTLP HTTP port starts accepting TCP connections.
 *
 * Stops early if the collector process exits while the script is waiting.
 *
 * @param {string} host
 * @param {number} port
 * @param {number} [attempts=120]
 * @param {number} [sleepMillis=250]
 * @returns {Promise<boolean>}
 */
async function waitForPort(host, port, attempts = 120, sleepMillis = 250) {
  for (let index = 0; index < attempts; index++) {
    if (collectorExited !== null) {
      return false;
    }
    const ready = await new Promise(resolve => {
      const socket = net.createConnection({ host, port });
      let settled = false;
      const finish = result => {
        if (!settled) {
          settled = true;
          socket.destroy();
          resolve(result);
        }
      };
      socket.once("connect", () => finish(true));
      socket.once("error", () => finish(false));
      socket.setTimeout(sleepMillis, () => finish(false));
    });
    if (ready) {
      return true;
    }
    await sleep(sleepMillis);
  }
  return false;
}

/**
 * Stops the collector gracefully, then escalates to SIGKILL if it does not exit.
 *
 * @returns {Promise<void>}
 */
async function stopCollector() {
  if (collector === null || collector.exitCode !== null || collector.killed) {
    return;
  }
  collector.kill("SIGINT");
  const exited = await Promise.race([
    once(collector, "exit").then(() => true),
    sleep(5000).then(() => false),
  ]);
  if (!exited && collector.exitCode === null) {
    collector.kill("SIGKILL");
    await once(collector, "exit");
  }
}

/**
 * Removes the temporary collector config directory exactly once.
 */
function cleanupTempDir() {
  if (cleanedUp) {
    return;
  }
  cleanedUp = true;
  fs.rmSync(tempDir, { recursive: true, force: true });
}

process.on("exit", cleanupTempDir);
for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"]) {
  process.on(signal, () => {
    void stopCollector().finally(() => {
      cleanupTempDir();
      process.exit(1);
    });
  });
}

try {
  // Verify the requested otelcol binary is executable before starting any tests.
  runChecked(otelcolBin, ["--version"], { captureOutput: true });

  // Start one collector process for the whole run and capture its logs for failures.
  collector = spawn(otelcolBin, ["--config", configPath], {
    cwd: moduleRoot,
    env: process.env,
    stdio: ["ignore", "pipe", "pipe"],
  });
  collector.stdout.on("data", chunk => appendCollectorLog("stdout", chunk));
  collector.stderr.on("data", chunk => appendCollectorLog("stderr", chunk));
  collector.once("exit", (code, signal) => {
    collectorExited = { code, signal };
  });

  const ready = await waitForPort(collectorHost, collectorPort);
  if (!ready) {
    console.error(
      `collector did not become ready on ${collectorHost}:${collectorPort}`,
    );
    if (collectorExited !== null) {
      console.error(
        `collector exited early: code=${collectorExited.code} signal=${collectorExited.signal}`,
      );
    }
    if (collectorLogs.trim() !== "") {
      process.stderr.write(collectorLogs);
    }
    process.exit(1);
  }

  // Point all OTLP exporters in the MoonBit tests at the local collector endpoint.
  const testEnv = {
    ...process.env,
    OTEL_EXPORTER_OTLP_ENDPOINT: `http://${collectorHost}:${collectorPort}`,
  };

  for (const pkg of selectedPackages) {
    if (collectorExited !== null) {
      throw new Error(
        `collector exited before running ${pkg}: code=${collectorExited.code} signal=${collectorExited.signal}`,
      );
    }
    resetOutputForPackage(pkg);
    console.log(`==> moon test ${pkg}`);
    runChecked(
      moonBin,
      ["test", "--no-parallelize", pkg],
      { cwd: moduleRoot, env: testEnv },
    );
  }

  console.log("OTLP integration tests passed.");
} catch (error) {
  if (error.stdout) {
    process.stdout.write(error.stdout);
  }
  if (error.stderr) {
    process.stderr.write(error.stderr);
  }
  if (collectorLogs.trim() !== "") {
    process.stderr.write(collectorLogs);
  }
  if (error?.code === "ENOENT") {
    console.error(`failed to execute command: ${error.path ?? "unknown"}`);
  } else if (error instanceof Error) {
    console.error(error.message);
  } else {
    console.error(String(error));
  }
  process.exitCode = 1;
} finally {
  await stopCollector();
  cleanupTempDir();
}
