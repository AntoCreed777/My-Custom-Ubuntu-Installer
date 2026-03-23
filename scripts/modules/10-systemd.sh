#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

require_root

log "Set default target a graphical.target"
# En algunos entornos puede fallar (sin systemd activo en chroot); no queremos romper toda la instalación
systemctl set-default graphical.target 2>/dev/null || true