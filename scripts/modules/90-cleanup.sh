#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

require_root
log "Limpieza apt"
apt-get autoremove -y
apt-get clean