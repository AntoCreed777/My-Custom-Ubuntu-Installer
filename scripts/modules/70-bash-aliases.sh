#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

TARGET_USER="${TARGET_USER:?TARGET_USER requerido}"

require_root
require_user_exists "$TARGET_USER"
HOME_DIR="$(home_of "$TARGET_USER")"
ALIASES_FILE="$HOME_DIR/.bash_aliases"

log "Configurar aliases en $ALIASES_FILE"

append_once "# Visualizacion" "$ALIASES_FILE"
append_once "alias bat='batcat'" "$ALIASES_FILE"
append_once "alias cls='clear'" "$ALIASES_FILE"
append_once "" "$ALIASES_FILE"

append_once "# Navegacion" "$ALIASES_FILE"
append_once "alias ..='cd ..'" "$ALIASES_FILE"
append_once "alias ...='cd ../..'" "$ALIASES_FILE"
append_once "alias irgit='cd $HOME_DIR/Documentos/GitHub'" "$ALIASES_FILE"
append_once "" "$ALIASES_FILE"

append_once "# ls" "$ALIASES_FILE"
append_once "alias ls='lsd --group-dirs first -1'" "$ALIASES_FILE"
append_once "alias ll='ls -AlF'" "$ALIASES_FILE"
append_once "alias tree='lsd --tree --group-dirs first --depth=2 2>/dev/null'" "$ALIASES_FILE"
append_once "" "$ALIASES_FILE"

append_once "# Actualizacion" "$ALIASES_FILE"
append_once "alias actualizar='sudo apt update && sudo apt upgrade -y'" "$ALIASES_FILE"
append_once "" "$ALIASES_FILE"

append_once "# Python" "$ALIASES_FILE"
append_once "alias activate='source ./.venv/bin/activate'" "$ALIASES_FILE"
append_once "" "$ALIASES_FILE"

append_once "# Git" "$ALIASES_FILE"
append_once "alias gs='git status'" "$ALIASES_FILE"
append_once "alias gaa='git add .'" "$ALIASES_FILE"
append_once "alias gcm='git commit -m'" "$ALIASES_FILE"

chown "$TARGET_USER:$TARGET_USER" "$ALIASES_FILE"