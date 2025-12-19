#!/bin/sh
set -eu

# Run the project from the repo root (this script's directory).
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT_DIR"

exec zig build run
