#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_SRC="$REPO_DIR/open-in-dolphin.sh"

BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
SCRIPT_DST="$BIN_DIR/open-in-dolphin.sh"
DESKTOP_DST="$APP_DIR/dolphin-handler.desktop"

mkdir -p "$BIN_DIR" "$APP_DIR"

install -m 0755 "$SCRIPT_SRC" "$SCRIPT_DST"

# Genera .desktop con path assoluto allo script
sed "s|@SCRIPT_ABS_PATH@|$SCRIPT_DST|g" \
  "$REPO_DIR/dolphin-handler.desktop.in" > "$DESKTOP_DST"

# Aggiorna database desktop (se disponibile)
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

# Registra l'handler
xdg-mime default "$(basename "$DESKTOP_DST")" x-scheme-handler/dolphin

echo "Installazione completata."
echo "Test: xdg-open \"dolphin:///home/$USER/\""