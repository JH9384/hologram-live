# Holo Lab H0 — Target-Mac Host Baseline

Status: READY FOR LOCAL EXECUTION  
Qualification target: `JH9384/hologram-live @ cbbf97b5b8199f5701c621cd3ba0b26187417ffa`

## Purpose

H0 records the target Mac as it exists before Hologram qualification changes it. It is observation only.

H0 does **not** install packages, change FileVault, move files, start Hologram, build the repository, download models, or contact hosted inference providers.

## Run

From the Hologram Live qualification checkout:

```bash
git fetch origin
git checkout holo-lab/qualification-2026-10-06
git status --short
./scripts/holo-lab-h0-baseline.sh
```

The collector writes a timestamped local record under:

```text
.holo-lab/evidence/
```

That directory is Git-ignored. The collector prints the evidence file's SHA-256.

Raw H0 evidence is **LOCAL ONLY / DO NOT COMMIT** because it contains the absolute local repository path and may identify local cloud-storage provider directories. The collector intentionally does not record the Mac serial number or hardware UUID.

## H0 observations

The record captures:

- local and UTC time;
- macOS product/version/build;
- architecture and Mac model identifier;
- CPU/chip/core and GPU summary;
- RAM;
- free disk for the qualification workspace;
- Rust/Cargo;
- Node/npm;
- Git;
- repository absolute path, origin, HEAD, branch, and worktree status;
- FileVault status;
- whether the repository path matches common macOS cloud-sync roots.

## Cloud-sync interpretation

`NO_KNOWN_SYNC_ROOT_MATCH` means the repository path does not match the common iCloud Drive or `~/Library/CloudStorage` roots tested by the collector. It is evidence, not proof that no third-party synchronization software exists.

`SYNC_ROOT_MATCH` blocks H0 until the evidence/work directory is deliberately relocated or the trust-boundary decision is documented.

`MANUAL_CONFIRMATION_REQUIRED` is emitted for `~/Desktop` or `~/Documents`, because those directories may or may not be synchronized by iCloud depending on host settings. Do not infer the answer.

## Pass condition

H0 PASS requires:

1. host identity fields are observed;
2. workspace free space is observed;
3. required tool presence/absence is observed rather than guessed;
4. FileVault status is observed;
5. repository absolute path is known;
6. no unresolved cloud-sync ambiguity exists for the repository/evidence workspace.

Missing Node/npm does not itself fail H0; it is a recorded prerequisite finding if Desktop qualification will be attempted later. A mismatched Rust version also does not fail H0; H1 is responsible for using the repository-declared Rust 1.97.1 toolchain.

## Handoff into H1

Do not begin H1 until H0 is dispositioned PASS.

For the campaign record, retain locally:

- H0 evidence filename;
- its SHA-256;
- H0 PASS/FAIL;
- any sanitized finding IDs.

Do not paste or commit the raw H0 record unless it has first been reviewed for local-path or provider-identifying information.
