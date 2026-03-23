#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(dirname "$0")")/lib/common.sh"

require_root
export DEBIAN_FRONTEND=noninteractive

log "Instalar FastFetch via PPA"
apt-get update -y
apt-get install -y software-properties-common
add-apt-repository -y ppa:zhangsongcui3371/fastfetch
apt-get update -y
apt-get install -y fastfetch