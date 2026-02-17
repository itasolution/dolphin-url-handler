#!/usr/bin/env bash
set -euo pipefail

# Config
DEBUG="${DEBUG:-false}"
LOGFILE="${LOGFILE:-$HOME/.cache/dolphin-handler.log}"
DOLPHIN_BIN="${DOLPHIN_BIN:-}"      # override opzionale

log() {
  [[ "$DEBUG" == "true" ]] || return 0
  mkdir -p "$(dirname "$LOGFILE")"
  printf '%s %s\n' "$(date -Is)" "$*" >> "$LOGFILE"
}

fail() { log "FAIL: $*"; exit 1; }

url="${1:-}"
log "RAW(arg): [$url]"

# Sanitizzazione input (alcuni layer aggiungono CR/LF/TAB)
url="${url//$'\r'/}"
url="${url//$'\n'/}"
url="${url//$'\t'/}"
log "SANITIZED: [$url]"

# Accetta solo schema dolphin:///
[[ "$url" =~ ^dolphin:/// ]] || fail "schema-not-dolphin ($url)"

# Rimuovi fragment/query
url="${url%%\#*}"
url="${url%%\?*}"

# Estrai path
path="${url#dolphin://}"   # -> /home/...

# Decodifica minima (estendibile)
path="${path//%20/ }"
path="${path//%23/#}"
path="${path//%25/%}"
log "PATH(decoded): [$path]"

# Safety minima
[[ "$path" == /* ]] || fail "not-absolute ($path)"
[[ "$path" != *"/../"* && "$path" != *"/./"* ]] || fail "traversal ($path)"

# Trova dolphin anche con PATH minimale
if [[ -z "$DOLPHIN_BIN" ]]; then
  if command -v dolphin >/dev/null 2>&1; then
    DOLPHIN_BIN="$(command -v dolphin)"
  elif [[ -x /usr/bin/dolphin ]]; then
    DOLPHIN_BIN="/usr/bin/dolphin"
  else
    fail "dolphin-not-found (PATH=$PATH)"
  fi
fi

log "EXEC: $DOLPHIN_BIN --new-window [$path]"
exec "$DOLPHIN_BIN" --new-window "$path"