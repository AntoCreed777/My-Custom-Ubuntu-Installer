#!/usr/bin/env bash
set -euo pipefail

log() { printf "[postinstall] %s\n" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Ejecuta como root (usa sudo)."
  fi
}

require_user_exists() {
  local user="$1"
  id "$user" >/dev/null 2>&1 || die "No existe el usuario '$user'."
}

home_of() {
  local user="$1"
  getent passwd "$user" | cut -d: -f6
}

run_as_user() {
  local user="$1"; shift
  runuser -l "$user" -c "$*"
}

append_once() {
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -Fxq -- "$line" "$file" || echo "$line" >> "$file"
}

replace_or_append_kv() {
  # reemplaza "Key ..." si existe, si no, agrega al final
  local key="$1"
  local value="$2"
  local file="$3"
  if grep -Eq "^\s*${key}\b" "$file"; then
    sed -i "s|^\s*${key}\b.*|${key} ${value}|" "$file"
  else
    echo "${key} ${value}" >> "$file"
  fi
}
