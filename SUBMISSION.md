# HotCRP submission fields

Paste into https://submit.iacr.org/ches27artifacts/. Not part of the artifact itself.

**Title:** Pairing Proofs and Polynomial Ring Toolkit

**Authors and affiliations:** Shramee Srivastav, MIST.cash, Singapore

**Contact email:** shramee@proton.me

**Paper PDF:** `paper.pdf` (camera-ready)

**Abstract:**

Elliptic curve pairings are fundamental to modern zero-knowledge proof systems, including Groth16, PLONK, and KZG polynomial commitments. In resource-constrained execution environments (Ethereum VM, BitVM, blockchain smart contracts), where computation is metered by gas fees, and in arithmetized computation systems (R1CS, Plonkish, Cairo AIR), where each computational step imposes significant prover overhead, the cost of pairing computation remains a practical bottleneck.

We present a public-coin interactive proof system that consolidates the Miller loop iterations and final exponentiation into a single polynomial relation. The relation can then be verified as polynomial identities, greatly reducing the pairing costs.

We present a full implementation in gnark (the industry-standard framework for arithmetized circuit development) as a reusable polynomial ring toolkit in the `emulated` package. Benchmarked on a 3-pairing product check (the pairing workload of a Groth16 verification), our gnark implementation achieves over 32% reduction in constraints, over 50% reduction in committed elements, and reductions in both compile-time and solver memory for both BN254 and BLS12-381 curves. This enables practical pairing verification in recursive proof systems and resource-constrained environments.

**Brief description of the artifact:**

Go source code for the paper's gnark implementation, in two pinned repositories. `ppprt` is the frozen gnark fork the paper was measured on and reproduces Table 7 as published (both curves, SCS and R1CS), together with a script that rebuilds the upstream-gnark baseline column. `polyring` is the maintained standalone module: the same technique on gnark with two later upstream security fixes, a recursive Groth16 verifier and a Solidity verifier. It includes a test that re-measures Table 7 on patched gnark and fails if any constraint count drifts. One script (`scripts/run.sh`) runs all experiments in about 5 minutes on a laptop; it needs only Go 1.26.8. A Dockerfile is included. Table 6 (Cairo) was measured in Garaga and is out of scope.

**Archive:** `dist/ches27-185-artifact.zip` (built by `scripts/make-zip.sh`)

**Repository:** https://github.com/mistcash/polyring @ `673387a412724cbd7d7695d8ae01a5619656c66c` and https://github.com/mistcash/ppprt @ `5d8353cbc9fff4a7f949e3698a86dc27193e9e44`
