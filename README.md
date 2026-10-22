# Artifact: Pairing Proofs and Polynomial Ring Toolkit

> Shramee Srivastav (MIST.cash, Singapore). *Pairing Proofs and Polynomial Ring Toolkit.*
> IACR TCHES, Volume 2027, Issue 1, paper #185. [paper.pdf](paper.pdf) · shramee@proton.me

The paper's main measured result is Table 7: a 32–36% constraint reduction for a three-pair pairing check in gnark, on BN254 and BLS12-381, for both SCS and R1CS.

## Contents

| Path | What | Read |
|---|---|---|
| `ppprt/` | The gnark fork the paper was measured on. Frozen, to reproduce Table 7 as published. Not sound: it predates two gnark security fixes. | [ppprt/README.md](ppprt/README.md) |
| `polyring/` | The maintained implementation on patched gnark. Re-measures Table 7, maps paper sections to code. | [polyring/paper/ARTIFACT.md](polyring/paper/ARTIFACT.md), then [polyring/README.md](polyring/README.md) |
| `scripts/run.sh` | Runs all experiments, saves output to `results/` | |
| `scripts/make-zip.sh` | Builds `dist/ches27-185-artifact.zip` without git/GitHub files | |
| `patches/` | ppprt's commitment counter, applied to upstream gnark for the baseline | |

Both repositories are git submodules at pinned commits (`git submodule update --init`). The zip already includes them.

Table 6 (Cairo) was measured in [Garaga](https://github.com/keep-starknet-strange/garaga) and is not part of this artifact.

## Requirements

Go 1.26.8, git, bash. Network access on the first run, for Go modules and the baseline's gnark clone. Any 64-bit machine with ≥ 8 GB RAM; the reference machine is an Apple M3 Pro.

## Run

```sh
scripts/run.sh            # everything, ~5 min
scripts/run.sh ppprt      # Table 7 "This Work", as published     ~1 min
scripts/run.sh baseline   # Table 7 baseline, upstream gnark        ~2 min
scripts/run.sh table7     # Table 7 on patched gnark (polyring)     ~45 s
scripts/run.sh smoke      # polyring test suite                     ~25 s
```

## Expected output

| Command | Paper | Expected |
|---|---|---|
| `ppprt` | Table 7, "This Work" | `nb constraints` 1,035,645 SCS / 316,181 R1CS (BN254), 1,191,256 / 368,461 (BLS12-381): within 0.02% of the paper |
| `baseline` | Table 7, baseline | 1,604,279 / 495,810 (BN254), 1,779,202 / 542,925 (BLS12-381): within 1% of the paper |
| `table7` | Table 7 on patched gnark | Full table printed, gnark vs polyring; fails if any count drifts |
| `smoke` | correctness | every package `ok` |

How to read each output line: [ppprt/README.md](ppprt/README.md#reading-the-output). Why the patched numbers differ from the paper: [polyring/paper/ARTIFACT.md](polyring/paper/ARTIFACT.md#why-the-numbers-move).

Constraint counts are exact. Times and memory move ~20% between runs and machines, so compare reductions rather than absolute values.

## Licence

Apache-2.0 ([LICENSE](LICENSE)), as are both components.
