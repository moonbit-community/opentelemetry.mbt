#!/usr/bin/env node

import fs from "node:fs";
import net from "node:net";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

/**
 * Runs the OTLP integration packages against one Collector container.
 *
 * The script starts a container with the repository's collector config, rewires
 * the exported OTLP endpoint to the mapped host port, runs the selected MoonBit
 * test packages sequentially, and always tears the container down on exit.
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
const selectedPackages = packages.length === 0 ? ["traces", "logs", "metrics", "fullstack"] : packages;

for (const pkg of selectedPackages) {
  if (!validPackages.has(pkg)) {
    console.error(`unknown package: ${pkg}`);
    process.exit(1);
  }
}

const collectorImage =
  process.env.OTEL_COLLECTOR_IMAGE ??
  "ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector:0.150.1";
const dockerBin = process.env.DOCKER_BIN ?? "docker";
const moonBin = process.env.MOON_BIN ?? "moon";

// The collector writes one file per signal; truncate them before each package.
const actualDir = path.join(moduleRoot, "actual");
const configPath = path.join(moduleRoot, "otel-collector-config.yaml");
const tracesFile = path.join(actualDir, "traces.json");
const logsFile = path.join(actualDir, "logs.json");
const metricsFile = path.join(actualDir, "metrics.json");

fs.mkdirSync(actualDir, { recursive: true });
for (const filePath of [tracesFile, logsFile, metricsFile]) {
  fs.writeFileSync(filePath, "");
  fs.chmodSync(filePath, 0o666);
}

let containerId = "";
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
 * Removes the collector container exactly once.
 */
function cleanup() {
  if (cleanedUp) {
    return;
  }
  cleanedUp = true;
  if (containerId !== "") {
    spawnSync(dockerBin, ["rm", "-f", containerId], {
      stdio: "ignore",
      encoding: "utf8",
    });
  }
}

/**
 * Polls until the collector's mapped OTLP HTTP port starts accepting TCP connections.
 *
 * @param {string} host
 * @param {number} port
 * @param {number} [attempts=120]
 * @param {number} [sleepMillis=250]
 * @returns {Promise<boolean>}
 */
async function waitForPort(host, port, attempts = 120, sleepMillis = 250) {
  for (let index = 0; index < attempts; index++) {
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
    await new Promise(resolve => setTimeout(resolve, sleepMillis));
  }
  return false;
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

process.on("exit", cleanup);
for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"]) {
  process.on(signal, () => {
    cleanup();
    process.exit(1);
  });
}

try {
  // Start the collector with random host port mapping and bind the result files.
  const runResult = runChecked(
    dockerBin,
    [
      "run",
      "-d",
      "--rm",
      "-P",
      "-v",
      `${configPath}:/etc/otelcol/config.yaml:ro`,
      "-v",
      `${tracesFile}:/testresults/traces.json`,
      "-v",
      `${logsFile}:/testresults/logs.json`,
      "-v",
      `${metricsFile}:/testresults/metrics.json`,
      collectorImage,
      "--config=/etc/otelcol/config.yaml",
    ],
    { captureOutput: true },
  );
  containerId = runResult.stdout.trim();

  // Discover which host port Docker mapped to container port 4318.
  const portResult = runChecked(
    dockerBin,
    ["port", containerId, "4318/tcp"],
    { captureOutput: true },
  );
  const lines = portResult.stdout
    .split("\n")
    .map(line => line.trim())
    .filter(line => line !== "");
  const lastLine = lines.at(-1) ?? "";
  const httpPortText = lastLine.includes(":") ? lastLine.split(":").at(-1) : "";
  if (httpPortText === "") {
    console.error("failed to discover collector OTLP HTTP port");
    process.exit(1);
  }
  const httpPort = Number.parseInt(httpPortText, 10);
  if (!Number.isInteger(httpPort) || httpPort <= 0) {
    console.error(`invalid collector OTLP HTTP port: ${httpPortText}`);
    process.exit(1);
  }

  const ready = await waitForPort("127.0.0.1", httpPort);
  if (!ready) {
    console.error(`collector did not become ready on port ${httpPort}`);
    spawnSync(dockerBin, ["logs", containerId], { stdio: "inherit", encoding: "utf8" });
    process.exit(1);
  }

  // Point all OTLP exporters in the MoonBit tests at the mapped collector endpoint.
  const testEnv = {
    ...process.env,
    OTEL_EXPORTER_OTLP_ENDPOINT: `http://127.0.0.1:${httpPort}`,
  };

  for (const pkg of selectedPackages) {
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
  if (error?.code === "ENOENT") {
    console.error(`failed to execute command: ${error.path ?? "unknown"}`);
  } else if (error instanceof Error) {
    console.error(error.message);
  } else {
    console.error(String(error));
  }
  process.exitCode = 1;
} finally {
  cleanup();
}
