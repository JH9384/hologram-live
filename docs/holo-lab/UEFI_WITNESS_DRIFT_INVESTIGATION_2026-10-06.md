# Hologram Core UEFI Witness Drift Investigation — 2026-10-06

Status: OPEN — ROOT CAUSE NOT YET PROVEN

## Observation

Hologram core commit `b6d9a76ca953610f9facfdefac0d0db0ece4d954` remained unchanged while its scheduled Release CI bare-metal witness changed outcome.

| Date | Release CI | UEFI job | Rust setup | Boot step |
|---|---:|---|---:|---:|
| 2026-10-01 | 36823146253 | PASS | ~2 s | ~7 s |
| 2026-10-02 | 36972062105 | FAIL | ~11 s | ~19 s |
| 2026-10-03 | 37102133543 | FAIL | — | — |
| 2026-10-04 | 37187436879 | FAIL | — | — |
| 2026-10-05 | 37271378042 | FAIL | — | — |
| 2026-10-06 | 37422042548 | FAIL | ~9 s | ~1 s |

The failure is isolated to `Bare-metal UEFI boot (QEMU/OVMF)` / `Boot hologram.efi and assert PASS`. Other inspected release-tier witnesses remain green, including Holospaces V&V, docs conformance, browser OPFS, fuzzing, and SDK/package jobs.

## Mutable inputs in the witness

The release workflow does not fully pin the witness environment:

- runner: `ubuntu-latest`;
- Rust action: `dtolnay/rust-toolchain@stable`;
- QEMU and OVMF: installed from live apt repositories without package-version pins;
- actions/checkout is release-tagged rather than immutable-SHA pinned.

The UEFI crate itself declares `rust-version = "1.94"`, but the workflow asks for the moving stable channel rather than a specific qualified compiler.

## Time-correlated external change

Rust 1.99.0 was released on 2026-10-01. Therefore the first scheduled run after the stable-channel transition is the first observed red run on 2026-10-02.

This is a correlation, not a root-cause conclusion.

GitHub's Ubuntu 24.04 runner image also received a 2026-10-04 image update that changed cached Rust 1.98.1 -> 1.99.0. That update is too late to explain the first red run on Oct 2, though it increases later environmental drift.

## Current hypothesis ranking

1. **Rust stable-channel drift (1.98.1 -> 1.99.0)** — HIGH priority to falsify. Exact temporal boundary aligns; workflow explicitly follows stable.
2. **QEMU/OVMF apt package drift** — PLAUSIBLE. Packages are live/unpinned.
3. **GitHub runner image drift** — CONTRIBUTING POSSIBILITY for later runs, but cannot explain Oct 2 by the Oct 4 image update alone.
4. **Hologram source regression** — LOW given identical source SHA across green/red boundary, but not logically impossible if nondeterminism or external build inputs interact with source.
5. **UEFI witness nondeterminism/timing** — PLAUSIBLE; the boot script suppresses QEMU exit status with `|| true` and only asserts on the PASS marker.
6. **Cache contamination** — PLAUSIBLE but secondary; the workflow uses a mutable cache key `substrate-uefi` and `cache-on-failure: true`.

## Diagnostic experiment prepared

Repository: `JH9384/hologram`  
Branch: `holo-lab/uefi-drift-diagnostic-2026-10-06`  
Diagnostic commit: `fc5e79831255114faf5391d5219c6e4df0f04ada`

The branch adds only `.github/workflows/holo-lab-uefi-drift.yml`; no product source is modified.

Matrix:

- explicit `ubuntu-24.04`;
- Rust 1.98.1;
- Rust 1.99.0;
- same QEMU/OVMF installation;
- record rustc/cargo/QEMU/OVMF/runner versions;
- build UEFI binary as a separate step;
- run the repository's exact `scripts/uefi-boot-test.sh`.

At time of this record, the branch push has not produced an Actions run. Treat the experiment as PREPARED / NOT EXECUTED, not failed.

## Falsification logic

If 1.98.1 passes and 1.99.0 fails:
- classify as toolchain compatibility regression or changed-codegen interaction;
- capture exact build/boot failure;
- pin the qualified Rust version in the witness;
- independently investigate whether Hologram should become compatible with 1.99;
- do not silently move the qualification baseline.

If both pass:
- Rust drift is not sufficient;
- next isolate QEMU/OVMF and runner image versions;
- run repeated trials to test nondeterminism/cache effects.

If both fail:
- compare with the Oct 1 green environment;
- inspect apt/firmware/QEMU and runner-image deltas;
- run with clean cache;
- verify whether the UEFI build itself or only boot fails.

If build succeeds but boot fails:
- focus on QEMU/OVMF/firmware/runtime behavior.

If build fails before QEMU:
- focus on Rust/compiler/linker/dependency behavior.

## Witness-quality defects exposed by the investigation

Regardless of root cause, the current witness is insufficiently reproducible for a release gate because important execution dependencies move independently of the source SHA.

A future repair should be evidence-driven but likely needs:

- explicit runner generation (`ubuntu-24.04`, not `ubuntu-latest`);
- explicit Rust version qualified by the project;
- recorded QEMU and OVMF versions;
- immutable SHA pins for GitHub Actions where practical;
- separate build and boot steps;
- upload of UEFI build/boot diagnostics on failure;
- preserve QEMU exit status instead of collapsing all non-PASS outcomes into one result;
- cache key including compiler/toolchain identity;
- a small environment manifest emitted by every release witness.

These are reproducibility/observability controls, not a proposed source-code repair.

## Qualification consequence

Until the diagnostic is executed and the witness is green under a controlled environment:

- Hologram Live qualification can continue at its pinned runtime boundary;
- current Hologram core head must remain OPEN/RED at the complete release-witness level;
- H0-H10 should not use the current core Release CI as blanket proof;
- no architecture claim should be withdrawn solely because this externalized witness is red;
- no bare-metal capability should be promoted to newly observed Holo Lab truth from the current run.

## Decision

Preserve the failure. Do not weaken or delete the witness. Make the environment deterministic enough that a future green result means the same thing tomorrow that it means today.
