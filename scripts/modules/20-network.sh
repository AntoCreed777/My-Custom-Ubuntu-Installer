#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

require_root

log "Asegurar NetworkManager y desactivar wait-online de systemd-networkd (si existe)"
systemctl enable NetworkManager.service 2>/dev/null

if service_exists "systemd-networkd-wait-online.service"; then
	systemctl disable systemd-networkd-wait-online.service 2>/dev/null
else
	warn_skip "systemd-networkd-wait-online.service no existe"
fi