#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

require_root

log "Asegurar NetworkManager y desactivar wait-online de systemd-networkd (si existe)"
systemctl enable NetworkManager.service 2>/dev/null || true
systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true