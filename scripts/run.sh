#!/usr/bin/env bash
# Runs the artifact experiments. Usage: scripts/run.sh [smoke|table7|ppprt|baseline|all]
#   smoke     polyring test suite, no on-chain test               (~25 s)
#   table7    Table 7 re-measured on patched gnark, polyring      (~45 s)
#   ppprt     Table 7 "This Work" column as published, ppprt      (~1 min)
#   baseline  Table 7 baseline column, upstream gnark @ GNARK_REV (~2 min, clones gnark)
#   all       everything above (default)
# Output is printed and also saved under results/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/components.env"
RESULTS="$ROOT/results"
mkdir -p "$RESULTS"

BENCH=(go test -v -run '^$' -bench 'Groth16Simulation' -benchmem
  ./std/algebra/emulated/sw_bn254/ ./std/algebra/emulated/sw_bls12381/)

smoke() { (cd "$ROOT/polyring" && go test -short ./...) 2>&1 | tee "$RESULTS/smoke.txt"; }

table7() { (cd "$ROOT/polyring" && go test ./paper/ -run TestTable7 -v) 2>&1 | tee "$RESULTS/table7-polyring.txt"; }

ppprt() { (cd "$ROOT/ppprt" && "${BENCH[@]}") 2>&1 | tee "$RESULTS/table7-ppprt.txt"; }

# Same benchmark file on upstream gnark, plus ppprt's one-line commitment counter
# (ppprt commit 8ea4366, kept in patches/). See ppprt/README.md, "Baseline column".
baseline() {
  local dir="$ROOT/gnark-baseline"
  if [ ! -d "$dir/.git" ]; then
    git clone "$GNARK_URL" "$dir"
    git -C "$dir" checkout -q "$GNARK_REV"
    git -C "$dir" apply "$ROOT/patches/gnark-nb-commitments.patch"
    for c in sw_bn254 sw_bls12381; do
      cp "$ROOT/ppprt/std/algebra/emulated/$c/g16_simulation_test.go" "$dir/std/algebra/emulated/$c/"
    done
  fi
  (cd "$dir" && "${BENCH[@]}") 2>&1 | tee "$RESULTS/table7-baseline.txt"
}

case "${1:-all}" in
  smoke | table7 | ppprt | baseline) "$1" ;;
  all) smoke; table7; ppprt; baseline ;;
  *) sed -n '2,8p' "$0"; exit 1 ;;
esac
