#!/usr/bin/env bash
set -euo pipefail

# Holo Lab H0 host-baseline collector.
# Read-only: does not install, configure, start services, or modify host settings.
# Raw output may contain local filesystem paths. Keep it local.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
cd "$ROOT"

OUT_DIR="${HOLO_LAB_EVIDENCE_DIR:-.holo-lab/evidence}"
mkdir -p "$OUT_DIR"
STAMP="$(date -u '+%Y%m%dT%H%M%SZ')"
OUT="$OUT_DIR/H0_HOST_BASELINE_${STAMP}.txt"

have() { command -v "$1" >/dev/null 2>&1; }
version_or_absent() {
  local name="$1"; shift
  if have "$name"; then "$@" 2>&1 | head -n 3; else echo "ABSENT"; fi
}

workspace="$(pwd -P)"
cloud_status="NO_KNOWN_SYNC_ROOT_MATCH"
cloud_detail="workspace does not match common CloudStorage/iCloud Drive roots"
case "$workspace" in
  "$HOME/Library/Mobile Documents/com~apple~CloudDocs"|"$HOME/Library/Mobile Documents/com~apple~CloudDocs/"*)
    cloud_status="SYNC_ROOT_MATCH"; cloud_detail="workspace is inside iCloud Drive CloudDocs";;
  "$HOME/Library/CloudStorage/"*)
    cloud_status="SYNC_ROOT_MATCH"; cloud_detail="workspace is inside macOS CloudStorage provider root";;
  "$HOME/Desktop"|"$HOME/Desktop/"*|"$HOME/Documents"|"$HOME/Documents/"*)
    cloud_status="MANUAL_CONFIRMATION_REQUIRED"
    cloud_detail="workspace is under Desktop/Documents; confirm whether iCloud Desktop & Documents is enabled";;
esac

{
  echo "format: holo-lab-h0-host-baseline-v1"
  echo "gate: H0"
  echo "collected_utc: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "collected_local: $(date '+%Y-%m-%dT%H:%M:%S%z')"
  echo
  echo "[host]"
  echo "macos_product: $(sw_vers -productName 2>/dev/null || echo UNKNOWN)"
  echo "macos_version: $(sw_vers -productVersion 2>/dev/null || echo UNKNOWN)"
  echo "macos_build: $(sw_vers -buildVersion 2>/dev/null || echo UNKNOWN)"
  echo "architecture: $(uname -m)"
  echo "model_identifier: $(sysctl -n hw.model 2>/dev/null || echo UNKNOWN)"
  echo "cpu_brand: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo APPLE_SILICON_OR_UNKNOWN)"
  echo "logical_cpu: $(sysctl -n hw.logicalcpu 2>/dev/null || echo UNKNOWN)"
  echo "physical_cpu: $(sysctl -n hw.physicalcpu 2>/dev/null || echo UNKNOWN)"
  echo "memory_bytes: $(sysctl -n hw.memsize 2>/dev/null || echo UNKNOWN)"
  echo "hardware_summary:"
  system_profiler SPHardwareDataType -detailLevel mini 2>/dev/null |     awk -F': ' '/Model Name:|Model Identifier:|Chip:|Total Number of Cores:|Memory:/ {gsub(/^[[:space:]]+/,"",$1); print "  " $1 ": " $2}' || true
  echo "graphics_summary:"
  system_profiler SPDisplaysDataType -detailLevel mini 2>/dev/null |     awk -F': ' '/Chipset Model:|Metal Support:/ {gsub(/^[[:space:]]+/,"",$1); print "  " $1 ": " $2}' || true
  echo
  echo "[storage]"
  df -h "$workspace"
  echo
  echo "[toolchain]"
  echo "rustc:"
  version_or_absent rustc rustc --version --verbose
  echo "cargo:"
  version_or_absent cargo cargo --version
  echo "node:"
  version_or_absent node node --version
  echo "npm:"
  version_or_absent npm npm --version
  echo "git:"
  version_or_absent git git --version
  echo
  echo "[repository]"
  echo "absolute_path: $workspace"
  echo "remote_origin: $(git remote get-url origin 2>/dev/null || echo UNKNOWN)"
  echo "head: $(git rev-parse HEAD 2>/dev/null || echo UNKNOWN)"
  echo "branch: $(git branch --show-current 2>/dev/null || echo DETACHED_OR_UNKNOWN)"
  echo "worktree_porcelain_begin"
  git status --porcelain --untracked-files=all 2>/dev/null || true
  echo "worktree_porcelain_end"
  echo
  echo "[security_and_containment]"
  echo "filevault: $(fdesetup status 2>/dev/null || echo UNKNOWN_OR_UNAVAILABLE)"
  echo "cloud_sync_status: $cloud_status"
  echo "cloud_sync_detail: $cloud_detail"
  echo "cloudstorage_roots_present:"
  if [ -d "$HOME/Library/CloudStorage" ]; then
    find "$HOME/Library/CloudStorage" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sed "s|$HOME|~|" || true
  else
    echo "  none"
  fi
  echo
  echo "[privacy]"
  echo "serial_number_collected: false"
  echo "hardware_uuid_collected: false"
  echo "raw_evidence_policy: LOCAL_ONLY_DO_NOT_COMMIT"
} > "$OUT"

echo "H0 evidence: $OUT"
echo "SHA-256:"
shasum -a 256 "$OUT"
echo
echo "Cloud containment: $cloud_status"
if [ "$cloud_status" = "MANUAL_CONFIRMATION_REQUIRED" ] || [ "$cloud_status" = "SYNC_ROOT_MATCH" ]; then
  echo "H0 cannot be marked PASS until workspace containment is resolved."
fi
