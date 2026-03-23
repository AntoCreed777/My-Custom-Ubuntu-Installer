#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

TARGET_USER="${TARGET_USER:?TARGET_USER requerido}"
NERD_FONTS_VERSION="${NERD_FONTS_VERSION:-v3.0.2}"
FONT_NAME="${FONT_NAME:-FiraCode}"

require_root
require_user_exists "$TARGET_USER"
HOME_DIR="$(home_of "$TARGET_USER")"

export DEBIAN_FRONTEND=noninteractive

log "Instalar Nerd Font: ${FONT_NAME} (${NERD_FONTS_VERSION})"
apt-get update -y
apt-get install -y unzip wget fontconfig

mkdir -p "$HOME_DIR/.local/share/fonts"

ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${FONT_NAME}.zip"
TMP_ZIP="/tmp/${FONT_NAME}.zip"

log "Descargando: $ZIP_URL"
wget -qO "$TMP_ZIP" "$ZIP_URL"

log "Descomprimiendo en: $HOME_DIR/.local/share/fonts"
unzip -o "$TMP_ZIP" -d "$HOME_DIR/.local/share/fonts" >/dev/null

chown -R "$TARGET_USER:$TARGET_USER" "$HOME_DIR/.local/share/fonts"

run_as_user "$TARGET_USER" "fc-cache -fv"

rm -f "$TMP_ZIP"