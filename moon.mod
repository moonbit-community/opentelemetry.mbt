name = "moonbit-community/opentelemetry"

version = "0.1.4"

import {
  "moonbitlang/async@0.17.1",
  "moonbitlang/protobuf@0.1.1",
}

readme = "README.mbt.md"

repository = "https://github.com/moonbit-community/opentelemetry.mbt"

license = "Apache-2.0"

keywords = [ ]

description = "The MoonBit implementation of OpenTelemetry."

preferred_target = "native"

options(
  exclude: [ "integration" ],
)
