# Artifact: Pairing Proofs and Polynomial Ring Toolkit

Artifact for:

> Shramee Srivastav (MIST.cash, Singapore). *Pairing Proofs and Polynomial Ring Toolkit.*
> IACR Transactions on Cryptographic Hardware and Embedded Systems (TCHES), Volume 2027, Issue 1. Paper #185.
> Paper: [paper.pdf](paper.pdf) · Contact: shramee@proton.me

The paper turns the Miller loop and final exponentiation of a pairing check into polynomial identities over 𝔽q[x], verified with a two-round public-coin protocol. Its main measured result (Table 7) is a 32–36% constraint reduction on a three-pair pairing check in gnark, on BN254 and BLS12-381, for both SCS (Plonkish) and R1CS.

## What is in here

| Path | What | Start with |
|---|---|---|
| [`ppprt/`](ppprt) | The gnark fork the paper's numbers were measured on. **Frozen** so Table 7 reproduces as published. Not sound: it predates two gnark security fixes. | [ppprt/README.md](ppprt/README.md), section "Reproducing Table 7" |
| [`polyring/`](polyring) | The maintained implementation: a standalone Go module on patched gnark, with a recursive Groth16 verifier and a Solidity verifier. Re-measures Table 7 on sound gnark. | [polyring/paper/ARTIFACT.md](polyring/paper/ARTIFACT.md) (paper to code mapping, all numbers), then [polyring/README.md](polyring/README.md) |
| [`scripts/run.sh`](scripts/run.sh) | Runs every experiment below and saves output to `results/` | — |
| [`scripts/make-zip.sh`](scripts/make-zip.sh) | Builds the submission zip, without git or GitHub files | — |
| [`components.env`](components.env) | Pinned commits of every component | — |
| [`Dockerfile`](Dockerfile) | Optional clean environment with the pinned toolchain | — |

Both repositories are git submodules at the pinned commits (`git clone --recurse-submodules`, or `git submodule update --init`). The zip already contains them.

Which one to read for what:

- **Reproduce the paper's Table 7 exactly:** `ppprt`. See [ppprt/README.md](ppprt/README.md).
- **Map the paper's sections to code, see how the numbers moved after gnark's fixes:** [polyring/paper/ARTIFACT.md](polyring/paper/ARTIFACT.md).
- **Use or extend the technique:** `polyring`. See [polyring/README.md](polyring/README.md) and the glossary in [polyring/CONTEXT.md](polyring/CONTEXT.md).
- **Table 6 (Cairo / Garaga):** measured in [Garaga](https://github.com/keep-starknet-strange/garaga). Not part of this artifact.

## Requirements

- Go 1.26.8 (pinned in [polyring/go.mod](polyring/go.mod); ppprt needs ≥ 1.25.7). Go fetches every other dependency on the first build, so network access is needed once.
- git, bash.
- Optional: `solc` 0.8.24+ for polyring's on-chain test (skipped without it), Docker.
- Hardware: any recent 64-bit machine with ≥ 8 GB RAM. The reference numbers come from an Apple M3 Pro (36 GB).

## Running

```sh
scripts/run.sh            # everything, ~5 min after the first build
scripts/run.sh smoke      # polyring test suite                              ~25 s
scripts/run.sh table7     # Table 7 on patched gnark (polyring)              ~45 s
scripts/run.sh ppprt      # Table 7 "This Work" column as published (ppprt)  ~1 min
scripts/run.sh baseline   # Table 7 baseline column: clones upstream gnark   ~2 min
```

Or in Docker: `docker build -t ches27-185 . && docker run --rm ches27-185 table7`.

## Reading the output

| Command | Paper result | Expected |
|---|---|---|
| `ppprt` | Table 7, "This Work" | BN254: 1,035,645 SCS / 316,181 R1CS constraints. BLS12-381: 1,191,256 / 368,461. Within 0.02% of the paper. How to read each line: [ppprt/README.md](ppprt/README.md), "Reading the output". |
| `baseline` | Table 7, baseline | Within 1% of the paper (upstream gnark moved before ppprt's last merge). The paper's raw baseline output is kept verbatim at the bottom of each `g16_simulation_test.go`. |
| `table7` | Table 7 on sound gnark | Prints the full table, gnark against polyring, and **fails if any constraint count moves**. Reductions are 2.0–3.6 points better than the paper's. Expected table: [polyring/paper/ARTIFACT.md](polyring/paper/ARTIFACT.md), "Table 7 on patched gnark". |
| `smoke` | Correctness | All packages `ok`. |

Constraint and committed-variable counts are exact. Times and memory are single runs and move by 20% or so between runs and machines; compare reduction percentages, not absolute values.

## Licence

Apache-2.0 ([LICENSE](LICENSE)) for this repository and both components (`ppprt` inherits gnark's Apache-2.0). The IACR may redistribute the artifact under it.
