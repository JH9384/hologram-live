# Holo Lab Qualification Baseline — 2026-10-06

Status: FROZEN QUALIFICATION BASELINE  
Purpose: establish an evidence-first Hologram ecosystem baseline before integration, adoption, or performance claims.  
Doctrine: Claim -> Specification -> Executable -> Observed.

This branch is a qualification overlay for JH9384. It is not an upstream product branch and is not intended to alter Hologram architecture.

## 1. Governing rules

1. Qualification precedes integration.
2. SERP and UAR remain independent systems. Holo Lab tests interfaces; it does not merge their codebases.
3. No modeled, formal, synthetic, or documentation claim is promoted to Observed Truth without reproduction on the target Mac.
4. Preserve failures. Do not weaken gates to make a scenario pass.
5. Prefer the smallest experiment that can falsify a claim.
6. Record exact repository commit, dependency revision, host/runtime version, command, result, and evidence hash for each material run.
7. A dependency's canonical source, compatibility fork, vendored copy, and runtime-resolved revision are distinct provenance facts.
8. No performance claim is accepted solely because it is asserted in a report or encoded as a constant/cost model.

## 2. Ecosystem provenance manifest

Observed on 2026-10-06.

| Component | Role | Baseline source | Baseline revision | Qualification disposition |
|---|---|---|---|---|
| Hologram | execution substrate | JH9384/hologram, fork of Hologram-Technologies/hologram | b6d9a76ca953610f9facfdefac0d0db0ece4d954 | ADOPT experimentally |
| Hologram Live | operational host | JH9384/hologram-live, fork of Hologram-Technologies/hologram-live | cbbf97b5b8199f5701c621cd3ba0b26187417ffa | PRIMARY QUALIFICATION TARGET |
| Hologram AI | model/import/inference experiments | JH9384/hologram-ai, fork of Hologram-Technologies/hologram-ai | d5337ec2b3289fc8462abac2e627d165342079b2 | OBSERVE / REPRODUCE |
| Holospaces | historical/transition architecture | JH9384/holospaces | fd744fd3931ca92b052885fbe53bfad94eb7884f | REFERENCE |
| Hologram Storage | temporal CAS / graph store | JH9384/hologram-storage | ae71f47cc27bc30aa5e2d75621ebc5860beb8436 | EXPERIMENT |
| Hologram OS | product/interaction surface | JH9384/hologram-os, default branch home | 51c01932ddcdc500111abaa0e238bcc3be173249 | OBSERVE |
| Hologram Apps | heterogeneous workload corpus | JH9384/hologram-apps | 921dbc0fcd17d2ae68b2908b8f9a369de6a09297 | WORKLOAD CORPUS |
| Prism | UOR standard-library layer | UOR-Foundation/prism | 507995bab43c0cb06ec244c96e6fc25b3f502204 | CANONICAL REFERENCE |
| Kappa Registry | sovereign object fabric | UOR-Foundation/kappa-registry | 2af86560a177fc9651b6c0e92e7974140ed77dd5 | CANONICAL REFERENCE |

### Hologram Live resolved substrate

Hologram Live 1.0.0 does not resolve Hologram from the current Hologram repository head. Its Cargo manifest pins:

- source: Hologram-Technologies/hologram
- revision: 2bda6a9a9476872dade705bd61ece4209607f6da
- features: archive, space
- default features: disabled

This is an explicit historical runtime dependency and must be recorded separately from the current Hologram repository head.

### Prism compatibility lane

Hologram Live patches uor-prism-crypto from:

- source: Hologram-Technologies/prism
- branch: relax-blake3-pin
- observed branch revision: 02be04831cf71db6a665472c7419addfcc551432
- reason documented in Cargo.toml: relax the Prism blake3 cap for downstream compatibility.

Canonical Prism remains UOR-Foundation/prism at 507995bab43c0cb06ec244c96e6fc25b3f502204. The compatibility branch is not to be confused with canonical Prism main.

### Kappa vendoring lane

Hologram Live vendors kappa-core and kappa-store-redb under third_party/kappa.

The vendoring record states:

- canonical upstream: UOR-Foundation/kappa-registry
- canonical base revision: 2af86560a177fc9651b6c0e92e7974140ed77dd5
- compatibility source: Hologram-Technologies/kappa-registry @ c7b2ee722cfad39bfe486af0f5f37646bccc68f5
- six carried patches are stored as patch files
- VENDORED.sha256 records the vendored file set
- dcbor is separately vendored at 2e5b901e8c9946794c5491cf92eeec2540b84261

This is strong provenance, but the carried patch behavior still requires local qualification.

### Repository validation observations

For Hologram Live commit cbbf97b5b8199f5701c621cd3ba0b26187417ffa:

- upstream `gates-nightly` completed successfully on 2026-10-06 (run 37404311956);
- after the JH9384 fork was fast-forwarded to that exact commit, the fork's required release workflows all completed successfully:
  - `gates` run 37504432456 — SUCCESS;
  - `registry-os` run 37504432514 — SUCCESS;
  - `ci` run 37504432444 / 37504519906 — SUCCESS;
- `model-hub-clients` run 37504432424 — SUCCESS;
- `model-hub-openapi` run 37504432323 — SUCCESS.

This satisfies the repository's own `scripts/check-gates.sh` release-workflow naming contract on the forked exact SHA. It does not substitute for the target-Mac H1 run.

For Hologram core commit b6d9a76ca953610f9facfdefac0d0db0ece4d954, the latest upstream Release CI run observed on 2026-10-06 is overall FAILURE (run 37422042548). The failing job is `Bare-metal UEFI boot (QEMU/OVMF)`, step `Boot hologram.efi and assert PASS`. The same failure is present in the Oct 2–5 scheduled runs. In that latest run, the Holospaces V&V job and the `CS docs conformance (arc42 · C4 · OPM · ISO 15288 — V1–V8)` job both succeed.

Therefore Hologram Live is repository-gate green at the qualification SHA, while the broader current Hologram core substrate carries an open repeated bare-metal boot finding.

## 3. Known findings at campaign entry

### F-001 — Hologram AI dependency-lineage inconsistency

Hologram AI's current Cargo manifest resolves core Hologram crates from:
https://github.com/humuhumu33/hologram.git
at revision:
15d155b9b0ca7e6a68b35ab3a010424ffcf4505d

The manifest comments describe a Hologram Technologies substrate release, but the actual dependency source is a different repository lineage. The referenced revision was not found in the accessible Hologram-Technologies/hologram history during intake.

Classification: provenance/version-lineage inconsistency.  
Disposition: BLOCK ADOPTION; permit isolated reproduction only.

### F-002 — PrismPM performance claims require reproduction

Several reported performance values are generated from a formal/cost model or assigned comparison constants rather than end-to-end hardware measurement. Examples observed in source include a modeled 75% DRAM traffic reduction and assigned router latency comparison values.

Classification: evidence/claim-strength mismatch.  
Disposition: treat headline performance claims as UNPROVEN until reproduced with real models, real execution, and hardware/OS measurements.

### F-003 — Standalone Holospaces is transitional

Current Hologram has absorbed substantial Holospaces functionality while standalone Holospaces remains pinned to an older Hologram revision.

Classification: architecture evolution.  
Disposition: preserve as reference and compatibility evidence; do not make it the new Holo Lab foundation.

### F-004 — Distributed Hologram Storage is not a current qualified capability

Hologram Storage documents replication/distribution as planned and references a sibling hologram-network repository that was not accessible at intake.

Classification: future/unavailable capability.  
Disposition: qualify local storage only unless an actual network implementation is observed.

### F-005 — Hologram core current Release CI is repeatedly red on bare-metal UEFI boot

Hologram core commit b6d9a76ca953610f9facfdefac0d0db0ece4d954 has repeated scheduled Release CI failures from 2026-10-02 through 2026-10-06. The observed failing witness is `Bare-metal UEFI boot (QEMU/OVMF)` at `Boot hologram.efi and assert PASS`. The same runs continue to pass Holospaces V&V and arc42/C4/OPM/ISO 15288 documentation conformance.

Classification: executable substrate / platform witness failure.  
Disposition: OPEN. Preserve as an upstream/core qualification finding. Do not describe the complete Hologram core baseline as green until the bare-metal witness is explained or repaired and rerun.

### F-006 — Iroh design-status documents are stale relative to implementation

The Phase 2a and Phase 2b design documents still state `Designed, not implemented`, while current Cargo.toml, DEPENDENCIES.md, `src/cluster/iroh.rs`, `src/cluster/replication.rs`, and the enforced immutable-replication feature demonstrate that implementation work has landed. The default CI/release workflows inspected do not explicitly run a `--features p2p` test lane; the Kappa pin gate does inspect the `oci,p2p` dependency graph.

Classification: documentation/status drift + validation coverage gap.  
Disposition: OPEN for qualification. Holo Lab must explicitly build/test the p2p feature before promoting Iroh transport/blob replication to Observed Truth.

## 4. Qualification campaign

### Gate H0 — Host baseline

Record without changing the host:

- date/time
- macOS version and architecture
- Mac model
- CPU/GPU
- RAM
- free disk
- Rust and Cargo versions
- Node/npm versions if Desktop is tested
- Git version
- repository absolute path
- FileVault status
- whether the workspace is inside an automatic cloud-sync root

Pass condition: host identity and containment are known; no hidden cloud-sync ambiguity for evidence/work directories.

### Gate H1 — Source and build identity

On the target Mac:

1. clone or update JH9384/hologram-live
2. checkout cbbf97b5b8199f5701c621cd3ba0b26187417ffa
3. confirm clean worktree
4. install/use the repository's declared Rust toolchain context (CI currently uses Rust 1.97.1; Cargo.toml declares rust-version 1.95)
5. run the repository-owned full verification contract:
   just verify
6. confirm that verify includes formatting, file-size, product-boundary, Kappa pin, OCI streaming, locked checks/tests, OCI checks, Clippy, BDD, release build, and smoke test
7. record target/release/hologram SHA-256 and size

Pass condition: clean locked build and the repository-owned `just verify` contract succeed without local source modification.

Note: CI currently exercises the core Rust lane on Ubuntu 24.04. A successful target-Mac `just verify` run is therefore new observed platform evidence, not merely a repeat of CI.

### Gate H2 — Minimal local service

Use the default echo inference engine first; no external model and no hosted provider.

Run:
- hologram init
- hologram start (or foreground serve)
- hologram status --json
- hologram modules list --json

Verify:
- listener is loopback by default at 127.0.0.1:11435
- generated local state/config locations
- restart persistence
- clean stop/start
- no unexpected outbound dependency is required for the basic path

Pass condition: local host lifecycle works and state survives restart.

### Gate H3 — Content identity / file round trip

Create a small deterministic local fixture.

1. put file
2. record returned blake3 content ID
3. get file
4. hash original and recovered bytes
5. rename metadata
6. verify content ID and bytes are unchanged
7. restart service and repeat get

Pass condition: content identity is stable across metadata change and restart; recovered bytes equal original.

### Gate H4 — Minimal .holo execution

Build the smallest supported local application from repository-supported tooling.

Verify:
- archive validates
- archive identity is recorded
- execution succeeds with baseline capabilities
- execution is repeatable after restart
- output is deterministic where the fixture is deterministic

Pass condition: a local .holo application executes from a known archive with reproducible identity and output.

### Gate H5 — Capability denial

Use an application that attempts one capability it was not granted.

Pass condition: denied by default with typed/observable evidence; granting the minimum capability changes only the intended behavior.

### Gate H6 — Suspend/resume or equivalent continuity

Exercise the smallest repository-supported execution continuity path.

Pass condition: execution state can be preserved and resumed with identity/evidence sufficient to distinguish restart from replay.

If the current product surface does not expose the claimed path, classify that as a finding rather than inventing a substitute.

### Gate H7 — Local inference

Only after H0-H6.

Begin with echo as control, then one real local engine. On Apple hardware prefer an explicitly supported local path and record the feature set used. Do not compare PrismPM performance yet.

Pass condition: local model completion succeeds without hosted inference, and model/runtime identity is recorded.

### Gate H8 — Hologram Apps workload

Select one small, inspectable application from JH9384/hologram-apps.

Pass condition: application provenance, required capabilities, build path, execution, and evidence are understood. Do not begin with a complex OS/emulator workload.

### Gate H9 — Kappa object-fabric experiment

Enable the registry/Kappa path only after basic runtime qualification.

Verify:
- vendored SHA guard
- put/get identity
- restart persistence
- interrupted upload behavior if practical
- no silent mutation
- canonical Kappa base revision and carried patches remain reconstructable

Pass condition: object behavior matches documented invariants under local tests.

### Gate H10 — Prism and performance reproduction

Separate three evidence classes:

A. formal/cost-model result  
B. process/CLI benchmark  
C. end-to-end model inference measurement

Never report A as C.

For performance experiments record:
- model and exact artifact hash
- quantization
- context length
- prefix length
- backend/features
- host memory pressure
- wall-clock latency
- tokens/sec
- peak RSS / memory pressure
- hardware counters when available
- repeated trials and variance

Pass condition: any adopted performance claim is traceable to measured evidence at the same abstraction level.

## 5. Integration experiments after qualification

These are explicitly deferred until the relevant gates pass.

### SERP -> Hologram Storage projection

Do not migrate SERP. Project a fixed SERP canonical fixture into Hologram Storage and compare:
- identity
- provenance
- temporal reconstruction
- conflict representation
- round-trip loss

### UAR -> Hologram execution adapter

Treat Hologram as one execution target behind an adapter. UAR retains orchestration semantics.

### Holo Lab -> Kappa Registry

Evaluate whether Git/model/artifact/container projections can share one sovereign object fabric without weakening source-specific provenance.

## 6. Evidence record

For every material run record:

- run ID
- UTC/local timestamp
- host identity
- repository + commit
- dependency/runtime identity
- exact command
- expected behavior
- observed behavior
- stdout/stderr evidence location
- artifact hashes
- pass/fail
- finding ID if any
- smallest repair, if justified
- rerun result

Finding classes:
- bug
- model deficiency
- provenance inconsistency
- missing policy
- missing observability
- new requirement
- acceptable ambiguity
- scale/performance limit
- security/trust-boundary finding
- claim/evidence mismatch

## 7. Campaign exit

Holo Lab may call the Hologram baseline QUALIFIED only when:

1. locked build is reproducible on the target Mac;
2. local lifecycle works without hidden hosted dependency;
3. content-addressed file round trip is proven;
4. at least one .holo application executes reproducibly;
5. capability denial is observed;
6. continuity/suspend-resume claim is either proven or explicitly dispositioned;
7. one real local inference path is proven;
8. one Hologram Apps workload is qualified;
9. Kappa provenance and local object behavior are proven if Kappa is adopted;
10. performance claims are separated into modeled vs measured evidence;
11. all material surprises are classified and dispositioned;
12. SERP and UAR remain independently operable.

## 8. Immediate next action

Do not add architecture.

Run H0 on the target Mac, then H1. Preserve the first failure exactly if either gate fails.

Current qualification target:
JH9384/hologram-live @ cbbf97b5b8199f5701c621cd3ba0b26187417ffa
