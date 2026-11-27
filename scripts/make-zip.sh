#!/usr/bin/env bash
# Builds dist/ches27-185-artifact.zip: this repo plus the polyring and ppprt
# submodules at their pinned commits, with full git history.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME=ches27-185-artifact
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

git clone -q --single-branch --recurse-submodules "$ROOT" "$STAGE/$NAME"
git -C "$STAGE/$NAME" remote set-url origin https://github.com/mistcash/ches27-185-artifact

mkdir -p "$ROOT/dist"
rm -f "$ROOT/dist/$NAME.zip"
(cd "$STAGE" && zip -qr "$ROOT/dist/$NAME.zip" "$NAME")
du -h "$ROOT/dist/$NAME.zip"
