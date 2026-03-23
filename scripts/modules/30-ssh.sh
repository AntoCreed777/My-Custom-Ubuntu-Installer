#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

TARGET_USER="${TARGET_USER:?TARGET_USER requerido}"

require_root
require_user_exists "$TARGET_USER"

SSHD="/etc/ssh/sshd_config"
[[ -f "$SSHD" ]] || die "No existe $SSHD"

log "SSH hardening básico"
replace_or_append_kv "PermitRootLogin" "no" "$SSHD"

# AllowUsers: agregar sin duplicar
if ! grep -Eq "^\s*AllowUsers\b" "$SSHD"; then
  echo "AllowUsers $TARGET_USER" >> "$SSHD"
else
  grep -Eq "^\s*AllowUsers\b.*\b${TARGET_USER}\b" "$SSHD" || \
    sed -i "s/^\s*AllowUsers\s\+/AllowUsers /; s/^\s*AllowUsers.*/& ${TARGET_USER}/" "$SSHD"
fi

systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true