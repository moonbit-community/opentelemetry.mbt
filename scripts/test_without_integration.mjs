#!/usr/bin/env node

import path from "node:path";
import process from "node:process";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const moduleRoot = path.resolve(scriptDir, "..");

const gitResult = spawnSync(
  "git",
  ["ls-files", "-z", "--", "moon.pkg", "*/moon.pkg"],
  { cwd: moduleRoot, encoding: "utf8" },
);

if (gitResult.error) {
  console.error(`failed to list MoonBit packages: ${gitResult.error.message}`);
  process.exit(1);
}
if (gitResult.status !== 0) {
  process.stderr.write(gitResult.stderr);
  process.exit(gitResult.status ?? 1);
}

const packages = gitResult.stdout
  .split("\0")
  .filter(manifest => manifest !== "" && !manifest.startsWith("integration/"))
  .map(manifest => (manifest === "moon.pkg" ? "." : path.posix.dirname(manifest)));

if (packages.length === 0) {
  console.error("no non-integration MoonBit packages found");
  process.exit(1);
}

const targets = ["wasm", "native"];
let failed = false;
for (const target of targets) {
  console.log(
    `Running ${target} tests in ${packages.length} non-integration packages.`,
  );
  const moonResult = spawnSync(
    process.env.MOON_BIN ?? "moon",
    ["test", "--target", target, ...process.argv.slice(2), ...packages],
    { cwd: moduleRoot, stdio: "inherit" },
  );

  if (moonResult.error) {
    console.error(`failed to run moon test: ${moonResult.error.message}`);
    process.exit(1);
  }
  if (moonResult.status !== 0) {
    failed = true;
  }
}
process.exit(failed ? 1 : 0);
