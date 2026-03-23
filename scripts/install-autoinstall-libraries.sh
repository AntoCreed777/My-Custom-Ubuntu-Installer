#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

require_root
export DEBIAN_FRONTEND=noninteractive

PACKAGES=(
  ubuntu-desktop-minimal
  ca-certificates
  gnupg
  curl
  wget
  unzip
  git
  unattended-upgrades
  build-essential
  clang
  gdb
  valgrind
  python3
  python3-pip
  python3-venv
  python3-dev
  pipx
  vim
  lsd
  btop
  htop
  ncdu
  ripgrep
  bat
)

log "Instalando paquetes definidos en autoinstall.yaml"
apt-get update -y
apt-get install -y "${PACKAGES[@]}"

# Replica la instalacion de snaps del autoinstall cuando snapd este disponible.
if command -v snap >/dev/null 2>&1; then
  if snap list code >/dev/null 2>&1; then
    warn "snap code ya esta instalado"
  else
    log "Instalando snap code (stable, classic)"
    snap install code --classic --channel=stable
  fi
else
  warn_skip "snap no esta disponible para instalar code"
fi

log "Instalacion de librerias del autoinstall completada"
