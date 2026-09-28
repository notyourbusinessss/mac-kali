#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

require_apt

if ! command -v xfce4-session >/dev/null 2>&1 && [[ "${XDG_CURRENT_DESKTOP:-}" != *XFCE* ]]; then
  log_warn "XFCE doesn't look installed or running. mac-kali is built specifically for Kali's XFCE desktop."
  confirm "Continue anyway?" || die "Aborted."
fi

command -v xfconf-query >/dev/null 2>&1 || die "xfconf-query not found — install xfce4-utils and run this from inside an XFCE session."

mkdir -p "$MAC_KALI_STATE_DIR"
log_ok "Preflight checks passed."
