#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

TARGET_USER="${TARGET_USER:?TARGET_USER requerido}"

require_root
require_user_exists "$TARGET_USER"

log "pipx ensurepath + instalar PDM (si pipx existe)"
if user_has_cmd "$TARGET_USER" "pipx"; then
	run_as_user "$TARGET_USER" "pipx ensurepath"
	run_as_user "$TARGET_USER" "pipx install --force pdm"
else
	warn_skip "pipx no está instalado para $TARGET_USER"
fi