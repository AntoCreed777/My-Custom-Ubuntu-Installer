#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

TARGET_USER="${TARGET_USER:?TARGET_USER requerido}"

require_root
require_user_exists "$TARGET_USER"

log "pipx ensurepath + instalar PDM (si pipx existe)"
run_as_user "$TARGET_USER" "command -v pipx >/dev/null 2>&1 && pipx ensurepath || true"
run_as_user "$TARGET_USER" "command -v pipx >/dev/null 2>&1 && pipx install pdm || true"