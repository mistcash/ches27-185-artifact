#!/usr/bin/env bash
# Runs the artifact experiments. Usage: scripts/run.sh [smoke|table7|ppprt|baseline|summary|all]
#   smoke     polyring test suite, no on-chain test               (~25 s)
#   table7    Table 7 re-measured on patched gnark, polyring      (~45 s)
#   ppprt     Table 7 "This Work" column, ppprt at 2f9ffd0        (~2 min)
#   baseline  Table 7 baseline column, same tree, gnark's pairing (~2 min)
#   summary   benchstat of baseline vs ppprt: medians, spread, p-values
#   all       everything above (default)
# ppprt and baseline run each benchmark COUNT times (default 6, the fewest benchstat gives a spread for).
# Output is printed and also saved under results/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# ppprt commit Table 7 is measured at, and the upstream gnark its baseline pairing comes from.
PPPRT_REV=2f9ffd0
GNARK_REV=8e4363f1a60dc2febaa872fbda8847d78ce8cf48
RESULTS="$ROOT/results"
mkdir -p "$RESULTS"

BENCH=(go test -v -run '^$' -bench 'Groth16Simulation' -benchmem -count="${COUNT:-6}"
  ./std/algebra/emulated/sw_bn254/ ./std/algebra/emulated/sw_bls12381/)

smoke() { (cd "$ROOT/polyring" && go test -short ./...) 2>&1 | tee "$RESULTS/smoke.txt"; }

table7() { (cd "$ROOT/polyring" && go test ./paper/ -run TestTable7 -v) 2>&1 | tee "$RESULTS/table7-polyring.txt"; }

# Detached worktree of the ppprt submodule at PPPRT_REV (needs its git history), reused if present.
ppprt_tree() { [ -d "$1" ] || git -C "$ROOT/ppprt" worktree add -q --detach "$1" "$PPPRT_REV"; }

ppprt() { ppprt_tree "$ROOT/build/ppprt"; (cd "$ROOT/build/ppprt" && "${BENCH[@]}") 2>&1 | tee "$RESULTS/table7-ppprt.txt"; }

baseline() {
  local dir="$ROOT/build/baseline" e=std/algebra/emulated
  ppprt_tree "$dir"
  # gnark's pairing files from upstream GNARK_REV, and e12.go from ppprt 8ea4366.
  git -C "$dir" fetch -q --depth 1 https://github.com/Consensys/gnark "$GNARK_REV"
  git -C "$dir" checkout -q "$GNARK_REV" -- $e/sw_bn254/pairing.go $e/sw_bn254/hints.go $e/sw_bls12381/pairing.go
  git -C "$dir" checkout -q 8ea4366 -- $e/fields_bn254/e12.go $e/fields_bls12381/e12.go
  (cd "$dir" && "${BENCH[@]}") 2>&1 | tee "$RESULTS/table7-baseline.txt"
}

summary() {
  go run golang.org/x/perf/cmd/benchstat@v0.0.0-20261117185222-4febdb082b2c \
    baseline="$RESULTS/table7-baseline.txt" ppprt="$RESULTS/table7-ppprt.txt" | tee "$RESULTS/table7-summary.txt"
}

case "${1:-all}" in
  smoke | table7 | ppprt | baseline | summary) "$1" ;;
  all) smoke; table7; ppprt; baseline; summary ;;
  *) sed -n '2,10p' "$0"; exit 1 ;;
esac
