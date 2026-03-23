#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

TARGET_USER="${TARGET_USER:?TARGET_USER requerido}"

require_root
require_user_exists "$TARGET_USER"
HOME_DIR="$(home_of "$TARGET_USER")"

log "Crear carpeta GitHub"
mkdir -p "$HOME_DIR/Documentos/GitHub"
chown -R "$TARGET_USER:$TARGET_USER" "$HOME_DIR/Documentos/GitHub"