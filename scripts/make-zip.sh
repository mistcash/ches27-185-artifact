#!/usr/bin/env bash
# Builds dist/ches27-185-artifact.zip: this repo plus the polyring and ppprt
# submodules at their pinned commits, with no git or GitHub metadata.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME=ches27-185-artifact
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

cd "$ROOT"
git submodule update --init
# Tracked files only, so local build output, results/ and gnark-baseline/ stay out.
git ls-files --recurse-submodules -z | tar --null -T - -cf - | (mkdir "$STAGE/$NAME" && tar -xf - -C "$STAGE/$NAME")

cd "$STAGE/$NAME"
find . \( -name .git -o -name .github -o -name .gitmodules -o -name .gitignore -o -name .gitattributes -o -name .gitlint \) -prune -exec rm -rf {} +
# Of polyring's website source (docs/), keep only the PDF booklet.
find polyring/docs -mindepth 1 ! -name polyring-toolkit.pdf -delete

mkdir -p "$ROOT/dist"
rm -f "$ROOT/dist/$NAME.zip"
(cd "$STAGE" && zip -qr "$ROOT/dist/$NAME.zip" "$NAME")
du -h "$ROOT/dist/$NAME.zip"
