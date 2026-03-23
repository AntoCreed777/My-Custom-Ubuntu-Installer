#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

TARGET_USER="${TARGET_USER:-antocreed777}"
export TARGET_USER

# switches (por defecto todo ON)
DO_SYSTEMD=1
DO_NETWORK=1
DO_SSH=1
DO_FASTFETCH=1
DO_PYTHON=1
DO_FOLDERS=1
DO_ALIASES=1
DO_FONTS=1
DO_CLEANUP=1

usage() {
  cat <<EOF
Uso:
  sudo scripts/main.sh [--user <u>] [--only <mod1,mod2,...>] [--skip <mod1,mod2,...>]

Mods disponibles:
  systemd, network, ssh, fastfetch, python, folders, aliases, fonts, cleanup

Ejemplos:
  sudo scripts/main.sh --user antocreed777
  sudo scripts/main.sh --only ssh,aliases
  sudo scripts/main.sh --skip fonts,fastfetch
EOF
}

set_mod() {
  local mod="$1" val="$2"
  case "$mod" in
    systemd) DO_SYSTEMD="$val" ;;
    network) DO_NETWORK="$val" ;;
    ssh) DO_SSH="$val" ;;
    fastfetch) DO_FASTFETCH="$val" ;;
    python) DO_PYTHON="$val" ;;
    folders) DO_FOLDERS="$val" ;;
    aliases) DO_ALIASES="$val" ;;
    fonts) DO_FONTS="$val" ;;
    cleanup) DO_CLEANUP="$val" ;;
    *) die "Módulo desconocido: $mod" ;;
  esac
}

parse_list() {
  # "a,b,c" -> "a b c"
  echo "$1" | tr ',' ' '
}

require_arg_value() {
  local flag="$1"
  [[ $# -ge 2 ]] || die "Falta valor para $flag"
}

ONLY_LIST=""
SKIP_LIST=""
FAILED_MODULES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)
      require_arg_value "$@"
      TARGET_USER="$2"
      export TARGET_USER
      shift 2
      ;;
    --only)
      require_arg_value "$@"
      ONLY_LIST="$2"
      shift 2
      ;;
    --skip)
      require_arg_value "$@"
      SKIP_LIST="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0;;
    *) die "Flag desconocida: $1";;
  esac
done

require_root
require_user_exists "$TARGET_USER"

if [[ -n "$ONLY_LIST" ]]; then
  # apagar todo y prender sólo lo pedido
  for m in systemd network ssh fastfetch python folders aliases fonts cleanup; do
    set_mod "$m" 0
  done
  for m in $(parse_list "$ONLY_LIST"); do
    set_mod "$m" 1
  done
fi

if [[ -n "$SKIP_LIST" ]]; then
  for m in $(parse_list "$SKIP_LIST"); do
    set_mod "$m" 0
  done
fi

run_module() {
  local name="$1"
  local path="$2"
  log "==> Ejecutando ${name} ($(basename "$path"))"

  if bash "$path"; then
    log "OK: ${name}"
  else
    log "WARN: Falló ${name}, continuando con el resto"
    FAILED_MODULES+=("$name")
  fi
}

[[ "$DO_SYSTEMD" == "1" ]] && run_module "systemd" "$SCRIPT_DIR/modules/10-systemd.sh"
[[ "$DO_NETWORK" == "1" ]] && run_module "network" "$SCRIPT_DIR/modules/20-network.sh"
[[ "$DO_SSH" == "1" ]] && run_module "ssh" "$SCRIPT_DIR/modules/30-ssh.sh"
[[ "$DO_FASTFETCH" == "1" ]] && run_module "fastfetch" "$SCRIPT_DIR/modules/40-packages-fastfetch.sh"
[[ "$DO_PYTHON" == "1" ]] && run_module "python" "$SCRIPT_DIR/modules/50-python-pipx-pdm.sh"
[[ "$DO_FOLDERS" == "1" ]] && run_module "folders" "$SCRIPT_DIR/modules/60-folders.sh"
[[ "$DO_ALIASES" == "1" ]] && run_module "aliases" "$SCRIPT_DIR/modules/70-bash-aliases.sh"
[[ "$DO_FONTS" == "1" ]] && run_module "fonts" "$SCRIPT_DIR/modules/80-fonts-nerd.sh"
[[ "$DO_CLEANUP" == "1" ]] && run_module "cleanup" "$SCRIPT_DIR/modules/90-cleanup.sh"

if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
  log "Instalación completada con advertencias. Módulos fallidos: ${FAILED_MODULES[*]}"
else
  log "Todo listo."
fi